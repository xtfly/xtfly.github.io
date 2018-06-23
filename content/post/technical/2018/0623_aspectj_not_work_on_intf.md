---
title: "自定义扩展Spring Cache注解"
date: "2018-06-23"
categories:
 - "技术"
tags:
 - "Java"
toc: true

---

昨天在公司发现采用@Aspect定义一个切面，对MyBatis的Mapper接口方法上标注自定义的注解，无法切入拦截。

## 背景

Spring Cache提供了声明式的@Cacheable等注解，很方便地对Mapper接口方法来实现缓存。他们好用但简单，缓存的Key大多选择主键。但实际项目上有不少关系对象表（如下面的代码所示）；不能采用主键作为Key，因为大多数的查询场景是根据其关联的另一个字段查询。若以此字段作为Key，当存在批量插入，更新或删除时，都会影响缓存的数据。而Spring Cache的注解无法对参数为数组或List的生成Key。

于是想到自定义Cache注解来解决批量插入，更新或删除来刷新相应的缓存。对注解的拦截@Aspect声明的切面是最为简单的方式。核心实现代码如下：

<!--more-->
```
@Data
public class RoleAuthPO {
    String relId;  // primary key
    String roleId; // cache key
    String authId; // roleId<->authId: n<->m
}

@Mapper
@CacheConfig(cacheNames = "role-auth)
public interface RoleAuthMapper {
 
  @UpdateProvider(type=RoleAuthSQLProvider.class, method="batchUpdate")
  @BatchCache(keyPrefix="role-auth:role-id:", keyFiled="roleId")
  void batchUpdate(List<RoleAuthPO> pos);

  @Select("SELECT * FROM T_ROLE_AUTH WHERE ROLE_ID=#{roleId}")
  @Cacheable(key="`role-auth:role-id:`+p0")
  List<RoleAuthPO> queryByRoleId(@Param("roleId") String roleId);
}
 
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface BatchCache {
  String keyPrefix() default "";
  String keyFiled() default "";
}

@Aspect
@Component
public class BatchCacheAspect {
 
  @AfterReturing("@annotation(BatchCache)")
  public void doBatchCache(JoinPoint point) {
    System.out.println("before batchCache");
  }
}
```

笔者的项目是使用Spring Boot 1.5.12，Debug跟踪都无法进入doBatchCache方法。而项目也有采用@Aspect来实现其它的注解，这些注解能正常切入，他们的区别是这些注解是标注在具体类的方法上，而不是接口方法。

## 问题浮现

那为什么Spring Cache的注解可以切入？通过查看Cache的注解实现，它并没有采用@Aspect声明的切面，而是采用CacheOperationSourcePointcut。

后又做了一个验证，把Spring Boot切换到2.X，奇迹发生了，居然是可以切入。那有一种可能就是这个问题就出在Spring Boot 1.5.X的@Aspect不支持对标识在接口方法的拦截。

网上已有牛人对这个问题做了深入的分析，参见 [接口方法上的注解无法被 @Aspect 声明的切面拦截的原因分析](http://www.importnew.com/28788.html) ，从他的分析来看，Mybatis的Mapper接口是通过JDK动态代理生成的逻辑，此问题在Spring Boot 1.5.X下是无解的，@Aspect不支持切入不受Spring Bean管理的对象。而我的项目中存在大量的Mapper，也不可能给每个Mapper定义一个FactoryBean来达到让Spring来管理。


## 另一解决思路

既然Spring Cache的注解在接口方法上有效，那我们再来看看它的机制。当我们在Configuration类打上@EnableCaching注释时，除了启动Spring AOP机制,引入的另一个类ProxyCachingConfiguration就是SpringCache具体实现相关bean的配置类：

```
@Configuration  
public class ProxyCachingConfiguration extends AbstractCachingConfiguration {  

    @Bean(name = CacheManagementConfigUtils.CACHE_ADVISOR_BEAN_NAME)  
    @Role(BeanDefinition.ROLE_INFRASTRUCTURE)  
    public BeanFactoryCacheOperationSourceAdvisor cacheAdvisor() {  
        BeanFactoryCacheOperationSourceAdvisor advisor =  
                new BeanFactoryCacheOperationSourceAdvisor();  
        advisor.setCacheOperationSource(cacheOperationSource());  
        advisor.setAdvice(cacheInterceptor());  
        advisor.setOrder(this.enableCaching.<Integer>getNumber("order"));  
        return advisor;  
    }  
  
  
    @Bean  
    @Role(BeanDefinition.ROLE_INFRASTRUCTURE)  
    public CacheOperationSource cacheOperationSource() {  
        return new AnnotationCacheOperationSource();  
    }  
  
  
    @Bean  
    @Role(BeanDefinition.ROLE_INFRASTRUCTURE)  
    public CacheInterceptor cacheInterceptor() {  
        CacheInterceptor interceptor = new CacheInterceptor();  
        interceptor.setCacheOperationSources(cacheOperationSource());  
        .....
        return interceptor;  
    }  
}  

```

 - AnnotationCacheOperationSource的主要作用是获取定义在类和方法上的SpringCache相关的标注并将其转换为对应的CacheOperation属性。
 - BeanFactoryCacheOperationSourceAdvisor是一个PointcutAdvisor，是SpringCache使用Spring AOP机制的关键所在，该advisor会织入到需要执行缓存操作的bean的增强代理中形成一个切面。并在方法调用时在该切面上执行拦截器CacheInterceptor的业务逻辑。
 - CacheInterceptor是一个拦截器，当方法调用时碰到了BeanFactoryCacheOperationSourceAdvisor定义的切面，就会执行CacheInterceptor的业务逻辑，该业务逻辑就是缓存的核心业务逻辑。

从Spring的AOP机制已知，要对一个方法或类切入需要实现如下：

 - 一个Advisor，它可以扩展Spring中AbstractBeanFactoryPointcutAdvisor
 - 一个Pointcut，它可以扩展Spring中StaticMethodMatcherPointcut
 - 一个MethodInterceptor，在此接口中实现拦截逻辑

参考Spring Cache的ProxyCachingConfiguration，实现对@BatchCache拦截核心实现如下：

```
@Configuration
public class ProxyBatchCacheConfiguration {

    @Bean
    @Role(BeanDefinition.ROLE_INFRASTRUCTURE)
    public BatchCacheBeanFactorySourceAdvisor batchCacheAdvisor(@Autowired  CacheManager cacheManager) {
        BatchCacheBeanFactorySourceAdvisor advisor = new BatchCacheBeanFactorySourceAdvisor();
        advisor.setAdvice(new BatchCacheInterceptor(cacheManager));
        return advisor;
    }
}

// 对存在标识有@BatchCache方法进行切入
public class BatchCacheSourcePointcut extends StaticMethodMatcherPointcut implements Serializable {
    @Override
    public boolean matches(Method method, Class<?> aClass) {
        BatchCache batchCache =  method.getAnnotation(BatchCache.class);
        return batchCache != null;
    }
}

// 定义一个Advisor，指定Pointcut
public class BatchCacheBeanFactorySourceAdvisor extends AbstractBeanFactoryPointcutAdvisor {
    @Override
    public Pointcut getPointcut() {
        return new BatchCacheSourcePointcut();
    }
}

// 当Pointcut.matches时，Spring框架会调用invoke，即可实现BatchCache所要逻辑了
public class BatchCacheInterceptor implements MethodInterceptor, Serializable {

    // 注入CacheManager，可以根据cacheNames来操作Cache
    final CacheManager cacheManager;

    public BatchCacheInterceptor(CacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    @Override
    public Object invoke(MethodInvocation methodInvocation) throws Throwable {
        Method method = methodInvocation.getMethod();
        BatchCache batchCache = method.getAnnotation(BatchCache.class);
        // .... 省略BatchCache的逻辑
        return methodInvocation.proceed();
    }
}
```

![Snip20180623_3.png](/images/2018/Snip20180623_3.png)

从Debug的调用栈来看，在Spring框架中，当调用Bean是接口动态代理对象方法时，会生成JdkDynamicAopProxy，此对象会设置所有advisors。只要我们写的advisor以Bean方式注入到Spring框架，它会就生效，流程总结如下：

`声明advisor->Pointcut.matches->MethodInterceptor.invoke`

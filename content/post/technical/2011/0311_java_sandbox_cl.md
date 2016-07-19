---
title: "[WebApp沙箱]JRE类白名单运用"
date: "2011-03-11"
categories:
 - "技术"
tags:
 - "Java"

---

#### ClassLoader

JVM类加载器层次结构：

       Bootstrap ClassLoader
                |
       Extension ClassLoader
                |
       System ClassLoader

JVM一启动，会先做一些初始化的动作。一旦初始化动作完成之后，就会产生第一个类加载器，即所谓的Bootstrap Loader, Bootstrap Loader是由C++写成，这个BootstrapLoader所做的初始化中，除了做一些基本的初始化动作之外，最重要的就是加载定义在sun.misc命名空间下的Launcher.java之中的ExtClassLoader(因为是innerclass，所以编译之后会变成Launcher$ExtCjassLoader.class)，并设定其Parent为null,代表其父加载器为BootstrapLoader。然后再加载定义于sun.misc命名空间下的Launcher.java之中的AppClassLoader(因为是InnerClass，所以编译之后会变成Launcher$AppClassLoader.class)，并设定其Parent为之前产生的ExtClassLoader实例。AppClassLoader这一层我们也称之为SystemLoader。AppClassLoader会加载CLASSPATH目录下定义的Class。

每一个自定义ClassLoader都必须继承ClassLoader这个抽象娄，而每个ClassLoader都会有一个Parent的ClassLoader，我们可以看一下ClassLoader这个抽象类中有一个getParent()方法，这个方法用来返回当前ClassLoader的Parent。这个Parent不是指的被继承的类，而是在实例化该ClassLoader时指定的上层ClassLoader。

ClassLoader有两种载入类方式：

 * pre-loading：预先载入，载入基础类。
 * load-on-demand：按需求载入，动态载入。

当JVM载入Java类的时候，需要经过三个步骤，装载、连接、初始化。装载就是找到相应的Class文件，读入JVM。连接分三步：

  1. 验证Java类是否符合规格
  2. 准备，就是为类变量分配内存同时设置默认初始值
  3. 解释，而这步就是可选的，解释就是根据类中的符号引用查找相应的实体，再把符号引用替换成一个直接引用的过程。

每个ClassLoader加载Java类的过程如下：

  1. 检测此Java类是否载入过（即在Cache中是否有此Java类，包括所有Parent的ClassLoader已载入的Java类），如果有到第8步，如果没有到第2步
  2. 如果Parent ClassLoader不存在(没有Parent，那Parent一定是Bootstrap Loader)，到第4步
  3. 请求Parent ClassLoader载入，如果成功到第8步，不成功到第5步
  4. 请求JVM从Bootstrap Loacler中载入，如果成功到第8步
  5. 寻找Class文件（从与此classloader相关的类路径中寻找）,如果找不到则到第7步
  6. 从文件中载入Class，到第8步
  7. 否则找不到，抛出 ClassNotFoundException
  8. 返回Class类

这个过程就是双亲委托模式，一是可以避免重复加载，当父亲已经加载了该类的时候，就没有必要子ClassLoader再加载一次；二是出于考虑到安全因素，避免覆盖基础类。例如无法随时使用自定义的String动态替代java核心api中定义String类型。其中第5、6步我们可以通过覆盏ClassLoader的findClass方法来实现自己的载入策略。

#### Thread Context ClassLoader

Java 2中引入了线程上下文(Thread Context)类ClassLoader的概念，每一个线程有一个ContextClassLoader。这个Context ClassLoader是通过方法Thread.setContextClassLoader()设置的，如果当前线程在创建后没有调用这个方法设置Context ClassLoader，则当前线程从他的父线程继承Context ClassLoader。此Context ClassLoader默认的是System ClassLoader。

利用这个特性，我们可以“打破”ClassLoader委托机制，父ClassLoader可以获得当前线程的Context ClassLoader，而这个Context ClassLoader可以是它的子ClassLoader或者其他其他的ClassLoader，那么父ClassLoader就可以从其获得所需的Class，这就打破了只能向父ClassLoader请求的限制。

这个机制可以满足当我们的classpath是在运行时才确定，并由定制的ClassLoader加载的时候，由System Loader(即在JVM classpath中)加载的Class可以通过Context ClassLoader获得定制的ClassLoader并加载入特定的ClassLoader（通常是抽象类和接口，定制的ClassLoader中实现），例如web应用中的Servlet就是用这种机制加载的。

#### Class Instance

一个java类只有要实例化时，才会被ClassLoader动态载入，未使用并不会载入。而动态载类又分为两种方式：

  * Implicit隐式，即利用实例化才载入的特性来动态载入类，如new-个类的对象。
  * Explicit显式方式，又分为两种使用java.lang.Class的forName()方法与使用java.lang.ClassLoader的loadClass()方法。

当java类加载时，有一个`Class`类（JRE中基础类）与每个其它的Java类相关，每个被ClassLoader加载的class文件，最终都会以Class类的实例被程序引用，我们可以把`Class`类当作是普通类的一个模板。JVM根据这个模板生成对应的实例，最终被程序所使用。某个类的所有实例内部都有一个栏位记录着该类对应的`Class`的实例位置。java类对应的`Class`实例可以当作是类在内存中的代理者，所以当要获得类的信息（如有哪些类变量，有哪些方法）时，都可以让类对应的`Class`实例代劳。java的Reflection机制就大量的使用这种方法来实现。每个java类都是由某个ClassLoader(ClassLoader的实例)来载入的，因此`Class`类别的实例中都会有栏位记录他的ClassLoader的实例。

#### WebApp Class WhiteList

对于WebApp，不管是Web容器采用Jetty还是Tomcat。他们都针对每个WebApp Context自定义ClassLoader。为了能达到白名单检查的功能，我们可能在这个自定义ClassLoader的实现对类进行检查(如不在白名单内的类load时报ClassNotFoundException)。

  * 一种方案是重载ClassLoader.loadClass方法，不允许load此类，也不会在Cache中存在。但这种方案会带来很大的性能问题。每次运行时实例化一个Java类，在Cache中肯定不会存在此java类的Class类。那又会去调用loadClass尝试加载此java类，那又会再一次去检查一下白名单列表，而且白名单列表会很多，遍历会损耗性能。另外，WebApp自己创建的ClassLoader，没有办法重载loadClass方法。

  * 另一个方案是在WebApp Context的ClassLoader.defineClass方法中修改从Class文件中读取的WebApp中每个类的字节码。使用ASM工具来解释与修改字节码，如果发现此Class的方法中在调用有不在白名单内中的类，则插入抛出NoClassDefFoundError代码。这种方案可以只在第一次加载WebApp类时，判断了它依赖的类是否有不在白名单内中。这种相对前一种方案可以提高性能。同样，WebApp自己创建的ClassLoader，没有办法重载defineClass方法。

  对于ClassLoader.defineClass方法的实现：

  * 一种方案重载Web容器的WebApp Context自定义ClassLoader.defineClass方法，这要求Web容器支持插件方式替换已有WebApp Context ClassLoader。

  * 另一种方案是采用JVM的Instrumentation功能。在JVM级别，以插件的方法动态AOP切入JVM或JRE类中已有的实现。正好Instrumentation提供一种机制切入到每个ClassLoader.defineClass方法之前。应用只需要实现接口java.lang.instrument.ClassFileTransformer。在transform方法实现对类字符码的转换。此方法的原型为
    ```
      byte[] transform(ClassLoader loader,  String className,  Class<?> classBeingRedefined, ProtectionDomain protectionDomain,  byte[] classfileBuffer) throws IllegaIClassFormatException
      ```

      转换器ClassFileTransformer利用Instrumentation.addTransformer注册之后，在定义每个新类和重定义每个类时都将调用该转换器。对新的类定义的请求通过ClassLoader.defineClass进行。对类重定义的请求通过Instrumentation.redefineClasses方法进行。转换器是在验证或应用class文件字节之前的处理请求过程中进行调用的。

      如果实现的方法确定不需要进行字节码转换，则将返回null。否则它将刨建一个新的byte[]数组。将输入classfileBuffer连同所有需要的转换复制到其中，并返回新数组。

采用第二种方案是不个不错的选择，即使用Instrurnentation功能。在transform方法扫描类的字节码，检查类的方法中是否有非白名单中的类。如果有，则插入抛出NoClassDefFounclError代码。

#### 实现简介

1. 定义-个类实现premain接口，做为Instrumentationa机制的入口。并在MANIFEST.MF文件中指定Premain-Class为此类．premain接口如下，顾名思义，它是在main方法之前调用：

    `public static void premain(String agentArgs, Instrumentation inst);`

2. 实现ClaSsFileTransformer接口。并在premain方法中调用Instrumentation.addTransfanner注册此接口。

3. 当每个ClassLoader加载字节码时，会回调ClaaaFileTransfonner.transform方法，它实现主要逻辑：

  - 判断是加载类的ClassLoader是否Web容器中WebAppCantext ClasaLoader。对于WebAppContext ClassLoader可以通过类名在判断。对于webApp创建的新ClassLoader。需扫描字节码，获取类的类型继承列表是否属于ClassLoader，并记录下来。

  * 如果加载类的ClasaLoade不是应用的ClasSLoader，直接口返回null

  * 如果是，使用ASM工具对字节码进行分析与重写:

     1. 第一遍扫描类的所有方法字节码，如果Visit到类的类型在不在白名单列表中，则在原有方法中直接插入抛NoClassDefFoundErro代码。满足如下条件：

          * 调用黑名单列表类的方法
          * 调用黑名单列表类的属性

            新的代码类似如下：
            ```
            //插入抛NoClassDefFoundError代码，调用一个类的静态方法
            //原代码
            ```

      2. WebApp可能创建的自己实现的ClassLoader。第二遍扫描类的所有方法字节码，判断Visit到类的类型是否URLclassLoader，SecureClassLoader，ClassLoader其中的一个，或者是否继承自他们。则插入记录这些ClassLoader名的代码。自己实现的ClassLoader满足如下条件：

          - 任何一个新创建的ClassLoader，肯定会在它的调用父类的构造方法，那在此方法中它的字节码肯定会调用URLClassLoader，SecureCldaaLoader，ClassLonder其中一个构造方法；

          - 另外还可能使用URLClassLoader.newinstance(…）来创建新的classloader；


            上述两种方法新创建的ClassLoader，它的双亲ClassLoader可能不是WebAppContext的Classloader(构造方法或newinatance没有指定参数parent，那parent默认为System ClaaSLoader)，修改字节码时需要修改为调用有参数parent的方法，并且把parent指向WebApp Context的ClasSloader。


      3. WebApp也可能使用反射机制来访问类。第三遍扫描类的所有方法字节码，判断所Visit到类的类型与Viait到方法，满足如下条件：

          - 类型为java/lang/reflect/Method，调用方法为invoke
          - 类型为java/lang/reflect/Field，调用方法为getXXXX/setXXXX等方法
          - 类型为java/lang/reflect/Constructor，调用方法为newinstance;
          - 类型为java/lang/Class，调用方法为newlnstance.


            当满足上面条件时，修改原有这些方法调用，则在原有方法中插入检查反射的target对象的类型是否不在白名单列表中。新的代码类似如下
            ```
            void setBoolean (Field f, Object a, final boolean value) {
            ／／插入检查obj是否有访问权限（配合Securtiy访问控制）
            ／／插入检查obj是否在黑名单列表中
            ／／再加上原有的f.setBoolean(obj，value)；
            }
            ```

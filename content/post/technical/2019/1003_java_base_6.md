---
title: "Java基础知识点6"
date: "2019-10-03"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# 泛型

泛型是Java 5的一项新特性，它的本质是参数化类型（Parameterized Type）的应用，也就是说所操作的数据类型被指定为一个参数，在用到的时候在指定具体的类型。这种参数类型可以用在类、接口和方法的创建中，分别称为泛型类、泛型接口和泛型方法。

泛型使类型（类和接口）在定义类、接口和方法时成为参数，好处在于：
 
 - 强化类型安全，由于泛型在编译期进行类型检查，从而保证类型安全，减少运行期的类型转换异常
 - 提高代码复用，泛型能减少重复逻辑，编写更简洁的代码
 - 类型依赖关系更加明确，接口定义更加优好，增强了代码和文档的易读性

## 实现

Java 5推出了泛型，也就是在原本的基础上加上了编译时类型检查的语法糖。泛型对于JVM来说是透明的，有泛型的和没有泛型的代码，通过编译器编译后所生成的二进制代码是完全相同的。这个语法糖的实现被称为擦除。Java中的泛型基本上都是在编译器这个层次来实现的。在生成的Java字节码中是不包含泛型中的类型信息的。使用泛型的时候加上的类型参数，会在编译器在编译的时候去掉。这个过程就称为类型擦除。

无论何时定义一个泛型类型，都自动提供一个相应的原始类型(Raw Type，这里的原始类型并不是指int、boolean等基本数据类型)，原始类型的类名称就是带有泛型参数的类删去泛型参数后的类型名称，而原始类型会擦除(Erased)类型变量，并且把它们替换为限定类型(如果没有指定限定类型，则擦除为Object类型)。

泛型变量的类型的使用：

 - 在调用泛型方法的时候，可以指定泛型，也可以不指定泛型
 - 在不指定泛型的情况下，泛型变量的类型为 该方法中的几种类型的同一个父类的最小级，直到Object
 - 在指定泛型的时候，该方法中的几种类型必须是该泛型实例类型或者其子类

<!--more-->

### 桥方法

什么是桥方法(Bridge Method)，从实际代码入手：

```
// 父类
public interface Supper<T> {
    void method(T t);
}

// 其中一个子类
public class Sub implements Supper<Integer> {
	@Override
	public void method(Integer value) {
		System.out.println(value);
	}
}
```

父类Supper<T>在泛型擦除后原始类型是：

```
public interface Supper{
    void method(Object t);
}
```

子类Sub虽然实现了父类Supper，但是它只实现了void method(Integer value)而没有实现父类中的void method(Object t)，这个时候，编译期编译器会为子类Sub创建此方法，也就是子类Sub会变成这样：

```
public class Sub implements Supper<Integer> {
	@Override
	public void method(Integer value) {
		System.out.println(value);
	}
		
	public void method(Object value) {
		this.method((Integer) value);
	}
}
```

- 编译的时候Java的方法签名是方法名称加上方法参数类型列表，也就是方法名和参数类型列表确定一个方法的签名(这样就可以很好理解方法重载，还有Java中的参数都是形参，所以参数名称没有实质意义，只有参数类型才是有意义的)。
- Java虚拟机定义一个方法的签名是由方法名称、方法返回值类型和方法参数类型列表组成，所以JVM认为返回值类型不同，而方法名称和参数类型列表一致的方法是不相同的方法。

### 约束

 - 泛型类型变量不能是基本数据类型
 - 运行时类型无法查询到，如`a instanceof Pair<String>`是错误的
 - 方法重载问题：如`void method(List<String> list)`与`void method(List<Integer> list)`冲突
 - 异常中使用泛型的问题：不能抛出也不能捕获泛型类的对象，不能再catch子句中使用泛型变量
 - 不能声明参数化类型的数组：如`Pair<String>[]`是错误的
 - 不能实例化泛型类型：如`new T()`
 - 要支持擦除的转换，需要强行制一个类或者类型变量不能同时成为两个接口的子类，而这两个子类是同一接品的不同参数化
 - 泛型类中的静态方法和静态变量不可以使用泛型类所声明的泛型类型参数
  
## 类型边界

泛型与向上转型的概念:

 - 协变：子类能向父类转换 
 - 逆变：父类能向子类转换
 - 不变：两者均不能转变

无限定通配符使用<?>的格式，代表未知类型的泛型。 当可以使用Object类中提供的功能或当代码独立于类型参数来实现方法时，这样的参数可以使用任何对象。

限定通配符对类型进行了限制:

 - <? extends T>它通过确保类型必须是T的子类来设定类型的上界
 - <? super T>它通过确保类型必须是T的父类来设定类型的下界。

PECS原则，Producer-Extend,Customer-Super，也就是泛型代码是生产者，使用Extend，泛型代码作为消费者Super


## 泛型反射

由于Java中的泛型，在编译后会被擦除类型参数。如果用instanceof来查询对象的类型，只能查到对应的原始类型(raw type)。虽然有类型擦除，但也不是所有的地方都会被擦除。

Java泛型有这么一种规律：

 - 位于声明一侧的，源码里写了什么到运行时就能看到什么；
 - 位于使用一侧的，源码里写什么到运行时都没了。

```
import java.util.List;  
import java.util.Map;  
  
public class GenericClass<T> {                // 1  
    private List<T> list;                     // 2  
    private Map<String, T> map;               // 3  
      
    public <U> U genericMethod(Map<T, U> m) { // 4  
        return null;  
    }  
}  
```

上面的代码实际上：

- 1的GenericClass<T>，运行时通过Class.getTypeParameters()方法得到的数组可以获取那个“T”；
- 2的T、3的java.lang.String与T、4的T与U都可以获得。源码文本里写的是什么运行时就能得到什么；
- 像是T、U等在运行时的实际类型是获取不到的。

这是因为从Java 5开始class文件的格式有了调整，规定这些泛型信息要写到class文件中。在Java里面可以通过反射获取泛型信息的场景有：

 - 成员变量的泛型
 - 方法参数的泛型
 - 方法返回值的泛型

不能通过反射获取泛型类型信息的场景有：

 - 类或接口声明的泛型信息
 - 局部变量的泛型信息

### 类型体系

Java 5在java.lang.reflect中新引入四种泛型类型：ParameterizedType、TypeVariable、WildcardType、GenericArrayType都是接口。

#### ParameterizedType

也就是参数化类型，注释里面说到ParameterizedType表示一个参数化类型，例如`Collection<String>`，实际上只要带有参数化(泛型)标签`<ClassName>`的参数或者属性，都属于ParameterizedType。

```
public interface ParameterizedType extends Type {
    Type[] getActualTypeArguments();
    Type getRawType();
    Type getOwnerType();
}
```

 - Type[] getActualTypeArguments()：返回这个ParameterizedType类型的参数的实际类型Type数组，Type数组里面的元素有可能是Class、ParameterizedType、TypeVariable、GenericArrayType或者WildcardType之一。值得注意的是，无论泛型符号<>中有几层<>嵌套，这个方法仅仅脱去最外层的<>，之后剩下的内容就作为这个方法的返回值。
 - Type getRawType()：返回的是当前这个ParameterizedType的原始类型，从ParameterizedTypeImpl的源码看来，原始类型rawType一定是一个Class<?>实例。举个例子，List<Person>通过getRawType()获取到的Type实例实际上是Class<?>实例，和List.class等价。
 - Type getOwnerType()：获取原始类型所属的类型，从ParameterizedTypeImpl的源码看来，就是调用了原始类型rawType的getDeclaringClass()方法，而像rawType为List<T>、Map<T>这些类型的getOwnerType()实际上就是调用List.class.getDeclaringClass()，Map.class.getDeclaringClass()，返回值都是null。

#### TypeVariable

也就是类型变量，它是各种类型变量的公共父接口，它主要用来表示带有上界的泛型参数的信息，它和ParameterizedType不同的地方是，ParameterizedType表示的参数的最外层一定是已知具体类型的(如`List<String>)`，而TypeVariable面向的是K、V、E等这些泛型参数字面量的表示。常见的TypeVariable的表示形式是`<T extends KnownType-1 & KnownType-2>`


```
public interface TypeVariable<D extends GenericDeclaration> extends Type {
   //获得泛型的上限，若未明确声明上边界则默认为Object
    Type[] getBounds();
    //获取声明该类型变量实体(即获得类、方法或构造器名)
    D getGenericDeclaration();
    //获得名称，即K、V、E之类名称
    String getName();
    //获得注解类型的上限，若未明确声明上边界则默认为长度为0的数组
    AnnotatedType[] getAnnotatedBounds()
}
```

 - Type[] getBounds()：获得该类型变量的上限(上边界)，若无显式定义(extends)，默认为Object，类型变量的上限可能不止一个，因为可以用&符号限定多个（这其中有且只能有一个为类或抽象类，且必须放在extends后的第一个，即若有多个上边界，则第一个&之后的必为接口）。
 - D getGenericDeclaration：获得声明(定义)这个类型变量的类型及名称，会使用泛型的参数字面量表示，如`public void query(java.util.List<Person>)`
 - String getName()：获取泛型参数的字面量名称，即K、V、E之类名称。
 - AnnotatedType[] getAnnotatedBounds()：Jdk1.8新增的方法，用于获得注解类型的上限，若未明确声明上边界则默认为长度为0的数组。

#### WildcardType

用于表示通配符(?)类型的表达式的泛型参数，例如<? extends Number>等。根据WildcardType注释提示：现阶段通配符表达式仅仅接受一个上边界或者下边界，这个和定义类型变量时候可以指定多个上边界是不一样。但是为了保持扩展性，这里返回值类型写成了数组形式。实际上现在返回的数组的大小就是1。

```
public interface WildcardType extends Type {
    Type[] getUpperBounds();
    Type[] getLowerBounds();
}
```

 - Type[] getUpperBounds()：获取泛型通配符的上限类型Type数组，实际上目前该数组只有一个元素，也就是说只能有一个上限类型。
 - Type[] getLowerBounds()：获取泛型通配符的下限类型Type数组，实际上目前该数组只有一个元素，也就是说只能有一个下限类型。
  
#### GenericArrayType

也就是泛型数组，也就是元素类型为泛型类型的数组实现了该接口。它要求元素的类型是ParameterizedType或TypeVariable(实际中发现元素是GenericArrayType也是允许的)。

```
public interface GenericArrayType extends Type {

    Type getGenericComponentType();
}
```

- Type getGenericComponentType()：获取泛型数组中元素的类型。注意无论从左向右有几个[]并列，这个方法仅仅脱去最右边的[]之后剩下的内容就作为这个方法的返回值。


### 泛型API

Class

 - Type[] getGenericInterfaces()： 返回类实例的接口的泛型类型
 - Type getGenericSuperclass()：返回类实例的父类的泛型类型

Constructor：
  
  - Type[] getGenericExceptionTypes()：返回构造器的异常的泛型类型
  - Type[] getGenericParameterTypes()：返回构造器的方法参数的泛型类型

Method：

 - Type[] getGenericExceptionTypes()：返回方法的异常的泛型类型
 - Type[] getGenericParameterTypes()：返回方法参数的泛型类型
 - Type getGenericReturnType()：返回方法返回值的泛型类型
  
Field

 - Type getGenericType()：返回属性的泛型类型

----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 
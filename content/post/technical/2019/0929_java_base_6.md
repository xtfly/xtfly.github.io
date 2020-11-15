---
title: "跟我一起复习Java-6：反射/动态代理"
date: "2019-09-29"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# Java反射

Java的反射机制是在编译并不确定是哪个类被加载了，而是在程序运行的时候才加载、探知、自审，使用在编译期并不知道的类。这样的特点就是反射。

Java的反射就是利用加载到JVM中的.class文件来进行操作的。.class文件中包含Java类的所有信息，当你不知道某个类具体信息时，可以使用反射获取Class，然后进行各种操作。反射就是把Java类中的各种成分映射成一个个的Java对象，并且可以进行操作。

反射提供的主要功能：

 - 在运行时判断任意一个对象所属的类
 - 在运行时构造任意一个类的对象
 - 在运行时判断任意一个类所具有的成员变量和方法
 - 在运行时调用任意一个对象的方法

## RTTI

RTTI(RunTime Type Information)，所有的类型信息都必须在编译时已知。会在所有类第一次使用的时候，将class对象(保存在.class文件)动态加载到JVM。

RTTI与反射区别：

 - 编译器在编译时打开和检查.class文件
 - 运行时打开和检查.class文件
<!--more-->

## Class对象

JVM至少四个对象：Class、Field、Method、Constructor用于存储反射所需要信息

 - Class： 代表类的实体，在运行的Java应用程序中表示类和接口
 - Field： 代表类的成员变量（成员变量也称为类的属性）
 - Method： 代表类的方法
 - Constructor： 代表类的构造方法

而Class对象是类信息的载体，使用反射的前提是要获得某个类型的Class对象，有三种方式获取：

 - 对象调用 getClass() 方法来获取: obj.getClass()
 - 类名.class 的方式得到: Person.class
 - 通过 Class 对象的 forName() 静态方法来获取: Class.forName("reflex.Person")

Class对象主要能获取如下信息，

 - getName()：获得类的完整名字
 - getFields()：获得类的public类型的属性
 - getDeclaredFields()：获得类的所有属性，包括private 声明的和继承类  
 - getMethods()：获得类的public类型的方法
 - getDeclaredMethods()：获得类的所有方法，包括private 声明的和继承类
 - getMethod(String name, Class[] parameterTypes)：获得类的特定方法，name参数指定方法的名字，parameterTypes 参数指定方法的参数类型。
 - getConstructors()：获得类的public类型的构造方法
 - getDeclaredConstructors(): 获得类构造方法，包括private 声明的和继承类
 - getConstructor(Class[] parameterTypes)：获得类的特定构造方法，parameterTypes 参数指定构造方法的参数类型

带有Declared修饰的方法可以反射到私有的方法或属性，没有Declared修饰的只能用来反射公有的方法或属性。

# 动态代理

动态代理是一种方便运行时候动态的处理代理方法的调用机制。通过代理可以让调用者和实现者之间解耦。

我们常见的动态代理有：

 - JDK动态代理
 - Cglib(基于ASM)
 - Aspectj(动态织入)
 - Instrumentation(javaagent)

## JDK动态代理

代理类在程序运行时创建的方式被成为动态代理。也就是说，代理类并不是在Java代码中定义的，而是在运行时根据我们在Java代码中的"指示"动态生成的。

JDK动态代理是基于Java的反射机制实现的，它主要提供java.lang.reflect包两个类与接口：

 - Proxy：Java动态代理机制的主类，提供了一组静态方法来为一组接口动态地生成代理类及其实例。
 - InvocationHandler：调用处理器接口，它自定义了一个invoke方法，用于集中处理在动态代理对象上的方法调用，通常在该方法中实现对委托类的代理访问。每次生成动态代理对象时都需要指定一个实现了该接口的调用处理器对象。

JDK的反射是基于接口的，有一定的局限性。

## Cglib代理

Cglib采用了底层的字节码技术，为代理类创建了一个子类来代理它。Cglib是针对类来实现代理的，他的原理是对代理的目标类生成一个子类，并覆盖其中方法实现增强，因为底层是基于创建被代理类的一个子类，所以它避免了JDK动态代理类的缺陷。


Cglib主要提供一个对象一个接口：

 - Enhancer：加强器，用来创建动态代理类。需要指定需要代理的父类，以及方法拦截器，对于代理类上所有方法的调用。
 - MethodInterceptor：实现方法拦截器，


但因为采用的是继承，所以不能对final修饰的类进行代理。final修饰的类不可继承。


## Aspectj

Aspectj是面向切面编程（AOP）一种实现，也是基于字节码技术，与Cglib不同，它是修改目标类的字节，织入代理的字节，在程序编译的时候 插入动态代理的字节码，不会生成全新的Class。

面向切面的概念：
 
  - aspect（切面）：实现了cross-cutting功能，是针对切面的模块
  - jointpoint（连接点）：连接点是切面插入应用程序的地方，该点能被方法调用，而且也会被抛出意外。连接点是应用程序提供给切面插入的地方，可以添加新的方法。
  - advice（处理逻辑）：advice是我们切面功能的实现，它通知程序新的行为。
  - pointcut（切入点）：pointcut可以控制你把哪些advice应用于jointpoint上去，通常你使用pointcuts通过正则表达式来把明显的名字和模式进行匹配应用。决定了那个jointpoint会获得通知。
  - introduction：允许添加新的方法和属性到类中。
  - target（目标类）：是指那些将使用advice的类，一般是指独立的那些商务模型。
  - proxy（代理类）：使用了proxy的模式。是指应用了advice的对象，看起来和target对象很相似。
  - weaving(插入）：是指应用aspects到一个target对象创建proxy对象的过程：complie time，classload time，runtime。把切面连接到其它应用程序类型或者对象上，并创建一个被通知的对象，在运行时完成织入。


## Instrumentation

Instrumentation是可以独立于应用程序之外的代理程序，可以用来监控和扩展JVM上运行的应用程序，相当于是JVM层面的AOP。Instrumentation需要借助JVM的JavaAgent机制。

JavaAgent 相当于一个插件，在JVM启动的时候可以添加 JavaAgent 配置指定启动之前需要启动的agent jar包。这个Agent包中需要有MANIFEST.MF文件必须指定Premain-Class配置，且Premain-Class配置指定的Class必须实现premain()方法。

premain方法有两种：

 - static void premain(String agentArgs, Instrumentation inst)
 - static void premain(String agentArgs)

 premain方法中有一个参数，Instrumentation，这个是才是agent实现更强大的功能都核心所在。Instrumentation主要功能：监控和扩展JVM上的运行程序，替换和修改java类定义，提供一套代理机制，支持独立于JVM应用程序之外的程序以代理的方式连接和访问JVM
  
Instrumentation是的个接口定义，主要提供如下方法：

 - addTransformer：添加ClassFileTransformer
 - removeTransformer： 移除ClassFileTransformer
 - redefineClasses： 重新定义Class文件

ClassFileTransformer这个接口的作用是改变Class文件的字节码，返回新的字节码数组。


----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 

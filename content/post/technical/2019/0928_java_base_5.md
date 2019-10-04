---
title: "Java基础知识点5"
date: "2019-09-28"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# Java字节码

Java源文件编译之后生成的class文件，它是供JVM解释执行的二进制字节码文件。

其结构如下：

| 类型           | 名称                | 说明                                | 长度    |
| :------------- | :------------------ | :---------------------------------- | :------ |
| u4             | magic               | 魔数，识别Class文件格式，0XCAFEBABE | 4个字节 |
| u2             | minor_version       | 副版本号，如0x0000                  | 2个字节 |
| u2             | major_version       | 主版本号，如0x0034                  | 2个字节 |
| u2             | constant_pool_count | 常量池计数                          | 2个字节 |
| cp_info        | constant_pool       | 常量池                              | n个字节 |
| u2             | access_flags        | 访问标志                            | 2个字节 |
| u2             | this_class          | 类索引                              | 2个字节 |
| u2             | super_class         | 父类索引                            | 2个字节 |
| u2             | interfaces_count    | 接口计数                            | 2个字节 |
| u2             | interfaces          | 接口索引集合                        | 2个字节 |
| u2             | fields_count        | 字段个数                            | 2个字节 |
| field_info     | fields              | 字段集合                            | n个字节 |
| u2             | methods_count       | 方法计数器                          | 2个字节 |
| method_info    | methods             | 方法集合                            | n个字节 |
| u2             | attributes_count    | 附加属性计数                        | 2个字节 |
| attribute_info | attributes          | 附加属性集合                        | n个字节 |

<!--more-->

class文件只有两种数据类型：无符号数和表。

| 数据类型 | 定义                          | 说明                                                     |
| :------- | :----------------------------- | :--------------------------------------------------- |
| 无符号数 | 无符号数可以用来描述数字、索引引用、数量值或按照utf-8编码构成的字符串值 | 其中无符号数属于基本的数据类型。以u1、u2、u4、u8来分别代表1个字节、2个字节、4个字节和8个字节 |
| 表       | 表是由多个无符号数或其他表构成的复合数据结构  | 所有的表都以“_info”结尾。由于表没有固定长度，所以通常会在其前面加上个数说明       |

## 常量池

常量池主要存放两大类常量：

 - 字面量：文本字符串，声明为final的常量值
 - 符号引用：类和接口的全限定名，字段的名称和描述符，方法的名称和描述符
  
## 描述符

描述符的作用是用来描述字段的数据类型、方法的参数列表（包括数量、类型以及顺序）和返回值。

 - B：基本数据类型byte
 - C：基本数据类型char
 - D：基本数据类型double
 - F：基本数据类型float
 - I：基本数据类型int
 - J：基本数据类型long
 - S：基本数据类型short
 - Z：基本数据类型boolean
 - V：基本数据类型void
 - L：对象类型,如Ljava/lang/Object

## javap

javap是JDK自带的反解析工具。它的作用就是根据class字节码文件，反解析出当前类对应的code区（汇编指令）、本地变量表、异常表和代码行偏移量映射表、常量池等等信息。

```
-help  --help  -?         输出此用法消息
 -version                 版本信息，其实是当前javap所在jdk的版本信息，不是class在哪个jdk下生成的。
 -v  -verbose             输出附加信息（包括行号、本地变量表，反汇编等详细信息）
 -l                       输出行号和本地变量表
 -public                  仅显示公共类和成员
 -protected               显示受保护的/公共类和成员
 -package                 显示程序包/受保护的/公共类 和成员 (默认)
 -p  -private             显示所有类和成员
 -c                       对代码进行反汇编
 -s                       输出内部类型签名
 -sysinfo                 显示正在处理的类的系统信息 (路径, 大小, 日期, MD5 散列)
 -constants               显示静态最终常量
 -classpath <path>        指定查找用户类文件的位置
 -bootclasspath <path>    覆盖引导类文件的位置
```

# 类加载器

类加载器（ClassLoader）是用来加载Class的。它负责将Class的字节码形式转换成内存形式的Class对象。主要作用：

 - 负责将 Class 加载到 JVM 中
 - 审查每个类由谁加载（父优先的等级加载机制）
 - 将 Class 字节码重新解析成 JVM 统一要求的对象格式

Java语言系统自带有三个类加载器:

![classload](/images/java/class_loader.png)

 - Bootstrap ClassLoader：最顶层的加载类，主要加载核心类库，%JRE_HOME%\lib下的rt.jar、resources.jar、charsets.jar和class等。另外需要注意的是可以通过启动JVM时指定-Xbootclasspath和路径来改变Bootstrap ClassLoader的加载目录。
 - Extention ClassLoader：扩展的类加载器，加载目录%JRE_HOME%\lib\ext目录下的jar包和class文件。还可以加载-Djava.ext.dirs选项指定的目录。
 - Application ClassLoader：也称为System ClassLoader 加载当前应用的classpath的所有类

## 加载器特点

### 传递性

JVM的策略是使用调用者 Class 对象的 ClassLoader 来加载当前未知的类。所有延迟加载的类都会由初始调用 main 方法的这个 ClassLoader 全全负责，它就是 App ClassLoader。

### 双亲委派

每个 ClassLoader 实例都有一个父类加载器的引用（不是继承的关系，是一个组合的关系），每个 ClassLoader 都很懒，尽量把工作交给父亲做，父亲干不了了自己才会干。每个 ClassLoader 对象内部都会有一个 parent 属性指向它的父加载器。

### 动态性

程序启动时，并不是一次把所有的类全部加载后再运行，它总是先把保证程序运行的基础类一次性加载到JVM中，其它类等到JVM用到的时候再加载。而用到时再加载这也是java动态性的一种体现。

### 类与加载器

对于任意一个类，都需要由加载它的类加载器和这个类本身一同确立其在Java虚拟机中的唯一性，每一个类加载器，都拥有一个独立的类名称空间。比较两个类是否”相等”，只有再这两个类是有同一个类加载器加载的前提下才有意义，否则，即使这两个类来源于同一个 Class 文件，被同一个虚拟机加载，只要加载它们的类加载器不同，那这两个类就必定不相等。

## 自定义加载器

Java中提供的默认ClassLoader，只加载指定目录下的jar和class，如果我们想加载其它位置的类或jar时，需要自定义加载器。

ClassLoader 里面有三个重要的方法，调用顺序为：loadClass -> findClass -> defineClass

 - loadClass()：是加载目标类的入口，它首先会查找当前 ClassLoader 以及它的双亲里面是否已经加载了目标类，如果没有找到就会让双亲尝试加载
 - findClass()：如果双亲都加载不了，就会调用 findClass() 让自定义加载器自己来加载目标类。ClassLoader 的 findClass() 方法是需要子类来覆盖的，不同的加载器将使用不同的逻辑来获取目标类的字节码。
 - defineClass()：拿到这个字节码之后再调用 defineClass() 方法将字节码转换成 Class 对象。
  
定义自已的类加载器分为两步：

 - 继承java.lang.ClassLoader
 - 重写父类的findClass方法

## Class加载过程

类从被加载到虚拟机内存中开始，直到卸载出内存为止，它的整个生命周期包括了：加载、验证、准备、解析、初始化、使用和卸载这7个阶段。其中，验证、准备和解析这三个部分统称为连接（linking）。

 - 顺序确定的：加载、验证、准备、初始化和卸载这五个阶段的顺序是确定的
 - 顺序不确认的：解析阶段在某些情况下可以在初始化阶段之后再开始，这是为了支持Java语言的运行时绑定。

类的实例化与类的初始化是两个完全不同的概念：

 - 类的实例化是指创建一个类的实例(对象)的过程
 - 类的初始化是指为类中各个类成员(被static修饰的成员变量)赋初始值的过程，是类生命周期中的一个阶段。
  
### 加载方式

JVM加载class文件的两种方法：

 - 隐式加载：程序在运行过程中当碰到通过new 等方式生成对象时，隐式调用类装载器加载对应的类到JVM中
 - 显式加载：通过Class.forname()、ClassLoader().loadClass()等方法显式加载需要的类，或者我们自己实现的 ClassLoader 的 findlass() 方法。

Class.forName vs ClassLoader.loadClass

这两个方法都可以用来加载目标类，它们之间有一个小小的区别，那就是 Class.forName() 方法可以获取原生类型的 Class，而 ClassLoader.loadClass() 则会报错。

如 `Class<?> x = Class.forName("[I");`

Thread.contextClassLoader

contextClassLoader是线程上下文类加载器，是从父线程那里继承过来的，用途如下：

 - 它可以做到跨线程共享类，只要它们共享同一个 contextClassLoader。父子线程之间会自动传递 contextClassLoader，所以共享起来将是自动化的。
 - 如果不同的线程使用不同的 contextClassLoader，那么不同的线程使用的类就可以隔离开来。

### 加载异常

在类加载过程与初始化过程中，会出现如下异常：

 - ClassNotFoundExecption：当 JVM 要加载指定文件的字节码到内存时，并没有找到这个文件对应的字节码，也就是这个文件并不存在。解决方法就是检查在当前的 classpath 目录下有没有指定的文件。
 - NoClassDefFoundError：可能的情况就是使用new关键字、属性引用某个类、继承了某个接口或者类，以及方法的某个参数中引用了某个类，这时就会触发JVM或者类加载器实例尝试加载类型的定义，但是该定义却没有找到，影响了执行路径。换句话说，在编译时这个类是能够被找到的，但是在执行时却没有找到。解决这个错误的方法就是确保每个类引用的类都在当前的classpath下面。
 - UnsatisfiedLinkError：通常是在 JVM 启动的时候，如果 JVM 中的某个 lib 删除了，就有可能报这个错误。
 - ExceptionInInitializerError：在初始化时出异常，如给静态成员赋值出错。
 - NoSuchMethodError：NoSuchMethodError代表这个类型确实存在，但是一个不正确的版本被加载了，出现使用的方法不存在。
  

## Java9变化

Java9模块化之后，对ClassLoader有所改造，对应的ClassLoader加载各自对应的模块：
 
 - Bootstrap ClassLoader：加载lib/modules下基本的modules，如java.base ，jdk.net等20个modules
 - Extention ClassLoader：更名为Platform Classloader，加载lib/modules下其它的30个modules
 - Application classloader加载-cp，-mp指定的类，也会加载lib/modules下25个moduels


----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 
---
title: "跟我一起复习Java-9：JNI/JIT/SM"
date: "2019-10-05"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# JNI

JNI是Java Native Interface的缩写，通过使用 Java本地接口书写程序，可以确保代码在不同的平台上方便移植。JNI标准成为java平台的一部分，它允许Java代码和其他语言写的代码进行交互。JNI一开始是为了本地已编译语言，尤其是C和C++而设计的，但是它并不妨碍你使用其他编程语言，只要调用约定受支持就可以了。

JNI开发流程主要分为以下6步：

1. 编写声明了native方法的Java类
2. 将Java源代码编译成class字节码文件
3. 用javah -jni命令生成.h头文件（javah是jdk自带的一个命令，-jni参数表示将class中用native声明的函数生成jni规则的函数）
4. 用本地代码实现.h头文件中的函数
5. 将本地代码编译成动态库（`windows：*.dll，linux/unix：*.so，mac os x：*.jnilib`）
6. 拷贝动态库至 java.library.path 本地库搜索目录下，并运行Java程序
<!--more-->

## 数据类型

其实不能互通的原因主要是数据类型的问题，JNI解决了这个问题，例如那个c文件中的jstring数据类型就是java传入的String对象，经过JNI函数的转化就能成为c的char*。

基本数据类型

| Java 类型 | JNI本地类型 | C/C++数据类型  | 说明          |
| :-------- | :---------- | :------------- | :------------ |
| boolean   | jboolean    | unsigned char  | 无符号，8 位  |
| byte      | jbyte       | signed char    | 有符号，8 位  |
| char      | jchar       | unsigned short | 无符号，16 位 |
| short     | jshort      | signed short   | 有符号，16 位 |
| int       | jint        | signed int     | 有符号，32 位 |
| long      | jlong       | signed long    | 有符号，64 位 |
| float     | jfloat      | float          | 32 位         |
| double    | jdouble     | double         | 64 位         |


引用数据类型

| Java数据类型        | JNI的引用类型 | 类型描述                                                                      |
| :------------------ | :------------ | :---------------------------------------------------------------------------- |
| java.lang.Object    | jobject       | 可以表示任何Java的对象，或者没有。JNI对应类型的Java对象（实例方法的强制参数） |
| java.lang.String    | jstring       | Java的String字符串类型的对象                                                  |
| java.lang.Class     | jclass        | Java的Class类型对象（静态方法的强制参数）                                     |
| Object[]            | jobjectArray  | Java任何对象的数组表示形式                                                    |
| boolean[]           | jbooleanArray | Java基本类型boolean的数组表示形式                                             |
| byte[]              | jbyteArray    | Java基本类型byte的数组表示形式                                                |
| char[]              | jcharArray    | Java基本类型char的数组表示形式                                                |
| short[]             | jshortArray   | Java基本类型short的数组表示形式                                               |
| int[]               | jintArray     | Java基本类型int的数组表示形式                                                 |
| long[]              | jlongArray    | Java基本类型long的数组表示形式                                                |
| float[]             | jfloatArray   | Java基本类型float的数组表示形式                                               |
| double[]            | jdoubleArray  | Java基本类型double的数组表示形式                                              |
| java.lang.Throwable | jthrowable    | Java的Throwable类型，表示异常的所有类型和子类                                 |
| void                | void          | N/A                                                                           |

## 双向访问

每个JNI固有方法都会接收一个特殊的自变量作为自己的第一个参数：JNIEnv自变量。利用JNIEnv自变量，程序员可访问一系列函数。

 - 传递或返回数据
 - 操作实例变量或调用使用垃圾回收的堆中对象的方法
 - 操作类变量或调用类方法
 - 操作数组
 - 对堆中对象加锁,以便被当前线程独占
 - 创建对象
 - 加载类
 - 抛异常
 - 捕获本地方法调用的Java方法抛出的异常
 - 捕获虚拟机异常
 - 告诉垃圾回收器某个对象不再需要

## 函数注册

JNI函数的注册：将Java层的native函数和JNI层对应的实现函数关联起来。

 - 静态注册：通过java对象中声明native方法
 - 动态注册：通过JNINativeMethod结构用来记录Java的Native方法和JNI方法的关联关系

System.loadLibrary("xxx")用于加载动态库。

# JIT

JIT是Just In Time compiler的简称。，Java 程序最初是通过解释器（ Interpreter ）进行解释执行的，当虚拟机发现某个方法或代码块的运行特别频繁的时候，就会把这些代码认定为“热点代码”。为了提高热点代码的执行效率，在运行时，即时编译器（Just In Time Compiler ）会把这些代码编译成与本地平台相关的机器码，并进行各种层次的优化。

## 热点代码

在运行过程中会被即时编译的“热点代码”有两类，即：

 - 被多次调用的方法
 - 被多次执行的循环体
  
判断一段代码是否是热点代码，探测算法有两种：

 - 基于采样的热点探测（Sample Based Hot Spot Detection）：虚拟机会周期的对各个线程栈顶进行检查，如果某些方法经常出现在栈顶，这个方法就是“热点方法”。好处是实现简单、高效，很容易获取方法调用关系。缺点是很难确认方法的reduce，容易受到线程阻塞或其他外因扰乱。
 - 基于计数器的热点探测（Counter Based Hot Spot Detection）：为每个方法（甚至是代码块）建立计数器，执行次数超过阈值就认为是“热点方法”。优点是统计结果精确严谨。缺点是实现麻烦，不能直接获取方法的调用关系。


## compile模式

 - client-compiler：是主要跑在客户端本地的。特点是使用资源少启动快速。
 - server-compiler：跑在服务器上，因为服务器上程序本身是长时间运行的，而且对启动时间没有严格的要求。那么就可以牺牲启动时间获得深度的优化。
 - tiered-compiler：是两者的结合体。在启动之初用client的方案，并且收集数据。随着时间的推移，使用服务器的解决方案并使用之前收集的数据。这样做可以充分利用二者各自的优势，实现最佳的优化结果。

一般而言，client-compiler会提升大概五到十倍的运行效率。server-compiler比client-compiler提升百分之五十左右，但是需要以更多的资源作为代价。

## 常见的优化

JIT的核心就是分析代码，优化运行效率。一方面是，代码可能写的不够最优，由JIT代替程序员做一些优化。另一方面是，程序代码本身没问题，但是cpu和内存的操作可以进一步优化，这些程序员并不知道，由JIT来帮程序员做了。

 - 未使用和去重：就是检查一下代码上下文，删一删。
 - loop：这个主要是优化方式是减少程序运行指针的jump操作。优化方案有把loop展开，这样不用跳转顺序执行即可；用if加do while代替while，感觉这样操作只解决了一个特殊情况，且增加了复杂度，并没什么必要。
 - inline：这个操作应该是JIT的核心之一。解决的问题还是指针跳转和机器码重用。具体操作就是把常用的代码段对应机器码直接插入到caller那里。

# SecurityManager

应用都可以有自己的安全管理器，它是防范恶意攻击的主要安全卫士。安全管理器通过执行运行阶段检查和访问授权，以实施应用所需的安全策略，从而保护资源免受恶意操作的攻击。

## 基本概念

 - 策略(Policy)：类装载器用Policy对象帮助它们决定，把一段代码导入虚拟机时应该给它们什么样的权限. 任何时候，每一个应用程序都只有一个Policy对象.
 - 保护域(ProtectionDomain)：当类装载器将类型装入java虚拟机时，它们将为每一个类型指派一个保护域，保护域定义了授予一段特定的代码的所有权限.装载入java虚拟机的每一个类型都属于一个且仅属于一个保护域。

默认的安全管理器配置文件是 $JAVA_HOME/jre/lib/security/java.policy

## 使用方式

SecurityManager提供一系列的checkXXX方法，用于应用是否有权限操作。这些check方法，分别囊括了文件的读写删除和执行、网络的连接和监听、线程的访问、以及其他包括打印机剪贴板等系统功能。安全管理器可以自定义，作为核心API调用的部分，我们可以自己为自己的业务定制安全管理逻辑。

AccessController最重要的方法就是checkPermission()方法，作用是基于已经安装的Policy对象，能否得到某个权限。

AccessController的使用还是重度关联类加载器的。如果都是一个类加载器且都从一个保护域加载类，那么你构造的checkPermission的方法将正常返回。

AccessController另一个比较实用的功能是doPrivilege（授权）。假设一个保护域A有读文件的权限，另一个保护域B没有。那么通过AccessController.doPrivileged方法，可以将该权限临时授予B保护域的类。

## 启动方式

 - 启动参数方式：`-Djava.security.manager -Djava.security.policy="java.policy"`
 - 编码方式启动：`System.setSecurityManager(new SecurityManager());`

## 配置文件 

在启用安全管理器的时候，配置遵循以下基本原则：

 - 有配置的权限表示没有。
 - 只能配置有什么权限，不能配置禁止做什么。
 - 同一种权限可多次配置，取并集。
 - 统一资源的多种权限可用逗号分割。

样例：

```
grant codeBase "file:${{java.ext.dirs}}/*" {
    permission java.security.AllPermission;
};

grant { 
    permission java.lang.RuntimePermission "stopThread";
    ……   
}
```

Java本身包括了一些 Permission类，如下:

 - java.security.AllPermission：所有权限的集合
 - java.util.PropertyPermission：系统/环境属性权限
 - java.lang.RuntimePermission：运行时权限
 - java.net.SocketPermission：Socket权限
 - java.io.FilePermission：文件权限,包括读写,删除,执行
 - java.io.SerializablePermission：序列化权限
 - java.lang.reflect.ReflectPermission：反射权限
 - java.security.UnresolvedPermission：未解析的权限
 - java.net.NetPermission：网络权限
 - java.awt.AWTPermission：AWT权限
 - java.sql.SQLPermission：数据库sql权限
 - java.security.SecurityPermission：安全控制方面的权限
 - java.util.logging.LoggingPermission：日志控制权限
 - javax.net.ssl.SSLPermission：安全连接权限
 - javax.security.auth.AuthPermission：认证权限
 - javax.sound.sampled.AudioPermission：音频系统资源的访问权限

----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 
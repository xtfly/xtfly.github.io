---
title: "跟我一起复习Java-10"
date: "2019-10-06"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# JVMTI

JVMTI（Java VM Tool Interface）就是JVM对外暴露的接口。

JVMTI 本质上是在JVM内部的许多事件进行了埋点。通过这些埋点可以给外部提供当前上下文的一些信息。甚至可以接受外部的命令来改变下一步的动作。外部程序一般利用C/C++实现一个JVMTI Agent，在Agent里面注册一些JVM事件的回调。当事件发生时JVMTI调用这些回调方法。Agent可以在回调方法里面实现自己的逻辑。JVMTI Agent是以动态链接库的形式被虚拟机加载的。

JVMTI Agent启动方式： `-agentlib:<agent-lib-name>=<options>`

JVMTI Agent回调函数：

 - OnLoad阶段： 调用静态库的Agent_OnLoad函数
 - Live阶段： 调用静态库的Agent_OnAttach函数
 - 关闭阶段：调用静态库的Agent_OnUnload函数

<!--more-->

JVMTI 并不一定在所有的 Java 虚拟机上都有实现，不同的虚拟机的实现也不尽相同。

## JVMTI用途

 -  使用JVMTI对class文件加密：使用一些常规的手段（例如使用混淆器或者自定义类加载器）来对class文件进行加密很容易被反编译。使用JVMTI我们可以将解密的代码封装成.dll,或.so 文件。这些文件想要反编译就很麻烦了，另外还能加壳。解密代码不能被破解，从而也就保护了我们想要加密的class文件。
 -  使用JVMTI实现应用性能监控(APM)：基于JVMTI的APM能够解决分布式架构和微服务带来的监控和运维上的挑战。APM通过汇聚业务系统各处理环节的实时数据，分析业务系统各事务处理的交易路径和处理时间，实现对应用的全链路性能监测。开源的Pinpoint, ZipKin, Hawkular,商业的AppDynamics，OneAPM，Google Dapper等都是个中好手。
 -  产品运行时错误监测及调试：基于JVMTI可以开发出一款工具来时事监控生产环境的异常。这方面有一款成熟的商业软件OverOps，其有三个主要的功能：1. 采集到所有的异常，包括try catch之后没有打印出来的异常；2. 可以采集到异常发生时上下文所有变量的值；3. 可以将异常发生的堆栈对应的源代码采集展示出来，从而在一个系统上就可以看代码定位问题，不需要打开ide调试源代码。
 -  JAVA程序的调试(debug)：google甚至推出了云端调试工具cloud debugger。它时一个web应用，可以直接对生产环境进行远程调试，不需要重启或者中断服务。阿里也有类似的工具Zdebugger。
 -  JAVA程序的诊断(profile)：当出现cpu使用率过高、线程死锁等问题时，需要使用一些JAVA性能剖析或者诊断工具来分析具体的原因。例如Alibaba开源的Java诊断工具Arthas，它可以查看或者动态修改某个变量的值、统计某个方法调用链上的耗时、拦截方法前后，打印参数值和返回值，以及异常信息等。
 -  热加载：热加载指的是在不重启虚拟机的情况下重新加载一些class。热加载可以使本地调试代码非常节省时间，不用每次更新代码都重启一边程序。同时，在一线不方便重启的线上环境也能派上用场。这方面的代表产品有商业产品JRebel等。

## Instrumention

Java虽然提供了JVMTI，但是对应的Agent需要用C/C++开发，对Java开发者而言并不是非常友好。因此在Java 5的新特性中加入了Instrumentation机制。有了 Instrumentation，开发者可以构建一个基于Java编写的Agent来监控或者操作JVM了，比如替换或者修改某些类的定义等。

## Attach

开发的Agent需要启动就必须在JVM启动时设置参数，但很多时候我们想要在程序运行时中途插入一个Agent运行。在Java 6的新特性中，就可以通过Attach的方式去加载一个Agent了。

Attach机制的实现涉及到了进程间的通信。主要涉及到两个JVM的线程：
 
  - Attach Listener：用于JVM进程间的通信，但是它不一定会启动，启动它有两种方式。
  - Signal Dispatcher： 用于处理信号

启动Attach Listener方式 

 - 命令行参数启动：java -XX:+StartAttachListener
 - 依靠Signal Dispatcher线程来启动

Attach Listener线程启动后，就会创建一个监听套接字，并创建了一个文件/tmp/.java_pid的IPC socketFile，之后客户端和目标JVM进程就通过这个socketFile进行通信。客户端可以通过这个socketFile发送相关命令。Attach Listener线程做的事情就是监听这个socketFile，发现有请求就解析，然后根据命令执行不同的方法，最后将结果返回。

# JPDA

JPDA（Java Platform Debugger Architecture）是Java提供的一套用于开发Java调试工具的规范，任何的JDK实现都需要实现这个规范。JPDA是一个Architecture，它包括了三个不同层次的规范。

```
                 /    |--------------|
                /     |     VM       |
    debuggee - (      |--------------|  <------- JVMTI - Java VM Tool Interface
                \     |   back-end   |
                 \    |--------------|
                 /           |
 comm channel - (            |  <--------------- JDWP - Java Debug Wire Protocol
                 \           |
                 /    |--------------|
                /     |  front-end   |
    debugger - (      |--------------|  <------- JDI - Java Debug Interface
                \     |      UI      |
                 \    |--------------|

```

JDPA由3个模块组成：

 - JVMTI，即底层的相关调试接口调用。Oracle公司提供了一个jdwp.dll( jdwp.so)动态链接库，就是我们前面说的Agent实现。
 - JDWP（Java Debug Wire Protocol）,定义了Agent和调试客户端之间的通讯交互协议。
 - JDI（Java Debug Interface），是由Java语言实现的。有了这套接口，我们就可以直接使用Java开发一套自己的调试工具。

下面启动Debug命令即采用Agent实现：

`-agentlib:jdwp=transport=dt_socket,server=y,address=8787`

Linux下会使用libjdwp.so这个动态链接库。JVM启动的时候会去调用Agent的Agent_OnLoad方法，这个方法中会去解析我们传进来的transport=dt_socket,server=y,address=8787。

## 参数说明

JDK1.5 之前

`-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8888,onthrow=java.io.IOException,launch=/sbin/echo`

JDK1.5 之后，老的还是可以使用

`-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8888,onthrow=java.io.IOException,launch=/sbin/echo`

参数说明

 - -Xdebug：是通知JVM工作在DEBUG模式下
 - -Xrunjdwp：是通知JVM使用(java debug wire protocol)来运行调试环境
 - -agentlib:jdwp：通过JavaAgent加载jdwp动态库，见前面的介绍
 - transport：指定了调试数据的传送方式，dt_socket是指用SOCKET模式，另有dt_shmem指用共享内存方式，其中，dt_shmem只适用于Windows平台
 - server：参数是指是否支持在server模式的VM中
 - suspend：是否在调试客户端建立起来后，再执行JVM
 - address：启动地址，与transport有关
 - onthrow：当产生该类型的Exception时，JVM就会中断下来，进行调式。该参数可选。
 - launch：当JVM被中断下来时，执行的可执行程序。该参数可选 
 - onuncaught：值为y或n，出现uncaught exception 后，是否中断JVM的执行

样例：

 - `transport=dt_socket,server=y,address=8000 ` : 在8000端口监听Socket连接，挂起VM并且不加载运行主函数直到调试请求到达
 - `transport=dt_shmem,server=y,suspend=n `: 选择一个可用的共享内存（因为没有指address）并监听该内存连接，同时加载运行主函数 
 - `transport=dt_socket,address=myhost:8000 ` : 连接到myhost:8000提供的调试服务（server=n，以调试客户端存在），挂起VM并且不加载运行主函数 
 - `transport=dt_socket,server=y,address=8000, onthrow=java.io.IOException,launch=/usr/local/bin/debugstub ` : 等待java.io.IOException被抛出，然后挂起VM并监听8000端口连接，在接到调试请求后以命令/usr/local/bin/debugstub dt_socket myhost:8000执行 
 - `transport=dt_shmem,server=y,onuncaught=y,launch=d:\bin\debugstub.exe` : 等待一个RuntimeException被抛出，然后挂起VM并监听一个可用的共享内存，在接到调试请求后以命令d:\bin\debugstub.exe 

官方参考：[optionX](https://docs.oracle.com/cd/E13150_01/jrockit_jvm/jrockit/jrdocs/refman/optionX.html)


# JDK工具

Oracle的JDK提供一些常用工具，用于定位Java问题。

## jps

显示当前所有java进程pid的命令，我们可以通过这个命令来查看到底启动了几个java进程。

- jps -l : 输出应用程序main.class的完整package名或者应用程序jar文件完整路径名
- jps -v : 输出传递给JVM的参数

jps的实现机制：

java程序启动后，会在目录/tmp/hsperfdata_{userName}/下生成几个文件，文件名就是java进程的pid，因此jps列出进程id就是把这个目录下的文件名列一下而已，至于系统参数，则是读取文件中的内容。

## jstack

用于生成指定进程当前时刻的线程快照，线程快照是当前java虚拟机每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是用于定位线程出现长时间停顿的原因，如线程间死锁、死循环、请求外部资源导致长时间等待。

## jmap

主要用于打印指定java进程的共享对象内存映射或堆内存细节。

 - jmap pid : 输出的信息分别为：共享对象的起始地址、映射大小、共享对象路径的全程。
 - jmap -heap pid : 输出堆使用情况
 - jmap -histo pid：输出堆中对象数量和大小
 - jmap -dump:format=b,file=heapdump pid：将内存使用的详细情况输出到文件，然后使用jhat命令查看该文件：jhat -port 4000 文件名 ，在浏览器中访问http:localhost:4000/

## jstat

主要是对java应用程序的资源和性能进行实时的命令行监控，包括了对heap size和垃圾回收状况的监控。

`jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]`

 - option：我们经常使用的选项有gc、gcutil、class、compiler
 - vmid：java进程id
 - interval：间隔时间，单位为毫秒
 - count：打印次数

样例：

 - jstat -gc PID 5000 20： 输出堆中各分代的使用容量与GC的次数与所用时间 
 - jstat -gcutil PID 5000 20：输出堆中各分代的使用容量百分比

## jinfo

用来查看正在运行的java运用程序的扩展参数，甚至支持在运行时动态地更改部分参数。

`jinfo -<option> <pid>`

 - -flag <name>: 打印指定java虚拟机的参数值
 - -flag [+|-]<name>：设置或取消指定java虚拟机参数的布尔值
 - -flag <name>=<value>：设置指定java虚拟机的参数的值

## jcmd

JDK 1.7之后新增，用于向正在运行的JVM发送诊断信息请求。也可用来导出堆，查看java进程，导出线程信息，执行GC等。jcmd拥有jmap的大部分功能，Oracle官方建议使用jcmd代替jmap。

## jstatd

是一个RMI服务器应用程序，用于监控JVM的创建与终止，并提供一个接口允许远程监控工具依附到在本地主机上运行的JVM。

jstatd服务器需要在本地主机上存在一个RMI注册表。jstatd服务器将尝试在默认端口或-p port选项指定的端口附加到该RMI注册表上。如果RMI注册表不存在，jstatd应用程序将会自动创建一个，并绑定到-p port选项指定的端口上，如果省略了-p port选项，则绑定到默认的RMI注册表端口。


----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 
---
title: "响应式编程"
date: "2017-10-01"
categories:
 - "技术"
 - "笔记"
tags:
 - "软件开发"
 - "Java"
toc: true
---

## RxJava

最早接触响应式编程，是为了分析Netflix的架构。Netflix系统中大量使用了[RxJava(Reactive Extension for Java)](https://github.com/ReactiveX/RxJava)。由于Netflix中服务的高并发请求，需要一个高效的异步编程框架，于是他们参考了微软的[Rx.Net](http://Rx.Net)的实现原理，在JVM上实现了响应式编程(Reactive Programming)的一种方式。同类的库还有[Project Reactor](http://projectreactor.io/), [Akka](https://akka.io/)和[Agera](https://github.com/google/agera)等等。

传统编程模式下，我们通常是同步实现，同步是最能简单理解的，调用一个函数或方法，等待响应返回。但对于要求高并发的服务端的软件开发，同步实现带来的开销也是巨大的。像Java中，并没有语言层面实现异步，如果没有借助一些框架，1K的并发请求，可能使用1K的线程来处理；如果采用一些异步框架来实现异步，就会像早期的JavaScript，通常是CallBack，Future模式，代码逻辑变得离散而复杂，造成所谓的`Callback Hell`。JavaScript在ES5引入Promise机制，在ES6引入async关键字，就是想语言原生层面来解决`Callback Hell`。而Go语言则更进一步，通过Runtime机制，通过Goroutine调度实现IO调用等异步机制，让上层使用感不到异步调用的存在。

<!--more-->

再拿RxJava来说，其最基础原理是引入了`Observable`，一种观察者模式与Reactor模式的增强，但又与传统的观察者模式又不完全相同。传统的观察者模式是涉及到两个对象观察者（Observer ）和被观察者（Observable ）。观察者通过将被观察 的对象加到自己的观察队列中，当被观察者发生改变时，就会通知观察者东西已经改变。而RxJava中涉及到4个概念：

 - Observable：可观察者，即被观察者
 - Observer：观察者
 - Subscribe：订阅
 - Event：事件
 
 `Observable`和`Observer`通过`subscribe()`方法实现订阅关系，从而`Observable`可以在需要的时候发出事件来通知 `Observer`数据刷新。而上游只管同过`Observable`发送数据，或是异步或是同步。下游只管处理，也无须关心上游数据到底怎么生成。如果这样的话，其实和`CallBack`也差不多啊。但`Observable`通过`Observable Contract`，使得所有`CallBack`都可以走上同一个管道。这就引出Stream的概念，也是Java 8中最主要的特性。Stream是Java弥补函数式编程的缺陷，解决集合类型函数式与链式操作，它看起来像一个管道的不断地`Iterable`流。回到RxJava，它使得`CallBack`都到一个`Stream`管道流了，而可以与Java 8的函数式编程完美结合，从而避免了`Callback Hell`。

## 响应式编程

回到正题，什么是响应式编程，如下是来自Wiki的定义：

> In computing, reactive programming is an asynchronous programming paradigm concerned with data streams and the propagation of change.
> - [Reactive programming - Wikipedia](https://en.wikipedia.org/wiki/Reactive_programming)

响应式编程(简称RP)是一种异步编程范式，包含两个重要的关键词：

 - Data streams: 即数据流，分为静态数据流（比如数组，文件）和动态数据流（比如事件流，日志流）两种。基于数据流模型，RP得以提供一套统一的Stream风格的数据处理接口。和Java 8中的Stream API相比，RP API除了支持静态数据流，还支持动态数据流，并且允许复用和同时接入多个订阅者。

 - The propagation of change: 变化传播，简单来说就是以一个数据流为输入，经过一连串操作转化为另一个数据流，然后分发给各个订阅者的过程。这就有点像函数式编程中的组合函数，将多个函数串联起来，把一组输入数据转化为格式迥异的输出数据。

在JVM上，由于Java语言层面不支持原生异步，RxJava与Rector等都是一种异步编程框架，他们涵盖以下三个特性：

 - 描述而非执行：在你最终调用subscribe()方法之前，从发布端到订阅端，没有任何事会发生。就好比无论多长的水管，只要水龙头不打开，水管里的水就不会流动。为了提高描述能力，RP提供了比Stream丰富的多的多的API，比如buffer(), merge(), onErrorMap()等。

 - 提高吞吐量：RP通过线程复用来提高吞吐量，它有点像异步IO的多路复用机制，通过线程复用来处理数据流。

 - 背压（Backpressure）机制：背压就是一种流控机制。就是消费者需要多少，生产者就生产多少。这有点类似于TCP里的流量控制，接收方根据自己的接收窗口的情况来控制接收速率，并通过反向的ACK包来控制发送方的发送速率。

当然，与任何框架一样，有优势必然就有劣势：

 - 优势：
  - 适用于高并发、带延迟操作
 - 劣势：
  - 无线程隔离：由于是线程复用，若线程存在卡死，可能导致整个应用被拖垮而不可用。
  - 调试定位因难：采用Stream的链式表达式，一旦出错，你将很难定位到具体是哪个环节出了问题。

## 响应式宣言

和[敏捷宣言](http://agilemanifesto.org/)一样，响应式编程也有[响应式宣言](http://www.reactivemanifesto.org/):

 > We want systems that are Responsive, Resilient, Elastic and Message Driven. We call these Reactive Systems.

![](/images/y17/reactive-traits.svg)

宣言中也包含了4组关键词:

 - Responsive: 可响应的。要求系统尽可能做到在任何时候都能及时响应。
 - Resilient: 可恢复的。要求系统即使出错了，也能保持可响应性。
 - Elastic: 可伸缩的。要求系统在各种负载下都能保持可响应性。
 - Message Driven: 消息驱动的。要求系统通过异步消息连接各个组件。

从上面可以看，响应式宣言，主要目的是解决系统的可用性，用用性首先要保证就是可响应性。

## Spring 5 WebFlux

让我还在留在Java开发，还是因为Spring社区。Spring一直是Java编程领域的急先峰，如最早的IOC，后面AOP，当前微服务框架SpringCloud， SprintBoot，以及刚发布的Spring 5中最主要的WebFlux，它积极吸引业界优秀的实践，带入Java世界，给暮色沉沉的Java带来一些新意。

Spring 5最大的亮点是提供了提供了完整的端到端响应式编程的支持，也是Java世界首个响应式Web框架。

![](/images/y17/webflux-overview.png)

左侧是传统的基于Servlet的Spring Web MVC框架，右侧是5.0版本新引入的基于Reactive Streams的Spring WebFlux框架，从上到下依次是Router Functions，WebFlux，Reactive Streams三个新组件。

 - Router Functions: 对标@Controller，@RequestMapping等标准的Spring MVC注解，提供一套函数式风格的API，用于创建Router，Handler和Filter。
 - WebFlux: 核心组件，协调上下游各个组件提供响应式编程支持。
 - [Reactive Streams](http://www.reactive-streams.org/): 一种支持背压（Backpressure）的异步数据流处理标准，主流实现有RxJava和Reactor，Spring WebFlux默认集成的是Reactor。

 除了新的Router Functions接口，Spring WebFlux同时支持使用老的Spring MVC注解声明Reactive Controller。在Web容器的选择上，Spring WebFlux既支持像Tomcat，Jetty这样的的传统容器（前提是支持Servlet 3.1 Non-Blocking IO API），又支持像Netty，Undertow那样的异步容器。

参考：  
1. [Understanding Reactive types](https://spring.io/blog/2016/04/19/understanding-reactive-types)  
2. [Designing, Implementing, and Using Reactive APIs](Designing, Implementing, and Using Reactive APIs)  
3. [Spring Framework 5: History and Reactive features](https://www.slideshare.net/AliakseiZhynhiarousk/spring-framework-5-history-and-reactive-features)  
4. [响应式编程总览](http://blog.csdn.net/eMac/article/details/73557010) 

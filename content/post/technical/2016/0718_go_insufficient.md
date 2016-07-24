---
title: "Go语言不足"
date: "2016-07-18"
categories:
 - "技术"
tags:
 - "go"
toc: true

---

最近公司是在疯狂地推广Go语言，我也是推广小组成员。Go语言的确很多的优点，这里并不想表扬Go语言，而是说说它的不足。

## 生态不成熟

一个语言的流行，都有其背后的推动者。Go语言是由Google公司创建与推动。最近我司的高层也亲自拜访了Go语言的主创人员。Google称目前已有100+的App从Java转向Go。Google内部主要有三大语言（C++、Java、Python），之前对Go语言的公司内部的政治意义大于它的实际使用。近两年来，语言的战略地位凸显，不断地在推动Go语言的应用。

目前主要使用Go语言的公司是一些创业公司或互联网公司。而这些公司采用Go语言非技术的因素主要有：

 * 公司软件资产积累少，不存在切换其它语言成本，使用Go语言可以轻装上阵；
 * 互联网公司的技术人员流动大，Go语言面向开发简化，招人容易，上手快；

采用Go语言的技术因素主要有：

 * Go语言在语言级通过Goroutine与网络IO的Netpoller的封装，能大在简化高并发的网络应用开发，而互联网的应用都以HTTP、网络通讯应用为主；
 * Go语言标准库丰富，能满足互联网应用的常用应用场景：不需要太多的业务逻辑，偏网络接入；

Go当前很多的第三方开源框架，库都是最近一到两年内才诞生的，并且后面没有相应的大公司支撑，个人或小团体的维护的项目居多。这些框架，库的成熟需要时间来锤炼与稳定。

## 动态扩展机制不成熟

对于编译型静态语言，需要有一种机制来支持动态扩展。C/C++是通过动态库来扩展，Java是支持Class动态加载，或基于JVM平台的其它脚本语言互通。Go语言长期没有支持动态库，Go语言的创始人曾明确表态：

 > 动态库的存在是一个系统的设计Bug

但是在Go1.5版本又加入了动态库支持，对动态库支持采用一定的妥协，这也说明它确有它的应用场景。但目前只支持：Linux/AMD64，ARM平台（[cgo·golang/go Wiki](https://github.com/golang/go/wiki/cgo),[WindowsDLLs·golang/go Wiki](https://github.com/golang/go/wiki/WindowsDLLs)）。同时支持也是有限制：

 * Go语言代码，可以生成动态库给C代码调用，也可能给Go代码调用，但他们使用也有区别，参考：[Go1.5生成动态库](http://www.golangtc.com/t/55976045b09ecc0f51000001)
 * 不支持运行时在代码中动态加载库

目前可行的解决方案：

 * 生成C语言动态库：通过动态加载生成C语言动态库，实现动态扩展，一个进程中，运行了多个“Go世界”（Go的Runtime）

  - 这需要GCC编译器，所以严格来说并不支持Win下的纯DLL动态库（cywin之类的gcc没有验证过）

 * 嵌入脚本语言，实现功能逻辑的动态扩展。

  - 目前开源项目已有纯Go实现的Lua VM，也有通过CGo绑定C的Lua。也有开源项目通过Cgo绑定支持Python,Ruby等；
  - 自创脚本脚本，或DSL脚本，采用Go来实现脚本解释。但如果对性能要高要求，需要支持对脚本的JIT，这是相当有难度，目前也未见有解决方案。

 * 实现基于通信机制的插件模式

  - 类似于VScode的语言服务插件机制，参考：[通用语言协议](http://www.oschina.net/translate/common-language-protocol)
  - 这本质是进程间的通讯，并不传统意义上的插件扩展机制。


## 不支持泛型

泛型是目前高级语言最常见的语言基础，Java1.5采用擦除法的泛型（并不像C++一样的Template技术）也解放了不少生产力，能大大减少相似的代码。而Go语言官方团队相对是“民主集中制”，很难听取社区的意见，认为这个总是不紧急，并且他们也没有找到满意的实现方式（C++/Java实现方式都不让他们满意：C++是编译期间展示，生成不同的代码，对编译速度与生成文件大小都有影响；而Java是擦除法，只是语法糖，生成Bytecode变成Object对象，并没有本质变化）。

从目前来看，Go语言在1.0规范发布之后，语法特性几乎没有什么变化，围绕是性能优化与跨平台支持。至少在Go2.0之前，极可能不会引入这个语言特性。

目前可行的解决方案

 * interface{}

  - 类似于C的void*，Java的Object，但这会增加代码的可读性差与安全危险，又与Go的简单哲学不相符

 * Go generate

  - 参考：[Golang generate 草案](http://www.kuqin.com/shuoit/20141104/343014.html)

 * Go泛型编程库：[gen](http://www.open-open.com/lib/view/open1389580392476.html)

  - gen 项目目的是为 Go 语言带来了类似泛型的函数，灵感来自 C# 的 LinQ 和 JavaScript 的 Array methods 以及 underscore 库。操作包括过滤、分组、排序等等。

## Goroutine性能陷阱

Goroutine简化了并发编程，但它并不能消除并发问题（资源竞争，原子性操作），只是把线程的调度预置到了它的Runtime中，让上层应用代码变得很少。它的坑也主要体现在它的调度不可控制上。

下面阻塞不会创建新的调度线程：
 
 * 网络IO阻塞
 * Channel阻塞
 * Sleep，同步锁阻塞
 * 基于底层系统异步调用的Syscall

下面阻塞会创建新的调度线程：

 * 磁盘IO阻塞
 * CGo方式调用C语言动态库中的调用IO或其它阻塞

这些情况下会导致线程数量爆涨，从而导致系统性能下降，而Goroutine通过go func就能产生一个Goroutine，犯错的成本低，容易被滥用。这需要开发人员熟悉Goroutine内部机制，并小心地避开这些坑。期待Go官方将来能重点解决这些问题。

参考：  
[1] [goroutine背后的系统知识](http://studygolang.com/articles/84)  
[2] [golang的goroutine是如何实现的](http://www.zhihu.com/question/20862617)  
[3] [goroutine与调度器](http://studygolang.com/articles/1855)  
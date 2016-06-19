---
title: "Mesos与K8S的区别"
date: "2015-10-20"
categories:
 - "技术"
tags:
 - "Docker"
 - "容器"
 - "k8s"
 - "mesos"
toc: true
---


![pets vs cattle](https://dn-sdkcnssl.qbox.me/editor/fWnRKkZgug2fvzeDNd8k.jpg)

最近经常有同事问道，mesos与k8s有什么不同？平时对k8s要研究多一些，对mesos仅限于一些网上的了解。前一段时间去参加阿里云栖大会，正好也有一场是由于Mosos及Mesosphere公司的人来现身说“法”，听了之后对mesos算了解更深一点吧。

## Mesos

Mesos是倾向于是IaaS层上的 __资源管理器__。Mesos不要求计算计算是物理服务器还是虚拟机，只要是Linux操作系统计算资源就可以，Mesos可以理解成一个分布式的Kernel。所以讲师强调DCOS一个OS(阿里云栖讲师的分享)，而不是一个调度器。Mesos只分配集群计算资源，不负责任务调度。基于Mesos之上可以运行不同的分布式平台，如Spark，Storm，Hadoop，Marathon，Chronos等。

Mesos中的核心是DFS，即资源管理策略 Dominant Resource Fairness。Mesos能够保证集群内的所有用户有平等的机会使用集群内的资源，这些资源包括 CPU，内存，磁盘等等。Mesos只做一件事，就是分布式集群资源分配，不管任务调度。Mesos只要你给出CPU、Memory参数就能分配资源，用于你的计算。

Mesos 是一个双层调度器。 __在第一层中__，Mesos 将一定的资源提供（以容器的形式）给对应的框架或应用程序。__在第二层中__ ，应用程序将收到的资源进一步分配给内部的任务。但是资源分配器智能化程度不同，mesos是基于resource offer的调度机制，包含非常少的调度语义，他只是简单的将资源推给各个应用程序，由应用程序选择是否接受资源，而mesos本身并不知道各个应用程序资源需求。

Mesos是Apache的开源项目，起源于UC Berkeley的一个研究项目。而背后的商业运作公司是Mesosphere，主要产品是基于Mesos构建的DCOS(datacenter operation system)。Mesos的商用程度很高，在国外的Airbnb, Apple, Uber, Twitter在使用，其中Apple的语音助手 siri是基于DCOS部署，有6000+节点。而国内有携程，爱奇艺在使用。

### Mesos与Docker

没有Dokcer之前，物理机，虚拟机都可以作为Mesos的集群节点，引入Docker之后，对资源的管理与分配粒度更细，更能提高对资源的利用率。但Mesos只负责资源的分配，对Docker的调度需要上层的调度器，而马拉松Marathon框架就是解决这个问题。当前Mesos + Marathon 基本上是现在最成熟的分布式运行框架。

## K8S

与Mesos最大的不同就是，Kubernetes(K8S)一开始设计是 __面向应用的__，而Mesos是 __面向资源的__ 。Kubernetes是应用的集群管理工具。它是构建Docker技术（也可支持其它的容器技术，如Rocket）之上，为容器化的应用提供资源调度、部署运行、服务发现、扩容缩容等整一套功能，本质上可看作是基于容器技术的mini-PaaS平台。

Kubernetes重新实现了Google在构建集群应用时积累的经验。这些概念包括如下内容：

  - Pods：一种将容器组织在一起的方法
  - Replication Controllers：一种控制容器生命周期的方法（Replication Controller确保任何时候Kubernetes集群中有指定数量的pod副本(replicas)在运行）
  - Labels：一种可以找到和查询容器的方法
  - Services：一个用于实现某一特定功能的容器组

K8S和Borg系出同门，基本是Borg的开源改进版本，吸收了包括Omega在内的容器管理器的经验和教训，label, annotaion等功能的加入让容器分类检索信息标记管理更加便捷。目的就是将Borg最精华的部分提取出来，使现在的开发者能够更简单、直接地应用。K8S是在Google内部积累发展10年的容器及集群管理专家经验基础上开源实现，有其自身的独特优势来构建容器应用部署、可伸缩可扩展，多平台兼容的容器集群管理体系。可以说，K8S的出现，也是为容器而生。

使用K8S你就能够简单并快速的启动、移植并扩展集群。在这种情况下，集群就像是类似虚拟机一样灵活的资源，它是一个逻辑运算单元。打开它，使用它，调整它的大小，然后关闭它。


### Mesos与K8S

Mesos与K8S都起源于Borg，Mesos和K8S的愿景差不多，但是它们在不同的生命周期中各有不同的优势。Mesos 虽更多的是侧重在资源管理上。而Mesos+Marathon与K8S存在竞争关系，他们在容器调度编排上有些交叉，后续如何发展，还需要看社区的走向。目前K8S是可以运行在Mesos上。

## 如何选型

 - Mesos更适合做跨DC的资源管理，对于大数据领域，大量存在短任务，可以采用Mesos+上层调度器来解决大数据的资源池化调度问题。
 - K8S更适合当应用的集群管理，它解决大规模应用部署的问题，而它的集群的热升级，动态伸缩，负载均衡，服务发现等特性可以让你的应用的更可靠。

---
title: "微服务与SOA"
date: "2015-05-16"
categories:
 - "技术"
tags:
 - "软件架构"
 - "软件开发"

---

![microservices](http://martinfowler.com/articles/microservices/images/sketch.png)

我司学习一个新的技术，往往是搞得轰轰烈烈，比如数字化转型，向互联网技术学习。其中一个非常重要的方向就是学习互联网的服务化体系架构。国内的阿里，京东，腾讯在服务化，确切地说是微服务应用取得非常大的成功。而国外的Netflix的微服务架构更是成为我们必定的样板教材。你做设计，谈方案，不说说微服务都不好意思。如果你不说这样，说明你思维落后陈旧了。任何一项技术都有一段疯狂期，虽这近一次在搞架构重构，领导遇到你，总是关心地问到：“服务化进展怎么样了”。甚至还得跟一些不太懂的领导解释什么是微服务。

10年前差不到了SOA也像今天的微服务一样火爆。那微服务与SOA的关系或区别是什么？是不是SOA的旧洒换新瓶？软件界的大牛 Martinfowler的《[微服务](http://martinfowler.com/articles/microservices.html)》更是像一部微服务的圣经，无奈是E文，大家都有各自的理解。在我司更是大家对这个各抒己见，谁都可以说上几句服务化的原则是什么，微服务成了领导专家们口里的口头禅。如果我们的系统不是微服务化，都怀疑我们系统的先进性。想当初，大家也都谈SOA，也极力推广SOA。似乎到了今天，微服务与SOA两者是势不相容。SOA是传统的IT架构，而微服务是当今互联网架构，微服务似乎比SOA更“逼格”。甚至这样的争论成了不同兄弟的心头痛。

那先来看看Martinfowler怎么说的：

>    微服务风格也与SOA所提倡的一些优势非常相似。尽管如此，问题在于SOA意味的太多[不同的东西](http://martinfowler.com/bliki/ServiceOrientedAmbiguity.html)了，因此通常时候我们谈的所谓“SOA”时，它与我们谈论的风格不一致，因为它通常是指在整体风格应用中的ESB。

从试图使用ESB隐藏复杂性，到集中治理模式抑制变更，这种面向服务的风格是复杂的，没有ESB什么都不是。互联网的发展，利用简单的协议方法，让它从这些经验传达的出来。可能说对SOA集中式标准中的一种反模式，而SOA需要用一个服务来管理你的所有的服务，你就知道这很麻烦。

> SOA的这种常见行为让微服务的提倡者拒绝打上SOA的标签，尽管有人认为微服务是从SOA中发展而来的，或许面向服务是对的。无论如何，事实上SOA表达这么多的含义，它给一个团队清醒的认识到这种构架风格就已经值的了。

至少Martinfowler在面向服务体系中，微服务是从SOA发展出来的，只是大家受到SOA的伤害而不太愿意打上SOA的标签。他们本质与出发点是相同的。微服务是细粒度的SOA，你不用去关心“庞大的”ESB，也不用去熟悉大堆的WS-\*术语。当服务变得微小（micro）时，服务可能是由规模恰当的团队（12个人）制定的，也可能是单个人制定的。

我们没有办法对微服务进行准确的定义，怎么去划分服务，什么算是微服务？两个比萨能吃饱的团队（12个人）也说得太抽象了，在面对具体的实践来说，到底怎么才是SOA中微小服务，我们又如何去分析与设计？以为团队中的成员能力来划分，学是以业务功能集来划分，再去组织团队？这些问题都是我们在实践中面对的挑战。

微服务架构中的“微”体现了其核心要素，即服务的微型化，就是每个服务微小到只需专注做好一件事。 这件事紧密围绕业务领域，形成高度内聚的自治性。

微服务架构强调“微”，与之前有些采用了SOA服务化架构思想的系统搞出很多胖服务来说，一点也不微，这依然带来耦合。 这一点只能依赖系统架构师的服务化建模能力了，但微服务架构强调每个服务一个进程， 使用进程为边界来隔离代码库至少让同一应用系统不同层次的开发人员享有自己完全自治的领地，每个微服务都有一个掌控者。

[《Building Microservices》](http://book.douban.com/subject/25881698/)一书对实施微服务架构有系统性的描述和很多业界案例的简单引用描述，这里不展开讲实施细节，那样就太长了。简单总结下实施的要点：

  - 自动化文化与环境：自动构建、自动测试、自动部署。
  - 围绕业务能力建模服务，松耦合、高内聚、暴露接口而隐藏实现细节。
  - 服务协作模型：中心化（乐队模型：中心指挥）和去中心化（舞蹈模型：群舞自组织），各自场景不同。
  - 服务交互方式：RPC/REST/WS 技术很多但考虑统一。
  - 服务部署：独立性、失败隔离性、可监控性。
  - 服务流控：降级、限流
  - 服务恢复：多考虑故障发生如何快速恢复而非如何避免发生故障。
  - 服务发布：灰度。
  - 服务部署：一服务一主机模型，需要虚拟化(Hypervisor)、容器化(LXC, Docker)等技术支持，实现硬件资源隔离。
  - 服务配置：中心化配置服务支持
  - 康威定律：任何设计系统的组织，最终产生的设计等同于组织之内、之间的沟通结构。系统架构的设计符合组织沟通结构取得的收益最大。
  - 伯斯塔尔法则：服务健壮性原则 —— 发送时要保守，接收时要开放。

> 注：部分参考 [《微服务架构实践感悟》](http://mindwind.me/blog/2015/05/14/%E5%BE%AE%E6%9C%8D%E5%8A%A1%E6%9E%B6%E6%9E%84%E5%AE%9E%E8%B7%B5%E6%84%9F%E6%82%9F.html)
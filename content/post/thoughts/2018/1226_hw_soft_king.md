---
title: "一指流沙，程序年华"
date: "2018-12-26"
categories:
 - "感想"
tags:
 - "总结"
toc: true

---

时间就像指间握不住的流沙，静静从身边溜走。

这些年来，我所从事的工作领域在变化，所使用的技术在变化，经历过一线比拼的激情，持续熬夜的艰辛，产品上线的喜悦，一直在公司从事基层研发工作。人生就像自己编写的程序，在程序化地运行着，但能在最好的年华，做自己最热爱的事，于我是一种幸福。

# 有了电脑后的“放飞”

上世纪90年代，爸爸单位用电脑记账，我觉得很是神奇，买不起电脑就买了个学习机，按照说明书，用GBASIC语言输出满屏各种形状的图形，心中被巨大的喜悦填满，开始了编程的启蒙。高考那年，又被《第一次亲密接触》中互联网的桥段吸引，毫不犹豫报了计算机专业，但遗憾被调剂到信息管理专业，这两个专业之间关系不大，我与编程失之交臂了。

大一下学期买了电脑后，我开始“放飞”自己，各种操作系统只要出新的版本，我就会重装体验，此外就是打游戏，或者“泡”论坛，渐渐发现编程的乐趣，之后就在编码的路上停不下来了。参加过学校计算机编程比赛获三等奖，和室友一起搭建系里的网站，大学毕业去了一家互联网公司做程序员，直到2005年，我有幸加入华为，一晃已经十三年了。
<!--more-->

# 因挑战才能快速成长

来到华为之后，我才发现编程之外有一个更大的世界——一套业务与体系化的技术。外部形势与内部因素持续都在变化，对业务与技能的要求变化太快，我几乎时时刻刻都面临着挑战。

2008年，我们启动了下一代智能网平台的开发，当时智能网产品刚进入欧洲市场。版本刚开发不久，质量不稳定，经常出现宕机。在项目紧急关头，开发代表找到我，让原本做消息平台的我转做话音平台。一开始我是想拒绝的，话音的信令协议我从来没接触过，而且我对产品的代码一无所知，更遑论解决问题。

抱着先做做看的想法还是同意了，不熟悉信令协议，我就把协议规范打印出来当成案头书来读，和业务的兄弟一起开发业务，定位解决问题，让我渐渐熟悉信令协议；面对宕机的问题，尤其遇到地址空间完全破坏的情况，“疯狂”学习汇编指令来提升定位问题的能力。记得当时与一位同事同住坂田市场附近，每天下班回家的路上，我们都会一起讨论今天遇到什么问题，要怎么解决，要是找到解决的办法，有时甚至兴奋得睡不着。

从宕机的泥潭中走出来后，又遇产品在欧洲比拼测试，客户明确提出了稳定性与性能测试的诉求，领导再次安排我负责性能提升的攻关。我非常担心搞不定，一是时间很紧，离客户验收只有两个多月，二是我还没有非常熟悉整个系统的代码。性能提升不仅涉及到编码细节的优化，还要梳理业务流程与模块边界问题，好在领导给了我“一双翅膀”，我带着一名测试与一名开发兄弟，开始沟通与制定测试和优化计划。在计划上，白天我们全心投入分析前一晚的测试数据与优化代码，晚上用机器持续测试稳定性；在优化实施上，采用2/8原则，先解决优先级在前20%的问题，20%的问题大都能提升80%的性能。经过一多月的努力，产品的72小时稳定性呼叫各指标表现平稳，基准流程CAPS（每秒试呼次数）从原来每块单板100+提升到1300。

做完优化之后，我立即出差欧洲参与验证。一开始我没有经验，草率地拿出自研的测试工具给了我们的测试数据，但友商的系统CAPS刚破百，客户自己的测试工具最高也只能到200多，严谨的客户怀疑数据的真实性。我对我们的数据很有信心，于是尝试和客户沟通，对接实验室核心网设备，客户的测试工具以及我们的自研测试工具，一起呼叫测试。在长时间的稳定性测试过程中，即使增加到130%呼叫量的压力测试，我们的产品表现一直稳定如初。我还记得，验证完成的那个下午，客户当场对我们竖起了大拇指。在团队共同的努力下，华为最终拿下TLF三国子网的合同，这也是我们软件业务第一次交付欧洲客户。

努力与付出赢得了信任，让我有更多的机会去接触新的挑战，有了更多的成长机会。后来产品在欧洲大T不断地比拼测试和交付，都有我的参与。在VDF，与友商的核心网对接，发现我们系统的SIP协议连接转换功能缺失，一周内我疯狂写代码，成功对接上并调通业务流程。在DT，在一个月时间内独自完成了版本从Linux到PC的版本轻量化移植，解决客户在PC上一站式业务开发与调测诉求，获得客户认可……

# 越努力，越从容

2011年我们启动了新的虚拟化、云化支撑平台项目，曾经一起共事的领导点名让我参加新项目。改变对我来说，从来都不是事儿，这一次我还是选择了继续挑战自己。但转变也带给了我可能无法胜任工作的危机感，这让我从来不敢放松自己，而唯一能缓解危机感的方法就是增强应对实际困难的知识与技能。

从无到有构建项目中多个模块，开发基础框架来考虑提升团队开发效率，帮助大家解决很多技术问题，慢慢地团队内有人开始称我为“大侠”。但在我看来，做一个“大侠”，不仅仅是大家认为的“能力强，效率高”，那充其量只是个人贡献，更重要的是能带动团队成员一起成长。无论身处什么岗位，我都会在团队内积极总结和分享。迄今为止，我在Hi3MS上分享了180多篇技术博文，整理过三十页编码最佳实践来指导团队开发。这一过程可以督促我不断完善想法，加深认识，而且也可以传承知识，这可能远甚于写代码本身。

除了自我学习总结，面对层出不穷的知识，做技术的人更不可闭门造车，盲目自信，而是要多从业界“喝咖啡”吸收宇宙能量。2012年，我们基于开源CMDB（配置管理数据库）构建了网络拓扑服务，能端到端开通业务虚拟机组网下的网络配置，成功应用在某局点；2013年，我们研究TOSCA (云应用拓扑编排）规范，把它引入标准化图形化拓扑编排，简化了编排模型……

成功不是未来前进的可靠向导，对软件来说亦然，曾经优秀的技术也可能成为架构演进的绊脚石。2014年以前，我们的开发框架是OSGi，它的模块化，面向接口编程模式曾为我们带来开发便利。我一度很喜爱，但是由于它生态式微，越来越多的第三方组件不再支持，我们使用成本越来越高，反倒成了历史技术债务，团队内也因此多次争论它的去留。2015年初我作为负责人，带队渐进式地引入微服务框架替换了OSGi，提升了团队并行开发效率。

软件设计是一个不断打磨不断完善的过程，技术的提升更多需要亲身的实践。我做方案设计时，都会参与框架与核心代码的编写，也只有深入其中，才会知道其中的关键点，才能更好地解决问题。从2014年开始，我设计并编写了项目中调度控制部件的任务编排框架的代码，从支撑某局点业务的一百多虚拟机节点并发，优化到上千虚拟机节点并发……

多一份努力，就多一分收获。就这样在点点滴滴实战中，一路坚持下来，像玩游戏打怪升级技术点一样，我积累了非常多的技术经验，不管是面对技术方案还是技术实现，都多了一些从容。

# 诚于己，心得其宜

除了日常工作，我算得上是一个编程语言控了。写过种菜游戏的自动偷菜外挂，刷过手机多个版本，帮老婆微商写过小微记账App，可同时支持安卓与iOS……即使现在，每种语言流行时，我下班回到家只要有时间都会“练手”，关注其生态框架，还涉猎过Typescript、Go、 Rust、Scala，虽谈不上样样精通，但每每有新项目涉及到新语言与框架的应用，对我来说都不是一件太难的事。

我们就像一粒粒种子，因为有着对外面世界的好奇，才能从土壤中探出头来，亲眼见证这个美好的世界。这也是我坚持走技术路线的内在驱动力，是我在成长中能不断适应变化的关键所在。

如今我大学毕业十多年了，以前同学聚会被问得最多的问题是“你还在华为啊？”“还在写代码啊？”，现在大家已经不问了，因为他们知道我足够热爱，不会轻易放弃。

从2016年到2018年初，软件组织结构经历了多次调整。看着身边的同事，曾经带过的徒弟奔赴到新岗位，说实话，内心彷徨过。自己的转身在哪里？自己的追求是什么？要不要去新的领域开始新的挑战？我和很多留在软件的兄弟聊天，我们一致认为，软件一直存在新技术新业务的土壤，也曾是创新的推手。对于喜欢钻研技术的我们而言，组织的调整对我们影响不大，经过这次的变革，大家更加务实，我们有更多的时间来编写热爱的代码。能在一个环境中安心做自己喜欢的事，诚于己，心得其宜，这就是我的情怀。

软件需要传承，也需要积累。今天万物互联与人工智能已至，软件新的机会窗口已打开。去年末，我有幸和同事按需构建部分公共服务能力，开始支撑业务SaaS化探索。现在我又有幸开始参与构建一些智能运营数据分析的技术储备。在产业互联网这一条新的赛道上，虽然我们是后来的学习者，但我们为客户解决业务问题的能力从来不缺。能力源于专业的技术积累，核心竞争力源于关键技术突破，新的赛道上也就不缺技术人员的用武之地。

不记得自己何时把“一指流沙，程序年华”作为eSpace签名，当写下这句话时，我清楚地知道，我将会在技术这条路上坚定而持续地走下去。感谢公司为我提供了广阔的平台，但我还远远不够优秀，需要不断学习与提升。软件开发从来没有标准可以遵循，过程与结果充满不确定性，现在的产品也没有引领世界，我们还须继续努力。始于初心，保持好奇心，坚定恒心，我相信方向已越来越清晰，在前进的道路上，摆正自己的心态，我将继续为软件业务贡献微薄之力。

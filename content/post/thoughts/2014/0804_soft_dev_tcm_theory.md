---
title: "软件开发与中医理论"
date: "2014-08-04"
categories:
 - "感想"
tags:
 - "软件开发"

---


最近一段时间，看了些的版本迭代开发数据。有CI中QDI，FindBugs，重复率，复杂圈度；也有迭代的Story实现率，IR分解率，DI值;也有测试用例，覆盖率，执行时长，入门用例比等。反正各种度量数据多得是，从各个方面来反馈项目的质量。俗话说：有人的地方就有江湖。有江湖的地方就有纷争。有度量数据就有晒马排名，有排名的地方就有政治任务。我们的流程辅助度量工具多了，但这些真能带动我们的质量上去了吗？

小儿已一岁多，现在回顾他做的一些体检。前三个月每月一次体检，一岁之前每3个月一次，一岁之后是每6个月一次。体检的项目有称体重、量身高、量头围、量胸围、验视力、测听力、检查动作发育、口腔检查、评价智能发育、验血、骨骼检查、心肺与心率检查、大便和血红蛋白。体检医生一上来就是开各个体检单，采用是西医的方式，看指标数据，再评测，体检应该是医院最好的生财路之一。个人也明白，正如我妈说的，我小时候哪有什么体检，也不是好好的吗？现在带小孩去体检，也是图个安心，提早预防。

那说这些跟软件开发有什么关系？西医是基于实验科学，从实验走向临床，再到应用，它关注对外界变化的认知，比如发现了细菌，就有了抗生素；发现了病毒，就有了疫苗；发明了人工心脏，就可以做植入心脏。西医的研究对象是外界。__强调对症下药，看的是病__。而中医以阴阳五行为基础，将人体看到气，形，神的统一。聚焦于人本身，就是人的经络，阴阳，五行等。通过中药、针灸、推拿、按摩、食疗、拔罐等多种手段来达到人体的阴阳调和而康复。__强调调和平衡，看的是人__。西医通过相同的病因数据，药物使用可能复制到不同的人。而中医需要通过医生的非常经验，开出不同的药方。所以年纪越老的中医越是历害。

现在的软件工程，也似乎像西医一样，试图通过固化流程，工程手段，指标数据来统一所有项目的开发。典型的是CMM，它关注项目本身，往往忽略了项目中的人。一个C版本三个月，我们个人并没有在这短短的三个月里边发生什么实质性的变化。一个本来连计划变更都要审批，还要被QA严格审计的受控团队，有时又变成一个居然可以什么都自己估算，和中途临时领取需求任务的自组织的团队，不可不谓一个相当疯狂的举动。最后项目管控就看是各种指标数据，个中变化指标能看到什么呢？即使各种指标细化，能真实的反应项目的实情吗，这要大大地打个问号了。也有人会说，数据好的项目并不一定好，但数据差的项目一定是不好。好吧，我认这一条。

外界的敏捷开发，应该是强调项目中人的本身吧，快速适合各种变化。管理以人为本，时刻进行相应的调整，尽可能地发挥个体的能力。一个被各种指标数据盯着的团队能放下这些，快速适合变化，快速响应客户的需求吗？软件的开发过程也不可能固定不变，因人而异，因项目而异，一两种软件工程学能搞定所有的项目吗？
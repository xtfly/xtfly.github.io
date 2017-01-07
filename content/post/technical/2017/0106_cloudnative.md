---
title: "CloudNative初探"
date: "2017-01-06"
categories:
 - "技术"
tags:
 - "Cloud"
 - "容器"
 - "软件架构"
toc: true
---

随着日益普及的云计算，越来越多的传统应用迁移到云上。尤其是视频巨头NetFlix从2009年开始，放弃构建自己的数据中心，把所有应用迁移到AWS。NetFlix认为云环境下，everything will be failure。它基于微服务架构，以及Design for failure理论，构建出一系统非常成功的云应用（微服务），支持它的业务飞速发展。NetFlix认为他们比Amazon自己更懂得AWS。同时业界也提出了CloudNative概念，Netflix的应用也认为目前最为成功的CloudNative应用（参考[Cloud Native at Netflix](http://www.slideshare.net/adrianco/netflix-what-changed-gartner-catalyst)）。那什么是CloudNative？

## 概念

目前对CloudNative并没有明确的定义。15年，Google联合其他20家公司宣布成立了开源组织Cloud Native Computing Foundation（CNCF）。想通过开源的Kubernetes，在云计算领域占据主层地位。当然Kubernetes目前是一个以应用为中心容器编排，调度集群管理系统。它想做的是CloudNative Application的基石。从CNCF组织来看，CloudNative Application应该包含微服务，容器，CI/CD特征。
 
早在2010年，WSO2的联合他始人Paul Fremantle在业界最早提出[CloudNative，认为有如下几个关键特征](http://wso2.com/library/articles/2010/05/blog-post-cloud-native/)：
<!--more-->

 - Distributed/Dynamically wired，分布式/动态连接
 - Elastic，弹性；Scale down as well as up, based on load，基于系统负载的动态伸缩
 - Granularly metered and billed，粒度合适的计量计费；Pay per user，按使用量计费
 - Multi-tenant，多租户
 - Self service，自服务
 - Incrementally deployed and tested， 增量的部署与测试

CloudNative系统的效果： Better utilization of resources, faster provisioning, better governace。

在2013年，AWS的云战略架构师同时也是NetFlix的云架构师Adrian Cockcroft提出对[CloudNative新的定义](https://www.infoq.com/presentations/migration-cloud-microservices)：基于不可靠的，易失效的基础设施(ephermeral and assumed broken components), 构建高度敏捷（high agile），高可用（highly available）的服务，包括如下几个方面：

 - 目标：Scalability，伸缩性；Availablility，可用性；Agile，敏捷；Efficiency，效率
 - 原则：Separation of Concerns，关注点分离；Anti-Fragility，反脆弱性；High trust organization，高度信任的组织
 - 特点：Public Cloud，基于公有云； Mirco-services，微服务；De-normalized data，反范式化数据；Chaos Engines，混沌引擎；Continues Deployment，持续部署；DevOps等等

在2015年，Pivotal的产品经理Matt Stine又对[CloudNative关键架构特征](http://www.infoq.com/cn/articles/cloud-native-architectures-matt-stine)进行补充：

 - [Twelve Factor App](https://12factor.net/)，十二因子应用
 - Mirco-services，微服务
 - Self Service Agile Infrastructure，自服务敏捷的基础设施
 - API Based Clolaboration， 基于API的协作
 - Anti-Fragility，反脆弱性

## 总结

总结起来，要实施CloudNative，包括三个维度：

 - 软件架构：基于敏捷基础设施，是整个Cloud Native的根基；基于微服务架构，微服务架构是Cloud Native的一个核心要素；基于Design for failure理论，构建高可用的系统；基于容器部署，确保环境一致性，应用快速启动终止，水平扩展。
 - 组织变革：根据康威定律，如果要达到比较理想的云化效果，必须进行组织变革。一个合理的组织架构，将会极大提高云化的推行；推行DevOps文化，倡导开放、合作的组织文化。
 - 软件工程：推行持续集成与持续交付，联合开发、质量、运维各个环节，打通代码，编译，检查，打包，上线，发布各个环节。全自动化，包括自动化部署，升级，灰度，以及运维。

CloudNative背后的软件架构需求：
  
 - 按需特性的伸缩
 - 按特性持续演进
 - 应用快速上线
 - 系统的高用性
 - 全面解耦合
 - 系统自服务
 - 支持多租户
 - 异构公有云

---------
参考：   
1. http://wso2.com/library/articles/2010/05/blog-post-cloud-native  
2. https://www.infoq.com/presentations/migration-cloud-microservices  
3. http://www.infoq.com/cn/articles/cloud-native-architectures-matt-stine  
4. [一篇文章带你了解Cloud Native](http://www.open-open.com/lib/view/open1447420363069.html)  
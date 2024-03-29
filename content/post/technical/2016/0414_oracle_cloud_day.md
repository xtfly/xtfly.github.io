---
title: "Oracle Cloud Day见闻简纪"
date: "2016-04-14"
categories:
 - "技术"
tags:
 - "Oracle"
 - "Cloud"

---

今天有幸参加Oracle举办的cloud day。Oracle从开始对云计算不敏感，到后来的大力投入，并购与产品整合，目前Oracle在云计算领域已涵盖IaaS，PaaS，SaaS。Oracle正借助于云计算，把帮助企业把传统的应用产品搬迁到云计算上。Oracle应用产品发发展战略三个核心阶段：

 * 无极限的应用产品支持：对所有目前使用Oracle OP部署方式的应用产品客户提供持续支持。
 * 下一代“云”应用产品的开发以及战略并购：基于统一标准的PaaS平台，并购整合并开发下一代的，最优的基于云的产品。
 * 切实可行的”云”之路：为客户提供各种服务和商务方案使客户以最小的投资风险采用Oracle云服务。

从上也可以看出Oracle在云计算野心，它虽相对起步晚，但它由于在传统IT领域的优势，通过整合基础设施，平台与中间件，以及社交资源，是在云计算领域内少数几个能针对企业各种业务提供一套完整的解决方案，涵盖如下领域：
<!--more-->

  * 客户关系管理：销售管理（Sales），市场管理（Marketing），服务管理（Service），电子商务（Commerce），社交媒体（Social）
  * 供应链管理：产品创意与研发，供应认证与寻源，采购管理，物流管理，销售管理，计划管理，生产管理
  * 财务及人力资源：财务管理，差旅报销，财务报告与分析，见血预算管理，项目管理，人力资源管理

Oracle的云应用具有如下特点：

  * 完整：一个云平台支持所有业务动作
  * 一流：基于Oracle在企业领域的最佳实践
  * 现代：数据驱动的业务执行与管理；
  * 个性：个性化的“云”应用体验，提供SaaS（来ERP，HCM）来定制用户体验，提供PaaS来丰富与创建新的应用
  * 集成：提供iPaas与集成能力来连接与协作已有资产
  * 安全：大使级的安全性和兼容，支持传统的多租户的安全数据隔离，以及SaaS的便利

今天的cloud day也是从上述几个方面的展开的，我感兴趣的是他们的PaaS平台。确切地说，Oracle的PaaS是一个较泛的统称，今天主要介始的包括如下：

  * 应用开发云：提供代码配置库（git/svn）集成，支持直接从github同步代码，基于Maven等代码构建能力，有限地支持DevOps。
  * 应用部署云：提供企业级的Java云服务，它是基于Weblogic的Java应用，每个WebLogic部署在一个虚拟机内。也提供支持其它JEE的应用环境，如scala, groovy, jypthon, jruby, 它们基于Docker容器部署。也支持对Node应用的部署。
  * 数据库云：提供Oracle 11g与12c的数据库服务。
  * 集成云：集成平台即服务(iPassS)，其中包括了Oracle集成云服务(ICS)、Oracle SOA云服务以及Oracle Cloud中的Oracle SOA套件与Oracle API Manager Cloud Service。
  * 内容和协作云平台：个人感觉是就支持审批流程管理的文档管理云平台，像云盘一个共享文档，基于流程编排来文档审批。
  * 移动云：提供统一的App开发MAF，针对多种平台，只需编写一个应用，可以运行在iOS、Android，支持本地或混合开发。

一天下来，感觉Oracle的垂直整合能力太强了，即使在PaaS领域，你也要什么，它就能给你什么。相比与我司的企业BG，在企业云整合能力与之相差太远了，不知要追赶多少年。可见预见，未来在云计算领域，公有云的领导者是AWS，私有云的领导者或许就是Oracle。IBM呢？Pure System与BlueMix在Oracle面前，感觉有点小打小闹了。

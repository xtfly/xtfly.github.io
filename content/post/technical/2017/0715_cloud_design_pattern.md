---
title: "云设计模式"
date: "2017-07-15"
categories:
 - "技术"
 - "笔记"
tags:
 - "cloud"
 - "软件架构"
toc: true
---

![](/images/y17/azure.jpg)

在云环境下，如何构建出可靠，弹性，安全的应用？有哪些挑战？面对这些挑战如何解决，微软Azure总结一系列的设计模式。本文是翻译[Azure架构中心](https://docs.microsoft.com/en-us/azure/architecture/)在线资料中的[云设计模式](https://docs.microsoft.com/en-us/azure/architecture/patterns/)，仅个人的笔记，借翻译学习一下，英文好的可以直接阅读原文。

## 挑战

### 可用性

可用性是指系统功能可用的时间占整体的比例，通常以正常运行时间比来衡量，它会受到系统错误、基础设施问题、恶意攻击和系统负载的影响。云应用典型为用户提供提供服务级协议（SLA），因此必须设计应用以最大限度地可用性。
<!--more-->

### 数据管理

数据管理是云应用的关键要素，影响着大多数质量属性。由于性能、可伸缩性或可用性等原因，数据通常被存放在不同的位置和跨多个服务器上，这可能会带来一系列的挑战。例如，必须保持数据一致性，并且数据通常需要跨不同的位置同步。
   
### 设计与实施
   
好的设计包括组件设计和部署的一致性和关联性、可简化管理和开发的可维护性，以及允许组件和子系统在其他应用和其他场景中的可重用性等因素。在设计和实施阶段作出的决定，对云托管应用和服务的质量和总成本产生巨大影响。

### 消息

云应用的分布式属性需要一个消息交互基础设施，它将组件和服务连接起来，最好是以松耦合的方式，以最大限度地提高可伸缩性。异步消息的广泛使用，并提供了许多好处，但也带来了挑战，如消息的时序，消息的回环、幂等性等
 
### 管理与监控

云应用运行在远程数据中心中，在那里你不能完全控制基础设施，有时也无法控制操作系统。这会使管理和监控比私有部署环境下更加困难。应用必须暴露出管理员和运维员可以使用管理和监控系统运行信息，以及支持在不断变化的业务需求和定制下，而不需要停止或重新部署应用。
 
### 性能与扩展性

性能是指一个系统在给定的时间间隔内执行任何操作的响应指标，而可伸缩性是系统处理负载增加而不影响性能或所用资源容易地增加的能力。云应用通常会遇到不同的工作负载和活动高峰。预测这些，尤其是在多租户场景中，几乎是不可能的。相反，应用应该能够在限定范围内扩展，以满足需求高峰，并在需求减少时规模扩大。可伸缩性不仅涉及计算实例，还涉及其他元素，如数据存储、消息传递基础设施等等。

### 可靠性

可靠性是一个系统优雅地处理和从失败中恢复的能力。云托管的本质是，应用通常是多租户，使用共享平台服务，争夺资源和带宽，通过互联网进行通信，并在通用硬件上运行，这意味着出现瞬态故障和永久故障的可能性增加。检测故障并快速有效地恢复是保持可靠性的必要条件。

### 安全

安全性是系统在设计使用之外防止恶意或意外行为的能力，以及防止信息泄露或丢失的能力。云应用在互联网上暴露在可信的私有区域之外，通常向公众开放，并且可能服务于不可信的用户。应用必须设计和部署，以保护它们免受恶意攻击，限制对只有已允许的用户访问，并保护敏感数据。

## 设计模式

|模式|摘要|
|:--|:--|
|[Ambassador](https://docs.microsoft.com/en-us/azure/architecture/patterns/ambassador)|创建帮助服务，代表消费者服务或应用发送网络请求。|
|[Anti-Corruption Layer](https://docs.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer)|在现代应用和遗留系统之间实现个门面或适配层。|
|[Backends for Frontends](https://docs.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends)|创建隔离的后端服务，提供接口给特定的前端应用使用。|
|[Bulkhead](https://docs.microsoft.com/en-us/azure/architecture/patterns/bulkhead)|将应用的元素隔离到池中，以便当一个失败时，其他元素将继续发挥作用。|
|[Cache-Aside](https://docs.microsoft.com/en-us/azure/architecture/patterns/cache-aside)|将数据数从据存储中按需加载到缓存中。|
|[Circuit Breaker](https://docs.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker)|当是连接远程服务或资源时，修复错误可能需要花费可变的时间。（注：直译不好理解，指发生错误时像电源断路器一样断开访问远程服务或资源）|
|[CQRS](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)|更新数据的操作与读取数据的操作的接口隔离。|
|[Compensating Transaction](https://docs.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction)|撤消由一系列步骤执行，这些步骤一起达到一个最终一致的操作结果。|
|[Competing Consumers](https://docs.microsoft.com/en-us/azure/architecture/patterns/competing-consumers)|允许多个并发消费者在同一通道上接收处理消息。|
|[Compute Resource Consolidation](https://docs.microsoft.com/en-us/azure/architecture/patterns/compute-resource-consolidation)|将多个任务或操作合并到单个计算单元中。|
|[Event Sourcing](https://docs.microsoft.com/en-us/azure/architecture/patterns/event-sourcing)|使用额外的只可追加的存储来记录域中数据所有的操作事件。|
|[External Configuration Store](https://docs.microsoft.com/en-us/azure/architecture/patterns/external-configuration-store)|将配置信息从应用部署包中移到一个集中位置。|
|[Federated Identity](https://docs.microsoft.com/en-us/azure/architecture/patterns/federated-identity)|将身份验证委托给外部身份提供者。|
|[Gatekeeper](https://docs.microsoft.com/en-us/azure/architecture/patterns/gatekeeper)|在客户端与应用或服务之间，采用专用的主机实例作为代理，以保护应用或服务，代理在他们之间验证和审查请求，并传递请求和数据。|
|[Gateway Aggregation](https://docs.microsoft.com/en-us/azure/architecture/patterns/gateway-aggregation)|使用网关把多个独立请求合并一个请求。|
|[Gateway Offloading](https://docs.microsoft.com/en-us/azure/architecture/patterns/gateway-offloading)|分担共享与特定服务到网关代理。|
|[Gateway Routing](https://docs.microsoft.com/en-us/azure/architecture/patterns/gateway-routing)|使用同一端点路由请求到多个服务实例。|
|[Health Endpoint Monitoring](https://docs.microsoft.com/en-us/azure/architecture/patterns/health-endpoint-monitoring)|在外部工具可以定期通过暴露的端点检查应用中实现功能是否健康。|
|[Index Table](https://docs.microsoft.com/en-us/azure/architecture/patterns/index-table)|给频繁查询的数据字段创建索引。|
|[Leader Election](https://docs.microsoft.com/en-us/azure/architecture/patterns/leader-election)|在分布式应用中，一组协作的任务实例执行时，由Leader协同执行。Leader是通过选举一个实例来负责管理其它的实例。|
|[Materialized View](https://docs.microsoft.com/en-us/azure/architecture/patterns/materialized-view)|在一个或多个数据存储，当数据不理想数据格式查询时，生成预先设置好视图。|
|[Pipes and Filters](https://docs.microsoft.com/en-us/azure/architecture/patterns/pipes-and-filters)|将执行复杂处理的任务分解成一系列可重用的独立元素。|
|[Priority Queue](https://docs.microsoft.com/en-us/azure/architecture/patterns/priority-queue)|优先级高的请求发送给服务，较高优先级的请求比那些优先级较低的请求更快地接收和处理。|
|[Queue-Based Load Leveling](https://docs.microsoft.com/en-us/azure/architecture/patterns/queue-based-load-leveling)|使用一个队列作为一个任务和它调用的服务之间的缓冲区，以平滑间歇性的重载.|
|[Retry](https://docs.microsoft.com/en-us/azure/architecture/patterns/retry)|当它试图连接到一个服务或网络资源时，使应用能够处理预期的，暂时的失败，并透明地重试。|
|[Scheduler Agent Supervisor](https://docs.microsoft.com/en-us/azure/architecture/patterns/scheduler-agent-supervisor)|协调跨分布式服务集和其他远程资源的一组操作。|
|[Sharding](https://docs.microsoft.com/en-us/azure/architecture/patterns/sharding)|将数据存储水平分区或分片。|
|[Sidecar](https://docs.microsoft.com/en-us/azure/architecture/patterns/sidecar)|将应用的组件部署到一个单独的进程或容器中，以提供隔离和封装.|
|[Static Content Hosting](https://docs.microsoft.com/en-us/azure/architecture/patterns/static-content-hosting)|将静态内容部署到基于云的存储服务，该服务可以直接将它们提供给客户端。|
|[Strangler](https://docs.microsoft.com/en-us/azure/architecture/patterns/strangler)|通过新的应用和服务逐步替换特定的功能块，来逐步迁移遗留系统。|
|[Throttling](https://docs.microsoft.com/en-us/azure/architecture/patterns/throttling)|控制应用实例、单个租户或整个服务所使用的资源的消耗。|
|[Valet Key](https://docs.microsoft.com/en-us/azure/architecture/patterns/valet-key)|使用令牌或密钥，为客户提供对特定资源或服务的受限直接访问。|
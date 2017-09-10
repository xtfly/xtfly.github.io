---
title: "开源DNS Server"
date: "2017-09-10"
categories:
 - "技术"
 - "笔记"
tags:
 - "DNS"
toc: true
---

![](/images/y17/dns.jpg)

DNS是互联网的基础设备，开源的DNS也有不少，下面列出主要的主种几种供参考：

## Bind9

ISC（Internet System Consortium）的Bind一直以来基本上都是DNS的工业标准，Bind应该是目前世界上使用最为广泛的DNS服务器了。Bind起源于1980年的Berkeley大学，比起我的年龄还大，Bind的名称也是源自`Berkeley Internet Name Domain`。不过Bind也是一直漏洞不断，Bind9是ISC开发人员对Bind重写，目前常见的Linux发行版本中，会自带Bind9的安装包。

Bind9可以作为权威与递归DNS。主要特性如下：

作为权威DNS时：
<!--more-->

 - Response Rate Limiting (RRL)：对DNS增强，以减少放大攻击
 - Dynamically-Loadable Zones (DLZ)：支持从外部数据库获取Zone数据，但不建议使用在高性的权威DNS。
 - Minimum Re-load Time：支持配置文件动态加载。
 - HSM Support：支持通过原生的 PKCS#11接口或OpenSSL PKCS#11的接口的HSM（ Hardware Security Modules）。
 - DNSSEC with In-line Signing：支持NSEC与NSEC3的安全协议的签名。
 - Catalog Zones：支持多Zone的目录管理。
 - Scalable Master/Slave Hierarchy：支持Master+多Slave组网，Slave从Master同步Zone配置。

 作为递归DNS时：

 - NXDOMAIN Redirect：当查询一个不存在域名时，转向一个Web页面，它依赖于DLZ特征。
 - Flexible Cache Controls：对于不正确或过期的域名记录，灵活的缓存控制。
 - Split DNS：通过配置不同的View，来保护部分私有信息。
 - Optimum Cache Hit Rate：通过 DNS pre-fetch 技术来优化缓存命中率。
 - Resolver rate-limiting：在受攻击下，对权威DNS查询限速，减轻对路径解析器的DDoS攻击影响。
 - DNSSEC Validation：支持对DNSSEC的检验。
 - GeoIP：支持基于来源不同的递归DNS的请求给出不同的响应。
 - Response Policy Zone（RPZ）：通过响应策略的Zone来减少对被认为是滥用或非法目的Zone的访问。

双License：ISC 与Mozilla Public 2.0。

开发语言：C。

官方网站：https://www.isc.org/

## PowerDNS

PownerDNS发起于1999年，也是一个老牌的开源DNS了。它可以作为权威（最新版本3.4.11）与递归DNS（最新版本3.7.4）。2011年07月23日，PowerDNS 3.0 正式版发布，主要特性如下：

 - 完全支持 DNSSEC ，包括自动签名、rollovers 和密钥维护
 - TSIG，兼容 MyDNS 的后端
 - 基于 IPv6 的主从结构，并行从节点引擎，MongoDB 支持和 Lua 的区域编辑

欧洲30%+的域名采用PownerDNS，以及全世界75%+的DNSSEC应用。

作为权威DNS时：

 - Standards compliant serving of DNS information from all relevant databases
  - Text files, dynamic scripts in various languages
  - Native support for legacy BIND zonefiles
 - Leading DNSSEC implementation 
  - worldwide, hosting >75% of all DNSSEC domains
 - Powerful dynamic abilities
  - Geographical load balancing
  - Content redirection, 'best answer' generation
 - Supported on generic hardware running generic operating systems

作为递归DNS时：
 
 - Standards compliant resolution of domain names
  - Strive for maximum resolution percentage
  - or conversely, least customer complaints
 - Powerful dynamic abilities
  - Content redirection
  - 'best answer' generation
  - query & answer modification
  - Filtering
 - Supported on generic hardware running generic operating systems

提供相关的工具：

 - dnsscope: query/answer latency time statistics
 - dnsreplay: replay existing traffic against reference nameservers 
 - dnsgram: per-time period sampling of traffic to determine overloads
 - dnswash: anonimize PCAP traces, hiding IP addresses, for third party analysis

支持API，承载在（Local socket，"raw" TCP/IP，RESTful API direct，）

 - Statistics
 - Provisioning
 - Zone editing
 - Master/slave operations
 - Log-file investigations
 - Configuration (updates)
 - Stop/Start/Upgrade/Restart

License：GPL 2.0。

开发语言：C++，扩展：Lua。

官方网站：https://www.powerdns.com/

## CoreDNS

CoreDNS去年8月份发起新的开源项目，目前已纳入开源基金会CNCF（Cloud Native Computing Foundation，云端原生计算基金会），它归属于Linux基金会。

CoreDNS的前身是SkyDNS，它的主要目的是构建一个快速灵活的DNS服务器，让用户可以通过不同方式访问和使用DNS内的数据。它被设计为Caddy网络服务的一个服务器插件。CoreDNS的每个特性都可以被实现为可插拔的中间件，如，日志、基于文件的DNS以及多种后端技术，进而可以拼接多个插件来创建定制化的管道。CoreDNS已经得到扩展，可以直接被Kubernetes访问服务数据，并以KubeDNS的形式提供给用户使用。

CoreDNS同样可以权威与递归DNS，目前官方的中间件已有31个：

 - bind: Serve zone data from a file; both DNSSEC (NSEC only) and DNS are supported (file).
 - dnssec: Sign zone data on-the-fly
 - cache: Caching
 - etcd: Use etcd as a backend, i.e., a 101.5% replacement for SkyDNS 
 - kubernetes: Use k8s (kubernetes) as a backend 
 - proxy: Serve as a proxy to forward queries to some other (recursive) nameserver  
 - loadbalance:Load balancing of responses
 - rewrite: Rewrite queries (qtype, qclass and qname)
 - ...

License： Apache-2.0。

开发语言：GO。

官方网站：https://coredns.io/

## 其它

### DNSPod-SR

dnspod-sr是中国最大域名解析服务商DNSPod官方于2012年6月1日开源的一款递归DNS服务器软件。

主要特性：

 - CNAME解析加速
 - A记录组包缓存
 - 请求转发功能
 - 缓存刷新功能
 - HASH表缓存

License：BSD。

开发语言：C。
 
官方网站：https://github.com/DNSPod/dnspod-sr

### Dnsmasq

DNSmasq是一个小巧且方便地用于配置DNS和DHCP的工具，适用于小型网络，它提供了DNS功能和可选择的DHCP功能。

作为域名解析服务器(DNS)，dnsmasq可以通过缓存 DNS 请求来提高对访问过的网址的连接速度。

License： GPL-2.0。

开发语言：C。

官方网站：http://www.thekelleys.org.uk/dnsmasq/

### Atomia DNS

Atomia DNS是一个多租户DNS**管理系统**，通过编程接口处理大量的DNS数据。Atomia DNS支持对PowerDNS和BIND-DLZ DNS服务器的代理，PowerDNS是默认代理选项。

主要特性：

 - 支持DNSSEC
 - 完整，易于使用的API

Atomia DNS License：ISC。

开发语言：PHP。
 
官方网站：http://atomiadns.com/

### SmartDNS

smartdns是python语言编写，基于twisted框架实现的dns server，能够支持针对不同的dns请求根据配置返回不同的解析结果。smartdns获取dns请求的源IP或者客户端IP（支持edns协议的请求可以获取客户端IP），根据本地的静态IP库获取请求IP的特性，包括所在的国家、省份、城市、ISP等，然后根据我们的调度配置返回解析结果。

smartdns的使用场景：

1. 服务的多机房流量调度，比如电信流量调度到电信机房、联通流量调度到联通机房；
2. 用户访问控制，将用户调度到离用户最近或者链路质量最好的节点上。

主要特性：

 - 支持A、SOA、NS记录的查询
 - 支持DNS forward功能
 
License：未注名

开发语言：Python。

官方网站：https://github.com/xiaomi-sa/smartdns

## 总结

Bind9是最为成熟的DNS Server，代表了DNS的标准，它特性丰富，License友好，使用者众多，是作为权威与递归DNS的首先，缺点是扩展性一般（相对于CoreDNS），安全漏洞相对比较多（也说明使用者多，被研究与攻击多）。

CoreDNS是开源DNS Server的新星，它的架构优秀，扩展性非常好，是非常有前途的DNS；又在Linux基金会下，有Google带头大哥，主创人员为安全公司Infoblox，所谓是背影深厚。但由于项目时间太短，使用未经大规模考验，待它成熟之后，不排除它可能代替Bind9，成为互联网的基础设施。

PowerDNS它有成熟的管理控制系统，相比于Bind9，它提供基于REST API以及基于Lua脚本的扩展能力。但它的License商用不友好。在商用产品中集成或使用它要注意边界，避免使整个产品开源。

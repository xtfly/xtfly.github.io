---
title: "Taipei-Torrent源码分析"
date: "2016-01-17"
categories:
 - "技术"
tags:
 - "Torrent"
 - "Go"
 - "P2P"

---

提到P2P，总会少不了BitTorrent。BitTorrent是一种P2P协议。BitTorrent协议是由程序员Bram Cohen在2001年四月份设计的，最终版本在2008年确定。

#### BitTorrent协议简介

一个BitTorrent的文件在网络传输过程，由以下几个部分组成：

 * WEB服务器
 * 文件元信息(metainfo)
 * BitTorrent Tracker
 * 原始资源发布者
 * 目的端用户浏览器
 * 目的端用户下载者

其中原始资源发布者与目的端下载者都称为Peer，而Tracker主要用于获取不同的Peer信息信息，BitTorrent把要下载文件虚拟分成大小相等的块，并把每块的索引信息与Hash验证码等元数据信息写到一个.torrent文件中，即种子文件。种子文件采用B编码格式，它本质是一个文本。Peer与Tacker或DHT节点通讯也采用B编码格式。根据获取Peer信息的途径不同，又分为两种。

  * 有的Tracker结构

```
		[WebServer]
		  |
		  | torrent file
		  |
	 [  Peer ] ---Get Peers --- [TrackerServer]
	     \
	      \
	      Download&Upload(TCP)
	       \
	        \
	       [ OtherPeer ]
```
  * Trackerless的DHT结构

```
		[WebServer]
		  |
		  | torrent file
		  |
	 [  Peer ] ---Get Peers --- [DHT Nodes]
	     \
	      \
	      Download&Upload(TCP)
	       \
	        \
	       [ OtherPeer ]
```

Trackerless的DHT结构解决了Trakcer中心故障的问题，是一个更去中化的结构。DHT结构中，每个peer都可能是一个tracker。DHT是基于Kademila协议的，并且在UDP协议基础上实现。

每个节点都有一个全局唯一的标识符，称为节点ID。距离度量用来比较两个节点或者节点与infohash之间的远近程度。节点必须维护一个含有少量其他节点联系信息的路由表。ID越靠近自身ID时，路由表越详细。节点知道很多离它很近的节点，只知道少量离它很远地节点。

在Kademlia中，距离度量采用异或计算，结果解释成一个无符号整数。 distance (A,B)=(A ~| B)，值越小，距离越近。每个节点维护一个路由表，由它所知道的好节点组成。路由表中的节点被用作在DHT中发送请求的起点。当其他节点查询时，就返回路由表中的节点。

#### 开源实现

实现BitTorrent协议最有名要算两个C++的实现：

  * [rakshase](https://github.com/rakshasa/libtorrent) 版本：他来源于Mozilla NSS的项目，LICENSE是GPL，使用它的客户端亦rtorrent等，基于Posix接口开发，可以在兼容Posix系统中编译使用，也支持HDT。这个项目已有12年了，目前还在发展，可以是非常的稳定与成熟，据说是速度之王。
  * [rasterbar(arvidn/libtorrent)](https://github.com/arvidn/libtorrent)版本，GitHub上有两个地址，另一个是[libtorrent/libtorrent](https://github.com/libtorrent/libtorrent)。前者是还是发展，后者已停止开发了。rasterbar版本是基于boost asio编写的，跨平台不存问题。默认有Python与Ruby的绑定接口。并且具有良好扩展性，例如有uTP，DHT安全扩展

这个两个实现都是非常不错的，但由于个人爱好的原因，一真想找是否有Go语言实现版本，于是在GitHub上寻寻觅觅，也找到两个不错的实现：

  * [Taipei Torrent](https://github.com/jackpal/Taipei-Torrent)：它一个较轻量的，基于命令行接口的Torrent客户端，主要功能有支持多Torrent文件，Magnet链接，DHT，UPnP/NAT-PMP打洞，也提供简单的tracker服务。
  * [anacrolix/torrent](https://github.com/anacrolix/torrent): 它实现了BitTorrent协议相关功能包，以及提供较丰富的命令行工具集。支持加密协议，DHT，PEX，uTP以及多种扩展。从代码结构来说，anacrolix/torrent比Taipei Torrent更容易做二次开发。


#### Taipei Torrent

首先它的名字比较有意思，项目开始于作者在台北的旅游，所以取名为`Taipei Torrent`。它的代码量比较不多，像Bencode，DHT，NAT-PMP，网络工具包都采用第三方库。如下是它的代码结构：

````
Taipei-Torrent git:(master) tree
├── main.go
├── queryTracker.bash
├── resolveBindIP.go
├── resolveBindIP_test.go
├── test.bash
├── testData
│   ├── a.torrent
│   └── testFile
├── testdht.bash
├── testswarm.bash
├── testtracker.bash
├── torrent
│   ├── accumulator.go
│   ├── accumulator_test.go
│   ├── bitset.go
│   ├── cache.go
│   ├── cache_test.go
.......
│   ├── upnp.go
│   ├── uri.go
│   └── uri_test.go
└── tracker
    ├── tracker.go
    └── tracker_test.go
````

##### 源码分析

花了一个下午走读它的代码，代码简洁易懂，主要功能都在`torrent`目录下。每个Peer对一个torrent文件会产生一个会话，在我的笔记本记，使用Docker搭建了6个节点，发布下载77M的go的安装包，是秒级速度。如下所示：

```
2016/01/17 12:13:13 Starting.
2016/01/17 12:13:13 Listening for peers on port: 7777
2016/01/17 12:13:13 [ go1.5.3.linux-amd64.tar.gz ] Tracker: [], Comment: , InfoHash: 556871e1ada306c2da5033e8fe0d4f077edbe6f7, Encoding: , Private: 0
2016/01/17 12:13:13 [ go1.5.3.linux-amd64.tar.gz ] Computed missing pieces (0.35 seconds)
2016/01/17 12:13:13 [ go1.5.3.linux-amd64.tar.gz ] Good pieces: 0 Bad pieces: 1223 Bytes left: 80147269
2016/01/17 12:13:13 Created torrent session for go1.5.3.linux-amd64.tar.gz
2016/01/17 12:13:13 Starting torrent session for go1.5.3.linux-amd64.tar.gz
2016/01/17 12:13:14 [ go1.5.3.linux-amd64.tar.gz ] Peers: 0 downloaded: 0 (0.00 B/s) uploaded: 0 ratio: 0.000000 pieces: 0/1223
```

作为Peer Client，主要代码逻辑在`torrent\torrentLoop.go`的RunTorrents方法中，它充分利用了Go的channel机制。实现步骤如下：

  1. 根据命令参数，开启Peer连接端口（TCP）。若不指定端口，则采用随机端口。目前是绑定在所的IP上，如果是内网，可以做NAT转换。
  2. 根据MaxActive参数，开启Session（对象为TorrentSession）数，如果同时下载torrent多余MaxActive则排队处理
  3. 如果设置参数useDHT，或torrent文件中没有Tracker服务，则会开启DHT，而DHT是采用UDP，端口与第1步的相同。
  4. 如果设置useLPD（Use Local Peer Discovery），则又会通过组播在同一个网段内相互发现，组播地址为`239.192.152.143:6771`。
  5. 当完成上述初始化之后，在mainLoop主要根据事件来处理：
    1. 如果是Session创建成功，则异步执行`TorrentSession.DoTorrent`方法开始启动下载
    2. 如果是有Session下载结束，则从排队中取出未处理的torrent文件加入到Session处理。
    3. 如果是收到退出信号，则等下载结束退出。
    4. 如果是收到其它Peer的连接请求，根据Infohash来判断是否存在相应的Session，如果存在，则提供给其它的Peer下载数据。
    5. 如果是收到DHT Peer的请求结果，则处理其它的Peer地址，根据地址从其它Peer下载数据。
    6. 如果是收到其它Peer的组播请求，则处理其它的Peer地址，根据地址从其它Peer下载数据。

另一个核心代码逻辑是在`torrent\torren.go`的DoTorrent方法中，实现步骤如下：

  1. 如果设置了内存缓存或硬盘缓存数，则根据torrent文件中元信息（块个数，整个大小）初始化缓存。
  2. 开启几个定时器，每隔1秒心跳检查，每隔60秒连接KeepAlive，如果采用Tracker服务，每隔20秒与Tracker服务列表请求，直到有Tracker服务有咱应。
  3. 如果是DHT，则从DHT Peer获取其它的Peer地址。
  4. 处理各种Channel的消息。

还一个重要的`torrent\torren.go`的DoMessage方法，它用于是产生协议的消息，与一个peer建立TCP连接后，首先向peer发送握手消息，peer收到握手消息后回应一个握手消息。握手消息是一个长度固定为68字节的消息。消息的格式如下：

```
[pstrlen][pstr][reserved][info_hash][peer_id]
```

参    数|含    义
:-------|:--------
pstrlen|pstr的长度，该值固定为19
pstr|BitTorrent协议的关键字，即“BitTorrent protocol”
reserved|占8字节，用于扩展BT协议，一般这8字节都设置为0。有些BT软件对BT协议进行了某些扩展，因此可能看到有些peer发来的握手消息这8个字节不全为0，不过不必理会，这不会影响正常的通信
info_hash|与发往Tracker的GET请求中的info_hash为同一个值，长度固定为20字节

对于除握手消息之外的其他所有消息，其一般的格式为：

```
[length prefix][message ID][payload]
```

length prefix（长度前缀）占4个字节，指明message ID和payload的长度和。message ID（消息编号）占一字节，是一个10进制的整数，指明消息的编号。payload（负载），长度未定，是消息的内容。

 * keep_alive消息：\[len=0000\]

	keep_alive消息的长度固定，为4字节，它没有消息编号和负载。如果一段时间内客户端与peer没有交换任何消息，则与这个peer的连接将被关闭。keep_alive消息用于维持这个连接，通常如果2分钟内没有向peer发送任何消息，则发送一个keep_alive消息。

 * choke消息：\[len=0001\]\[id=0\]

	choke消息的长度固定，为5字节，消息长度占4个字节，消息编号占1个字节，没有负载。

 * unchoke消息：\[len=0001\]\[id=1\]

	unchoke消息的长度固定，为5字节，消息长度占4个字节，消息编号占1个字节，没有负载。客户端每隔一定的时间，通常为10秒，计算一次各个peer的下载速度，如果某peer被解除阻塞，则发送unchoke消息。如果某个peer原先是解除阻塞的，而此次被阻塞，则发送choke消息。

 * interested消息：\[len=0001\]\[id=2\]

	interested消息的长度固定，为5字节，消息长度占4个字节，消息编号占1个字节，没有负载。当客户端收到某peer的have消息时，如果发现peer拥有了客户端没有的piece，则发送interested消息告知该peer，客户端对它感兴趣。

 * not interested消息：\[len=0001\]\[id=3\]

	not interested消息的长度固定，为5字节，消息长度占4个字节，消息编号占1个字节，没有负载。当客户端下载了某个piece，如果发现客户端拥有了这个piece后，某个peer拥有的所有piece，客户端都拥有，则发送not interested消息给该peer。

 * have消息：\[len=0005\]\[id=4\]\[piece index\]

	have消息的长度固定，为9字节，消息长度占4个字节，消息编号占1个字节，负载为4个字节。负载为一个整数，指明下标为index的piece，peer已经拥有。每当客户端下载了一个piece，即将该piece的下标作为have消息的负载构造have消息，并把该消息发送给所有与客户端建立连接的peer。

 * bitfield消息：\[len=0001+X\]\[id=5\]\[bitfield\]

	bitfield消息的长度不固定，其中X是bitfield(即位图)的长度。当客户端与peer交换握手消息之后，就交换位图。位图中，每个piece占一位，若该位的值为1，则表明已经拥有该piece；为0则表明该piece尚未下载。具体而言，假定某共享文件共拥有801个piece，则位图为101个字节，位图的第一个字节的最高位指明第一个piece是否拥有，位图的第一个字节的第二高位指明第二个piece是否拥有，依此类推。对于第801个piece，需要单独一个字节，该字节的最高位指明第801个piece是否已被下载，其余的7位放弃不予使用。

 * request消息：\[len=0013\]\[id=6\]\[index\]\[begin\]\[length\]

	request消息的长度固定，为17个字节，index是piece的索引，begin是piece内的偏移，length是请求peer发送的数据的长度。当客户端收到某个peer发来的unchoke消息后，即构造request消息，向该peer发送数据请求。前面提到，peer之间交换数据是以slice（长度为16KB的块）为单位的，因此request消息中length的值一般为16K。对于一个256KB的piece，客户端分16次下载，每次下载一个16K的slice。

 * piece消息：\[len=0009+X\]\[id=7\]\[index\]\[begin\]\[block\]

	piece消息是另外一个长度不固定的消息，长度前缀中的9是id、index、begin的长度总和，index和begin固定为4字节，X为block的长度，一般为16K。因此对于piece消息，长度前缀加上id通常为00 00 40 09 07。当客户端收到某个peer的request消息后，如果判定当前未将该peer阻塞，且peer请求的slice，客户端已经下载，则发送piece消息将文件数据上传给该peer。

 * cancel消息：\[len=0013\]\[id\[=8\]\[index\]\[begin\]\[length\]

	cancel消息的长度固定，为17个字节，len、index、begin、length都占4字节。它与request消息对应，作用刚好相反，用于取消对某个slice的数据请求。如果客户端发现，某个piece中的slice，客户端已经下载，而客户端又向其他peer发送了对该slice的请求，则向该peer发送cancel消息，以取消对该slice的请求。事实上，如果算法设计合理，基本不用发送cancel消息，只在某些特殊的情况下才需要发送cancel消息。

 * port消息：\[len=0003\]\[id=9\]\[listen-port\]
 *
	port消息的长度固定，为7字节，其中listen-port占两个字节。该消息只在支持DHT的客户端中才会使用，用于指明DHT监听的端口号，一般不必理会，收到该消息时，直接丢弃即可。
	> 注：Taipei Torrent未实现此消息
	
 * extension消息：\[len=0009+X\]\[id=20\]\[payload\]
 
	extension消息消息的长度不固定，消息Id为20， Taipei Torrent来来与其它的Peer交换torrent文件的元数据信息（每块Pieces的信息），同样采用B编码格式。 




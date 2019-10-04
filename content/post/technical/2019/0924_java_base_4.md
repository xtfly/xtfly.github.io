---
title: "跟我一起复习Java-4"
date: "2019-09-23"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# IO体系

## 普通IO

整个Java.io包主要分为两大部分

 - 文件特征对象
 - 文件内容操作对象

### 文件对象

在类Unix系统中，一切对象皆文件，文件是OS中最为基本的对象。Java API提供了最为基本的文件对象。

文件特征对象主要有如下：

  - 文件（File）：用于文件或者目录的描述信息，例如生成新目录，修改文件名，删除文件，判断文件所在路径等
  - 文件描述符（FileDescriptor）： 主要映射到OS层的文件句柄对象
  - 文件系统（FileSystem）：子类有UnixFileSystem，WinNTFileSystem等，用于适配不同的文件系统，仅内部使用，用户层不可调用。通过DefaultFileSystem.getFileSystem获取对应平台文件系统
  - 文件特征，包括Closeable，Flushable，FileFilter，Serializable

文件内容操作对象主要有两大类：流式操作与数据转换。

<!--more-->

### IO操作

#### 流式操作组件

流式操作又分类(byte)字节流，与字符(char)流

| 分类       | 字节输入流           | 字节输出流            | 字符输入流        | 字符输出流         |
| :--------- | :------------------- | :-------------------- | :---------------- | :----------------- |
| 接口       | InputStream          | OutputStream          | Reader            | Writer             |
| Filter     | FilterInputStream    | FilterOutputStream    | FilterReader      | FilterWriter       |
| 访问文件   | FileInputStream      | FileOutputStream      | FileReader        | FileWriter         |
| 访问数组   | ByteArrayInputStream | ByteArrayOutputStream | CharArrayReader   | CharArrayWriter    |
| 访问管道   | PipedInputStream     | PipedOutputStream     | PipedReader       | PipedWriter        |
| 访问字符串 |                      |                       | StringReader      | StringWriter       |
| 缓冲流     | BufferedInputStream  | BufferedOutputStream  | BufferedReader    | BufferedWriter     |
| 转换流     |                      |                       | InputStreamReader | OutputStreamWriter |
| 打印流     |                      | PrintStream           |                   | PrintWriter        |
| 推回输入流 | PushbackInputStream  |                       | PushbackReader    |                    |
| 数据流     | DataInputStream      | DataOutputStream      |                   |                    |
| 对象流     | ObjectInputStream    | ObjectOutputStream    |                   |                    |

#### 数据转换组件

数据转换，支持把字节流与Java基本数据类型间相互转换
  
| 分类     | 数据输入          | 数据输出           |
| :------- | :---------------- | :----------------- |
| 抽象基类 | DataInput         | DataInput          |
| 数据操作 | DataInputStream   | DataOutputStream   |
| 对象操作 | ObjectInput       | ObjectOut         |
| 对象操作 | ObjectInputStream | ObjectOutputStream |
| 文件操作 | RandomAccessFile  | RandomAccessFile   |

## NIO

NIO是Java 1.4推出，提供一种更主高效的IO操作API，可以代替部分普通IO操作API。

### 区别

NIO和普通IO（后简称IO）之间第一个最大的区别是：

 - IO是面向流的。面向流意味着每次从流中读一个或多个字节，直至读取所有字节，它们没有被缓存在任何地方。此外，它不能前后移动流中的数据。如果需要前后移动从流中读取的数据，需要先将它缓存到一个缓冲区。
 - NIO是面向缓冲区的。NIO的缓冲导向方法略有不同。数据读取到一个它稍后处理的缓冲区，需要时可在缓冲区中前后移动。这就增加了处理过程中的灵活性。但是，还需要检查是否该缓冲区中包含所有您需要处理的数据。而且，需确保当更多的数据读入缓冲区时，不要覆盖缓冲区里尚未处理的数据。

另一个区别是是否阻塞：
 
 - IO是阻塞的。意味着当一个线程调用read() 或 write()时，该线程被阻塞，直到有一些数据被读取，或数据完全写入。该线程在此期间不能再干任何事情了
 - NIO可以是非阻塞的。 NIO的非阻塞模式，使一个线程从某通道发送请求读取数据，但是它仅能得到目前可用的数据，如果目前没有数据可用时，就什么都不会获取。而不是保持线程阻塞，所以直至数据变得可以读取之前，该线程可以继续做其他的事情。 非阻塞写也是如此。一个线程请求写入一些数据到某通道，但不需要等待它完全写入，这个线程同时可以去做别的事情。 线程通常将非阻塞IO的空闲时间用于在其它通道上执行IO操作，所以一个单独的线程现在可以管理多个输入和输出通道（channel）。


### 特性

基于通道（Channel）与缓冲区（Buffer）操作：

 - Channel：为所有IO提供Input/Output抽象,就像普通IO中的Stream一样原始IO操作
 - Buffer：为所有基础类型提供缓冲操作
 - 操作：数据从Channel读到Buffer，从Buffer写入到Channel

基于非阻塞（Non-Blocking）:

 - 提供 多路 非阻塞的I/O 抽象
  
IO选择器（Selector）:
 
 - 用于监控多个Channel的事件，如连接打开，数据到达
 - 单个线程可以监控多个数据通道

其它：

 - 提供字符编码/解码方案，java.nio.charset
 - 支持内存映射文件，锁文件的访问接口

### 核心组件

| 核心组件       | 定义                 | 作用            | 特点              | 使用                            |
| :------------- | :------------- | :------------------ | :--------------- | :-------------------- |
| 通道Channel    | 是数据的源头与目的地 | 给Buffer提供数据，从Buffer读取数据    | 双向读取<br/>异步读写   | 按数据来源划分:<br/>FileChannle: 从文件读写数据<br/>DatagramChannel: 从UDP连接读写数据<br/>SocketChannel：从TCP连接读写数据<br/>ServerSocketChannel：TCP服务侧的连接读写数据 |
| 缓存区Buffer   | 缓存数据             | 适用于所有基础数据类型（除了boolean） | 按类型类型划分：<br/> ByteBuffer<br/> ShortBuffer<br/>...<br/>不同的类型的Buffer可以相互换：提供asXxxBuffer() |   |
| 选择器Selector | 异步IO的核心对象     | 实现异步、非阻塞操作                  | 允许一个Selector线程管理与操作多个Channel<br/>事件驱动：监控多个Channel的事件，并对事件分发           | 向Selector注册Channel<br/>调用Selector的select方法监控        |

#### Buffer

Buffer顾名思义：缓冲区，实际上是一个容器，一个连续数组。Channel提供从文件、网络读取数据的渠道，但是读写的数据都必须经过Buffer。

向Buffer中写数据：

- 从Channel写到Buffer (fileChannel.read(buf))
- 通过Buffer的put()方法 （buf.put(…)）

从Buffer中读取数据：

 - 从Buffer读取到Channel (channel.write(buf))
 - 使用get()方法从Buffer中读取数据 （buf.get()）

可以把Buffer简单地理解为一组基本数据类型的元素列表，它通过几个变量来保存这个数据的当前位置状态：capacity, position, limit, mark：

| 索引     | 说明                                                    |
| :------- | :------------------------------------------------------ |
| capacity | 缓冲区数组的总长度                                      |
| position | 下一个要操作的数据元素的位置                            |
| limit    | 缓冲区数组中不可操作的下一个元素的位置：limit<=capacity |
| mark     | 用于记录当前position的前一个位置或者默认是-1            |

几个重要标识操作方法：clear，compact，mark，mark|

| 方法      | 说明  |
| :-------- | :----------- |
| clear()   | position将被设回0，limit设置成capacity，换句话说，Buffer被“清空”了，其实Buffer中的数据并未被清除，只是这些标记告诉我们可以从哪里开始往Buffer里读写数据 |
| compact() | 将所有未读的数据拷贝到Buffer起始处。然后将position设到最后一个未读元素正后面，limit设置成capacity，Buffer准备好写数据但不会覆盖未读的数据             |
| mark()    | 可以标记Buffer中的一个特定的position，之后可以通过调用reset()方法恢复到这个position      |
| rewind()  | 将position设回0，可以重读Buffer中的所有数据。limit保持不变，仍然表示能从Buffer中读取多少个元素         |

#### Selector

Selector可以监控的四种不同类型的事件：

 - Connect：某个channel成功连接到另一个服务器称为“连接就绪”
 - Accept：一个server socket channel准备好接收新进入的连接称为“接收就绪”
 - Read：一个有数据可读的通道可以说是“读就绪”
 - Write：等待写数据的通道可以说是“写就绪”

通过Selector选择通道，有几种方法

 - int select()：阻塞到至少有一个通道在你注册的事件上就绪了
 - int select(long timeout)：和select()一样，除了最长会阻塞timeout毫秒(参数)
 - int selectNow()：不会阻塞，不管什么通道就绪都立刻返回

select()方法返回的int值表示有多少通道已经就绪。然后可以通过调用selector的selectedKeys()方法，访问“ 已选择键集（selected key set）”中的就绪通道。

### 其它

#### 内存映射文件

处理大文件，一般用BufferedReader,BufferedInputStream这类带缓冲的IO类，不过如果文件超大的话，更快的方式是采用MappedByteBuffer。

ByteBuffer有两种模式:直接/间接。间接模式最典型(也只有这么一种)的就是HeapByteBuffer,即操作堆内存 (byte[])。

ByteBuffer.MappedByteBuffer 只是一种特殊的ByteBuffer MappedByteBuffer 将文件直接映射到内存（这里的内存指的是虚拟内存，并不是物理内存）。通常，可以映射整个文件，如果文件比较大的话可以分段进行映射，只要指定文件的那个部分就可以。

FileChannel提供了map方法（`MappedByteBuffer map(int mode,long position,long size)`）来把文件影射为内存映像文件。 可以把文件的从position开始的size大小的区域映射为内存映像文件，mode指出了 可访问该内存映像文件的方式：

 - READ_ONLY,（只读）： 试图修改得到的缓冲区将导致抛出 ReadOnlyBufferException
 - READ_WRITE（读/写）： 对得到的缓冲区的更改最终将传播到文件；该更改对映射到同一文件的其他程序不一定是可见的
 - PRIVATE（专用）： 对得到的缓冲区的更改不会传播到文件，并且该更改对映射到同一文件的其他程序也不是可见的；相反，会创建缓冲区已修改部分的专用副本

#### 工具

Scatter/Gatter

 - 分散（scatter）从Channel中读取是指在读操作时将读取的数据写入多个buffer中
 - 聚集（gather）写入Channel是指在写操作时将多个buffer的数据写入同一个Channel

Pipe是两个线程之间的单向数据连接

 - Pipe有一个source通道和一个sink通道
 - 数据会被写到sink通道，从source通道读取


Path表示文件系统中的路径

- 一个路径可以指向一个文件或一个目录。路径可以是绝对路径，也可以是相对路径
- 绝对路径包含从文件系统的根目录到它指向的文件或目录的完整路径
- 相对路径包含相对于其他路径的文件或目录的路径


Files提供一些工具，它依赖于Path

 - Files.exists()
 - Files.createDirectory()
 - Files.copy()
 - Files.move()
 - Files.delete()
 - Files.walkFileTree()
  
----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。  
---
title: "Java基础知识点1"
date: "2019-09-21"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# 基本数据类型

|数据类型           |大小       |范围                                              |默认值|
|:------           |:------    |:------                                          |:------|
|byte(字节) 	      |8          | -128 - 127                                       |0    |
|shot(短整型)       |16         | -2^15 - 2^15-1                                   |0    |
|int(整型)          |32         | -2^31 - 2^31-1                                   |0    |
|long(长整型)       |64         | -2^63 - 2^63-1                                   |0     |   
|float(浮点型)      |32         | 1.4013E-45 - 3.4028E+38                          |0.0f  |
|double(双精度)	    |64         | -1.7976E+308 - 1.79769E+308                      |0.0d  |
|char(字符型)       |16         | `\u0000 - u\ffff`                                |`\u0000`|
|boolean(布尔型)    |1          | true/false                                       |false |

<!--more-->

# 控制语句

## Swith语句

switch(A)括号中A的取值类型如下：

 - byte
 - short
 - int
 - char
 - 枚举
 - String(Java 7)

注意不能是long

case B:C 

 - case是常量表达式， case后的语句可以不用大括号，也就是说C不需要使用大括号；
 - default没有符合的case就执行它，default并不是必须的。

## for语法

 - 无限循环： for（；；）
 - index for: for(int i = 0; i < MAX; i++)
 - for each: for（a : iterator）  Java 5

## labeled loop

```
vectorLoop:
for( int idx = 0; idx < vectorLength; idx++) {
    if( conditionAtVectorPosition( v, idx ) ) continue vectorLoop;

    matrixLoop:
    for( rowIdx = 0; rowIdx < n; rowIdx++ ) {
        if( anotherConditionAtVector( v, rowIdx ) ) continue matrixLoop;
        if( conditionAtMatrixRowCol( m, rowIdx, idx ) ) continue vectorLoop;
    }
    setValueInVector( v, idx );
}     
```

# 异常体系

- Throwable作为所有异常的超类
- Error（错误）：是程序中无法处理的错误，表示运行应用程序中出现了严重的错误。此类错误一般表示代码运行时JVM出现问题。通常有Virtual MachineError（虚拟机运行错误）、NoClassDefFoundError（类定义错误）等。比如说当jvm耗完可用内存时，将出现OutOfMemoryError。此类错误发生时，JVM将终止线程。这些错误是不可查的，非代码性错误。因此，当此类错误发生时，应用不应该去处理此类错误。
- Exception（异常）：程序本身可以捕获并且可以处理的异常。 
  - 运行时异常(不受检异常)：RuntimeException类极其子类表示JVM在运行期间可能出现的错误。比如说试图使用空值对象的引用（NullPointerException）、数组下标越界（ArrayIndexOutBoundException）。此类异常属于不可查异常，一般是由程序逻辑错误引起的，在程序中可以选择捕获处理，也可以不处理。
  - 编译异常(受检异常)：Exception中除RuntimeException极其子类之外的异常。如果程序中出现此类异常，比如说IOException，必须对该异常进行处理，否则编译不通过。在程序中，通常不会自定义该类异常，而是直接使用系统提供的异常类。


# 集合体系

集合是存储多个元素的容器，数组长度固定，不能满足长度变化的需求。其特点：

 - 长度可变
 - 存储元素可以是引用类型
 - 可以存储多种类型的对象
  
## Iterator
Iterator接口：

 - 对 Collection 进行迭代的迭代器，即对所有的Collection容器进行元素取出的公共接口。
 - 提供`boolean hasNext()`和`E next()`两个方法

ListIterator：

 - 只能用于List的迭代器。
 - 在使用迭代器迭代的过程中需要使用集合中的方法操作元素，出现ConcurrentModificationException异常时，可以使用ListIterator避免

## Collection

Collection接口：

- List接口：有序(存入和取出的顺序一致),元素都有索引(下标)，元素可以重复。
  - Vector：内部是 数组 数据结构，是同步的。增删，查询都很慢！100%延长（几乎不用了）  
  - ArrayList：内部是 数组 数据结构，是不同步的。替代了Vector，查询的速度快，增删速度慢。50%延长。查询时是从容器的第一个元素往后找，由于数组的内存空间是连续的，所以查询快；增删的话所有元素内存地址都要改变，所以增删慢。
  - LinkedList：内部是 链表 数据结构，是不同步的。增删元素的速度很快。同理，链表的内存空间是不连续的，所以查询慢；增删时只需改变单个指针的指向，所以快。
- Set接口：无序，元素不能重复。Set接口中的方法和Collection一致。
  - HashSet：内部数据结构是哈希表 ，是不同步的。
  - LinkedHashSet：内部数据结构是哈希表和链表，是有顺序的HashSet。
  - TreeSet：内部数据结构是有序的二叉树，它的作用是提供有序的Set集合，是不同步的。
  
List接口：

 - 有一个最大的共性特点就是都可以操作角标，所以LinkedList也是有索引的。list集合可以完成对元素的增删改查。 

Set和List的区别：

 - Set 接口实例存储的是无序的，不重复的数据。List 接口实例存储的是有序的，可以重复的元素。
 - Set检索效率低下，删除和插入效率高，插入和删除不会引起元素位置改变 。
 - List和数组类似，可以动态增长，根据实际存储的数据的长度自动增长List的长度。查找元素效率高，插入删除效率低，因为会引起其他元素位置改变。

## Map

Map接口：

 -  一次添加一对元素，Collection 一次添加一个元素。
 -  Map也称为双列集合，Collection集合也称为单列集合。
 -  map集合中存储的就是键值对，map集合中必须保证键的唯一性
  
Map常用的子类：

- Hashtable :内部结构是哈希表，是同步的。不允许null作为键，null作为值。
  - Properties：用来存储键值对型的配置文件的信息，可以和IO技术相结合。 
- HashMap : 内部结构是哈希表，不是同步的。允许null作为键，null作为值。
- TreeMap : 内部结构是二叉树，不是同步的。可以对Map集合中的键进行排序。 

Map的迭代方法（Map本身没有迭代器）：

 - 利用Map接口的values()方法,返回此映射中包含的值的 Collection（值不唯一），然后通过Collecion的迭代器进行迭代。（只需要Value，不需要Key的时候）
 - 通过keySet方法获取map中所有的键所在的Set集合（Key和Set的都具有唯一性），再通过Set的迭代器获取到每一个键，再对每一个键通过Map集合的get方法获取其对应的值即可。
 - 利用Map的内部接口Map.Entry<K,V>使用iterator。

## Queue

Queue接口:

  - 继承Collection
  - boolean add(E e)，队列满，抛IllegalStateException / boolean offer(E e)，当容量限制时，与add相同抛IllegalStateException
  - E remove()，抛NoSuchElementException / E poll()，不抛，返回null
  - E element()，抛NoSuchElementException / E peek()，不抛，返回null

Deque接口，是一个实现了双端队列数据结构的队列，即在头尾都可进行删除和新增操作；

  - 继承Queue
  - 依旧保持着“先进先出”的本质
  - 增加 xxxFirst与xxxLast方法
  - 可以被当做“栈”来使用，即“后进先出”，添加元素、删除元素都在队头进行通过push/pop两个方法来实现
  - 主要两个实现LinkedList与ArrayDeque

PriorityQueue:

  - 不同于先进先出，它可以通过比较器控制元素的输出顺序（优先级）
  - 本质上就是一个最小堆存储结构数组了
  - 通过“极大优先级堆”实现的，即堆顶元素是优先级最大的元素。算是集成了大根堆和小根堆的功能。
  - 堆的操作，主要就是两个：siftUp和siftDown，一个是向上调整堆，一个是向下调整堆。


## 集合框架工具类Collections
 
根据字符串长度的正序和倒序排序：

 - `Collections.reverse(List<?> list) ` 反转指定列表中元素的顺序。
 - `<T> Comparator<T> Collections.reverseOrder()` 返回一个比较器，它强行逆转实现了 Comparable 接口的对象 collection 的自然顺序。
 - `<T> Comparator<T> reverseOrder(Comparator<T> cmp) `  返回一个比较器，它强行逆转指定比较器的顺序。

排序

 - `Collections.sort(List<?> list)`
 - `Collections.sort(List<?> list, Collections.reverseOrder())`

同步视图

 - `<T> Collection<T> synchronizedCollection(Collection<T> c)`
 - `<T> Collection<T> synchronizedCollection(Collection<T> c, Object mutex)`
  
只读视图

 - `<T> Collection<T> unmodifiableCollection(Collection<? extends T> c)`

其它工具

  - `<T> int binarySearch(List<? extends Comparable<? super T>> list, T key)`
  - `<T> int indexedBinarySearch(List<? extends Comparable<? super T>> list, T key)`
  - `<T> T max(Collection<? extends T> coll, Comparator<? super T> comp)`
  - `<T> T min(Collection<? extends T> coll, Comparator<? super T> comp)`
  - `<T> void fill(List<? super T> list, T obj)`
  - `<T> List<T> nCopies(int n, T o)`

## 并发集合

List接口:

 - CopyOnWriteArrayList,线程安全的ArrayList
    - 适用于读操作远远多于写操作，并且数据量较小的情况
    - 修改容器的代价是昂贵的，因此建议批量增加addAll、批量删除removeAll
    - CopyOnWrite机制
      - 使用volatile修饰数组引用：确保数组引用的内存可见性
      - 对容器修改操作进行同步：从而确保同一时刻只能有一条线程修改容器（因为修改容器都会产生一个新的容器，增加同步可避免同一时刻复制生成多个容器，从而无法保证数组数据的一致性）
      - 修改时复制容器：确保所有修改操作都作用在新数组上，原本的数组在创建过后就用不变化，从而其他线程可以放心地读。

Set接口: 

 - CopyOnWriteArraySet是线程安全的Set，它内部包含了一个CopyOnWriteArrayList，因此本质上是由CopyOnWriteArrayList实现的。
 - ConcurrentSkipListSet相当于线程安全的TreeSet。它是有序的Set。它由ConcurrentSkipListMap实现。
   - 它是一个有序的、线程安全的Set，相当于线程安全的TreeSet。
   - 

Map接口：

 - ConcurrentHashMap线程安全的HashMap。采用分段锁实现高效并发。
   - ConcurrentHashMap由多个Segment构成，每个Segment都包含一张哈希表。每次操作只将操作数据所属的Segment锁起来，从而避免将整个锁住。
 - ConcurrentSkipListMap线程安全的有序Map。使用跳表实现高效并发。
   - 它是一个有序的Map，相当于TreeMap。TreeMap采用红黑树实现排序，而ConcurrentHashMap采用跳表实现有序。
   - 跳表是条有序的单链表，它的每个节点都有多个指向后继节点的引用。

Queue：

 - ConcurrentLinkedQueue线程安全的无界队列。底层采用单链表。支持FIFO。
   - head、tail、next、item均使用volatile修饰，保证其内存可见性，并未使用锁，从而提高并发效率。
 - ConcurrentLinkedDeque线程安全的无界双端队列。底层采用双向链表。支持FIFO和FILO。
 - ArrayBlockingQueue数组实现的阻塞队列。
   - 内部由Object数组存储元素，构造时必须要指定队列容量。
   - 由ReentrantLock实现队列的互斥访问，并由notEmpty、notFull这两个Condition分别实现队空、队满的阻塞。
   - ReentrantLock分为公平锁和非公平锁，可以在构造ArrayBlockingQueue时指定。默认为非公平锁。
   - 队满阻塞：当添加元素时，若队满，则调用notFull.await()阻塞当前线程；当移除一个元素时调用notFull.signal()唤醒在notFull上等待的线程。
   - 队空阻塞：当删除元素时，若队为空，则调用notEmpty.await()阻塞当前线程；当队首添加元素时，调用notEmpty.signal()唤醒在notEmpty上等待的线程。
 - LinkedBlockingQueue链表实现的阻塞队列。
   - 由单链表实现，因此是个无限队列。但为了方式无限膨胀，构造时可以加上容量加以限制。
   - 分别采用读取锁和插入锁控制读取/删除 和 插入过程的并发访问，并采用notEmpty和notFull两个Condition实现队满队空的阻塞与唤醒。
   - 队满阻塞：若要插入元素，首先需要获取putLock；在此基础上，若此时队满，则调用notFull.await()，阻塞当前线程；当移除一个元素后调用notFull.signal()唤醒在notFull上等待的线程；最后，当插入操作完成后释放putLock。
   - 若要删除/获取元素，首先要获取takeLock；在此基础上，若队为空，则调用notEmpty.await()，阻塞当前线程；当插入一个元素后调用notEmpty.signal()唤醒在notEmpty上等待的线程；最后，当删除操作完成后释放takeLock。
 - LinkedBlockingDeque双向链表实现的双端阻塞队列。

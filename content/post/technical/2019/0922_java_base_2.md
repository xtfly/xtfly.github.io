---
title: "跟我一起复习Java-2：集合/Stream"
date: "2019-09-22"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# 集合体系

集合是存储多个元素的容器，数组长度固定，不能满足长度变化的需求。其特点：

 - 长度可变
 - 存储元素可以是引用类型
 - 可以存储多种类型的对象
  
## Iterator
Iterator接口：

 - 对 Collection 进行迭代的迭代器，即对所有的Collection容器进行元素取出的公共接口。
 - 提供`boolean hasNext()`和`E next()`两个方法
<!--more-->

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


## 工具类Collections
 
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

# Stream

Stream 是对集合（Collection）对象功能的增强，它专注于对集合对象进行各种非常便利、高效的聚合操作（aggregate operation），或者大批量数据操作 (bulk data operation)。

对 Stream 的使用就是实现一个 filter-map-reduce 过程，产生一个最终结果，或者导致一个副作用（side effect）。Stream 不是集合元素，它不是数据结构并不保存数据，它是有关算法和计算的，它更像一个高级版本的 Iterator。

## 操作类型

 - Intermediate（中间操作）: 可以后面跟随零个或多个 intermediate 操作。这类操作都是惰性化的（lazy）。map (mapToInt, flatMap 等)、 filter、 distinct、 sorted、 peek、 limit、 skip、 parallel、 sequential、 unordered等
 - Terminal（终止操作）: 只能有一个 terminal 操作, Terminal 操作的执行，才会真正开始流的遍历，并且会生成一个结果。forEach、 forEachOrdered、 toArray、 reduce、 collect、 min、 max、 count、 anyMatch、 allMatch、 noneMatch、 findFirst、 findAny、 iterator等

还有一种操作被称为 short-circuiting（短路操作）：

 - 对于一个 intermediate 操作，如果它接受的是一个无限流，它可以返回一个有限的新 Stream。
 - 对于一个 terminal 操作，如果它接受的是一个无限流，但能在有限的时间计算出结果。anyMatch、 allMatch、 noneMatch、 findFirst、 findAny、 limit

## 构造

 - Stream.of(T… values)：需要注意的是，不能全是null
 - Stream.<Integer>empty()：构造一个空流
 - Stream.iterate(BigInteger.ONE, n->n.add(BigInteger.ONE))
 - Stream.generate(new Random()::nextInt)
 - Stream.concat(list1.stream(),list2.stream())
 - IntStream.range(1, 3)
 - IntStream.rangeClosed(1, 3)

## reduce

reduce的作用是把stream中的元素给组合起来。至于怎么组合起来：它需要我们首先提供一个起始种子，然后依照某种运算规则使其与stream的第一个元素发生关系产生一个新的种子，这个新的种子再紧接着与stream的第二个元素发生关系产生又一个新的种子，就这样依次递归执行，最后产生的结果就是reduce的最终产出。

运用reduce我们可以做sum,min,max,average，这些常用的reduce，stream api已经为我们封装了对应的方法。

 -  reduce(T iden, BinaryOperator b)： 可以将流中元素反复结合起来，得到一个值，返回 T
 -  reduce(BinaryOperator b)： 可以将流中元素反复结合起来，得到一个值，返回 Optional
 -  reduce(U identity, BiFunction a, BinaryOperator combiner)： 可以将流中元素反复结合起来，得到一个值，返回 Optional

三个参数时是最难以理解的。 分析下它的三个参数：

 - identity: 一个初始化的值；这个初始化的值其类型是泛型U，与Reduce方法返回的类型一致；注意此时Stream中元素的类型是T，与U可以不一样也可以一样，这样的话操作空间就大了；不管Stream中存储的元素是什么类型，U都可以是任何类型，如U可以是一些基本数据类型的包装类型Integer、Long等；或者是String，又或者是一些集合类型ArrayList等
 - accumulator: 其类型是BiFunction，输入是U与T两个类型的数据，而返回的是U类型；也就是说返回的类型与输入的第一个参数类型是一样的，而输入的第二个参数类型与Stream中元素类型是一样的
 - combiner: 其类型是BinaryOperator，支持的是对U类型的对象进行操作

## collect

Collectors里常用搜集器

 -  toList：list.stream().collect(Collectors.toList())
 -  toSet：list.stream().collect(Collectors.toSet())
 -  toCollection：list.stream().collect(Collectors.toCollection())
 -  counting：计算流中元素的个数， list.stream().collect(Collectors.counting())
 -  summingInt：对流中的元素的整数求和, list.stream().collect(Collectors.summingInt(Employee::getSalary))
 -  averagingInt：对流中的元素的整数求平均值，list.stream().collect(Collectors.averagingInt(Employee::getSalary))
 -  summarizingInt：对流中的元素的整数求统计值，list.stream().collect(Collectors.summarizingInt(Employee::getSalary)).getAverage()
 -  joining：连接每个字符串，list.stream().map(Employee::getName).collect(Collectors.joining(","))
 -  maxBy：根据比较器选择最大值，list.stream().collect(Collectors.maxBy(comparingInt(Employee::getSalary)))
 -  minBy：根据比较器选择最小值，list.stream().collect(Collectors.minBy(comparingInt(Employee::getSalary)))
 -  reduce：list.stream().collect(Collectors.reduc(0, Employee::getSalary, Integer::sum))
 -  collectingAndThen：list.stream().collect(Collectors.collectingAndThen(Collectors.toList(), List::size))
 -  groupBy：根据属性对流分组，返回Map，属性为K，list.stream().collect(Collectors.groupBy(Employee::status))
 -  partitiongBy：根据true/fase对流分组，返回Map, 
 -  toMap：toMap最少应接受两个参数，一个用来生成key，另外一个用来生成value。当key重复时，会抛出异常;当value为null时，会抛出异常，list.stream()
                .collect(toMap(t -> t.getId(), Function.identity(), (k1, k2) -> k1, LinkedHashMap::new))
 -  toConcurrentMap: 线程安全的Map


----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 
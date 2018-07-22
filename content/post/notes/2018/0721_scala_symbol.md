---
title: "Scala中的符号"
date: "2018-07-21"
categories:
 - "笔记"
tags:
 - "Scala"
toc: true
---

Scala被有人戏称是 “太阳系最难的语言” ，那我们来看看他那些各种奇怪的符号使用吧，不少用法只能用 “惊为天书” 来形容啊。

_说明：本文为学习笔记，下面内容多数来源于网上多篇文档的汇总，在此感谢原作者们。_ 

## 泛型

### `:`

scala中泛型使用`[]`指定泛型的类型参数，上下文界定是隐式参数的语法糖

 - `:` 表示上下文界定，如`A：B` 表示 B 可以进行隐式转化的A类型

示例：

 - `T:A:B` 表示即同时满足AT这种隐式值和BT这种隐式值

### `<:` 与 `:>`

 - `<:` 表示只限定子类，如 `T <: A` 表示T必须为A的子类
 - `>:` 表示只限定子类，如 `T >: A` 表示T必须为A的父类

`<:` 与 `:>` 相当于java范型编程中的extends，super对泛型变量的限定。

示例：

 - `T <: A with B` 表示A和B为T上界 
 - `T >: A with B` 表示A和B为T下界 
 - `T >: A <: B` 表示同时拥有上界和下界，并且A为下界，B为上界，A为B的子类，顺序不能颠倒。  

<!--more-->
### `<%`

`<%` 表示“view bounds”(视界)，比 `<:` 适用的范围更广，除了所有的子类型，还允许隐式转换过去的类型。

示例：

 - `T <% A <% B ` 表示：同时能够满足隐式转换的A和隐式转换的B 

###  `=：=` , `<:<` 与 `<%<`

这些被称为广义的类型约束。他们允许你从一个类型参数化的class或trait，进一步约束其类型参数之一。

 - `=：=` 表示必须是这种类型，如 `A =:= B` 表示 A 必须是 B 类型
 - `<:<` 表示必须是子类型，如 `A <:< B` 表示 A 必须是B的子类型 (类似于简单类型约束 `<:` )
 - `<%<` 表示必须是可视化类型，`A <%< B` 表示 A 必须是可视化为 B类型, 可能通过隐式转换 (类似与简单类型约束` <%` )

### `[+T]` 与 `[-T]`
 
在泛型中，需要描述泛型的类型之间`继承`关系可以转化的关系。

 - `[+T]` 表示“协变“，是指能够使用与原始指定的派生类型相比，派生程度更大的类型。如：String => AnyRef
 - `[-T]` 表示“逆变”，是指能够使用派生程度更小的类型。如： AnyRef => String

#### `[+T]`

A是B的子类，如果想让Container[A]是Container[B]的子类，那么只需在定义Container的时候加上“[+T]”就好了；但是注意，如果只加了“[+T]”，只可以实例化从父类到子类的引用。

假定，Bird extends Animal extends Earth

当有`Space[+T]`定义时，

```
    var a = new Space[Animal]
    a = new Space[Bird]
```

但不能是

```
    var a = new Space[Animal]
    a = new Space[Earth]
```

#### `[-T]`

面向对象编程中，子类也可以指向父类的引用，在正常情况下，通过强制类型转换，是可以实现。但是在有集合类的情况下如何实现呢？这就是“协变”`[-T]`了，只需在定义集合类的时候在集合类上加上“[-T]”即可。

假定，Bird extends Animal extends Earth

当有`Space[-T]`类定义时，

则如下是OK的：

```
    var a = new Space[Animal]
    a = new Space[Earth]
```

## 列表操作符

### `::` 与 `++`

`::` 表示普通元素与List的连接操作，示例：

```
    val a = 1
    val b = List(3, 4)
    val c = 1 :: b
```

`++` 表示用于连接两个集合， 示例

```
    val a = List(1, 2)
    val b = List(3, 4)
    val c = a ++ b
```

其中a,b保持不变，a和b连接产生一个新表List(1,2,3,4)，而不是在a上面做add操作。

`++=` 表示连接两个集合，并赋值，示例

```
    var a = List(1, 2)
    a ++= List(3, 4)
```

### `:::`

`:::` 表示只能List的连接操作，示例：

```
    val a = List(1, 2)
    val b = List(3, 4)
    val c = a ::: b
```

其中a,b保持不变，a和b连接产生一个新表List(1,2,3,4)，而不是在a上面做add操作。

### `:+` 与 `+:`

 -  `:+` 用于List在尾部追加元素
 -  `+:` 用于List在头部追加元素

示例：

 - `"A"+:"B"+:Nil` 结果为 List(A, B)
 - `Nil:+"A":+"B"` 结果为 List(A, B)

则c的结果是List(1,3,4)，需要注意的是，`1 :: b` 操作，`::` 是右侧对象的方法，即它是b对象的方法，而``::``左侧的运算数是 `::` 方法的参数，所以 `1::b` 的含义是 `b.::(1)`

## 成对的符号

### `->` 与 `<-`

 - `->` 是所有Scala对象都有的方法，生成元组，如 `A->B` 结果是返回一个二元的元组(A,B)
 - `->` 用于map构建，表示Key -> vlue， 如 `Map(1 -> "one", 2 -> "two")`
 - `<-` 用于for循环中，`<-` 在Scala中称为generator，在每次遍历的过程中，生成一个新的对象A，这个A是val，而不是var

### `<=` 与 `=>`

 - `<=` 只表示 小于等于号
 - `=>` 使用场景相当地多

#### `=>`用法

##### Call by name

`传名调用`(Call by name)`，在 `传名调用` 求值中，根本就不求值给函数的实际参数，而是使用避免捕获代换把函数的实际参数直接代换入函数体内。如果实际参数在函数的求值中未被用到，则它永不被求值；如果这个实际参数使用多次，则它每次都被重新求值。

传名调用求值超过传值调用求值的优点是传名调用求值在一个值存在的时候总是生成这个值，而传名调用可能不终止如果这个函数的实际参数是求值这个函数所不需要的不终止计算。反过来说，在函数的实际参数会用到的时候传名调用就非常慢了，这是因为实践中几乎总是要使用如 thunk 这样的机制。

`传需求调用(Call by need)`，`传需求调用` 是 `传名调用` 的记忆化版本，如果 “函数的实际参数被求值了”，这个值被存储起来已备后续使用。在“纯”(无副作用)设置下，这产生同传名调用一样的结果；当函数实际参数被使用两次或更多次的时候，传需求调用总是更快。

示例：

```
    object TargetTest2 extends Application {
        def loop(body: => Unit): LoopUnlessCond =
            new LoopUnlessCond(body)

        protected class LoopUnlessCond(body: => Unit) {
            def unless(cond: => Boolean) {
            body
            if (!cond) unless(cond)
            }
        }

        var i = 10
        loop {
            println("i = " + i)
            i -= 1
        } unless (i == 0)
    }
```

上面的程序运行结果是

```
    i = 10
    i = 9
    i = 8
    i = 7
    i = 6
    i = 5
    i = 4
    i = 3
    i = 2
    i = 1
```

##### 函数定义

使用方式一：In a value：it introduces a function literal（通译为匿名函数，有时候也叫函数显式声明，函数字面量）, or lambda（参考lambda表达式的文章，其实也是匿名函数），示例：

```
    List(1,2,3).map { (x: Int) => x * 2 }
```

使用方式二：in a type, with symbols on both sides of the arrow (e.g. A => T, (A,B) => T, (A,B,C) => T, etc.) it's sugar（syntactic sugar语法糖） for Function<n>[A[,B,...],T], that is, a function that takes parameters of type A[,B...], and returns a value of type T.（语法糖通过更简洁的语法达到目的，直接把所需要的参数、类型、函数最简化，然后把解析的工作交给编译器来完成，这步称为去糖化。例如，(A,B)=>T，包含了函数，参数以及类型，实际上是一个匿名函数，func(A,B,T)或者func(A T,B T)）。

示例：

```
    scala> val f: Function1[Int,String] = myInt => "my int: "+myInt.toString
    f: (Int) => String = <function1>

    scala> f(0)
    res0: String = my int: 0

    scala> val f2: Int => String = myInt => "my int v2: "+myInt.toString
    f2: (Int) => String = <function1>

    scala> f2(1)
    res1: String = my int v2: 1

    scala> val f2: Function2[Int,Int,String] = (myInt1,myInt2) => "This is my function to transfer " + myInt1 + " and " + myInt2 + " as a string component."
    f2: (Int, Int) => String = <function2>

    scala> f2(1,2)
    res6: String = This is my function to transfer 1 and 2 as a string component.

    scala> val f22:(Int,Int)=>String = (myInt1,myInt2) => "This is my function to transfer " + myInt1 + " and " + myInt2 + " as a string component."
    f22: (Int, Int) => String = <function2>
    scala> f22(2,4)
    res7: String = This is my function to transfer 2 and 4 as a string component.

    Here myInt is binded to the argument value passed to f and f2.
    () => T is the type of a function that takes no arguments and returns a T. It is equivalent to Function0[T]. () is called a zero parameter list I believe.
    scala> val f: () => Unit = () => { println("x")}
    f: () => Unit = <function0>

    scala> f()
    x
```

使用方式三：Empty parens on the left hand side (e.g. () => T) indicate that the function takes no parameters (also sometimes called a "thunk");

示例：

```
    object TimerAnonymous {
        def oncePerSecond(callback: () => Unit) {
            while (true) { callback(); Thread sleep 1000 }
        }
        
        def main(args: Array[String]) {
            oncePerSecond(() => println("time flies like an arrow..."))
        }
    }
```

##### 模式匹配

这个比较容易理解，示例：

```
    object MatchTest extends App {
        def matchTest(x: Int): String = x match {
            case 1 => "one"
            case 2 => "two"
            case _ => "many"
        }
        println(matchTest(3))
    }
```

##### 自身类型（self type）

When a trait extends a class, there is a guarantee that the superclass is present in any class mixing in the trait. Scala has analternate mechanism for guaranteeing this: self types.
When a trait starts out with
this: Type =>
then it can only be mixed into a subclass of the given type.

示例
```
    scala> trait LoggedException {
        |   this: Exception =>
        |   def log(): Unit = {
        |     println("Please check errors.")
        |   }
        | }
    defined trait LoggedException

    scala> import java.io.File
    import java.io.File

    scala> val file = new File("/user") with LoggedException
    <console>:13: error: illegal inheritance;
    self-type java.io.File with LoggedException does not conform to LoggedException's selftype LoggedException with Exception
        val file = new File("/user") with LoggedException
```

在定义LoggedException使用了this: Exception =>那么意味着LoggedException只能被“混入”Exception的子类中，因为File不是Exception的子类，所以报错。

## 下划线 `_`

`_` 在Scala上通常代表是通配符，占位符。

### 作为标识符

例如定义一个变量 `val _num = 123`

### 作为通配符

#### import语句

例如 `import scala.math._`

#### case语句

```
    object MatchTest extends App {
        def matchTest(x: Int): String = x match {
            case 1 => "one"
            case 2 => "two"
            case _ => "many"
        }
        println(matchTest(3))
    }
```

#### 元组（tuple）访问

```
    scala> val t = (1, 3.14, "Fred")
    t: (Int, Double, String) = (1,3.14,Fred)
    //可以用_1，_2，_3访问这个元组
    scala> t._1
    res3: Int = 1

    scala> t._2
    res4: Double = 3.14

    scala> t._3
    res5: String = Fred
```

可以通过模式匹配获取元组的元素，当不需要某个值的时候可以使用_替代，例如：

```
    scala> val t = (1, 3.14, "Fred")
    t: (Int, Double, String) = (1,3.14,Fred)

    scala> val (first, second, _) = t
    first: Int = 1
    second: Double = 3.14

    scala> val (first, _, _) = t
    first: Int = 1

```

### 将方法转换为函数

请参见 [Scala中Method方法和Function函数的区别](https://www.jianshu.com/p/d5ce4c683703)

### 作为函数的参数

一个匿名的函数传递给一个方法或者函数的时候，scala会尽量推断出参数类型。例如一个完整的匿名函数作为参数可以写为：

```
    scala> def compute(f: (Double)=>Double) = f(3)
    compute: (f: Double => Double)Double

    //传递一个匿名函数作为compute的参数
    scala> compute((x: Double) => 2 * x)
    res1: Double = 6.0
```

如果参数x在=>右侧只出现一次，可以用_替代这个参数，简写为：

```
    scala> compute(2 * _)
    res2: Double = 6.0
```

更常见的使用方式为：

```
    scala> (1 to 9).filter(_ % 2 == 0)
    res0: scala.collection.immutable.IndexedSeq[Int] = Vector(2, 4, 6, 8)

    scala> (1 to 3).map(_ * 3)
    res1: scala.collection.immutable.IndexedSeq[Int] = Vector(3, 6, 9)
```

以上所说的为一元函数，那么对于二元函数，即有两个参数x和y的函数，是如何使用 `_` 的？下面方法需要的参数是一个二元函数，而且函数参数的类型为`T`，可以用 `_` 分别表示二元函数中的参数 `x` 和 `y` 。例如：

```
    scala> List(10, 5, 8, 1, 7).sortWith(_ < _)
    res0: List[Int] = List(1, 5, 7, 8, 10)
```

函数组合的参数

```
scala> def f(s: String) = "f(" + s + ")"
f: (String)java.lang.String

scala> def g(s: String) = "g(" + s + ")"
g: (String)java.lang.String
```

compose 组合其他函数形成一个新的函数 f(g(x))

```
scala> val fComposeG = f _ compose g _
fComposeG: (String) => java.lang.String = <function>

scala> fComposeG("yay")
res0: java.lang.String = f(g(yay))
```

有时候，你并不关心是否能够命名一个类型变量，例如：

```
scala> def count[A](l: List[A]) = l.size
count: [A](List[A])Int
```

这时你可以使用“通配符”取而代之：

```
scala> def count(l: List[_]) = l.size
count: (List[_])Int
```

这相当于是下面代码的简写：

```
scala> def count(l: List[T forSome { type T }]) = l.size
count: (List[T forSome { type T }])Int
```

你也可以为通配符类型变量应用边界：

```
scala> def hashcodes(l: Seq[_ <: AnyRef]) = l map (_.hashCode)
hashcodes: (Seq[_ <: AnyRef])Seq[Int]

scala> hashcodes(Seq(1,2,3))
<console>:7: error: type mismatch;
 found   : Int(1)
 required: AnyRef
Note: primitive types are not implicitly converted to AnyRef.
You can safely force boxing by casting x.asInstanceOf[AnyRef].
       hashcodes(Seq(1,2,3))
                     ^

scala> hashcodes(Seq("one", "two", "three"))
res1: Seq[Int] = List(110182, 115276, 110339486)
```

### 下划线和其他符号组合的使用方式

#### 下划线与等号 `_=`

自定义setter方法，请参见 [Overriding def with var in Scala](https://www.jianshu.com/p/4a3362ec22de)

#### 下划线与星号 `_*` 

##### 变长参数

例如定义一个变长参数的方法sum，然后计算 `1-5` 的和，可以写为：

```
    scala> def sum(args: Int*) = {
        | var result = 0
        | for (arg <- args) result += arg
        | result
        | }
    sum: (args: Int*)Int

    scala> val s = sum(1,2,3,4,5)
    s: Int = 15
```

但是如果使用这种方式就会报错

```
    scala> val s = sum(1 to 5)
    <console>:12: error: type mismatch;
    found   : scala.collection.immutable.Range.Inclusive
    required: Int
        val s = sum(1 to 5)
                        ^
```

这种情况必须在后面写上: `_*` 将` 1 to 5` 转化为参数序列

```
    scala> val s = sum(1 to 5: _*)
    s: Int = 15
```

##### 变量声明中的模式

例如，下面代码分别将arr中的第一个和第二个值赋给first和second

```
    scala> val arr = Array(1, 2, 3, 4, 5)
    arr: Array[Int] = Array(1, 2, 3, 4, 5)

    scala> val Array(1, 2, _*) = arr

    scala> val Array(first, second, _*) = arr
    first: Int = 1
    second: Int = 2
```

## At符 `@`

### 标识注解

在方法，类，属性上标识一个注解， 如:

```
    @deprecated("the delayedInit mechanism will disappear", "2.11.0")
    override def delayedInit(body: => Unit) {
        initCode += (() => body)
    }
```

### 赋值检测

```
object test {
  def main(args: Array[String]) {
    val b=Some(2)
    val a@Some(1)  =  Some(1)
    println(b)
    println(a)

    val bb= 2
    val aa@"IMF" = "IMF"
    println(bb)
    println(aa)
  }
}
```

输出结果如下，`@` 符号在scala编译中做了一个模式配置的工作。将字符串做了比对，如果值相等，将这个值取到赋值给变量；如果值不相等，匹配不上，就报一个异常

```
Some(2)
Some(1)
2
IMF
```

### 值匹配重命名

使用在match case场景，可以将匹配的值重新命名，示例：

```
def calcType(calc: Calculator) = calc match {
  case Calculator("HP", "20B") => "financial"
  case Calculator("HP", "48G") => "scientific"
  case Calculator("HP", "30B") => "business"
  case c@Calculator(_, _) => "Calculator: %s of unknown type".format(c)
}
```

## `%` 与 `%%`

使用SBT时，在build.st文件中，通常会看到

```
"org.hibernate" % "hibernate-entitymanager" % "4.1.0.Final",
"com.typesafe" %% "play-plugins-mailer" % "2.1"
```

`groupID %% artifactID % revision` 来代替 `groupID % artifactID % revision`

`%%` 表示SBT会增加工程的Scala版本以 `artifact name`

示例：

```
org.scala-tools" % "scala-stm_2.9.1" % "0.3"
```

假定工程的Scala版本为2.9.1，则上面可以简写为

```
org.scala-tools" %% "scala-stm" % "0.3"
```

----- 
参考：  
1. [scala =>符号含义总结](https://blog.csdn.net/bon_mot/article/details/52397933)  
2. [Scala中_(下划线)的常见用法](https://www.jianshu.com/p/0497583ec538)  
3. [Scala中那些令人头痛的符号](https://blog.csdn.net/bobozhengsir/article/details/13023023) 
---
title: "C++技巧之断言Assert"
date: "2009-06-14"
categories:
 - "技术"
tags:
 - "cpp"

---

断言的应该是一种编程的常见技巧。我所应用的断言有两种，一种是动态断言，即大家所熟知的C标准库的assert()宏，一种是C++中的静态断言，即在编译期间检查。

## 动态断言：

assert宏的原型定义在<assert.h>中，其作用是如果它的条件返回错误，则终止程序执行，原型定义：
```
#include <assert.h>  
void assert( int expression );
```
`assert`的作用是先计算表达式`expression` ，如果其值为假（即为0），那么它先向`stderr`打印一条出错信息，然后通过调用`abort` 来终止程序运行。

大家要注意是，其中的表达式为假时，会终止程序运行，包括我在内经常会写错代码，断言一个指针是否为空，往往写成了
`assert(!p);`其实应该写成`assert(p);`。

 `assert`是运行期的判断，并且会强制终止程序，一般要求只能用于`debug`版本中，是为了尽可能快的发现问题。尤其在我所从事的电信软件产品中，`assert`是要从`release`版本中去掉。所以一般开发会重新定义`assert`宏。

## 静态断言：

在新的`C++`标准中`C++0x`中，加了对静态断言的支持，引入了新的关键字`static_assert`来表示静态断言。

使用静态断言，我们可以在程序的编译时期检测一些条件是否成立。但这个关键字太新了，没有几个编译器是支持的(好像VC2008支持，我用VC很少，主要是在linux下C++编程)。

于是可以使用C++现有的模板特性来实现静态断言的功能。`boost`中也已有`BOOST_STATIC_ASSERT`宏的实现，有兴趣的同学可以down下来仔细研究一下，它的断言信息更丰富，下面为我的简单实现：

```
// declare a tempalte class StaticAssert.  
template <bool assertion> struct StaticAssert;  

// only partial specializate parameter's value is true.  
template <> struct StaticAssert<true>   
{  
  enum { VALUE = 1 };  
};

#define STATIC_ASSERT(expression) (void)StaticAssert<expression>::VALUE  
```

原理是，先声明一个模板类，但后面仅仅偏特化参数值为true的类，而为false的类则一个未定义的类，即是一个未完整的类型,编译期间无法找到`StaticAssert<false>::VALUE`类型。举例如下：
```
STATIC_ASSERT(4 == sizeof(long) ); //在 32bit机上OK  
STATIC_ASSERT(4 == sizeof(long) ); //在 64bit机上NG，long为8字节
```  
静态断言在编译时进行处理，不会产生任何运行时刻空间和时间上的开销，这就使得它比assert宏具有更好的效率。另外比较重要的一个特性是如果断言失败，它会产生有意义且充分的诊断信息，帮助程序员快速解决问题。

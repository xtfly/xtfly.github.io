---
title: "C++技巧之宏Macro应用"
date: "2009-06-12"
categories:
 - "技术"
tags:
 - "cpp"

---

1. 宏不要用来定义常量，因为宏变量是没有类型安全，也没有名字空间约束，会造成名字的污染。

2. 宏的展开是一行，所以宏中的注释不能使用`//`，只能使用`/* */`。宏的代码也不能gdb跟踪，宏中代码逻辑要尽量简单。

3. 宏的参数一般情况下使用时要用()括起来，如:
`#define MAX(a, b) a /2 > b ? a /2  : b`
MAX(3,4)使用没有问题，但MAX(3+4, 4)却有问题，因为宏的参数仅为符号替换。
应用定义为`#define MAX(a, b)  (a) / 2 >  (b) ?  (a) /2 : (b)`

4. 宏的连接符分为`#`与`##`
`#`表示一个符号直接转换为字符串，如
`#define CAT(x) "First "#x " Third"
const char * pszStr = CAT(Second);` str的内容就是"First Second Third"，也就是说#会把其后的符号直接加上双引号。
`##`符号会连接两个符号，从而产生新的符号(词法层次)，例如：
`#define NAME( x ) name_##x`
`char* NAME( szlanny );` 宏被展开后将成为：`char* name_szlanny;`

5. 宏中如有存在if等语句产生的分支，要使用do{}while(0)包起来，如
`#define TEST(a ) if ( 0 == a ) dosomething()`
如果在下面使用是会存在问题
```
if ( 1 == b)
    TEST(a ):
else
{
     dootherthing();
}
```
那当代码展开之后，宏中的if与外面的else是一起匹配，而不是else与if ( 1 == b)匹配。
所以上述宏要修改为
```
#define TEST(a )  do {/
 if ( 0 == a )  { dosomething(); }  }while(0)
```

6. 对于可变参宏，可以使用__VA_ARGS__，GCC支持它，但并非所有的编译器支持，如果你的代码要跨平台，慎用。
```
#define LOG( format, ... ) printf( format, __VA_ARGS__ )
 LOG( "%s %d", str, count );
```
`__VA_ARGS__`被自动替换为参数列表。

7. 宏不能嵌套使用，如:
`#define TEST( x ) ( x + TEST( x ) )`，编译器展开过程中发现第二个TEST，那么就将这个TEST当作一般的符号。

8. 当宏的逻辑比较多时，可以考虑宏中使用模板方法来代替宏的逻辑实现。

---
title: "跟我一起复习Java-1"
date: "2019-09-21"
categories:
 - "技术"
tags:
 - "软件开发"
 - "Java"
toc: true
---

# 基本数据类型

| 数据类型        | 大小 | 范围                        | 默认值   |
| :-------------- | :--- | :-------------------------- | :------- |
| byte(字节)      | 8    | -128 - 127                  | 0        |
| shot(短整型)    | 16   | -2^15 - 2^15-1              | 0        |
| int(整型)       | 32   | -2^31 - 2^31-1              | 0        |
| long(长整型)    | 64   | -2^63 - 2^63-1              | 0        |
| float(浮点型)   | 32   | 1.4013E-45 - 3.4028E+38     | 0.0f     |
| double(双精度)  | 64   | -1.7976E+308 - 1.79769E+308 | 0.0d     |
| char(字符型)    | 16   | `\u0000 - u\ffff`           | `\u0000` |
| boolean(布尔型) | 1    | true/false                  | false    |

<!--more-->

# 控制语句

主要例举一些需要注意的点

## swith

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

## for

 - 无限循环： for（；；）
 - index for: for(int i = 0; i < MAX; i++)
 - for each: for（a : iterator）  Java 5

## labeled loop

对循环打标签，用于控制语句跳到不同层次的循环。

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

# 正则表达式

正则表达式定义了字符串的模式，可以用来搜索、编辑或处理文本。并不仅限于某一种语言，但是在每种语言中有细微的差别。

Java 正则表达式和 Perl 的是最为相似的。

 - Pattern 类：是一个正则表达式的编译表示。Pattern 类没有公共构造方法。要创建一个 Pattern 对象，你必须首先调用其公共静态编译方法，它返回一个 Pattern 对象。该方法接受一个正则表达式作为它的第一个参数。
 - Matcher 类： Matcher 对象是对输入字符串进行解释和匹配操作的引擎。与Pattern 类一样，Matcher 也没有公共构造方法。你需要调用 Pattern 对象的 matcher 方法来获得一个 Matcher 对象。

## 捕获组

捕获组是把多个字符当一个单独单元进行处理的方法，它通过对括号内的字符分组来创建。

捕获组是通过从左至右计算其开括号来编号。例如，在表达式`（（A）（B（C）））`，有四个这样的组：

 - `((A)(B(C)))`
 - `(A)`
 - `(B(C))`
 - `(C)`

可以通过调用 matcher 对象的 groupCount 方法来查看表达式有多少个分组。groupCount 方法返回一个 int 值，表示matcher对象当前有多个捕获组。 还有一个特殊的组（group(0)），它总是代表整个表达式。该组不包括在 groupCount 的返回值中。


## 语法

**元字符**

 - `.` : 匹配除换行符以外的任意字符
 - `\w`: 匹配字母或数字或下划线或汉字 
 - `\s`: 匹配任意的空白符
 - `\d`: 匹配数字
 - `^`: 匹配字符串的开始
 - `$`: 匹配字符串的结束
 - `\b`: 匹配单词的边界

**重复**

 - `*` : 重复零次或更多次
 - `+` : 重复一次或更多次
 - `?` : 重复零次或一次
 - `{n}` : 重复n次
 - `{n,}` : 重复n次或更多次
 - `{n,m}` : 重复n到m次

**反义**

 - `[^x]` : 匹配除了x以外的任意字符
 - `[^aeiou]` : 匹配除了aeiou这几个字母以外的任意字符
 - `\W` : 匹配任意不是字母，数字，下划线，汉字的字符
 - `\S` : 匹配任意不是空白符的字符
 - `\D` : 匹配任意非数字的字符
 - `\B` : 匹配不是单词开头或结束的位置

**零宽断言**

 - `(?=exp)` : 匹配exp前面的位置
 - `(?<=exp)` : 匹配exp后面的位置
 - `(?!exp)` : 匹配后面跟的不是exp的位置
 - `(?<!exp)` : 匹配前面不是exp的位置
  
**注释**

 - `(?#comment)` : 注释

**贪婪与懒惰**

 - `*?` : 重复任意次，但尽可能少重复
 - `+?` : 重复1次或更多次，但尽可能少重复
 - `??` : 重复0次或1次，但尽可能少重复
 - `{n,m}?` : 重复n到m次，但尽可能少重复
 - `{n,}?` : 重复n次以上，但尽可能少重复

**其他**

 - POSIX 字符类: 如`\p{Lower}`表示小写字母字符：[a-z]
 - 引用： `\`, `\Q`, `\E`
  

----- 

注：以上内容收集于互联网多篇文章，在此感谢原作者们。 

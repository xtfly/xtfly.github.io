---
title: "编写短小的函数/方法"
date: "2019-05-29"
categories:
 - "技术"
tags:
 - "软件开发"
toc: true
---

# 函数与方法

我们经常会遇到两个词，函数（Function）与方法（Method），简言之： 
 
  - 函数不属于任何对象
  - 方法是关联到对象内的函数

他们的区别：
 
  - 函数是面向过程编程中，为解决问题划分每个步骤的体现
  - 方法是面向对象编程中，对象能提供的能力或行为的体现
  
方法底层实现本质还是函数，只是隐式传递了对象引用或指针，方法最终通过转化为函数的形式进行调用。为了简化后面的叙述，方法与函数统一称函数，不再区分。

他们的必要性：

 - 让代码可以重复使用，他们是”积木“
 - 函数黑盒特性，有效封装，隐藏细节
<!--more-->

# 短小的好处

`Kent Beck` 在 `Smalltalk Best Practice Patterns` 中定义的 `Composed Method` 模式。指出函数应该只能做一个层次上的抽象。函数应该是短小的，对于Smalltalk函数大小应该在一至六行。

如果是现代语言像Java/Go/Scala/Kotlin等，每个函数应该是控制有效行数在 **20到25** 行 。短小的函数会带来如下好处：

 - 维护成本：越长的函数越要花费更大的成本去了解它要做什么，以及在什么地方作修改。而对于小函数，你可以快速的查明应该在何处作修改（尤其是在应用测试驱动开发的时候）
 - 代码可读性：在初始的学习曲线之后，小函数使得你更容易理解一个类要做什么。而且你不必滑动窗口就可以理解代码
 - 拥有重用潜力：把函数分解成一些小的模块，你可以识别出代码中通用的抽象，通过使用这些通用的抽象使你的代码总量急剧下降
 - 拥有子类化潜力：函数越长，你就越难以创建一个子类使用这个函数
 - 命名：小的函数命名起来要容易一些，因为它做的事情少
 - 性能属性：遇到了性能问题，一个使用composed method的系统更容易定位性能瓶颈
 - 灵活性：小函数使得重构更加容易，并且容易找到设计缺陷，比如feature envy
 - 代码质量：把大函数分解成小函数，定位隐晦的错误更加容易
 - 最小化注释：虽然注释是很有价值的东西，大多数注释可以通过谨慎的命名和调整结构消除。代码已经能说清楚，则注释是没有必要的。

注：来自[Small Methods: Nine Benefits of Making Your Methods Shorter](http://langrsoft.com/articles/smallMethods.shtml)

# 影响因素

为了达成短小的函数，业界已有非常多的度量指标，指导我们写出可读性很好的函数。当然我们不能只是奔着降低指标而去，指标只是手段，不是目标。

## 圈复杂度

圈复杂度是一种衡量代码复杂程度的标准，由`Thomas J. McCabe, Sr.`提出。它用来衡量一个模块判定结构的复杂程度，数量上表现为独立的行路径条数。

圈复杂度高带来的害处有（建议平均值控制在15以内）：

 - 过高说明逻辑复杂不容易理解
 - 逻辑复杂可能导致质量低下
 - 路径过多难以测试覆盖
  
圈复杂度高主要表现：
 
  - 分支语句多：if/else, switch/case, for, while
  - 表达式复杂：条件表达式复杂，3个及以上逻辑运算符

降低圈复杂度方法：

 - 抽取函数：独立业务代码封装为函数，通过函数名诠释代码作用，做到见名知意
 - 合并重复：不同条件的分支，有相似的处理，可以提炼出分支以外，或者封装为函数
 - 分解条件式：复杂的条件表达式，使用函数进行封装
 - 移除控制标记：有控制标签作为条件的，使用break/return取代
 - 设计模式：对于同一层的if/else, switch/case分支过多，可考虑采用状态机或策略模式、表驱动法（Map查找）
 - 单一职责：一个函数应该只实现一个功能点

## 嵌套层次

不恰当的if/else与try/catch语句，是最为常见的嵌套层次过深代码；对于异步api，像nodejs还没有promise与async/await语言特性时，也会导致callback嵌套层次过深。

嵌套层次过深带来害处显而易见（建议层次不要超过4层）：

 - 圈复杂度变高，难以理解与测试
 - 有时像”横放着的金字塔“，代码太长，不方法阅读

降低if/else嵌套层次方法：

 - 少使用else：使用`if + return`，代码反向判断，避免进入 else 分支，提前 return
 - 减少非空判断：如Java8引用Optional的orElse或orElseGet方法
 - 合并if条件判断：使用条件与（&&），利用条件短路的特性
 - 三元表达式：如Java中的 ` e = (a==b) ? c : d` ，c与d可以是函数调用

 try/catch可以再嵌套try/catch，但也是最容易出逻辑问题的地方，降低try/catch嵌套层次方法：

  - 抽取函数：try与catch的中各代码块超过10行以上，建议是分别抽取函数，try/catch块内只有函数调用
  - 合并try/catch：分析是否可以合并try/catch到同一层次
  - 折分try/catch：让try的范围更小，尽早catch，避免大try中不必要的嵌套

我们会经常对数据进行操作，Java8引入Stream对象。若能合理使用它，也可以减少迭代（for语句--> map方法调用）、条件判断（if/else语句 --> filter方法调用）组合带来的嵌套。面向过程变成面向函数式编程，也会让你的代码更为的清爽。

## 参数个数

函数的输入参数过多，会使函数易于受外部的变化影响，从而导致函数变得不稳定，代码维护困难。过多的控制标记参数也会导致参数的使用组合变多，代码的分支路径变多，也就增加了测试的工作量。

参数个数多少个才算多？建议是不超过5个。

是否要将参数封装成对象，不能只看参数的数量，还要看它的业务意义，有时封装成对象反倒增加了阅读成本。参数过多说明它依赖过多，我们需要考虑是否需要对函数进一步拆分。

对于构造方法参数过多，我们可以采用 `链式调用` ，它是一种Builder模式，比一堆的参数列表调用更有意义，也不容易出现赋值顺序出错而导致问题。

## 变量个数

函数局部变量个数多，是函数的逻辑实现需要依赖较多的外数或内部数据，依赖多则会导致复杂度增加。

局部变量个数多少个才算多？建议是不超过5个。

解决局部变量变多的另一种思路是 `Replace Method with Method Object` (来自重构一书)，以函数对象取代函数，做法是将函数放进一个单独的对象当中，使用这个单独对象的值域（filed）来替代原函数中的局部变量。若这个单独的对象使用的范围非常小，我们通过把它声明为内部静态类。


# 结语

千里之堤溃于蚁泬，短小精悍的函数，是构建健壮的软件基石。千里之行始于足下，从编写短小精悍的函数开始。

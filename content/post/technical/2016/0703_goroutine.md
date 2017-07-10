---
title: "Goroutine陷阱"
date: "2016-07-03"
categories:
 - "技术"
tags:
 - "go"
toc: true

---

Go在语言层面通过Goroutine与channel来支持并发编程，使并发编程看似变得异常简单，但通过最近一段时间的编码，越来越觉得简单的东西，很容易会被滥用。Java的标准库也让多线程编程变得简单，但想当初在公司定位Java的问题，发现很多的同学由于没有深入了解Java Thread的机制，Thread直接New从不管理复用，那Goroutine肯定也要面临这类的问题。

## Goroutine泄漏问题
Rob Pike在2012年的Google I/O大会上所做的“Go Concurrency Patterns”的演讲上，说道过几种基础的并发模式。从一组目标中获取第一个结果就是其中之一。
<!--more-->

```go
func First(query string, replicas ...Search) Result {  
    c := make(chan Result)
    searchReplica := func(i int) { c <- replicas[i](query) }
    for i := range replicas {
        go searchReplica(i)
    }
    return <-c
}
```
在First()函数中的结果channel是没缓存的。这意味着只有第一个goroutine返回。其他的goroutine会困在尝试发送结果的过程中，如果你有不止一个的重复时，每个调用将会泄露资源。为了避免泄露，你需要确保所有的goroutine退出。一个不错的方法是使用一个有足够保存所有缓存结果的channel。

```go
func First(query string, replicas ...Search) Result {  
    c := make(chan Result,len(replicas))
    searchReplica := func(i int) { c <- replicas[i](query) }
    for i := range replicas {
        go searchReplica(i)
    }
    return <-c
}
```

另一个不错的解决方法是使用一个有default情况的select语句和一个保存一个缓存结果的channel。default情况保证了即使当结果channel无法收到消息的情况下，goroutine也不会堵塞。

```go
func First(query string, replicas ...Search) Result {  
    c := make(chan Result,1)
    searchReplica := func(i int) { 
        select {
        case c <- replicas[i](query):
        default:
        }
    }
    for i := range replicas {
        go searchReplica(i)
    }
    return <-c
}
```

你也可以使用特殊的取消channel来终止workers。

```go
func First(query string, replicas ...Search) Result {  
    c := make(chan Result)
    done := make(chan struct{})
    defer close(done)
    searchReplica := func(i int) { 
        select {
        case c <- replicas[i](query):
        case <- done:
        }
    }
    for i := range replicas {
        go searchReplica(i)
    }
    return <-c
}
```

为何在演讲中会包含这些bug？Rob Pike仅仅是不想把演示复杂化。这么做是合理的，但对于Go新手而言，可能会直接使用类似代码，而不去思考它可能有问题。

## Goroutine Race问题

Go语言支持函数中定义函数，看下一个例子：

```go
func saveRequest(request *Request) {
            ….
            go func() {
                     request.Users = []{1,2,3}
                      …
                      db.Save(request)
            }
 
}
```

很多情况下，由于程序员对goroutine了解不够深入，又由于goroutine使用很容易。为了性能，很容易把一个同步函数变成异步函数，但这违背了go”不要通过共享内存来通信，相反应该通过通信来共享内存“的原则。即上述的例子中起了一个goroutine，并修改了request指针指向的对象。即使对request只读，也可能不是安全，因为你无法保证request指针不在其它goroutine中修改。

在本质上讲，goroutine的使用会增加了函数的危险系数，尤其是函数参数传递指针时。任何一个对象的操作，如果没有加上锁，当项目比较庞大时，可能不知道这个对象是不是会引起多个goroutine竞争。

什么是goroutine race（竞争）问题？官网的文章
[Introducing the Go Race Detect](http://blog.golang.org/race-detector)给出的例子如下：

```go
package main

import(
    "time"
    "fmt"
    "math/rand"
)

func main() {
    start := time.Now()
    var t *time.Timer
    t = time.AfterFunc(randomDuration(), func() {
        fmt.Println(time.Now().Sub(start))
        t.Reset(randomDuration())
    })
    time.Sleep(5 * time.Second)
}

func randomDuration() time.Duration {
    return time.Duration(rand.Int63n(1e9))
}
```

这个例子看起来没任何问题，但是实际上，time.AfterFunc是会另外启动一个goroutine来进行计时和执行func()。由于func中有对t(Timer)进行操作(t.Reset)，而主goroutine也有对t进行操作(t=time.After)。
这个时候，其实有可能会造成两个goroutine对同一个变量进行竞争的情况。

那什么才是goroutine的使用正确姿势，怎么理解“通过通信来共享内存”来避免Race问题？先看一个例子：

```go
type SimpleAccount struct{
  balance int
}

func NewSimpleAccount(balance int) *SimpleAccount {
  return &SimpleAccount{balance: balance}
}

func (acc *SimpleAccount) Deposit(amount uint) {
  acc.setBalance(acc.balance + int(amount))
}

func (acc *SimpleAccount) Withdraw(amount uint) {
  if acc.balance >= int(amount) {
    acc.setBalance(acc.balance - int(amount))
  } else {
    panic("杰克穷死")
  }
}

func (acc *SimpleAccount) Balance() int {
  return acc.balance
}

func (acc *SimpleAccount) setBalance(balance int) {
  acc.balance = balance
}

type ConcurrentAccount struct {
  account     *SimpleAccount
  deposits    chan uint
  withdrawals chan uint
  balances    chan chan int
}

func NewConcurrentAccount(amount int) *ConcurrentAccount{
  acc := &ConcurrentAccount{
    account :    &SimpleAccount{balance: amount},
    deposits:    make(chan uint),
    withdrawals: make(chan uint),
    balances:    make(chan chan int),
  }
  acc.listen()

  return acc
}

func (acc *ConcurrentAccount) Balance() int {
  ch := make(chan int)
  acc.balances <- ch
  return <-ch
}

func (acc *ConcurrentAccount) Deposit(amount uint) {
  acc.deposits <- amount
}

func (acc *ConcurrentAccount) Withdraw(amount uint) {
  acc.withdrawals <- amount
}

func (acc *ConcurrentAccount) listen() {
  go func() {
    for {
      select {
      case amnt := <-acc.deposits:
        acc.account.Deposit(amnt)
      case amnt := <-acc.withdrawals:
        acc.account.Withdraw(amnt)
      case ch := <-acc.balances:
        ch <- acc.account.Balance()
      }
    }
  }()
}
```
上面的例子，SimpleAccount所有方法，当多goroutine操作是不安全的，而通过ConcurrentAccount封装，所有处理都统一通过channel通信到listen开启的goroutine，即只有一个goroutine能操作SimpleAccount中成员变量，那也就不会发现Goroutine Race问题。

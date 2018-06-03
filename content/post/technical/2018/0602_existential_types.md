---
title: "Rust支持既存类型的理解"
date: "2018-06-02"
categories:
 - "技术"
tags:
 - "Rust"
toc: true

---

最近利用周末时间来学习Rust编程，发现新发布的1.26版本，带来了[`impl Trait`](https://github.com/rust-lang/rust/pull/49255)，一时对它的写法难以理解，今天又找点资料再温习一下。

> impl Trait is now stable allowing you to have abstract types in returns or in function parameters. e.g. fn foo() -> impl Iterator<Item=u8> or fn open(path: impl AsRef<Path>).

<!--more-->

## 既存类型

`impl Trait`是对[`既存类型(Existential types)`](https://en.wikipedia.org/wiki/Type_system#Existential_types)的支持，那什么是既存类型?

> Existential types are frequently used in connection with record types to represent modules and abstract data types, due to their ability to separate implementation from interface. For example, the type "T = ∃X { a: X; f: (X → int); }" describes a module interface that has a data member named a of type X and a function named f that takes a parameter of the same type X and returns an integer. This could be implemented in different ways; for example:
> 
> intT = { a: int; f: (int → int); }   
> floatT = { a: float; f: (float → int); } 
> 
> These types are both subtypes of the more general existential type T and correspond to concrete implementation types, so any value of one of these types is a value of type T. Given a value "t" of type "T", we know that "t.f(t.a)" is well-typed, regardless of what the abstract type X is. This gives flexibility for choosing types suited to a particular implementation while clients that use only values of the interface type—the existential type—are isolated from these choices.
> 
> In general it's impossible for the typechecker to infer which existential type a given module belongs to. In the above example intT { a: int; f: (int → int); } could also have the type ∃X { a: X; f: (int → int); }. The simplest solution is to annotate every module with its intended type, e.g.:
> 
> intT = { a: int; f: (int → int); } as ∃X { a: X; f: (X → int); }  
> Although abstract data types and modules had been implemented in programming languages for quite some time, it wasn't until 1988 that John C. Mitchell and Gordon Plotkin established the formal theory under the slogan: "Abstract [data] types have existential type".[24] The theory is a second-order typed lambda calculus similar to System F, but with existential instead of universal quantification.


从上面wiki的介绍，既存类型相对还是比较容易理解，既存类型早已发明，有着距今约30年的历史。既存类型是用来表达一个为模块(module)与抽象类型(ADT) 的一种类型，它连接record types（如rust中的struct），其实现与接口分离。说白一点，就是Java中interface或GO的Interface。

在Rust中，我们可以采用`impl Trait`指定函数的返回类型，而不必指出具体是哪一种类型。例如：

```
fn foo() -> impl Trait {
    // ...
}
```

如果是这样，为什么Rust不直接设计为如下，Trait像Java8中interface或GO的Interface，函数返回interface：

```
fn foo() -> Trait {
    // ...
}

// 或者
fn  foo2<T : Trait >() -> T  {
}
```

遗憾地是，上面的写法在Rust都不可能编译通过，因为在Rust变量lifetime之说，返回值的lifetime不能悬空，那只能变成这种写法

```
fn foo3() -> Box<Trait> {
    Box::new(5) as Box<Trait>
}
```

这样写是不是很繁琐，不过，使用Box<Trait>意味着动态分配，我们并非总是希望或需要这样，而`impl Trait`确保了静态分配。这种方法使foo仅能返回同样的类型。

```
trait Trait {
    fn method(&self);
}

// 表示类型T实现了Trait
impl<T: Sized> Trait for T {
    fn method(&self) {    
    }
}

fn new_foo1() -> impl Trait {
    5  // 我们可以仅返回一个i32类型的值
}

fn new_foo2() -> impl Trait {
    5.0f32  // 我们可以仅返回一个f32类型的值
}
```

在定义返回闭包的函数时，新的`impl Trait`语法也可以如下使用，闭包函数实现了特性Fn：

```
fn foo() -> impl Fn(i32) -> i32 {
    |x| x + 1
}
```

另外，`impl Trait`语法还可以用于替代泛型类型的声明，如下例所示，虽然在这种情况下，它定义了一个通用类型，而不是存在类型：

```
// 之前
fn foo<T: Trait>(x: T) {

// 之后
fn foo(x: impl Trait) {
```

从上面来看，`impl Trait`其实就是一种语法糖而已，在其中语言中司空见惯的用法，由于在Rust的lifetime管理，简单问题复杂化了。


## 具体应用

actix是rust实现的一个web框架，它很快就使用到`impl Trait`，如下所示：

```
[derive(Serialize)]
struct Measurement {
    temperature: f32,
}

fn hello_world() -> impl Responder {
    "Hello World!"
}

fn greet(req: HttpRequest) -> impl Responder {
    let to = req.match_info().get("name").unwrap_or("World");
    format!("Hello {}!", to)
}

fn current_temperature(_req: HttpRequest) -> impl Responder {
    Json(Measurement { temperature: 42.3 })
}
```

其中Responder是一个Trait，它定义如下：

```
// https://github.com/actix/actix-web/blob/master/src/handler.rs#L24

pub trait Responder {
    /// The associated item which can be returned.
    type Item: Into<AsyncResult<HttpResponse>>;

    /// The associated error which can be returned.
    type Error: Into<Error>;

    /// Convert itself to `AsyncResult` or `Error`.
    fn respond_to<S: 'static>(
        self, req: &HttpRequest<S>,
    ) -> Result<Self::Item, Self::Error>;

```

Json是一个struct，它的实现在json.rs文件，也是实现了Responder Trait，在respond_to方法中对T进行了序列化，并生成Result对象

```
// https://github.com/actix/actix-web/blob/master/src/json.rs#L119

impl<T: Serialize> Responder for Json<T> {
    type Item = HttpResponse;
    type Error = Error;

    fn respond_to<S>(self, req: &HttpRequest<S>) -> Result<HttpResponse, Error> {
        let body = serde_json::to_string(&self.0)?;

        Ok(req
            .build_response(StatusCode::OK)
            .content_type("application/json")
            .body(body))
    }
}
```

为什么直接返回"Hello World!"与format!("Hello {}!", to)也行，它是怎么做到，原因在于在handler.rs中AsyncResult实现From Trait，支持把任一类型转成AsyncResult。

```
https://github.com/actix/actix-web/blob/master/src/handler.rs#L292

impl<T> From<T> for AsyncResult<T> {
    #[inline]
    fn from(resp: T) -> AsyncResult<T> {
        AsyncResult(Some(AsyncResultItem::Ok(resp)))
    }
}

```
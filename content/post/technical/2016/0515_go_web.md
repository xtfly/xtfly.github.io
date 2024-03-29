---
title: "Golang Web开发"
date: "2016-05-15"
categories:
 - "技术"
tags:
 - "go"
 - "web"
toc: true
---

## 标准库[net/http]

采用Golang来开发Web应用或Rest接口的应用还是比较容易的。golang标准库就提供对Http协议的封装，主要涉及到`net/http`包，它包括了HTTP相关的各种函数、类型、变量等标识符。标准库的`net/http`是支持HTTP1.1协议，而目前Go1.6也支持HTTP2.0，包放在` golang.org/x/net/http2`,后续可能会移到标准库。

`net/http`库中主要涉及到如下几个类型与接口：

### Request结构体

封装了HTTP的请求消息，其结构如下，可以很方便的地取出Method，Header与Body。
<!--more-->

  ```
  type Request struct {
      Method string
      URL *url.URL
      Proto      string
      ProtoMajor int
      ProtoMinor int
      Header Header
      Body io.ReadCloser
      ContentLength int64
      TransferEncoding []string
      Close bool
      Host string
      Form url.Values
      PostForm url.Values
      MultipartForm *multipart.Form
      Trailer Header
      RemoteAddr string
      RequestURI string
      TLS *tls.ConnectionState
      Cancel <-chan struct{}
  }
  ```

### Response结构体

封装HTTP的响应消息，其结构如下，Response会关联Request。

  ```
  type Response struct {
    Status     string
    StatusCode int
    Proto      string
    ProtoMajor int
    ProtoMinor int
    Header Header
    Body io.ReadCloser
    ContentLength int64
    TransferEncoding []string
    Close bool
    Trailer Header
    Request *Request
    TLS *tls.ConnectionState
 }
  ```

### Handler接口

用于构建Response。应用开发就编写各种实现该Handler接口的类型，并在该类型的ServeHTTP方法中编写服务器响应逻辑。

 ```
 type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
 }
 ```

### ResponseWriter接口

即应用通过各种Handler操作ResponseWriter接口来构建Response。ResponseWriter实现了`io.Writer`接口，可以写入响应的Body，`WriteHeader`方法用于向HTTP响应信息写入状态码，但必须先于`Writer`方法调用。若不调用`WriteHeader`，使用`Write`方法会自动写入状态码`http.StatusOK`。

 ```
 type ResponseWriter interface {
    Header() Header
    Write([]byte) (int, error)
    WriteHeader(int)
 }
 ```

### ListenAndServe函数

启动HTTP服务，需要构建Server对象，并调用该Server的`ListenAndServe`方法，Server是HTTP服务的主控器。期结构定义如下，应用可以设置HTTP监听的地址，配置TLS，以及一些其它参数配置。

```
type Server struct {
    Addr           string        // TCP address to listen on, ":http" if empty
    Handler        Handler       // handler to invoke, http.DefaultServeMux if nil
    ReadTimeout    time.Duration // maximum duration before timing out read of the request
    WriteTimeout   time.Duration // maximum duration before timing out write of the response
    MaxHeaderBytes int           // maximum size of request headers, DefaultMaxHeaderBytes if 0
    TLSConfig      *tls.Config   // optional TLS config, used by ListenAndServeTLS
    TLSNextProto map[string]func(*Server, *tls.Conn, Handler)
    ConnState func(net.Conn, ConnState)
    ErrorLog *log.Logger
    disableKeepAlives int32     // accessed atomically.
    nextProtoOnce     sync.Once // guards initialization of TLSNextProto in Serve
    nextProtoErr      error
}
```

Server需要关注如下几个方法，从方法名就可能知道它的用途。

```
func (srv *Server) ListenAndServe() error
func (srv *Server) Serve(l net.Listener) error
```

### ServeMux结构体

用于HTTP路由配置，其结构体定义如下：

```
type ServeMux struct {
    mu    sync.RWMutex
    m     map[string]muxEntry
    hosts bool // whether any patterns contain hostnames
}
```

ServeMux有如下几个方法，用于配置HTTP与URL的映射关系。其实ServeMux也是实现`ServeHTTP`接口，其ServeHTTP方法完成了ServeMux的主要功能，即根据HTTP请求找出最佳匹配的`Handler`并执行之，它本身就是一个多`Handler`封装器，是各个`Handler`执行的总入口。

```
func (mux *ServeMux) Handle(pattern string, handler Handler)
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request))
func (mux *ServeMux) Handler(r *Request) (h Handler, pattern string)
func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request)
```

ServeMux的路由功能是非常简单的，其只支持路径匹配，且匹配能力不强，也不支持对Method的匹配。`net/http`包已经为我们定义了一个可导出的ServeMux类型的变量`DefaultServeMux`。`net/http`包也提供了注册`Handler`的方法，它其实也是操作`DefaultServeMux`：

  * 调用`http.Handle`或`http.HandleFunc`实际上就是在调用`DefaultServeMux`对应的方法。
  * 若`ListenAndServe`的第二个参数为nil，它也默认使用`DefaultServeMux`.

##  第三方库[fasthttp]

说到Golang的http，也不是只有标准库一家，Github也有人开源了[fasthttp](https://github.com/valyala/fasthttp)，并号称比`net/http`包快10倍，上面介绍的[echo](https://github.com/labstack/echo)，底层同时支持`net/http`与`fasthttp`，其性能测试对比如下：
![echo perform](https://camo.githubusercontent.com/b3432f107b2bdaaca11a4ee0225edeb121b02607/687474703a2f2f692e696d6775722e636f6d2f665a566e4b35322e706e67)
但是由于`fasthttp`的API与`net/http`完全不同，这使得无法重用目前基于`net/http`开发的路由，Handler等工具，这也让人在选择它时不得不面临考虑的问题。

##  工具或框架

由于Golang提供了标准库`net/http`，使得开发Go的Web框架变得很简单，在Github上可以搜索到各种不同层次的框架。

###  路由工具

  * [gorilla/mux](https://github.com/gorilla/mux)
  * [julienschmidt/httprouter](https://github.com/julienschmidt/httprouter)

###  Handler工具

  * [gorilla/handlers](https://github.com/gorilla/handlers)
  * [codegangsta/negroni](https://github.com/codegangsta/negroni)

###  轻量框架

  * [echo](https://github.com/labstack/echo)，底层支持绑定fasthttp，号称10倍快于其它框架。
  * [goji](https://github.com/goji/goji)，借鉴了Sinatra了思想。
  * [martini](https://github.com/go-martini/martini)，提供了丰富的中间件。
  * [goin](https://github.com/gin-gonic/gin)，借鉴了Martini，号称比它更快。
  * [macaron](https://github.com/go-macaron/macaron)，其思路来自martini，个人感觉API比martini方便很多。

### 全功能框架

  * [web.go](https://github.com/hoisie/web)，其思路来自web.py。
  * [beego](http://beego.me/)，其思路来自Tornado, Sinatra与Flask框架。
  * [revel](http://revel.github.io/)，其思路完全来自Java的Play Framework。

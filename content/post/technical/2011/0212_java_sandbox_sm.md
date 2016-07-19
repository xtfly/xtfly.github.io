---
title: "[WebApp沙箱]SecurityManager运用"
date: "2011-03-12"
categories:
 - "技术"
tags:
 - "Java"

---


在JRE类白名单能控制类的使用权限（[请点击](/post/technical/110311_java_sandbox_cl)），但控制不了一些资源的访问权限。如默认情况下可访问机器下的任意资源，如读取、删除一些文件，网络操作，创建进程与线程等。必须对Web容器下的WebApp进行资源权限访问控制。

#### Security Manager

Java从JDK 1.0开始就实现一套安全架构，主要用于Applet。在这种体系下Java Code的执行环境被严格划分为两部分，本地代码可以访问计算机的所有资源，而远端代码（Remote Code，主要是Applet）只能支行在严格限制的沙箱里面。安全管理器（`SecurityManager`）作为一个子系统来决定哪些资源允许沙箱中程序访问。这是一种运行期的安全检查。

`SecurityManager`是一个API级别的，可自定义的安全策略管理器，它深入到Java API中，在各处都可以见到它的身影。默认情况下，Java应用程序是不设置`SecurityManager`实例的（意味着不会起到安全检查），这个实例需要我们在程序启动时通过`System.setSecurityManager`来设置。一般情况下，检查权限是通过`SecurityManager.checkPermission(Permission perm)`来完成的。外部程序通过创建`Permission`实例，传递给前面的`check`方法。`Permission`是一个抽象类，需要继承它实现不同的权限验证，比如`FilePermission`，代表对某个文件的读写权限。`new FilePermission("test.txt", "read")；`将这个实例传给`SecurityManager`，检查是否要读test.txt这个文件。

但`SecurityManager`也是一个全局管理类，一旦设置，则同容器中所有代码将会受到影响。但我们需要仅仅是对WebApp运行期的资源安全访问控制检查。

#### 检查Permission时机

所以在设计方案时必须考虑对WebApp进行的资源授权只针对WebApp，不能影响Web容器其它代码运行。由于检查权限是通过`SecurityManager.checkPermission(Permission perm)`来完成的，如果在`checkPermission`实现很复杂的逻辑会对性能造成影响。所以需要分二个层次来设计Security Manager的设置：

  * 当Web容器启动时不设置任何的`SecurityManager`
  * WebApp支行时采用新的`SecurityManager`类，在部署它时指定新`SecurityManager`类与`Policy`,在自定义的Filter中init方法中实现

重载`java.security.SecurityManager`(假定子类名定为`CustomSecurityManager`)。它主要是重载如下几个方法：

  * `checkPermission(Permission perm)`
  * `checkPermission(Permission perm, Object context)`
  * `checkAccess(ThreadGroup g)`
  * `checkAccess(Threa t)`

在两个`checkPermission`方法中主要是判断不是不WebApp的工作线程，如果是再做授权检查，使用自定义的Permissions。否则不做任何的处理.

在两个`checkAccess`方法中，对Thread权限如创建做一些检查特殊处理,如检查 `RuntimePermission("modifyThread")`与`RuntimePermission("modifyThreadGroup")`。

如果判断WebApp执行线程？由于不允许WebApp创建新的线程，那一个WebApp的一次http请求在Servlet的service方法实现的逻辑肯定只会在一个线程调用栈中。在Servlet的service方法入口前设置当前线程名到系统环境量Value为true，在service方法出口后设置当前线程名到系统环境量Value为false，为了能把上面的`Permission`只限制在WebApp中使用。需要在`CustomSecurityManager.checkPermission`根据当前线程名在系统环境量Value是否为true来判断是否需要做`Permission`检查。

如何在Servlet的service方法入口设置环境变量？Servlet规范中的Filter机制可以使得Web请求在交给Web Servlet处理前进行对请求的预先处理，以及Web Servlet处理完成之后响应后处理。也就是说在相同的URL请求下，容器会优先由Filter处理，再给Web Servlet处理，利用这个特性完成对当前线程名在系统环境变量中的设置。

同样，在Filter的init方法也就可以对`CustomSecurityManager`注册到系统全局的`SecurityManager`中。

#### 自定义Permission

配置WebApp安全策略的`Permission`，可以基于Policy文件配置，以不同的CodeBase来区分不同的权限。由于配置Policy文件时，并不知道WebApp war包解压的具体目录。以Jetty为例，默认会把War解压在java.io.tmpdir目录下，那对WebApp的CodeBase可设置为java.io.tmpdir，否则根据部署实际目录来调整。

另外，需要对容器的其它jar文件的代码权限授权。由于类动态加载的原因，WebApp ClassLoder会委托它的双亲加载。如果不设置，也会在WebApp的工作线程中，会导致在Servlet运行时报一些权限禁止，如`SecurityPermission`。通过不同的CodeBase来进行不同的授权，除WebApp的Class之外，假定可以考虑是AllPermission。

那如果WebApp的工作线程调用系统平台提供一些API，而平台API要求可以读写文件，开启特定的端口等，这也与WebApp在同一个线程调用栈中，同样也没有权限，那就又何处理？需要两步来完成对平台API的权限授权：

  * 平台的API Jar包不能放在WebApps目录下，应用与WebApp的War属于不现的保护域（ProtectionDomain）
  * 在平台的API的入口需要加上对`AccessController.doPrivileged`设置，这样是在调用`doPrivileged`的方法相关联的保护域拥有执行被请求的操作的权限，`AccessController`将立即返回，不再在栈的下层继续检查操作权限（也就是说它的代码主休是享受“privileged”特权），它单独负责对它的可使用的资源的访问请求，而不管这个请求是由什么代码所引发的。

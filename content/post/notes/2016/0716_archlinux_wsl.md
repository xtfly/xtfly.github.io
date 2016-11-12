---
title: "Archlinux on WSL"
date: "2016-10-30"
categories:
 - "笔记"
tags:
 - "Archlinux"
 - "WSL"
toc: true

---

最近国庆某东活动，搞了一台HP的笔记本，系统是Win10，经过不断地折腾。在Win10上启用了Windows Subsystem for Linux（简称WSL），并在WSL上安装了Archlinux。加入Insider Preview会员计划，可以最快地获取Win10的最新内部版本，以便及时获取WSL的功能更新。

## WSL

Windows Subsystem for Linux是一个为在Windows 10上能够原生运行 Linux 二进制可执行文件（ELF 格式）的兼容层。 WSL提供了一个微软开发的 Linux 兼容内核接口（不包含Linux代码）。它包含用户模式和内核模式组件，主要是由如下组成：

 - 用户模式会话管理器服务，处理Linux实例的生命周期
 - Pico（可编程输入输出）提供驱动程序（lxss.sys，lxcore.sys），通过转换的Linux系统调用模拟Linux内核
 - 承载未经修改的用户模式Linux的Pico进程，例如/bin/bash

生在用户模式Linux程序和Windows内核组件之间，通过将未修改Linux程序放入Pico进程，我们让Linux系统调用被引导至Windows内核。lxss.sys和lxcore.sys驱动转换Linux系统调用进入NT API并模拟Linux内核。

Bash on Ubuntu on Windows就是WSL 的具体应用。它是由微软与 Canonical 公司合作开发，目标是使纯正的 Ubuntu 14.04映像能下载和解压到用户的本地计算机，并且映像内的工具和实用工具能在此子系统上原生运行。在最近的14959更新中，Ubuntu已是默认为16.04。

## Bash on Ubuntu on Windows

作为一名ArchLinux忠实爱好者，自然想在WSL上运行ArchLinux。参考了一些网上的资料，我已把Win10升级到14955，首先还是先得安装Bash on Ubuntu on Windows：

 1. 开启开发人员模式：设置-更新与恢复-针对开发人员-开发人员模式
 2. 开启WSL子系统：控制面板-程序和功能-启用或关闭 Windows 功能-适用于 Linux 的 Windows 子系统（beta）
 3. 安装Bash on Ubuntu on Windows: 命令提示符（cmd）-输入bash-按提示完成安装

由于需要下载Ubuntu需要从应用商店下载，在天朝的网络，可能会比较慢，甚至会连接不上，我就折腾好久。并且它居然没有断点续传，好几次下载到70%多，就断开了，真让人受不了。

由于后续把Ubuntu替换成Archlinux，需要使用到Archlinux的roofs。squashfs-tools 工具，所以先把Ubuntu的更新源替换成国内的，比如[mirrors.163.com/ubuntu](http://mirrors.163.com/.help/ubuntu.html)或[mirrors.aliyun.com/ubuntu](http://mirrors.aliyun.com/help/ubuntu)。

	$ sudo apt-get update
	$ sudo apt-get install squashfs-tools

## Archlinux on WSL


首先从<<http://mirrors.aliyun.com/archlinux/iso/latest/>>下载最新的ArchISO。

从 ArchISO 中提取出 /arch/x86_64/airoot.sfs 文件放在 Bash on Ubuntu on Windows 能读取的目录下。WSL系统会把Windows的磁盘挂载到/mnt目录下，如D盘则是/mnt/d。

在Ubuntu中把airoot.sfs解压，建议在当前Ubuntu的用户Home目录下执行：

	$ sudo unsquashfs airoot.sfs

然后把Bash窗口关掉，通过Windows的文件资源管理器进行到`C:\Users\<用户名>\AppData\Local\Lxss`文件夹。由于AppData与Lxss都是隐藏目录，可以在地址栏上直接输入路径就可以直接进入，否则需要在文件夹选项 中把“隐藏受保护的操作系统文件”选项取消才能看到。

其中的`rootfs`文件夹就是Linux中的`/`，先把原有的`rootfs`修改其它名称备份，还把之前`airoot.sfs`解压的`squashfs-root`直接剪切到Lxss，重命名为`rootfs`。**注意**，`squashfs-root`不能在Windows下拷贝到`Lxss\rootfs`，由于在WSL与Windows对文件读写操作还是有区别，Windows下拷贝可能存在丢失文件。

先在命令提示符（cmd）用`lxrun /setdefaultuser root` 把默认的用户换成root。再输入bash进入Linux。

这个我们就把Ubuntu替换成Archlinux。我们就可以像使用Archlinux一样来在WSL中使用Archlinux。比如创建新的用户，设置locale，替换Archlinux的更新源。不过由于我最早是在14396版本中使用WSL，还是在使用过程遇到了几个问题：

 - 无法chroot，解决办法：

 升级到14936或以后的Insider Preview版本。
 
 - Archlinux无法更新或安装新的软件，由于keyringVerifying失败，解决办法:

 ```
# pacman-key --init
# pacman-key --populate
```
 
 - locale-gen失败(找不到UTF-8的charmaps文件)，解决办法：

 ```
# cd /usr/share/i18n/charmaps
# tar zxvf UTF-8.gz
# locale-gen
```

 - 编译Go语言程序失败（估计是系统调用没有实现，没有proc），解决办法：

 升级到14959或以后的Insider Preview版本。


## WSL终端

windows下命令提示符（cmd），输入bash可以直接进入WSL，但它的使用体验无法跟Linux中的终端相比。好在网上已有同学先贡献了终端模拟器，都是基于mintty，总算能找回一些在纯Linux中使用终端的感觉。若使用下msys2的同学应该对它比较熟悉。

 - https://github.com/mintty/wsltty
 - https://github.com/goreliu/wsl-terminal

----------

参考：   
[1] https://blog.yoitsu.moe/arch-linux/wsl_with_arch_linux.html  
[2] http://tieba.baidu.com/p/4834742871   
[3] https://linux.cn/article-7857-1.html  
[4] https://linux.cn/article-7209-1.html   





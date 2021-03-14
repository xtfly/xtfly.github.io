---
title: "制作Archlinux Docker基础Image"
date: "2016-04-10"
categories:
 - "笔记"
tags:
 - "Linux"
 - "Docker"

---

想在Mac本上使用Docker来运行Archlinux，家里安装的是长城宽带，无奈从docker hub下载Archlinux基础Image网速无法忍受。在国内的alauda.cn镜像中心搜索到有Archlinux基础Image，可能由于在Docker使用Archlinux国内人比较少，估计alauda.cn的CDN也没有缓存Archlinux基础Image，下载同样也是龟速，下载多次超时就放弃了。

正好个人还有一台老的笔记本安装了Archlinux，那何不自己做一个基础Image。说真的，还没有从零开始做过基础Image。在Docker hub搜索时发现有一个已有的脚本[mkimage-arch.sh](https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh)，于是把它做了些改造，制作过程记录一下：
<!--more-->

  * 源修改为国内的阿里Archlinux镜像源，这个速度快，超赞。
  * 默认安装`openssh`软件，可以通过ssh来连接Container。
  * 增加一个入口脚本`run.sh`，在此脚本主配置`sshd`，并启动`sshd`。

这个过程看似简单，不过还是遇到一些坑，毕竟Archlinux最小系统与自己已安装的Archlinux在使用`sshd`上有些区别，不得不反复修改脚本，Build Image与Run Container来验证：

  * 先是采用systemd来启动sshd，在`run.sh`使用`systemctl enable sshd`是OK的，但`systemctl start sshd`却无法启动报找不到文件。
  * 是systemd的配置问题，也没有再去深究，放弃`systemd`，于是又直接使用`/usr/bin/sshd -D`来启动`sshd`，发现还启动失败报没有sshkey。
  * 再使用`ssh-keygen`来生成系统的`ssh_host_*_key`。
  * 终于`sshd`可以正常启动了，但使用`ssh -p <port> root@<host>`来连接Container，发现报无权限。
  * 于是又得修改`/etc/ssh/sshd_config`，让`root`可以ssh登陆。

修改之后的脚本已提交到个人github上，可以在[这里](https://github.com/xtfly/dockerimage)下载，使用方式如下：

  * 前提Archlinux中也安装了docker引擎
  ```
    # pacman -S docker
    # systemctl enable docker
    # systemctl start docker
  ```
  * 以root用户执行mkimage.sh脚本
  ```
    # ./mkimage.sh
  ```
  * 制作完成之后，使用`docker images`查看，生成一个名为`archlinux`的images
  ```
    # docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    archlinux           latest              dc54036acaa4        About an hour ago   337.2 MB
  ```
  * 使用如下命令生成一个container，容器名为`arch1`
  ```
    # docker run -d --name -arch1 -p 2222:22 archlinux /run.sh
  ```
  * 使用ssh登陆验证，`ssh -p <port> root@127.0.0.1`，默认密码是`123456`。
  * 也可以使用命令`docker exec -it arch1 bash`来执行`bash`进入container操作。

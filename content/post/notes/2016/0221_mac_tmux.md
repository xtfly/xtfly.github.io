---
title: "使用tmux"
date: "2016-02-21"
categories:
 - "笔记"
tags:
 - "Mac"
 - "Shell"
toc: true

---

## 什么是tmux

[tmux](http://tmux.github.io/)是一个支持多会话独立运行的优秀的终端复用软件。它类似[GNU Screen](http://www.gnu.org/software/screen/)，自于OpenBSD，采用BSD授权。使用它最直观的好处就是，通过一个终端登录远程主机并运行tmux后，在其中可以开启多个控制台而无需再“浪费”多余的终端来连接这台远程主机。

## tmux的使用场景

Mac自带的Iterm2很好用啊。既支持多标签，也支持窗体内部Panel的分割，为什么还要用tmux？

 * 与VIM配合使用，打造出更高效、更优雅的终端工具。尤其是在当前大屏幕显示器下，多标签和分割窗体，无缝跳转。既可使用vim来写代码，也可使用tmux来查询代码编译与支行结果。
 * 提供了一个窗体组随时存储和恢复的功能。调试程序，开了一堆窗口。出去吃了个饭，发现SSH超时了，如果使用tmux就attach就能找回原来打开的那些窗口。
<!--more-->

## tmux的基本概念

tmux的主要元素分为三层：

 * Session会话： 一组窗口的集合，通常用来概括同一个任务。session可以有自己的名字便于任务之间的切换。
 * Window 窗口： 单个可见窗口。Windows有自己的编号，也可以认为和ITerm2中的Tab类似。
 * Pane 窗格： 被划分成小块的窗口，类似于Vim中 `C-w +v` 后的效果。

![层次结构](http://ww1.sinaimg.cn/mw690/7178f37egw1esoxc7hp5oj20gm0bkjs6.jpg)

## 安装

在Mac环境下，先安装[Brew](http://brew.sh/)，使用Brew安装tmux命令如下：

    brew install tmux


## 使用

安装完成之后，在终端中直接敲入`tmux`就可启动一个 tmux 的会话。退出会话敲入 `exit` 即可退出当前会话Pane。可以使用 `tmux detach` 命令断开已有的会话。也可以使用快捷键 `Ctrl-b d` 断开会话

tmux 默认使用 `Ctrl-b` 作为激活快捷键的开关,开关开启后就可以通过快捷键迅速调用大量的功能。快捷键参考如下：

### 基础

 * ? 获取帮助信息

### Session管理

 * s 列出所有会话
 * $ 重命名当前的会话
 * d 断开当前的会话

### window管理

 * c 创建一个新窗口
 * , 重命名当前窗口
 * w 列出所有窗口
 * % 水平分割窗口
 * " 竖直分割窗口
 * n 选择下一个窗口
 * p 选择上一个窗口
 * 0~9 选择0~9对应的窗口
 
### pane管理

 * % 创建一个水平窗格
 * " 创建一个竖直窗格
 * h 将光标移入左侧的窗格*
 * j 将光标移入下方的窗格*
 * l 将光标移入右侧的窗格*
 * k 将光标移入上方的窗格*
 * q 显示窗格的编号
 * o 在窗格间切换
 * } 与下一个窗格交换位置
 * { 与上一个窗格交换位置
 * ! 在新窗口中显示当前窗格
 * x 关闭当前窗格> 要使用带“*”的快捷键需要提前配置

### 其他

 * t 在当前窗格显示时间

## 配置

像VIM一样，可以定制你的tmux。tmux默认会先从 `/etc/tmux.conf` 加载系统级的配置项，然后从 `~/.tmux.conf` 加载用户级的配置项。也可以启动tmux时使用参数 `-f` 指定一个配置文件。配置包含如下几个配置项：

 * 自定义各种快捷键
 * 自定义屏幕下方的状态条
 
如配置激活快捷键：

    set -g prefix ^k
    unbind ^b

默认的tmux风格比较朴素甚至有些丑陋。如果希望做一些美化和个性化配置的话，建议使用[gpakosz](https://github.com/gpakosz/.tmux) 的tmux配置。它的本质是一个tmux配置文件，实现了以下功能：

 * 基于powerline的美化
 * 显示笔记本电池电量
 * 和Mac互通的剪切板
 * 和vim更相近的快捷键

![.tmux](https://cloud.githubusercontent.com/assets/553208/9890858/ee3c0ca6-5c02-11e5-890e-05d825a46c92.gif)

---
title: "从Archlinux到Manjaro+i3 WM"
date: "2018-04-15"
categories:
 - "笔记"
tags:
 - "Archlinux"
 - "Manjaro"

---

这个周未又在家折腾我的Archlinux，把Archlinux换成了Manjaro，窗口管理采用i3-wm，先上图：

![](/images/screenshot/manjaro/1.png)
![](/images/screenshot/manjaro/2.png)

<!--more-->

本文是折腾之后的记录备份，也适合于目前是Archlinux，想把系统转成Manjaro的同学们参考。

Manjaro安装软件列表与配置已归档到GitHub: [xtfly/mydots](https://github.com/xtfly/mydots) 。

## 安装Manjaro

修改/etc/pacman.d/mirrorlist 

```
Server = https://mirrors.tuna.tsinghua.edu.cn/manjaro/stable/$repo/$arch
```

修改/etc/pacman.conf，由于在Archlinux上安装Manjaro，签名key变化，先配置为对安装包不做签名检查，SigLevel配置为Optional TrustAll，等所有软件安装完成之后再恢复 。

并配置archlinuxcn，用于下载一些国人已打包的软件，如yaourt, vscode等。

```
SigLevel    = Optional TrustAll  #Required DatabaseOptional
LocalFileSigLevel = Optional TrustAll  #Optional

......

[archlinuxcn]  
SigLevel = Optional TrustAll  
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch  
```

个人目前系统的安装包列表： [mydots/files/manjaro_i3_packages.txt](https://github.com/xtfly/mydots/blob/master/manjaro_i3_packages.txt)。

根据安装包列来安装所有包，大约有1000个包共1G的下载量，请耐心等待。

```
pacman -Syu
pacman -S `cat manjaro_i3_packages.txt` 
```

## 主要使用软件

下面这些软件已包含在manjaro_i3_packages.txt，部分介绍：

 - 桌面窗口管理：i3-wm，一种平铺风格的窗口管理，简单高效，适合于键盘党
 - 状态栏：i3pystatus，结合i3 bar使用，各种插件
 - 桌面菜单：dmenu与maro_menu
 - 终端模拟器：urxvt
 - 终端下的菜单：bmenu
 - 中文输入：fcitx
 - 浏览器：google-chrome-stable
 - 编辑器：visual-studio-code与VIM
 - 文件管理：PcManFM
 - 视频：VLC
 - 视频：PulseAudio与pavucontrol（配置界面）
 - 蓝牙：blueman
 - 多显示器: xrandr与arandr（配置界面）
 - ......

## i3pystatus

i3pystatus是采用python写的i3stauts，它比原生的i3stauts有更多的插件，配置也更丰富

配置python pip，在root目录下，打开`.pip/pip.conf`，修改为国内源

```
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple/ 
```

执行安装，i3pystatus若显示网卡流量，需要安装netifaces等

```
sudo pip install git+https://github.com/enkore/i3pystatus.git
sudo pip install netifaces colour pypi
```

## 配置

本人参考了网上多个配置，形成自己的配置，已经上传到个人GitHub: [xtfly/mydots](https://github.com/xtfly/mydots) ，供大家参考：

下载之后，在某个用户下，直接执行install.sh可快速安装配置文件，则此用户即采用i3来做窗口管理，主要配置文件 

 - i3配置，快捷键参考: [mydots/files/.i3](https://github.com/xtfly/mydots/blob/master/files/.i3/config)
 - i3pystatus配置: [files/.config/i3pystatus](https://github.com/xtfly/mydots/blob/master/files/.config/i3pystatus/config.py)
 - .Xresources配置：[files/.Xresources](https://github.com/xtfly/mydots/blob/master/files/.Xresources)


---
title: "Hexo NexT主题移植"
date: "2016-08-28"
categories:
 - "技术"
tags:
 - "hugo"
 - "theme"
toc: true

---

## 概述

我应该是一个喜欢折腾的技术党。从采用Hugo建静态blog以来，算上今天移植的这个，一共使用了三个主题：

第一个是修改自[Hueman](http://blog.coderzh.com/)，它是一个Wordpress主题。第二个是修改自[pacman](http://coderzh.github.io/hugo-pacman-theme/)，它是一个Hexo的主题。

这二个主题都是[coderzh](http://blog.coderzh.com/)最早移植的，我只是在其上修改些布局，增加点功能，换个图片什么。这个过程让我弄清楚了Hugo中模板制作方法。

第三个则是从零开始，移植Github上人气最高的Hexo主题：[NexT](https://github.com/iissnan/hexo-theme-next/)。正如你现在看到的，NexT是一款简洁又富有动感的主题，当前天我第一眼看到它时，就喜欢上它的风格。于是乎趁着周日，就开始NexT主题移植之旅。
<!--more-->

## 功能

 - 支持分类、标签索引
 - 支持归档列表索引
 - 支持分页栏
 - 支持RSS
 - 支持文章大纲（TOC）
 - 支持分享，采用多说的分享
 - 支持统计分析（目前支持百度统计，与REVOLEERMAPS）
 - 支持评论系统（多说）
 - 支持菜单定制
 - 支持社区链接定制
 - 支持外部链接定制
 - 全配置化

## 分享

这个NexT主题是使用Hugo的模板语法，从零开始，经过差不多一天的时间折腾才完工。目前也应用到了我现在的这个Blog上，看起来还行:)。若有需要的朋友尽管拿去使用，有问题欢迎反馈。

GitHub地址：https://github.com/xtfly/hugo-theme-next

由于Hugo的模版引擎和Hexo有区别，部分Hexo的样式或功能暂时无法实现，它还没有像Hexo NexT那样能高度地配置定制。并且它也仅仅在自己的Blog简单测试过，可能并不一定完全适合您的定制，您可以根据需求调整。

## 注意

由于Hugo的`.Summary`只有70个字符，对于中文文章来说，实在是太短了，你可以在文档中任一地方增加`<!--more-->`来分割。

---

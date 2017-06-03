---
title: "Install MySQL on MacOS"
date: "2017-06-03"
categories:
 - "笔记"
tags:
 - "MySQL"
 - "MacOS"

---

最近在家想写的东西，在MacOS上需要使用到MySQL。在MacOS下，使用brew来安装软件是最便捷。关于brew是什么，可在brew官网查看：[brew官网](https://brew.sh/index_zh-cn.html)

安装：

    ➜  ~ brew info mysql
    mysql: stable 5.7.18 (bottled)
    Open source relational database management system
    ......
    ➜  ~ brew install mysql
<!--more-->

mysql的安装过程会显示，注，我安装的5.7.18，目录为`/usr/local/Cellar/mysql/5.7.18_1`：

    ==> /usr/local/Cellar/mysql/5.7.18_1/bin/mysqld –initialize-insecure –user=xiao –basedir=/usr/local/Cellar/mysql/5.7.18_1 –datadir=/usr/local/var/mysql –t
    ..... 
    We’ve installed your MySQL database without a root password. To secure it run: 
    mysql_secure_installation

这说明MySQL已安装成功，必需要使用mysql_secure_installation来初始化用户密码：

    ➜  ~ mysql.server start
    Starting MySQL
    SUCCESS!
    ➜  ~ mysql_secure_installation
    Securing the MySQL server deployment.

    Connecting to MySQL using a blank password.

    ......

按英文提示一步步设置password validation policy与password等。

测试，输入mysql_secure_installation设置过程的密码：

    ➜  ~ mysql -u root –p
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 6
    Server version: 5.7.18 Homebrew
    ......

新增用户xiao，密码为123456，并赋所有权限给他：

    mysql>use mysql;
    mysql>GRANT ALL PRIVILEGES ON *.* TO 'xiao'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
    mysql>flush privileges;

如果想设置开机启动MySQL，执行如下命令：

    ➜  ~ mkdir -p ~/Library/LaunchAgents
    ➜  ~ cp /usr/local/Cellar/mysql/5.7.18_1/homebrew.mxcl.mysql.plist ~/Library/LaunchAgents/  
    ➜  ~ launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

使用命令行来操作MySQL不方便，推荐使用Navicat MySQL/Preminum软件。软件安装包在网上搜索吧。


参考：    

[1] https://dev.mysql.com/doc/refman/5.7/en/mysql-secure-installation.html
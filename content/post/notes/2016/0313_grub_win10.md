---
title: "Grub引导Win10"
date: "2016-03-13"
categories:
 - "笔记"
tags:
 - "Archlinux"
 - "Win10"
 - "grub2"

---

个人有两台笔记本电脑，一台Sony安装Win10，平时给岳父上上网，自己使用比较少；另一台是MBA，自己在捣腾点代码，写点东西。今天心血来潮，想体验一个KDE的plasma 5，于是又来折腾Sony安装双系统。由于在使用MBA之前，也在Sony上安装过Archlinux，不过后来安装Win10，又把Archlinux删除了。这次的双系统，Linux还是选择Archlinux。

安装Archlinux按照Wiki一路下来很顺利，最后安装plasma，使用了一下，感觉也不够如此，可能是使用Mac OSX时间长了的原因。后面发现想回到Win10，发现Grub默认没有生成Win10的引导菜单。
<!--more-->
我的Sony本本比较老，并不支持UEFI，所以系统选择安装Grub来引导。

	# grub-install --target=i386-pc --recheck /dev/sda
	# grub-mkconfig -o /boot/grub/grub.cfg
	
采用grub-mkconfig生成的grub.cfg并没有引导Win10的菜单，解决方法如下。为了实现多系统启动，需要安装os-prober。进入到/etc/grub.d/目录下，发现存在`30_os-prober`文件，说明os-prober是安装的（`pacman -S grub`会自动安装）。

我的Windows分区是/dev/sda1。首先，找到Windows系统分区的UUID(bootmgr存放其上)。

	# mount /dev/sda1 /mnt
	# grub-probe --target=fs_uuid /mnt/bootmgr
	70B235F6749E84AE
	# grub-probe --target=hints_string /mnt/bootmgr
	--hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1
	
接着，将下面的代码添加到`/boot/grub/grub.cfg`中，注意替换其中的`fs_uuid`，即`70B235F6749E84AE`。保存`grub.cfg`文件，重启系统，在gurb菜单就可以看到`Windows 10 (loader) (on /dev/sda1)`项了。选择，成功进入win10。

	### BEGIN /etc/grub.d/30_os-prober ###
	menuentry 'Windows 10 (loader) (on /dev/sda1)' --class windows --class os $menuentry_id_option 'osprober-chain-70B235F6749E84AE' {
	    insmod part_msdos
	    insmod ntfs
	    set root='hd0,msdos1'
	    if [ x$feature_platform_search_hint = xy ]; then
	      search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1  70B235F6749E84AE
	    else
	      search --no-floppy --fs-uuid --set=root 70B235F6749E84AE
	    fi
	    parttool ${root} hidden-
	    drivemap -s (hd0) ${root}
	    chainloader +1
	}
	set timeout_style=menu
	if [ "${timeout}" = 0 ]; then
	  set timeout=10
	fi
	### END /etc/grub.d/30_os-prober ###
	

注：后经验证，grub-mkconfig无法扫描到win10，是由于少安装了os-prober。
   
	# pacman -S os-prober

参考：[GRUB_(简体中文)](https://wiki.archlinux.org/index.php/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
	



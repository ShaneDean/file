# 前言
之前每次编译内核都需要收集网上，写完一份就可以直接参考自己的了。
后续有什么奇怪的需求自己再慢慢往上加

# 基本情况

下载的Linux内核版本是linux-4.4.145

```
[nss@localhost linux-4.4.145]$ cat /proc/version
Linux version 3.10.0-862.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-28) (GCC) ) #1 SMP Fri Apr 20 16:44:24 UTC 2018

[nss@localhost linux-4.4.145]$ cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)
```

# 准备依赖


```
sudo yum groupinstall "Development Tools"
sudo yum install ncurses-devel openssl-devel

//在源码/目录下

make menuconfig
```
现在已经弹出内核的配置界面， 现在可以直接修改。

```
 cp /boot/config-3.10.0-862.el7.x86_64 ./.config
 
 make -j4
 sudo make modules_install
 sudo make install
 
```

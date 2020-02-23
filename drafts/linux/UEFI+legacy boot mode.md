# 简介

[wiki](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface)

UEFI : Unified Extensible Firmware Interface

定义了操作系统和固件之间通用软件接口。

![position](https://github.com/ShaneDean/file/raw/master/blog/linux/_UEFI_position.png)

目标是替换之前的BIOS。

它支持没有OS的情况下诊断和修复电脑。

现在开源的项目 [mu](https://github.com/microsoft/mu) , [EDK II](https://github.com/tianocore/edk2)

# 优势

uefi 和它之前的BIOS系统有以下优势

-   可以使用 [GPT](https://en.wikipedia.org/wiki/GUID_Partition_Table) 来访 2T以上的磁盘
-   CPU 独立架构
-   CPU 独立驱动
-   无OS下的灵活功能，如网络
-   模块化设计
-   向后兼容


# 服务

提供2种类型的服务， boot 和 runtime。

boot服务和固件平台绑定，包括text/graphical控制台（在ExitBootService）

runtime服务 在OS运行时也可以访问，如date、time、NVRAM访问

-   variable ： UEFI可以存储一些非易失性的数据。可以用来存放crash信息
-   time： 提供设备独立的时间服务，包括时区等其他字段。

# 独立应用

UEFI除了加载os，还可以运行特殊应用。这些应用运行在UEFI的命令行中。一种应用类型就是操作系统加载器，如GRUB、Gummiboot、Windows Boot Manager等。另一类就是 UEFI Shell工具

EADK （EDK2 Application Development Kit）可以在UEFI程序中使用标准C库。
 

# 注

QEMU/KVM can be used with the Open Virtual Machine Firmware (OVMF) provided by TianoCore


# otopi

## 简介
otopi全称是 oVirt Task Oriented Pluggable Installer/Implementation.

一个基于插件机制的系统组件安装框架.插件特性提供了一种简单的方式来完成新组件的安装而无需复杂的状态和事物管理.

实现的核心是环境变量字典和插件的状态流程.环境变量可以被命令行参数,配置文件或交互窗口修改.

# 使用方式

otopi [variables]

variables ::= name=type:value variables | APPEND:name=type:value | ''
type ::= none | bool | int | str | multi-str
APPEND:给后面的值都加上前缀

## CUSTOMIZATION

通过设置下面的环境变量:
    
    DIALOG/customization=bool:True
    
它会在验证和结束之前立即触发命令行参数.

详见 otopi_dialog

## FILES

Configuration files used to override the environment

System environment:

    OTOPI_CONFIG

Environment:

    CORE/configFileName
    
Default:

    /etc/otopi.conf

Config files to be read:
    
    @configFileName@
    @configFileName@.d/*.conf (已排序)
    
结构:

    [environment:default]
    key=type:value
    //default:如果setup阶段没有覆盖变量那么久会保留
    
    [environment:int]
    key=type:value
    //init:即使setup阶段覆盖了也生效
    
    [enviroment:override]
    key=type:value
    //override:如果无customization的修改那么就生效
    
    [environment:enforce]
    key=type:value
    //enforce:即使customization修改了生效
    
    //type ::= none | bool | int | str | multi-str

##ENVIRONMENT

详见otopi_environment

## 未特权执行

sudo可能会到权限扩散,可以使用下面的configuration来避免:

/etc/sudoers.d/50-otopi.conf

    Defaults:user1 !requiretty
    user1 ALL=(ALL) NOPASSWD: /bin/sh
    
## 兼容

python 2.6 2.7 3.2

当前的otopi 版本是1.5.2
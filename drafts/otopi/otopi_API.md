# API
otopi是可插拔框架,plugin分配到group里面,每个grou可以在启动的时候加载.

例如,两个plugin在一个group里面
    
    /usr/share/otopi/group1/plugin1
    /usr/share/otopi/group1/plugin2
    
可以通过BASE/pluginGroups environment变量中查看被加载的group

这里的实现核心是environment

environment是一个安装过程中的状态集,所有的插件都可以访问environment.environment可以在安装过程中通过配置文件来加载,还可以通过DIALOG/customization environment来触发command-line的检查.

Plugin的条目按Stages来加载和排序,每个Stage都有priority,按照提示的前后顺序,这样每个plugin就可以以此调用

所有Plugin都继承自PluginBase并使用@Plugin.event注解来声明该插件所在的流程位置(详见例子),python模块可以使用createPlugins方法来加载插件.

请注意每个Installer都可以修改工作目录到 '/'  每个文件都有可能被plugin.resolveFile()来访问.

注意:启动时候的异常不会打印,但可以通过设置环境变量 OTOPI_DEBUG=1 在otopi脚步之前来打印.

## priorities

可选的优先级包括

    PRIORITY_FIRST
    PRIORITY_HIGH
    PRIORITY_MEDIUM
    PRIORITY_DEFAULT
    PRIORITY_POST
    PRIORITY_LOW
    PRIORITY_LAST

## 阶段

可选的阶段按顺序排列如下:

    STAGE_BOOT
        用来设置boot_environment
        通常避免
    STAGE_INIT
        用来初始化组件的阶段
        也会初始化key_environment
        只能使用setdefault来改变environment
    STAGE_SETUP
        使用这个阶段来设置environment
        只能使用setdefault来改变environment
    STAGE_INTERNAL_PACKAGES
        安装依赖的本地包
        这些包没有回滚机制
    STAGE_PROGRAMS
        检测本地程序
    STAGE_LATE_SETUP
        设置结束后的阶段
    STAGE_CUSTOMIZATION
        dialog的修改时期,劲量避免
    STAGE_VALIDATION
        程序验证
    STAGE_TRANSACTION_BEGIN
        事务开始了,这个阶段需要确保之前的结点都加完了.
    STAGE_EARLY_MISC
        早期的MISC action
    STAGE_PACKAGES
        包安装
    STAGE_MISC
        MISC action 放着
    STAGE_TRANSACTION_END
        事务提交了
    STAGE_CLOSEUP
        执行无破坏力的action
        只有不出错才会执行
    STAGE_CLEANUP
        clean up 阶段,总会执行
    STAGE_PRE_TERMINATE
        结束dialog, 避免执行
    STAGE_TERMINATE
        结束,避免执行
    STAGE_REBOOT
        重启, 避免执行

## bundle

一个 installer bundle 允许通过ssh传输一个installer到一个远程的机器上并在只依赖pytho的情况下执行安装.创建这样的一个bundle需要使用位于package的datadir目录下的otopi-bundle脚本

使用方法:
    
    otopi-bundle gettext_domains target [root]

在完成依赖插件的连接之后,可通过加入下面的install脚本

    #!/bin/bash
     exec "$(dirname "$0")/otopi" "APPEND:BASE/pluginGroups=str:my-group $*"
     
下面的例子里,Bundle使用叫做setup的初始化脚本来完成安装工作

    bundledir=LOCATION
    ( tar -hc -C "${bundledir}" . && cat) | \
        ssh "${HOST}" '( \
            dest="$(mktemp -t install-XXXXXXXXXX)"; \
            trap "chmod -R u+rwX \"${dest}\" > /dev/null 2>&1; \
                rm -fr \"${dest}\" > /dev/null 2>&1" 0;
            rm -fr "${dest}" && mkdir -p "${dest}" && \
            tar -C "${dest}" -x && "${dest}"/setup \
        )'

## 例子

假设写了plugin example1 在group1里面


```
//__init__.py
from otopi import util

from . import example1

@util.export
def createPlugins(context):
    example1.Plugin(context=context)
```


```
//example1.py
import platform
import gettext
_ = lambda m: gettext.dgettext(message=m, domain='otopi')


from otopi import constants
from otopi import util
from otopi import plugin
from otopi import filetransaction


@util.export
class Plugin(plugin.PluginBase):

    def __init__(self, context):
        super(Plugin, self).__init__(context=context)

    #
    # Register init stage at default priority.
    #
    @plugin.event(
        stage=plugin.Stages.STAGE_INIT,
    )
    def _init(self):

        #
        # Use only setdefault to keep existing environment
        #
        self.environment.setdefault('var1', False)

    #
    # perform validation, last chance before changes.
    #
    @plugin.event(
        stage=plugin.Stages.STAGE_VALIDATION,
        priority=plugin.Stages.PRIORITY_LOW,
    )
    def _validate(self):
        if not self._distribution in ('redhat', 'fedora'):
            raise RuntimeError(
                _('Unsupported distribution for iptables plugin')
            )

    #
    # perform some action.
    #
    @plugin.event(
        stage=plugin.Stages.STAGE_MISC,
        condition=lambda self: self.environment['var1'],
    )
    def _store_iptables(self):
            self.environment[constants.CoreEnv.TRANSACTION].append(
                filetransaction.FileTransaction(
                    name='/etc/example1.conf',
                    content=(
                        'hello',
                        'world',
                    )
                )
            )

@util.export
def createPlugins(context):
    Plugin(context=context)

```


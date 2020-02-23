# debug plugins

可选包 otopi-debug-plugins 提供了一些用来帮助调试基于otopi开发的工具。

## wait_on_error

通过设置系统环境变量 OTOPI_WAIT_ON_ERROR=1 来激活

如果激活成功 ,每个 ERROR 消息触发的时候立即进入

    Press Enter to continue.
    
## force_fail

通过设置环境变量 OTOPI_FORCE_FAIL_STAGE 来激活，这个值应该是 plugin.Stages 中 定义的 AGE_*常量中的一个

也通常可以给failure设置优先级(OTOPI_FORCE_FAIL_PRIORITY)，该优先级也为plugin.Stages中定义的PRIORITY_*常量中的一个。

如果激活成功，会在定义好的阶段和优先级上触发RuntimeError。

## 例子


    OTOPI_WAIT_ON_ERROR=1 OTOPI_FORCE_FAIL_STAGE=STAGE_SETUP engine-setup

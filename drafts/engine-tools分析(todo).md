
在engine安装完成之后，bin目录下由ovirt提供的工具，其中engine-config是用来管理engine中的各类配置项。

engine-config其实是 share/ovirt-engine/bin/engine-config.sh的链接。

简单看下engine-config的用法

    调用形式： engine-config <action> [<args>]
    
    可用的形式是ACTION包括
        -l, --list  列出所有可配置的值
        -a, --all   获得所有可配置的值
        -g KEY, --get=KEY
            获得给定key的value(本文忽略版本情况)
        -s KEY=VALUE, --set KEY=VALUE
            设置给定key的value(本文忽略版本情况)
        -m KEY=VALUE, --merage KEY=VALUE
            合并该value和数据中给定key的value(本文忽略版本情况)
        -h --help
    其他选项
        --cver=VERSION
            指定版本
        -p PROP_FILE, --properties=PROP_FILE
            替换Properties文件
        -c CFG_FILE, --config=CFG_FILE 
            替换Configuration文件
        --log-file=LOG_FILE
        --log-level=LOG_LEVEL

    还可以用来设置password
        engine-config -s PasswordEntry=interactive
    也可以用来支持文件配置
        engine-config -s PasswordEntry --admin-pass-file=/tmp/mypass
        engine-config -s PasswordEntry=/tmp/mypass
    
    还支持指定 java.utils.logging的 Properties文件，通过设置OVIRT_LOGGING_PROPERTIES环境变量给engine-config。
    

进入engine-config.sh，发现这个脚本主要是 打印一下命令说明，过滤下命令行参数，最终调用 org.ovirt.engine.core.config.EngineConfigExecutor。而EngineConfigExecutor只是一个入口类，只包含一个main，所有的args会根据类空格字符切割成 String[] args传递给main。main中的处理逻辑是
        
        EngineConfigCLIParser parser.parse(args);
        
        EngineConfigMap argsMap = parser.getEngineConfigMap();
        
        //处理 argsMap中log相关逻辑
        
        EngineConfig.getInstance().setUpAndExecute(parser);
        



    EngineConfigCLIParser
        
        HashMap<String, String> argsMap;    //保存参数
        EgnineConfigMap engineConfigMap;    //一个用来保存调用EngineConfig Tool 相关值的结构体
        
    EngineConfig    //engine-tool的主类
    
    
    enum ConfigActionType   保存了engine configuration的可选ACTION
    
    enum OptionKey          保存了engineconfig tool可以配置的Options
    
    
    
    
org.ovirt.engine.core //todo 包说明
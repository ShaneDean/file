# otopi-config-query 配置查询工具

## ABOUT

otopi-config-query 脚本是一个帮助工具,来更简单的处理otopi通过脚本生成的配置文件.

允许用户来匹配或查询配置文件内容里面对应的值.

## COMMAND LINE

otopi-config-query 支持下面两种操作:

    - match
    - query
    
### match 
该操作会尝试去寻找用户提供的值,匹配在configuration 文件里面给定的值.

tool 会返回下面的代码.

- 0, 如果用户提供的值和configuration里面的值配对上了.
- 1, 如果key存在于configuration文件里面,但是用于提供的value对不上
- 2, 请求的key/section都不存在与configuration文件里面,或者没有配置文件被找到

工具会抛出一个python exception来警告用户,异常包括:
    
- valueError ,如果用户没有提供otopi支持的类型的值 如 <type>:<value>
- KeyError,如果用户提供了一个无效的variable类型    



```
Usage: otopi-config-query match [-h] [-s SECTION] -k KEY -v VALUE -f FILE

Options:
  -h, --help                     show this help message and exit
  -s SECTION, --section SECTION  Configuration section, defaults to
                                 'environment:default'
  -k KEY, --key KEY              Configuration key
  -v VALUE, --value VALUE        Configuration value, in the format
                                 <type>:<value>
  -f FILE, --file FILE           Configuration file. Will also look for
                                 *.conf files inside <FILE>.d directory, if
                                 exists
```

例子:

Check if ovirt-engine is enabled for a host:

    $ otopi-config-query match \
          --key OVESETUP_ENGINE_CORE/enable \
          --value bool:True \
          --file /etc/ovirt-engine-setup.conf
    $ echo $?
    0

Check if ovirt-engine is using firewalld as the firewall manager:

    $ otopi-config-query match \
          --key OVESETUP_CONFIG/firewallManager \
          --value str:firewalld \
          --file /etc/ovirt-engine-setup.conf
    $ echo $?
    0

Check for invalid key:

    $ otopi-config-query match \
          --key OVESETUP_CONFIG/firewallManager2 \
          --value str:firewalld \
          --file /etc/ovirt-engine-setup.conf
    $ echo $?
    2

Check for non-existing configuration file:

    $ otopi-config-query match \
          --key OVESETUP_CONFIG/firewallManager \
          --value str:firewalld \
          --file /etc/ovirt-engine-setup2.conf
    $ echo $?
    2

Check for invalid variable type:

    $ otopi-config-query match \
          --key OVESETUP_CONFIG/firewallManager \
          --value st:firewalld \
          --file /etc/ovirt-engine-setup.conf
    Traceback (most recent call last):
      File "/usr/bin/otopi-config-query", line 197, in <module>
        sys.exit(main())
      File "/usr/bin/otopi-config-query", line 191, in main
        rv = args.callback(args)
      File "/usr/bin/otopi-config-query", line 93, in do_match
        user_value = common.parseTypedValue(args.value)
      File "/usr/lib/python2.7/site-packages/otopi/common.py", line 42, in parseTypedValue
        type=vtype
    KeyError: 'Invalid variable type st'

Check for variable without type:

    $ otopi-config-query match \
          --key OVESETUP_CONFIG/firewallManager \
          --value firewalld \
          --file /etc/ovirt-engine-setup.conf
    Traceback (most recent call last):
      File "/usr/bin/otopi-config-query", line 197, in <module>
        sys.exit(main())
      File "/usr/bin/otopi-config-query", line 191, in main
        rv = args.callback(args)
      File "/usr/bin/otopi-config-query", line 93, in do_match
        user_value = common.parseTypedValue(args.value)
      File "/usr/lib/python2.7/site-packages/otopi/common.py", line 27, in parseTypedValue
        raise ValueError(_("Missing variable type"))
    ValueError: Missing variable type


### query

这个action 还会去到configuration file里面去寻找给定的值，如果找到了就打印出来。

工具会返回以下的值：

    - 0 ， 成功，并且打印了在configuration file中找到的值。 如果这是了--with-type，还会打印类型
    
如果出错了则会抛出一个python 异常
    
    - configaparser.NoOptionError , configparser.NoSectionError 如果 key/section在configuration file 里面找不到
    - FileNotFound ， 如果没有 configuration file 找到。
    
```
Usage: otopi-config-query query [-h] [-t] [-s SECTION] -k KEY -f FILE

Options:
  -h, --help                     show this help message and exit
  -t, --with-type                Return configuration value with type
  -s SECTION, --section SECTION  Configuration section, defaults to
                                 'environment:default'
  -k KEY, --key KEY              Configuration key
  -f FILE, --file FILE           Configuration file. Will also look for
                                 *.conf files inside <FILE>.d directory, if
                                 exists

```

例子

Examples:

Get ovirt-engine-setup version used to install ovirt-engine (with variable type):

    $ otopi-config-query query \
          --key OVESETUP_CORE/generatedByVersion \
          --file /etc/ovirt-engine-setup.conf \
          --with-type
    str:4.0.0_master

Get ISO NFS domain storage directory:

    $ otopi-config-query query \
          --key OVESETUP_CONFIG/isoDomainStorageDir \
          --file /etc/ovirt-engine-setup.conf
    /var/lib/exports/iso/b991c2df-eafe-431e-956c-3537efb81407/images/11111111-1111-1111-1111-111111111111

Get value of invalid key:

    $ otopi-config-query query \
          --key OVESETUP_CONFIG/isoDomainStorageDir2 \
          --file /etc/ovirt-engine-setup.conf
    Traceback (most recent call last):
      File "/usr/bin/otopi-config-query", line 197, in <module>
        sys.exit(main())
      File "/usr/bin/otopi-config-query", line 191, in main
        rv = args.callback(args)
      File "/usr/bin/otopi-config-query", line 58, in do_query
        value = config.get(args.section, args.key)
      File "/usr/lib64/python2.7/ConfigParser.py", line 618, in get
        raise NoOptionError(option, section)
    ConfigParser.NoOptionError: No option 'OVESETUP_CONFIG/isoDomainStorageDir2' in section: 'environment:default'

Get value from non-existing configuration file:

    $ otopi-config-query query \
          --key OVESETUP_CONFIG/isoDomainStorageDir \
          --file /etc/ovirt-engine-setup2.conf
    Traceback (most recent call last):
      File "/usr/bin/otopi-config-query", line 197, in <module>
        sys.exit(main())
      File "/usr/bin/otopi-config-query", line 191, in main
        rv = args.callback(args)
      File "/usr/bin/otopi-config-query", line 57, in do_query
        config = get_configparser(args.file)
      File "/usr/bin/otopi-config-query", line 43, in get_configparser
        raise FileNotFound('No configuration file found')
    __main__.FileNotFound: No configuration file found


### FILE LOADER BEHAVIOR

工具使用通常的文件加载器，按照用户的要求去读取文件，也会直接去读取 <文件名>.d 的目录下面所有的.conf文件，在加载完main文件后，其他文件按照字母顺序读取。
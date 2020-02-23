# otopi Dialog

## 关于

dialog是一个用来和manager交互的接口。本文主要是用来描述用来和software交互的'machine'dialog.

交互接口通过来半人工的过程来接收人工指令。

这个接口可以通过下默的environment来选择

    DIALOG/dialect=str:machine
    
## COMMAND LINE

command line interface 可以通过下面的environment来触发。

    DIALOG/customization=bool:True
    
List:

- abort - 结束进程
- env-get - 获得environment 变量
- env-query - 查询environment 变量
- env-query-multi - 获得多String的environment  变量
- env-set   -设置environment 变量
- env-show  - 显示environment变量
- exception-show - 显示exception 信息
- help - 显示可用的command
- install - 安装软件
- log   - 检索日志文件
- noop  - 无操作
- quit  -  退出

```
Usage: env-get [options]

Options:
  -h, --help         This text
  -k KEY, --key=KEY  Environment key

Usage: env-query [options]

Options:
  -h, --help         This text
  -k KEY, --key=KEY  Environment key

Usage: env-query-multi [options]

Options:
  -h, --help         This text
  -k KEY, --key=KEY  Environment key

Usage: env-set [options]

Options:
  -h, --help            This text
  -k KEY, --key=KEY     Environment key
  -t TYPE, --type=TYPE  Variable type ('bool', 'int', 'str'), default 'str'
  -v VALUE, --value=VALUE
                        Variable value
```

## ITERATIVE DIALOG VARIABLES

CUSTOMIZATION_COMMAND

    Query customization command 

TERMINATION_COMMAND

    Query termination command
    
TIME
    
    Query current time

## INTERACTIVE CONFIRMATIONS

GPG_KEY

    Confirm trust of GPG key.
    
## MACHINE DIALECT

Note

    ^#+ (.*)\n$
        Group1 - message.
    
每一行由 '#'开始的内容都会被manager无视。 Notes 是用来和人来交互的。

Terminate

    ^***TERMINATE\n$
    
Terminate dialog


Log 

    ^\*\*\*L:INFO (.*)\n$
    ^\*\*\*L:WARNING (.*)\n$
    ^\*\*\*L:ERROR (.*)\n$
        Group1 - message.
        
Query

每个query都由下面部分组成

    ^\*\*\%QStart: (?P<NAME>.*)\n
    and
    ^\*\*\%QEnd: (?P<NAME>.*)\n
    
每个qeury 一般都包含

    ^\*\*\*Q:(?P<TYPE>STRING|MULTI-STRING|VALUE) (?P=NAME)\s?(?P<BOUNDARY>.*)\s?(?P<ABOUNDARY>.*)\n$
        NAME: Variable name
        TYPE: Query type

每个query还可以包含附加的查询选项

    ^\*\*\%QDefault: (?P<DValue>.*)\n$
        DValue: default value as string
        
    ^\*\*\%QValidValues: (?P<ValidValues>.*)\n$
        ValidValues: valid value list. '\\' in each value is replaced with '\\\\',
                     '|' is replaced with '\\|', and values are separated with '|'.
    
    ^\*\*\%QHidden: (?P<Hidden>.*)\n$
        Hidden: TRUE or FALSE. If TRUE, the reply should be hidden.
    
    ^\*\*\*Q:STRING (.*)\n$
        Group1: variable name.
        Single line response.
    
    ^\*\*\*Q:MULTI-STRING (.*) (.*) (.*)\n$
        Group1: variable name.
        Group2: boundary.
        Group3: abort boundary.
        Multiple line response.
        Boundary at own line marks end.
    
    ^\*\*\*Q:VALUE (.*)\n$
        Group1: variable name.
        Response:
            ^VALUE (.*)=(.*):(.*)\n$
            Group1: variable name.
            Group2: variable type.
            Group3: variable value.
        Response:
            ^ABORT (.*)\n$
            Group1: variable name.
            
query可能包含其他输出，如提供给用户的注意。

通常需要提示给用户的部分内容都一般在query前显示

Confirm

    ^\*\*\*CONFIRM (.*) (.*)$
        Group1: id.
        Group2: description.
        Response:
            ^CONFIRM (.*)=(yes|no)\n$
            Group1: id
            Group2: response
        Response:
            ^ABORT (.*)\n$
            Group1: variable name.
    
Display
    
    ^\*\*\*D:VALUE (.*)=(.*):(.*)\n$
        Group1: variable name.
        Group2: type.
        Group3: value.
    
    ^\*\*\*D:MULTI-STRING (.*) (.*)\n$
    (^.*\n$)*
    ^(.*)\n$
        Group1: variable name.
        Group2: boundary.
        Group3: content.
        Group4: boundary.
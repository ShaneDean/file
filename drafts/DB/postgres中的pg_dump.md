# 前言

pqsl 可以通过pg_dump来完成备份工作

pg_dump 可以将一个PostgreSQL数据库转存到一个脚本文件或者其他归档文件中

[参考1](http://www.postgres.cn/docs/9.4/app-pgdump.html)

# 说明

pg_dump是一个用于备份PostgreSQL 数据库的工具。它甚至可以在数据库正在使用的时候进行完整一致的备份。
pg_dump并不阻塞其它用户对数据库的访问(读或者写)。


转储格式可以是一个脚本或者归档文件。脚本转储的格式是纯文本，它包含许多 SQL 命令， 这些 SQL 命令可以用于重建该数据库并将之恢复到保存成脚本的时候的状态。

它甚至可以用于在其它机器甚至是其它硬件体系的机器上重建该数据库， 通过对脚本进行一些修改，甚至可以在其它 SQL 数据库产品上重建该数据库。

归档文件格式必须和pg_restore一起使用重建数据库。
它们允许pg_restore对恢复什么东西进行选择， 或者甚至是在恢复之前对需要恢复的条目进行重新排序。归档文件也是设计成可以跨平台移植的。

如果一种候选文件格式和pg_restore结合，
那么pg_dump就能提供一种灵活的归档和传输机制。
pg_dump可以用于备份整个数据库，
然后就可以使用 pg_restore检查这个归档和/或选择要恢复的数据库部分。 最灵活的输出文件格式是"custom"(自定义)格式(-Fc)和 "directory"（目录）格式(-Fd)。 它们允许对归档元素进行选取和重新排列，支持并行恢复并且缺省时是压缩的。 "directory"格式是唯一支持并行转储的格式。

在运行pg_dump的时候，应该检查输出， 看看是否有任何警告存在(在标准错误上打印)，特别是下面列出的限制。

# 使用

    pg_dump [connection-options...] [option...] [dbname]
    
## 选项
dbname
将要转储的数据库名。如果没有声明这个参数，那么使用环境变量PGDATABASE。 如果那个环境变量也没声明，那么使用发起连接的用户名。

```
-a
--data-only
    只输出数据，不输出模式(数据定义)。转储表数据、大对象和序列值。

    这个选项类似于声明--section=data，但是只是因为历史原因存在并不完全相同。

-b
--blobs
    在转储中包含大对象。除非指定了--schema, --table, --schema-only开关，否则这是默认行为。因此-b 开关仅用于在选择性转储的时候添加大对象。

-c
--clean
    输出命令在输出创建数据库命令之前先清理(drop)该数据库对象。 （除非也声明了--if-exists，如果任何对象在目标数据库中不存在， 则转储可能生成一些无害的错误消息。）

    这个选项只是对纯文本格式有意义。对于归档格式，可以在调用pg_restore的时候声明该选项。

-C
--create
    以一条创建该数据库本身并且与这个数据库连接命令开头进行输出。如果是这种形式的脚本， 那么你在运行脚本之前和目的安装中的哪个数据库连接就不重要了。如果也声明了 --clean，那么脚本在重新连接到数据库之前删除并重新创建目标数据库。

    这个选项只对纯文本格式有意义。对于归档格式，可以在调用pg_restore 的时候声明该选项。

-E encoding
--encoding=encoding
    以指定的字符集编码创建转储。缺省时，转储是按照数据库编码创建的。 另外一个获取同样结果的方法是将PGCLIENTENCODING环境变量设置为期望的转储编码。

-f file
--file=file
    把输出发往指定的文件。文件基础输出格式时可以省略这个参数，这种情况下使用标准输出。 但是，在声明目标目录而不是文件时必须给出目录输出格式。在这种情况下， 目录通过pg_dump创建并且必须之前不存在。

-F format
--format=format
    选择输出的格式。format可以是下列之一：

    p
    plain
        纯文本SQL
        
    c
    custom
        适合输入到pg_restore里的自定义格式归档。 加上目录输出格式，这是最灵活的格式，它允许在转储期间对已归档的条目进行手动选择和重新排列。 这个格式缺省的时候是压缩的。
    
    d
    directory
        适合输入到pg_restore里的目录格式归档。这将创建一个目录， 该目录包含一个为每个被转储的表和二进制大对象的文件，加上一个号称目录的文件， 该文件以pg_restore可读的机器可读格式描述转储的对象。 目录格式归档可以用标准Unix工具操作；例如，在非压缩归档中的文件可以用 gzip工具压缩。这个格式缺省的时候是压缩的， 并且也支持并行转储。
    
    t
    tar
        适合输入到pg_restore里的tar归档文件。 tar格式兼容目录格式；提取tar格式归档产生一个有效的目录格式归档。不过， tar格式不支持压缩并且限制单独的表为8 GB。还有，表数据条目的相关顺序在转储期间不能更改。
```
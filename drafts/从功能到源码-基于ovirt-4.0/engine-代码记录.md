# 记录

## request.getSession

request.getSession(true)：若存在会话则返回该会话，否则新建一个会话。

request.getSession(false)：若存在会话则返回该会话，否则返回NULL。

## engine mode

-   ACTIVE      所有command 都可以执行
-   PREPARE     如果增加了@DisableInPrepareMode 就不能执行
-   MAINTENANCE 所有command 都不可以执行

## dwh

git@172.16.6.201:vms-group/dwh.git

      yum install dom4j apache-commons-collections postgresql-jdbc

make install-dev PREFIX='/FULL/PATH'


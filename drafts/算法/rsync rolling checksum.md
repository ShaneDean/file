# 前言

在《代码之美》的第二章里提到了rsync的rolling checksum算法，花点时间了解下。

[paper](https://rsync.samba.org/tech_report/),
[rsync](https://en.wikipedia.org/wiki/Rsync),[rolling hashing](https://en.wikipedia.org/wiki/Rolling_hash),[blog1](https://coolshell.cn/articles/7425.html),[blog2](https://cloud.tencent.com/developer/article/1058192),[blog3](http://www.cnblogs.com/Creator/archive/2012/03/30/2426070.html)

# 背景


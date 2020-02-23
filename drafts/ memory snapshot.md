# 前言
整理快照、磁盘、模板概念的时候碰到了内存信息、cpu状态、设备状态、磁盘数据相关问题，查阅了一下资料来做个记录。

[ram snopshots in ovirt](https://www.youtube.com/watch?v=xIhPV66uGo8)

# virtual disk

virtual disk 由 volumes组成, volume的类型包括 raw \ cow \ qcow2

# backup & restore

create snapshot

preview snapshot

commit to snapshot

# stateless vm 

# Live storage migration 

a preliminary step in process

## offline snapshot

## live snapshot


# snapshot in libvirt 

## disks snapshot 
-   internal



-   external

## memory state

-   Piggy-backed
-   external

## system checkpoint

disk snapshot +  memory state

ram snapshots  : disk snapshot with memory state

## export/import with ram snapshots
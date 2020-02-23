# 前言

[wiki](https://en.wikipedia.org/wiki/Split-brain_(computing)),[参考](https://cloud.tencent.com/developer/article/1027323),[参考](https://www.ovirt.org/develop/release-management/features/storage/vm-leases.html)

# 概念
## 脑裂(split-brain)

指在一个高可用（HA）系统中，当联系着的两个节点断开联系时，本来为一个整体的系统，分裂为两个独立节点，这时两个节点开始争抢共享资源，结果会导致系统混乱，数据损坏。

## 防止HA的脑裂

- 仲裁 ： 当两个节点出现分歧时，由第3方的仲裁者决定听谁的。这个仲裁者，可能是一个锁服务，一个共享盘或者其它什么东西。
- fencing ： 当不能确定某个节点的状态时，通过fencing把对方干掉，确保共享资源被完全释放，前提是必须要有可靠的fence设备。

# vm Leases
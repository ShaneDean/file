# 前言

engine中管理的实体对象主要包括，VDS、vm、TODO

# 总述

每个entity有关的部分包括  
- 数据库表、视图、存储过程
- 相关Command和Query
- Validator
- ResourceModel , Mapper
- PermissionSubject

# VDS

VDS是一台物理主机的抽象，每台物理主机上跑着VDSM服务，提供计算、网络、存储等服务。所有虚拟机都跑在任意一台VDS之上。每个vds都对应一个VdsManager

## 实体设计
vds的实体类是 VDS  ,  在数据库层定义了一个vds的视图，从8个表中抽取数据组合而成。
```
CREATE OR REPLACE VIEW vds AS
    SELECT cluster.xxx as xxx,
    vds_static.xxx as xxx,
    vds_dynamic.xxx as xxx,
    vds_statistics.xxx as xxx,
    storage_pool.xxx as xxx,
    vds_spm_id_map.xxx as xxx,
    fence_agents.xxx as xxx,
    gluster_server.xxx as xxx,
        where id=id
```
主要的属性包括

- VdsStatic : 主机的静态数据，创建时候指定
- VdsDynamic ： 主机的动态数据，运行之后读取到
- VdsStatistics ：主机运行中的状态，需要统计收集的数据
- VdsNetworkInterface[]：VDS上的网卡
- fenceAgents[]

## status
VDSStatus

- Unasigned     初始化的值
- Down          虚拟机关机状态，被Stop、PownerDown、XXPolicyUnit
- Maintenance
- Up
- NonResponsive
- Error
- Installing
- InstallFailed
- Reboot
- PreparingForMaintenance
- NonOperational
- PendingApproval
- Initializing
- Connecting
- InstallingOs
- Kdumping


## validator

## 相关命令
AddVdsCommand 新建主机
updateVdsCommand 更新主机
HostEnrollCertificateCommand \ HostEnrollCertificateInternalCommand


## 相关对象

### vdsDeploy

vdsDeployUnit

# Storage

## frontend
IStorageModel 定义存储模型的接口，包含下面2个实现类，并各自有更细分的子类
- SanStorageModelBase
    - FcpStorageModel
    - IscsiStorageModel
    - ImportSanStorageModel
        - ImportFcpStorageModel
        - ImportIscsiStorageModel
- FileStorageModel
    - GlusterStorageModel
    - NfsStorageModel
    - PostStorageModel
        - LocalStorageModel

### nfs
```
VDCQueryType.GetStorageDomainsByConnection

VdcActionType.AddStorageServerConnection
    VDSCommandType.ConnectStorageServer
VdcActionType.AddNFSStorageDomain
VdcActionType.DisconnectStorageServerConnection

VdcActionType.AttachStorageDomainToPool
```
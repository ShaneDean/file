# 前言

分析、整理engine中dao层的代码

# BusinessEntityWithStatus

定义所有包含状态的实体对象。

```java
public interface BusinessEntityWithStatus<ID extends Serializable, Status extends Enum<?>> extends BusinessEntity<ID> {
    Status getStatus();     //获取状态
    void setStatus(Status status);      //修改状态
}
```

Snapshot  :  Snapshot.SnapshotStatus

StorageDomain  : StorageDomainStatus

StoragePool  :  StoragePoolStatus

StoragePoolIsoMap  :  StorageDomainStatus

VDS : VDSStatus

VdsDynamic   :   VDSStatus

VM  :   VMStatus

VmDynamic : VMStatus

VmTemplate  :  VmtemplateStatus

GlusterBrickEntity  :  GlusterStatus

GlusterGeoRepSession    :    GeoRepSessionStatus

GlusterVolumeEntity     :   GlusterStatus

GlusterVolumeSnapshotEntity     :   GlusterSnapshotStatus

NetworkCluster      :       NetworkStatus

NetworkStatistics   :   InterfaceStatus

Image       :       ImageStatus


# 
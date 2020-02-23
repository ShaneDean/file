# 前言
ovirt 在挂在nfs存储的时候需要使用vdsm:kvm的权限，在dell/netapp等存储应为权限原因失败，在整理下nfs相关内容。

[参考1](http://cn.linux.vbird.org/linux_server/0330nfs.php),[参考2](http://www.faqs.org/rfcs/rfc1094.html),[参考3](http://www.faqs.org/rfcs/rfc1094.html)


# exports 


参数值	 | 内容说明
---|---
rw\ro     | 该目录分享的权限是可擦写(read-write)或只读(read-only)，但最终能不能读写，还是与文件系统的rwx 及身份有关。
sync\async       | sync 代表数据会同步写入到内存与硬盘中，async则代表数据会先暂存于内存当中，而非直接写入硬盘！
no_root _squash\root _squash | 客户端使用NFS 文件系统的账号若为 root 时，系统该如何判断这个账号的身份？预设的情况下，客户端root 的身份会由root _squash的设定压缩成nfsnobody，如此对服务器的系统会较有保障。但如果你想要开放客户端使用root 身份来操作服务器的文件系统，那么这里就得要开 no _root _squash 才行！
all_squash       | 不论登入NFS 的使用者身份为何，他的身份都会被压缩成为匿名用户，通常也就是 nobody(nfsnobody) 啦！
anonuid \anongid     | anon 意指anonymous (匿名者) 前面关于*_squash 提到的匿名用户的UID设定值，通常为nobody(nfsnobody)，但是你可以自行设定这个UID 的值！当然，这个UID必需要存在于你的/etc/passwd当中！anonuid指的是UID 而anongid 则是群组的GID 啰。


# ovirt相关代码分析  

## frontend

    StorageListModel
        ->NewDomainCommand -> newDomain()  
            -> OnSaveCommand -> onSave()
                                -> storageNameValidation() -> isStorageDomainNameUnique()
                                    -> postStorageNameValidation()
                                        -> onSavePostNameValidation()
                                            -> saveNfsStorage() 
                                                -> Task.run() -> saveNfsStorage(TaskContext)
                                                                -> saveNewNfsStorage()
                                                                        =>| actionTypes.add(VdcActionType.AddStorageServerConnection);
                                                                          | actionTypes.add(VdcActionType.AddNFSStorageDomain);
                                                                          | actionTypes.add(VdcActionType.DisconnectStorageServerConnection);
                                                                        => Frontend.getInstance().runMultipleActions        
## backend         

### AddStorageServerConnection  
```
AddStorageServerConnectionCommand
    => storageServerConnectionDao.save(StorageServerConnections)
        => psql: Insertstorage_server_connections
```            
### AddNFSStorageDomain
```    
AddNFSStorageDomainCommand
    => storageDomainStaticDao.save(StorageDomainStatic)
    => storageDomainDynamicDao.save(StorageDomainDynamic)
    => if isDataDomain() => runInternalActionWithTasksContext(VdcActionType.AddDiskProfile)
    => connectStorage()
        =>runVdsCommand(VDSCommandType.ConnectStorageServer)  
    => updateStorageDomainDynamicFromIrs
        =>runVdsCommand(VDSCommandType.GetStorageDomainStats)
        =>storageDomainDynamicDao.update
```
### DisconnectStorageServerConnection
```
    DisconnectStorageServerConnectionCommand
        =>runVdsCommand(VDSCommandType.DisconnectStorageServer)
```

## vdsm
### ConnectStorageServer
```
StoragePool.connectStorageServer
    _COMMOND_CONVERTER => connectStorageServer  (hsm.py)
    =>      conInfo = _connectionDict2ConnectionInfo(domType, conDef)
            conObj = storageServer.ConnectionFactory.createConnection(conInfo)
            conObj.connect()
                => self._mount.mount(self.options, self._vfsType, cgroup=self.CGROUP)
                    => mount = supervdsm.getProxy().mount if os.geteuid() != 0 else _mount
                    => mount(self.fs_spec, self.fs_file, mntOpts=mntOpts, vfstype=vfstype, timeout=timeout, cgroup=cgroup)
                => fileSD.validateDirAccess(self.getMountObj().getRecord().fs_file)
                    => 确保 vdsm:kvm的rwx和qemu:qemu的rx
```
### GetStorageStats
```
StorageDomain.getStats
    _COMMOND_CONVERTER => getStorageDomainStats (hsm.py)
```
### DisconnectStorageServer
```
StoragePool.disconnectStorageServer
    _COMMOND_CONVERTER => disconnectStorageServer (hsm.py)
```
# 错误描述

vdsm.log中报错  检查vdsm:kvm权限读写目录失败
vdsm上手动使用root 执行挂在命令成功， 但是读写失败

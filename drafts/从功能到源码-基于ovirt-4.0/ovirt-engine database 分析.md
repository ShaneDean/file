# 前言

分析 ovirt-engine的database

# table

## config
```sql
vdc_options
    --使用fn_db_add_config_value增加系统配置项名称


```

## vds
```sql

vds_dynamic
vds_static
vds_statistics

vds_interface

vds_interface_statistics

```

## vm

```sql

vm_device

vm_dynamic

vm_init

vm_interface

vm_interface_statistics

vm_pools

vm_pool_map

vm_statistics

```

## cluster
```sql
cluster

```

## task

```sql
async_tasks

async_tasks_entities

```

## audit_log

```sql

audit_log

```

## 存儲

```sql

base_disks

disk_image_dynamic

disk_lun_map


image_storage_domain_map  --image属于哪个存储域

images


iscsi_bonds

iscsi_bonds_networks_map

iscsi_bonds_storage_connections_map


luns

lun_storage_server_connection_map


storage_domain_static


repo_file_meta_data


snapshots

storage_domain_dynamic  

storage_domain_static

storage_pool

storage_server_connections


```
## 网络

```sql

network   -- 逻辑网络

network_cluster   --  集群下该逻辑网络的类型

vnic_profiles

```



## dwh

```sql
dwh_history_timekeeping
dwh_osinfo

```

## event

```sql
event_map

event_notification_hist
```

## 权限

```sql
permissions

roles

roles_groups  -- role 和 action group的关系 
定义为ActionGroup枚举类

users

login_record



```

## other

```sql

bookmarks

custom_actions


cluster_policies

cluster_policy_units

event_map

event_notification_hist

event_subscriber

business_entity_snapshot

job

job_subject_entity

object_column_white_list

object_column_white_list_sql  ?

quota

quota_limitation

schema_version

vdc_db_log

```

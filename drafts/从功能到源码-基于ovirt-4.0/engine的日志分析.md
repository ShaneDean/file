# 描述
严格意义上来说，engine的日志分成2种：
- 一种是打印在控制台、engine.log文件中的，这个一般是提供给开发人员或者维护人员去定位engine运行中的各类问题，这种的实现方式就类似平常开发java的syslog性质，简单的就是 Logger log = LoggerFactory.getLogger(类名.class)， 然后log.info(xxx)。
- 还一种是显示在engine-webadmin中event面板的日志信息，这类一般是提供给管理员查看了解系统运行情况的，我们本篇主要介绍的时第二种。

分析的脉络 我们从持久化的数据区开展，再到 dao 数据访问层，再到 bll 业务成，最后到前台。

# 主要的对象
后台

相关的command和query包括
    
    DisplayAllAuditLogEventsCommand
    ClearAllAuditLogAlertsCommand
    DisplayAllAuditLogAlertsCommand
    RemoveAuditLogByIdCommand    
    AddExternalEventCommand
    
    SearchQuery
    GetAllEventMessagesQuery
    GetAllAuditLogsByVMIdQuery
    GetAllAuditLogsByVMTemplateIdQuery
    GetAllEventMessagesQuery

除了SearchQuery是自成体系（会有专门内容提及），其他的都是访问调用，不深入分析。





AuditLogDirector， 与AuditLog交互的访问对象

    //定义了 每种AuditlogType对应的message信息，并支持可扩展成国际化
    ResourceBundle resourceBundle = getResourceBundle();
    
    //外部的所有日志记录都是调用该方法
    log(...){
        //首先做一次过滤，过滤了特定AuditLogType的类型的日志
        if (!logType.shouldBeLogged()) {
            return;
        }
        
        //这个地方就可以补充其他自己设计的日志过滤代码。

        //Update the logged object timeout attribute by log type definition
        updateTimeoutLogableObject(auditLogable, logType);

        // Checks if timeout is used and if it is, checks the timeout. If no timeout set, then it will set this object as timeout.
        if (auditLogable.getLegal()) {
            //开支执行保存代码
            saveToDb(auditLogable, logType, loggerString);
        }
    }
    
    savetToDb(...){
        ...
        AuditLog auditLog = createAuditLog(auditLogable, logType, loggerString, severity);
        
        ...
        //更新auditLogable的值到 auditlog中
        setPropertiesFromAuditLogableBase(auditLogable, auditLog)
        //使用AuditLogDaoImpl的save方法将auditlog保存到db中
        getDbFacadeInstance().getAuditLogDao().save(auditLog);
        //打印到第一种日志中
        logMessage(severity, getMessageToLog(loggerString, auditLog));
        
    }
    
在setPropertiesFromAuditLogableBase中，基本上就是把 前者对象中的属性值设置到后者上面，auditLog是用来持久化到db中的对象，而AuditLogableBase则是所有这些数据的提供者。

在AuditLogableBase中多数为和其他模块处理业务的对象如  DbUser、StorageDomain、VM等。而在auditlog中多数为uuid、String 、Date等基础类型。

**AuditLogableBase**

继续深入分析，CommandBase继承了AuditLogableBase这个类，不难推测，这个类就是用来承载Command运行时候关于auditlog信息的上下文。AuditLogable类通过auditLogDirector来实现写入db的操作。

    protected void log (){
        ...
        auditLogDirector.log(this);
        ...
    }

找到CommandBase源码，它将上面的log方法包装成了  logCommand，分别在command中的 execute和endAction中调用，关于CommandBase的运行机制，找时间准备专门的材料去描述。

什么时候写到了db弄明白了， 那什么时候拿到数据的呢?

数据分两部分：
- 一部分是定义的日志类型决定了这个日志包含了那些信息

    每个Command和Query都有对应 VdcActionType 和VdcQueryType；log也有对应的AuditLogType，这里定了各种类型的日志的一些特性。包括AuditLogSeverity、eventFloodRate等信息，不同的type也对应了不同的message内容。
    
    例如AddBookmarkCommand，增加一个书签之后，前台事件面板的高级视图中没有包含诸如vm\cluster等ID信息，只包含基本的 message\time。
    
    代码中只包含了重写getAuditLogTypeValue()来确定是AuditLogType.USER_ADD_BOOKMARK还是AuditLogType.USER_ADD_BOOKMARK_FAILED的代码

- 另一部分是根据当前command的逻辑决定了日志中包含了那些信息.

    例如AddEmptyStoragePoolCommand，新建数据中心,
    
    //TODO



AuditLogableBase 提供了多种参数的构造方法。


AlertDirector

AuditLogCleanupManager


---
dao

AuditLog


AuditLogType

AuditLogSeverity

AuditLogDao
纯接口，继承了 engine中的 Dao 和 SearchDao (需要支持前台的搜索业务逻辑)，主要定义了更够执行的操作

AuditLogDaoImpl
，继承了BaseDao（engine中主要定义了一些从数据库到java的基本数据类型的访问方法），实现了 AuditLogDao中定义的接口。
在实现的接口中都可以通过调用关系了解到这些command到底是用在了那些地方。

其中在DaoImpl中要注意的就是 Mapper, 这里定义了 table 字段 和 AuditLog属性的映射关系。

AuditLogRowMapper 


AuditLogSeverity

audit_log_sp.sql

    -- 插入之日志的主要执行方法
    InsertAuditLog
    InsertExternalAuditLog
    
    -- 根据log id 来删log
    DeleteAuditLog
    -- 根据v_severity等级来清除日志  这里的v_severity 对应了 AuditLogSeverity 类
    ClearAllAuditLogEvents
    
    
    DisplayAllAuditLogEvents
    
    -- clearAllAlerts and displayAllAlerts
    SetAllAuditLogAlerts
    
    -- GetAllFromAuditLog  普通user获得log的主要sp, 它会根据用户的权限和log中包含的 vm 、 storage 、 cluster等字段区分普通用户对日志的查看情况，来筛选过滤对应的日志
    -- 参照得表包含  
    --          user_vds_permissions_view、user_object_permissions_view
    --          user_storage_pool_permissions_view 、 user_object_permissions_view
    --          user_storage_domain_permissions_view 、user_object_permissions_view
    --          user_cluster_permissions_view 、 user_object_permissions_view
    GetAllFromAuditLog
    GetAuditLogByAuditLogId
    GetAuditLogByVMId
    GetAuditLogByVMTemplateId
    RemoveAuditLogByBrickIdLogType
    
    -- 某时间之后的日志
    GetAuditLogLaterThenDate
    DeleteAuditLogOlderThenDate
    DeleteAuditAlertLogByVdsIDAndType
    
    -- 删除备份相关的日志
    DeleteBackupRelatedAlerts
    DeleteAuditAlertLogByVolumeIDAndType
    DeleteAuditLogAlertsByVdsID
    
    /*
    Used to find out how many seconds to wait after Start/Stop/Restart PM operations
    v_vds_name     - The host name
    v_event        - The event [USER_VDS_STOP | USER_VDS_START | USER_VDS_RESTART]
    v_wait_for_sec - Configurable time in seconds to wait from last operation.
    Returns : The number of seconds we have to wait (negative value means we can do the operation immediately)
    */
    get_seconds_to_wait_before_pm_operation
    
    GetAuditLogByOriginAndCustomEventId
    GetAuditLogByVolumeIdAndType

create_tables.sql  中创建audit_log的表
    
    CREATE TABLE audit_log (
        -- uuid
        audit_log_id bigint DEFAULT nextval('audit_log_seq'::regclass) NOT NULL,
        user_id uuid,
        user_name character varying(255),
        
        vm_id uuid,
        vm_name character varying(255),
        vm_template_id uuid,
        vm_template_name character varying(40),
        vds_id uuid,
        vds_name character varying(255),
        log_time timestamp with time zone NOT NULL,
        log_type_name character varying(100) DEFAULT ''::character varying,
        log_type integer NOT NULL,
        severity integer NOT NULL,
        message text NOT NULL,
        processed boolean DEFAULT false NOT NULL,
        storage_pool_id uuid,
        storage_pool_name character varying(40),
        storage_domain_id uuid,
        storage_domain_name character varying(250),
        vds_group_id uuid,
        vds_group_name character varying(255),
        correlation_id character varying(50),
        job_id uuid,
        quota_id uuid,
        quota_name character varying(60),
        gluster_volume_id uuid,
        gluster_volume_name character varying(1000),
        origin character varying(255) DEFAULT 'oVirt'::character varying,
        custom_event_id integer DEFAULT (-1),
        event_flood_in_sec integer DEFAULT 30,
        custom_data text DEFAULT ''::text,
        deleted boolean DEFAULT false,
        call_stack text DEFAULT ''::text
    );


---
rest 

BackendEventsResource

还有部分的相关代码被拆分到了
https://github.com/oVirt/ovirt-engine-api-model.git
项目中


---
web 前台：

EventListModelTable

EventListModel

定义了全部的前台操作后台的接口

AlertListModel

TaskListModel

EventModel

MainTabEventView

MainTabEventPresenter


AuditLogMessages.properties  //记录了每一个auditlogType对应额描述
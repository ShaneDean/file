# 原文地址
https://www.ovirt.org/develop/release-management/features/infra/commandcoordinator/
# 详细描述
一个新的表 将会保存所有的信息用来存储command 并且在稍后的某个时间去重建。当前 Asyc Tasks table爆粗拿了需要重新构建一个AsyncTask的参数，但是在引入完CommandEntity表之后，async tasks表就不需要包保存这些列了。这个新的表将会用来存储 SPM和 NON SPM的Command。所有来自Async Tasks表的并与command有关的column豆浆会被移动到这个新的表中。除了这些已经存在 Async Tasks 表中的列,新的表还会有一个parent command id。 这个将在rebuilding command的时候对reconstruct parent command parameters十分有帮助

这个特性使得 NON SPM command (例如 LiveMerge) 将会被存储到数据库中. 长时间运行command使用使用这个特性来持久化command并且在晚些的某个时间来重新加载它。在执行LiveMerge或其他长时间command的时候，哪怕engine重启，它也提供了一种方式来保存和加载这些长时间命令。
![架构图](https://www.ovirt.org/images/wiki/Coco.png?1478101462)

Entity Table
    
    CREATE TABLE command_entities
    (
         command_id uuid NOT NULL,
         command_type integer NOT NULL,
         root_command_id uuid,
         command_parameters text,
         command_params_class character varying(256),
         created_at timestamp with time zone,
         status character varying(20) DEFAULT NULL::character varying,
         callback_enabled boolean DEFAULT false,
         callback_notified boolean DEFAULT false,
         return_value text,
         return_value_class character varying(256),
         job_id uuid,
         step_id uuid,
         executed boolean DEFAULT false,
         CONSTRAINT pk_command_entities PRIMARY KEY (command_id)
    )
    CREATE INDEX idx_root_command_id ON command_entities(root_command_id)
    WHERE root_command_id IS NOT NULL;
    
**CommandCoordinator** 暴露了新的方法 persisCommand和 retrieveCommand。

    persisCommand可以被任何command。 
        通过 command.persistCommand(VdcActionType parentCommand)
        或  command.persistCommand(VdcActionType parentCommand, enableCallback) 来开启CommandExecutor Framework的call back.
    这将让CommandCoordinator来持久化这些命令到数据中
    
一些操作的接口

    public boolean hasCommandEntitiesWithRootCommandId(Guid rootCommandId);
    public CommandEntity createCommandEntity(Guid cmdId, VdcActionType actionType, VdcActionParametersBase params);
    public List<Guid> getChildCommandIds(Guid commandId);
    public CommandEntity getCommandEntity(Guid commandId);
    public CommandStatus getCommandStatus(Guid commandId);
    public List<CommandEntity> getCommandsWithCallBackEnabled();
    public void persistCommand(CommandEntity cmdEntity);
    public void persistCommand(CommandEntity cmdEntity, CommandContext cmdContext);
    public CommandBase<?> retrieveCommand(Guid commandId);
    public void removeCommand(Guid commandId);
    public void removeAllCommandsInHierarchy(Guid commandId);
    public void removeAllCommandsBeforeDate(DateTime cutoff);
    public void updateCommandStatus(Guid commandId, CommandStatus status);
    public void updateCommandExecuted(Guid commandId);
    public void updateCallBackNotified(Guid commandId);
        
Command Entity DAO， 处理持久CommandEntity 对象的主要类，下面是一些操作command entity的方法。

    void saveOrUpdate(CommandEntity commandEntity);
    void remove(Guid commandId);
    void removeAllBeforeDate(Date cutoff);
    void updateExecuted(Guid id);
    void updateNotified(Guid id);
    void updateStatus(Guid command, Status status);

Command Entity Cleanup Manager
  一个类似于AuditLogCleanupManager的 cleanup manager ，用来移除在被标记完成之后的old command ，它们被存储但是还未被清除。
  
##   CommandExecutor Framework
这个框架构建在新引进的CommandCoordinator之上，一个命令可以被CommandExecutor提交来运行在一个separate 线程， 并且 Command 可以提供一个commandCallBack类似于callback方法，CommandExecutor将会在生命周期的任意个点去掉用这些command

1. Submit a command to CommandExecutor
    
    可以通过调用executeAsyncCommand并提供action type和 action parameters

x``
    public static Future<VdcReturnValueBase> executeAsyncCommand(
      VdcActionType actionType, VdcActionParametersBase parameters, CommandContext cmdContext)        

2. CommandCallBack




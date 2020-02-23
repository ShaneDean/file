
VDSBrokerFrontend 

    VDSRenturnValue -- VDSCommandType -- VDSParametersBase


AsyncTaskCreationInfo  has  AsyncTaskType




CommandBase <T extends VdcActionParametersBase> extends AuditLogableBase  implements TransactionMethod<Object> , Command <T> 

猜测：继承CommandBase都是 org.ovirt.engine.core.bll;

VDSCommandBase<P extends VDSParametersBase> extends VdcCommandBase

猜测： 继承 VDSCommandBase的都是org.ovirt.engine.core.vdsbroker


实现了BackendService接口的类都是交由EJB进行管理和注入


CommandBase : 

    成员
    
        VdcReturnValueBase  returnValue;
        CommandActionState  actionState;
        VdcActionType   actionType;
        private final List<Class<?>> validationGroups = new ArrayList<>();
        Guid commandId;
        TransactionScopeOption scope;
        TransactionScopeOption endActionScope;
        List<QuotaConsumptionParameter> consumptionParameters;
        Map<String, Serializable> commandData;
        Long sessionSeqId;
        
        QuotaManager quotaManager;p
        SessionDataContainer sessionDataContainer;
        BackendInternal backendInternal;
        VDSBrokerFrontend  vdsBroker;
        ObjectCompensation objectCompensation;
        
        /** Indicates whether the acquired locks should be released after the execute method or not */
        boolean releaseLocksAtEndOfExecute = true;
        
        /** The context defines how to monitor the command and handle its compensation */
        CommandContext context;
        
        /** A map contains the properties for describing the job */
        protected Map<String, String> jobProperties;
        
        /** Handlers for performing the logical parts of the command */
        private List<SPMAsyncTaskHandler> taskHandlers;
        
        private CommandStatus commandStatus = CommandStatus.NOT_STARTED;

    方法
        postConstruct   //当CommandBase有参数传输入的时候，提供初始化
                        //Command还提供了 空的init方法，提供给子类进行初始工作
        executeAction() //执行command的主体逻辑
        
        setActionMessageParamters() //为了bll message 用来设置参数

        
**Command**

    该接口定义了两个方法
    
        VdcReturnValueBase endAction();
        
        T getParameters(); // 这里的T extends VdcActionParametersBase

    Command代表一个命令，VdcReturnValueBase表示执行万endAction()后的返回值
    还可以通过 getParameters()来获得 该Action的参数  VdcActionParametersBase

**VdcReturnValueBase**

    抽象返回值
    
**VdcActionParametersBase**

    抽象传入参数


CommandActionState   
    每个继承了CommandBase的子类  获取当前状态来判断需要执行的日志类别AuditLogType
    判断的逻辑在getAuditLogTypeValue中
    该字段包含 EXECUTE, END_SUCCESS , END_FAILURE;
    效果只作用于日志的场景中

CommandStatus
    猜测  控制 由于command执行结果不同而导致代码的控制逻辑不同
所有的 status的转换都由setCommandStatus来变化


**CommandCallback**


**ChildCommandsCallbackBase** extends CommandCallback



**ConcurrentChildCommandsExecutionCallback** extends ChildCommandsCallbackBase  

    //A callback that should be used by commands that execute number of child commands concurrently. When the execution of  child commands is over, the end method of the commands is called.



**SerialChildCommandsExecutionCallback** extends         ChildCommandsCallbackBase      

    //  A callback for commands that are executing their child commands serially. Note that this callback supports execution of child commands until a failure or until successful completion.



**CommandContext** 

用来保存command执行的上下文

    private CompensationContext compensationContext;
    //用来保存当command 执行失败后需要补偿的信息
    
    private final EngineContext engineContext;  
    //保存sessionId
    
    private EngineLock lock;
    
    private ExecutionContext executionContext;  


CommandsFactory
    用来创建command
    
    //todo
    

    
**CommandCoordinatorUtil**    

        基本上就是针对  
            CommandCoordinator 的 impl 和
            getAsyncTaskManager()  的 AsyncTaskManager
        这两个类的方法调用的包装

        
**CommandCoordinatorImpl** implements CommandCoordinator

    其中 
        public interface CommandCoordinator extends TaskHelper, AsyncCommandCallback, CommandCRUDOperations, AsyncTaskCRUDOperations, CommandScheduler 

    
        
        
    
    
    
    **ExecutionContext**
    
    用来检测 Step/Job 的执行情况
    // Step / Job   // TODO
    
    
Task Manager Add bussiness entities

    涉及 
        ExternalSystem
        ExternalSystemType
        Job
        JobExecutionStatus
        Step
        StepEnum

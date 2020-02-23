# 前言

ovirt-engine中，所有执行的业务流程都被抽象成一个个命令实体。 

这里ovirt-engine版本基于4.1。

# 概述

![总体框架](https://github.com/ShaneDean/file/blob/master/blog/ovirt_engine_env/ovirt-engine-command-mechanism.png?raw=true)

不同的caller通过传入参数ParamBase和指定执行的命令实体的类型ActionType（枚举），使用工厂方法模式创建对ActionType对应的命令实体ActionBase，
再由Executor来调用ActionBase中的execute方法，返回ReturnValueBase。

目前engine中有3类ActionType，分别是VdcActionType\VdcQueryType\VDSCommandType




类别 | 命名格式(suffix) |  ParamBase  | ActionBase  | ReturnValueBase  | Executor | CommandFactory
---|---|---|---|---|---|--
 VdcActionType | Command  | VdcActionParametersBase | CommandBase | VdcReturnValueBase  | BackendActionExecutor | CommandsFactory
 VdcQueryType | Query | VdcQueryParametersBase  | QueriesCommandBase[vdcCommandBase] | VdcQueryReturnValue | BackendQueryExecutor | CommandsFactory
 VDSCommandType | VDSCommand | VDSParametersBase | VDSCommandBase[vdcCommandBase] | VDSReturnValue | VdsCommandExecutor | ResourceManager
 



# VdcActionType
一个command在Create的时候被视为一个Job， 一个Job由多个Step组成

如果是param中包含 jobid或stepid，isExternal = true, 就无需增加StepEnum.VALIDATING的Step

CommandStatus定义了执行状态
- UNKNOWN               从db中恢复的Command的初始状态
- NOT_STARTED           CommandBase的初始值
- ACTIVE                通过了validate的检查
- FAILED                FIXME  
    - 理解1 提交CommandCoordinatorImpl之后出现错误的状态，一般说明engine本身流程正在，在调动外部服务时出错 ？？
    - 理解2 异步command执行中,线程池大道最大任务拒绝？
- EXECUTION_FAILED      异步任务执行中报错
- SUCCEEDED
- ENDED_SUCCESSFULLY
- ENDED_ WITH_FAILURE

# VdcQueryType

AsyncQuery 
```
    converterCallback : 对query返回结果进行转换
    asyncCallback：  请求结果的处理

```

# analzy


CommandBase : 

    成员
        VdcActionParametersBase  T parameters
        
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
        
        LOckManager lockManager;        //InMemoryLockManager
        QuotaManager quotaManager;      
        SessionDataContainer sessionDataContainer;
        BackendInternal backendInternal;
        VDSBrokerFrontend  vdsBroker;   //
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



## 执行顺序

    Backent.runActionImpl
        CommandsFactory.createCommand(actionType, parameters, context);
            findCommandConstructor
            CommandBase<P> command = (CommandBase<P>) commandConstructor.newInstance(parameters, commandContext);
            Injector.injectMembers(command);
                -------CommandBase-----
                    command的构造方法
                    postConstruct
                        initCommandBase()
                        init()   // 虚函数
                -------CommandBase-----
        runAction
            returnValue = actionExecutor.get().execute(command);
                --------CommandBase------
                executeAction()
                    setActionMessageParameters() // 子函数 多处实现
                    if(parentHasCallback()) persistCommand(getParameters().getParentCommand());   //如果有回调， CommandCallback
                    actionAllowed = getReturnValue().isValid() || internalValidate();
                        returnValue = isUserAuthorizedToRunAction() && validateInputs() && acquireLock() && validate()  && internalValidateAndSetQuota();
                            //isUserAuthorizedToRunAction
                            !MultiLevelAdministrationHandler.isMultilevelAdministrationOn()
                            getPermissionCheckSubjects()  //虚函数
                            checkPermissions()      //检测是否有权限执行该command
                            //validate
                            ValidationUtils.validateInputs(getValidationGroups(),getParameters());  // TODO  validation
                            

                
    
    
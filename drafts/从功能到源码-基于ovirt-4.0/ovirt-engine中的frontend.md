# 前言


# Frontend 
```
runQuery  | runPublicQuery
    -> new VdcOperation() -> new VDCOperationCallback() 
    -> raise qeury event
    -> VdcOperationManager.addOperation


runMultipleQueries
    -> new OperationCallabckList  (onSuccess\onFailure ,执行  IFrontendMultipleQueryAsyncCallback.executed())
    -> new operationList
    -> raise qeury event
    -> VdcOperationManager.addOperationList
    

runAction 
    -> new VdcOperation() -> new VDCOperationCallback() 
    -> raise action event
    -> VdcOperationManager.addOperation

runMultipleAction
    -> new VdcOperationCallbackList()   (onSuccess\onFailure ,执行  IFrontendMultipleActionAsyncCallback.executed())
    -> new operationList
    -> raise action event
    -> if             //Someone called run multiple actions with a single action without parameters. The backend will return
                    //an empty return value as there are no parameters, so we can skip the round trip to the server and return
                    //it ourselves.
       else -> VdcOperationManager.addOperationList

```

# vdc请求

VdcOperationManager



同步请求


异步请求和回调
FrontendActionAsyncResult  ---  IFrontendActionAsyncCallback
FrontendMultipleActionAsyncResult  ---  IFrontendMultipleActionAsyncCallback
FrontendMultipleQueryAsyncResult  --- IFrontendMultipleQueryAsyncCallback
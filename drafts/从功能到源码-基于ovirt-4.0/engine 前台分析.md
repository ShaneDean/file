# 说明
ovirt前台主要是基于gwtp框架实现的，本人水平有限，说明内容并不对GWTP做过多的介绍，想了解更多内容的请自寻访问[document](https://dev.arcbees.com/gwtp/)去扩展学习。



AbstractSubTabPresenter

TabContentProxyPlace

PlaceRequest

PlaceRequestFactory

DetailModelProvider

GridController

IProvidePropertyChangedEvent

HasCleanup

IModel

BaseModel

IEventListener

EventArgs

ICommandTarget

UIConstants

UIMessages


Frontend。一个用来和后台通信的单例
    
VdcOperationManager 



OperationProcessor

CommunicationProvider


ErrorTranslator

IFrontendEventsHandler

FrontendFailureEventArgs

org.ovirt.engine.ui.compat.Event

uicommon中事件通信的主架构，这个和gwt没关系。封装一个给某个Model对象发生的事件，这个事件可以是任何内容，但一般是某个属性值的修改。Event使用发送订阅模式。通过addListener()来订阅事件【一般在view和Presenter中】，事件保存订阅者在list中。通过调用Event.raise()的时候触发事件【一般在Model的setter】   




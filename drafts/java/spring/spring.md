

## Lifecycle Callbacks

```java
    InitializationBean
    DisposableBean
    
    @PostConstruct
    @PreDestroy
    
```

    org.springframework.context.Lifecycle


## 构建工具插件

org.springframework.boot
spring-boot-maven-plugin

# spring mvc 

## DispatcherServlet

### 处理流程

绑定一些Attribute 
    
    WebApplicationContext / LocaleResolver / ThemeResolver

处理 Multipart

    如果是将请求转换为 MultipartHttpServletRequest

Handler处理

    如果找到对应的Handler， 执行Controller 及 前后置5处理器逻辑

处理返回的Model，呈现视图
 

### Controller

定义处理方法

@PathVariabble / @RequestParam / @RequestHeader

HttpEntity / ResponseEntity

### xxxResolver

-   ViewResolver
-   HandlerExceptionResolver
-   MultipartResolver

### HandlerMapping

### 自定义类型转换

自己实现WebMvcConfigurer

-   Spring boot 在WebMvcAutoConfiguration中实现一个
-   添加自定义Converter
-   添加自定义Formatter  

configureMessageConverters()， spring boot 自动查找HttpMessageConverters进行注册

Spring boot 对 jackson 支持

-   JacksonAutoCOnfiguration
    -   Spring Boot 通过@JsonComponent 注册 JSON序列化组件
    -   Jackson2ObjectMapperBuilderCustomizer
-   JacksonHttpMessageConvertersConfiguration
    -   增加jackson-dataformat-xml 支持xml序列化

### 自定义校验

-   validator 对绑定结果进行校验
    -   Hibernate validator
-   @Valid注解
-   BindingResult

### Multipart 上传

-   配置MultipartResolver
    -   Spring Boot 自动配置MultipartAutoConfiguration
-   支持multipart/form-data
-   MultipartFile 类型


### 视图

ViewResolver 与 View 接口
-   AbstractCachingViewResolver
-   UrlBasedViewResolver
-   FreeMarkerViewResolver
-   ContentNegotiatingViewResolver
-   InternalResourceViewResolver

支持  thymeleaf / freemarker / mustache / groovy templates



### DispatcherServlet中的试图解析逻辑

-   initStrategies()
    -   initViewResolvers() 初始化了对应ViewResolver
-   doDispatch()
    -   processDispatchResult()
        -   没有返回视图的话，尝试RequestToViewNameTranslator
        -   resolveViewName()解析view对象

使用 @ResponseBody的情况

-   在HandlerAdapter.handle() 的中完成了Response的输出
-   RequestMappingHandlerAdapter.invokeHandlerMethod()
-   HandlerMethodReturnValueHandlerComposite.handleReturnValue()
-   RequestResponseBodyMethodProcessor.handleReturnValue()

### 重定向

两种不同的重定向前缀

-   redirect        客户端发出的  会丢失上一个Request的信息
-   forward         服务器发出的



## 常用注解

-   @Controller
    -   @RestController
-   @RequestMapping
    -   @GetMapping / @PostMapping
    -   @PutMapping / @DeleteMapping
-   @RequestBody / @ResponseBody / @ResponseStatus 


## Spring 的应用程序上下文

-   BeanFactory
    -   DefaultListableBeanFactory
-   ApplicationContext
    -   ClassPathXmlApplicationContext
    -   FileSystemXmlApplicationContext
    -   AnnotationConfigApplicationContext
-   WebApplicationContext

### 静态资源

WebMvcConfigurer.addResourceHandlers()

配置

-   spring.mvc.static-path-pattern=/XX/**
-   spring.resources.static-locations=classpath:/resources/,classpath:/public/

缓存

ResourceProperties.Cache


### 异常处理

核心接口 

HandlerExceptionResolver

实现类

-   SimpleMappingExceptionResolver
-   DefaultHandlerExceptionResolver
-   ResponseStatusExceptionResolver
-   ExceptionHandlerExceptionResolver

处理方法

@ExceptionHandler

添加位置

-   @Controller / @RestController
-   @ControllerAdvice / @RestControllerAdvice


### mvc 拦截器

HandlerInteceptor

-   boolean preHandle()
-   void postHandle()
-   void afterCompletion()

针对@ResponseBody和ResponseEntity情况

-   ResponseBodyAdvice

针对异步请求的接口

-   AsyncHandlerInterceptor
    -   void afterConcurrentHandlingStarted()


配置方式

-   常规
    -   WebMvcConfigurer.addInterceptors()
-   spring boot 中
    -   创建一个带@Configuration的WebMvcConfigurer配置类
    -   不能带@EnableWebMvc(除非自己完全控制MVC配置)
    

### RestTemplate

需要自己配置 RestTemplateBuilder.build()

常用方法

-   get
    -   getForObject() / getForEntity()
-   post
    -   postForObject() / postForEntity()
-   put
    -   put()
-   delete
    -   delete()

构造URI

-   UriComponentsBuilder
-   ServletUriComponentsBuilder  相当于当前请求
-   MvcUriComponentsBuiler  指向controller

支持的HTTP库

-   通用接口    ClientHttpRequestFactory
-   默认实现    SimpleClientHttpRequestFacotry
-   Appache HttpComponents  HttpComponentsClientHttpRequestFactory
-   Netty   Netty4ClientHttpRequestFactory
-   OkHttp  OkHttp3ClientHttpRequestFactory

### WebClient

一个以 Reactive方式处理HTTP请求的非阻塞的客户端

支持的底层HTTP库

-   Reactor Netty  ReactorClientHttpConnector
-   Jetty ReactiveStream HttpClient JettyClientHttpConnector 

WebClient

-   create 
-   builder

## REST

REST提供了一组框架约束，当作为一个整体来应用，强调组件交互的可伸缩性、接口的通用性、
组件的独立部署、以及用来减少交互延迟、增强安全性、封装遗留系统的中间件

实现步骤

-  识别资源
    -  找到专有名词  可以使用CRUD操作
    -  将资源组织为集合（即集合资源）
    -  将资源组合为复合资源
    -  计算或处理函数
-  选择合适的资源粒度
    -  站在服务端角度
        -  网络效率
        -  表述的多少
        -  客户端的易用程度
    -  站在客户端角度
        -  可缓存性
        -  修改频率
        -  可变性
-  设计URI
    -  使用域及子域对资源进行合理的分组或划分
    -  在URI的路径部分使用斜杠分隔符（/）来并表示资源之间的层级关系
    -  在URI的路径部分使用逗号（，）和分号（；）来表示非层次元素
    -  使用连字符（-）和下划线（_）来改善长路径中名称的可读性
    -  在URI的查询部分使用“与”符号（&）来分隔参数
    -  在URI中避免出现文件扩展名（.php \ .aspx \ .jsp)
-  选择合适的HTTP方法和返回码
    -   方法
        -   GET  安全、幂等
        -   POST 不安全、不幂等
        -   DELETE  不安全、幂等
        -   PUT     不安全、幂等
        -   HEAD    安全、幂等      获得与GET一样的HTTP头信息，但没有响应体
        -   OPTIONS 安全、幂等      获取资源支持的HTTP方法列表
        -   TRACE   安全、幂等      让服务器返回其收到的HTTP头
    -   状态码
        -   200 OK
        -   201 Ceated
        -   202 Accepted
        -   301 Moved Permanently
        -   303 See Other
        -   304 Not Modified
        -   307 Temporary Redirect
        -   400 Bad Request
        -   401 Unauthorized
        -   403 Forbidden
        -   404 Not Found
        -   410 Gone
        -   500 Internal Server Error
        -   503 Service Unavailable
-  设计资源的表述
    -   JSON
        -   MappingJackson2HttpMessageConverter
        -   GsonHttpMessageConverter
        -   JsonbHttpMessageConverter
    -   XML
        -   MappingJackson2XmlHttpMessageConverter
        -   Jaxb2RootElementHttpMessageConverter
    -   HTML
    -   ProtoBuf
        -   ProtobufHttpMessageConverter


### HATEOS
Hybermedia as the engine of application state

Richardson  成熟度模型 level 3 - hypermedia controls

HAL

Hypertext Application Language  : 为API中的资源提供简单的一致链接

HAL模型
-   链接
-   内嵌资源
-   状态

常用注解 (Spring Data REST)
-   @RepositoryRestResource
-   Resource<T>
-   PagedResource<T>

配置 Jackson JSON 支持 HAL

操作超链接
-   找到需要的Link
-   访问超链接

### 会话

常见解决方案
-   粘性会话    Sticky Session
-   会话复制    Session Replication
-   集中会话    Centralized Session

Spring Session
-   简化急群众的用户会话管理
-   无需绑定容器特定解决方案

支持的存储：Redis、MongoDB、JDBC、Hazelcast

原理：

通过定制的HttpServletRequest 返回定制的HTTP Session
-   SessionRepositoryRequestWrapper
-   SessionRepositoryFilter
-   DelegatingFilterProxy
   

## WebFlux

介绍
-   构建在基于Reactive技术栈之上的Web应用程序
-   基于Reactive Streams API ， 运行在非阻塞服务器上

出现的原因
-   非阻塞Web应用的需要
-   函数式编程

关于WebFlux的性能
-   请求的耗时并不会有很大的改善
-   仅需少量固定数量的线程和较少的内存即可实现扩展

WebMVC VS WebFlux
-   已有Spring MVC应用，运行正常，别改
-   以来了大量阻塞式持久化API和网络API，建议使用Spring MVC
-   以及使用了非阻塞技术栈，可以考虑使用WebFlux
-   想要使用JAVA 8 Lambda结合轻量级函数式框架，可以考虑WebFlux

编程模型
-   基于注解的控制器
-   函数式Endpoints

    
```
    返回值 Mono<T>  / Flux<T>
```

# spring boot

不是什么
-   不是应用服务器
-   不是Java EE之类的规范
-   不是代码生成器
-   不是Spring Framework升级版

特性
-   方便地创建可独立运行的Spring应用程序
-   直接内嵌Tomcat、jetty和Undertow
-   简化了项目的构建配置
-   为Spring及第三方库提供自动配置
-   提供生产级特性
-   无需生成代码或进行XML配置

4大核心
-    自动配置   auto configuration
-    起步依赖   Starter dependency
-    命令行     spring boot cli
-    actuator

调试
-   --debug

## 自己的自动配置
步骤
-   编写JAVA Config  @Configuration
-   添加条件    @Conditional
-   定位自动配置    META-INF/spring.factories

条件注解
-   @Confidtional
-   @ConditionalOnClass
-   @ConditionalOnMissingClass
-   @ConditionalOnProperty
-   @ConditionalOnBean
-   @ConditionalOnMissingBean
-   @ConditionalOnSingleCandidate
-   @ConditionalOnResource
-   @ConditionalOnWebApplicaiton
-   @ConditionalOnNotWebApplicaiton
-   @ConditionalOnExpression
-   @ConditionalOnJava
-   @ConditionalOnJndi
-   @AutoConfigureBefore
-   @AutoConfigureAfter
-   @AutoConfigureOrder
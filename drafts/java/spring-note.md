# spring



## spring boot

[doc](https://docs.spring.io/spring-boot/docs/2.2.5.RELEASE/reference/htmlsingle/)



- lazy initialization
  - ​	**spring.main.lazy-initialization**=true
- customizing bann
  - spring.banner.location
  - spring.banner.charset
  - spring.banner.image.location
  - banner.txt
    - ${application.version}	MANIFEST.MF:Implementation-version
    - ${application.formatted-version}
    - ${spring-boot.version}
    - ${spring-boot.formatted-version}
    - ${application.title}  MANIFEST.MF:implementation-title
- application events and listeners
  - ApplicationContext创建之前的listener使用METAINF/spring.factories < "org.springframework.context.ApplicationListener=com.example.project.MyListener"
  - application events order
    - ApplicationStartingEvent
    - ApplicationEnvironmentPreparedEvent: **Environment** 被使用
    - ApplicationContextInitializedEvent: **ApplicationContext** 准备好，在**ApplicationContextInitializers**被调用但是没有bean被加载
    - ApplicationPreparedEvent: refresh开始前、bean定义被加载之后
      - ContextRefreshedEvent
      - WebServerInitializedEvent
    - ApplicationStartedEvent: refreshed 之后，runners调用之前
    - ApplicationReadyEvent: runners调用之后。表明 application可以提供服务了
    - ApplicationFailedEvent: exectpion on startup
- Web Environment
  - 如果mvc: AnnotationConfigServletWebServerApplicationContext
  - 如果webflux: AnnotationConfigReactiveWebServerApplicationContext
  - 否则 ： AnnotationConfigApplicationContext
- Application Arguments
  - 使用ApplicationArguments注入，通过**option**、**non-option**来提供String[] 
- Runner
  - ApplicationRunner
  - CommandLineRunner
- Application Exit
  - 使用ExitCodeGenerator定义特殊的退出码给System.exit
- 管理特性
  - 需要spring.application.admin.enbaled = true
  - Externalized Configuration
    - 一套代码，不同环境
    - 外部配置的作用顺序
      - devtools global settings properties
      - @TestPropertySource
      - test中**properties**
      - command line arguments
      - Properties from **SPRING_APPLICATION_JSON**
      - **ServletConfig** init parameters
      - **ServletContext** init parameters
      - JNDI attributes from **java:comp/env**
      - Java System properties(**System.getProperties()**)
      - OS 环境变量
      - **RandomValuePropertySource**
      - jar外面的 特定profile(application-{profile}.yml)
      - jar里面的 特定profile(application-{profile}.yml)
      - jar外的默认配置(application.yml)
      - @PropertySource
      - 默认(SpringApplication.setDefaultProperties)
    - 使用： @Value("{name}")
    - random : RandomValuePropertySource
    - command line properties ： 使用 **--** 开头，会自动加到**Environment** 中
    - application properties files ： 自动查找application.properties到**Environment**
      - ./config/application.[properties/yml]
      - ./application.[properties/yml]
      - **classpath**:config/application.[properties/yml]
      - **classpath**:application.[properties/yml]
    - placeholder : ${previously-name}
    - encrypting properties: spring cloud vault => HashiCrop Vault
    - **@ConfigurationProperties** 使用前缀，支持POJO映射
    - @ConstructorBinding： 使用构造器
    - yml不支持@PropertySource 
    - 支持的宽松绑定
      - kebab case : a.b-cd
      - Standard camel: a.bCd
      - underscore notation: a.b_cd
      - Upper case: A_BCD
    - "[key]" : 保留 key内的特殊字符
    - @DurationUnit  时间转换
    - @DataSizeUnit  数据大小转换
    - 验证（@ConfigurationProperties  + @Validated） (JSR-303)
  - profiles
    - **spring.profiles.active** 
  - logging  
    - --debug / application.properties:debug = true 
    - --trace /  application.properties:trace = true 
    - color : spring.output.ansi.enabled = 
    - file output: logging.file.name/logging.file.path
      - logging.file.max-size: default 10MB
      - logging.file.max-history : default 7 days
      - total size : logging.file.total-size-cap
      - clean history log : logging.file.clean-history-on-start
    - levels: 分别定义root logger和 其他的logger
    - group : 不同的logger 定义成一个logging.group.xxx
      - 预定义 group
        - web
        - sql
    - cumstomization : loging.config
      - logback
      - log4j2
      - jdk
    - logback extensions 
      - profile  :  \<springProfile\>
      - environment properties: \<springProperty\>
  - 国际化 ： spring.messages.
  - json  : 支持 Gson / Jackson / JSON-B
  - web
    - spring mvc
      - 




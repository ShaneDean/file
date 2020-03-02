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
      - HttpMessageConverters
      - JSON Serializers / Deserializers : default Jackson
        - @JsonComponent
        - @MesssageCodeResolver :error codes => errors message
        - static content
          - ResourceHttpRequestHandler
          - (default)spring.mvc.static-path-pattern=/**
          - spring.resources.static-locations
          - version agnostic
          - cache busting
        - welcome page : index.html
        - custom favicon : favicon.icon
        - negotiation
          - spring.mvc.contentnegotiation.favor-parameter
          - spring.mvc.contentnegotiation.parameter-name
          - (additional file extensions) spring.mvc.contentnegotiation.media-types.markdown=text/markdown
        - TemplateEngines
          - FreeMarker / Groovy / Thymeleaf / Mustache
          - (default) **src/main/resources/templates**
        - Error handling
          - @ControllerAdvice
          - (error page)ErrorViewResolver : /resources/error/[error-code].[template]
            - FilterRegistrationBean  register **ERROR**
        - HATEOAS
          - @EnableHypermediaSupport 
            - LinkDiscoverers
            - ObjectMapper
        - CORS (Cross-origin resource sharing)
          -  WebMvcConfigurer:  CorsRegistry.addCorsMappings(CorsRegistry)
    - WebFlux : 略
    - JAX-RS and Jersey
      - include : **spring-boot-starter-jersey** dependency
      - extends **ResourceConfig** and register all endpoints
    - enbedded servlet container
      - support: Tomcat / Jetty / Undertow
      - customize : 也支持 programmatic customization
        - network-settings : server.port/server.address
        - session-settings : server.servlet.session
          - persistent
          - timeout
          - store-dir
          - cookie.*
        - Error-management server.error.path ...
        - SSL
        - HTTP compression
      - JSP Limitations
        - jetty / tomcat  in  **java -jar** not support jsp
        - undertow not support jsp
        - error.jsp not override default view for **error handling**
  - RSocket
    - spring-boot-starter-rsocket
    - RSocketMessageHandler  :  auto configure spring messaging
    - RSocketRequester : calling RSocket services
  - security : [detail](https://docs.spring.io/spring-security/site/docs/5.2.2.RELEASE/reference/htmlsingle/#jc-method)
    - 略
  - sql-db: 略
  - no-sql-db : 略
  - caching : 略
  - Messaging: 略
  - calling rest service ： 略
    - RestTemplate
    - WebClient
  - Validation
    - @Validated
  - mail
    - JavaMailSender
  - Distributed transactions with JTA
    - Atomikos / Bitronix
    - java ee managed transaction manager
  - Hazelcast ： 略
  - Quartz
    - spring-boot-starter-quartz
  - Task Execution and Scheduling
    - **ThreadPoolTaskExecutor ** / @EnableAsyc
    - spring.task.execution
  - Spring session: 略
  - Testing : [more](https://docs.spring.io/spring/docs/5.2.4.RELEASE/spring-framework-reference/testing.html#testing)
    - spring-boot-test / spring-boot-test-autoconfigure 
    - spring-boot-starter-test
      - JUnit5
      - SpringTest  & Spring Boot Test
      - AssertJ
      - Hamcrest
      - Mockito
      - JSONassert
      - JsonPath
    - @SpringBootTest
      - MOCK/RANDOM_PORT/DEFINED_PORT/NONE
    - 略
  - websocket
    - spring-boot-starter-websocket
  - Web Service
  - createing my own auto-configuration  **TODO**
  
- Deploying

  - jar -jar
  - fully executable

  ``` xml
  <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
      <configuration>
          <executable>true</executable>
      </configuration>
  </plugin>
  ```

  

  - init.d	
    -  sudo ln -s /var/myapp/myapp.jar /etc/init.d/myapp
    -  features
      - service myapp start
      - /var/run/myapp/myapp.pid
      - /var/log/myapp.log
  - systemd

  ```properties
  [Unit]
  Description=myapp
  After=syslog.target
  
  [Service]
  User=myapp
  ExecStart=/var/myapp/myapp.jar
  SuccessExitStatus=143
  
  [Install]
  WantedBy=multi-user.target
  ```

  - support config file
    - /var/myapp/myapp.conf
    - support [KEY](https://docs.spring.io/spring-boot/docs/2.2.5.RELEASE/reference/html/deployment.html#deployment-script-customization) 

- [more](https://docs.spring.io/spring-boot/docs/2.2.5.RELEASE/reference/htmlsingle/#appendix)


# 前言


ovirt-engine提供标准的RESTful服务。

[jaxrs](https://docs.oracle.com/javaee/7/tutorial/jaxrs.htm) 

[resteasy](https://docs.jboss.org/resteasy/docs/4.4.2.Final/userguide/pdf/resteasy-reference-guide-en-US.pdf)

本次分析内容覆盖

-   [ovirt-engine/backend/manager/modules/restapi](https://github.com/oVirt/ovirt-engine/tree/ovirt-engine-4.3/backend/manager/modules/restapi)
-   [oVirt Engine API  Model](https://github.com/oVirt/ovirt-engine-api-model) 
-   [oVirt Engine API Metamodel](https://github.com/oVirt/ovirt-engine-api-metamodel)

# restapi

## apidoc

该项目定义了engine服务发布后/ovirt-engine/apidoc/的访问路径指向的api文档

在pom.xml中定义了 maven-dependency-plugin，从[org.ovirt.engine.api.model](https://github.com/oVirt/ovirt-engine-api-model)的package 产出 解压到本项目中，再通过maven-war-plugin将解压后的文件定义为web资源

## interface

-   common
    -   jaxrs   通用的工具内容
-   definition  定义了和 api-model、api-metamodel整合方式

definition 中定义的mvn目标如下:

![mvn_lifecycle](https://github.com/ShaneDean/file/raw/master/blog/ovirt_engine_env/ovirt_engine_restapi_interface_definition_mvn_lifecycle.png)

**mvn package** 的执行顺序如下

1. copy-model-file
    -   [dependency:copy用法](https://maven.apache.org/plugins/maven-dependency-plugin/copy-mojo.html)
    -   把org.ovirt.engine.api.model-${model.version}的产出xxx-sources.jar copy到 SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-resources/model.jar
2. generate-code
    -   [exec:exec用法](https://www.mojohaus.org/exec-maven-plugin/exec-mojo.html)
    -   classpath 自动使用所有project的dependencies
    -   等同执行如下命令

```shell
java 
    org.ovirt.api.metamodel.tool.Main 
    org.ovirt.api.metamodel.tool.Tool
    --model=SOURCE/ovirt-engine/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-resources/model.jar
    --in-schema=SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/src/main/schema/api.xsd 
    --out-schema=SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-resources/v4/api.xsd 
    --jaxrs==SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-sources/model 
    --jaxrs-package=^services\.(.*)$=org.ovirt.engine.api.resource.$1
    --jaxrs-package=org.ovirt.engine.api.resource
```

3. xjc-v4
    -   [xjc](https://javaee.github.io/jaxb-v2/doc/user-guide/ch04.html#tools-xjc)
    -   [maven-jaxb2-plugin](https://github.com/highsource/maven-jaxb2-plugin)
    -   SOURCE前缀省略
    -   使用xjc将ovirt-engine/backend/manager/modules/restapi/interface/definition/src/main/schema/api.xjb和ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-resources/v4/api.xsd编译成ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-sources/xjc-v4/下的org.ovirt-engine.api.model包
4. xjc-v3
    -   SOURCE前缀省略
    -   使用xjc将ovirt-engine/backend/manager/modules/restapi/interface/definition/src/main/resources/v3/api.xjb和ovirt-engine/backend/manager/modules/restapi/interface/definition/src/main/resources/v3/api.xsd编译成ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-sources/xjc-v3/下的org.ovirt.engine.api.v3.types包
5. add-source
6. generate-enums-jaxb
7. extract-model-documentation
    -   [dependency:unpack用法](https://maven.apache.org/plugins/maven-dependency-plugin/unpack-mojo.html)
    -   把org.ovirt.engine.api.model-${model.version}的产出doc.jar unpack到 SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/generated-resources中
    -   文件包括model.adoc/.html/.json/.xml
8. default-resources
    -   默认阶段
9. default-compile
    -   默认阶段
10. animal-sniffer
    -   java版本检查 [地址](http://www.mojohaus.org/animal-sniffer/animal-sniffer-maven-plugin/)
11. checkstyle
    -   代码静态检查 [地址](https://maven.apache.org/plugins/maven-checkstyle-plugin/)
12. generate-rsdl
    -   [rsdl](https://en.wikipedia.org/wiki/RSDL) [rsdl-more](http://www.balisage.net/Proceedings/vol10/print/Robie01/BalisageVol10-Robie01.html)
    -   [exec:java](https://www.mojohaus.org/exec-maven-plugin/java-mojo.html)
    -   如同执行

```shell
java 
    org.ovirt.engine.api.rsdl.RsdlManager
    /ovirt-engine/api
    SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/classes/v4/rsdl.xml
    SOURCE/ovirt-engine/backend/manager/modules/restapi/interface/definition/target/classes/v4/rsdl_gluster.xml
```

13. 其他后续mvn默认阶段(testResources/testCompile/test/...)
    - 略


## jaxrs

[resteasy-3.0.24](https://docs.jboss.org/resteasy/docs/3.0.24.Final/userguide/html_single/index.html)

RESTful服务实现的主体，在4.0+版本包含了对历史版本的兼容，分了v4和v3两个入口，通过HEADER中的Version标志区分，自动默认进入v4路径。v4的具体情况如下：

-   /ovirt-engine/api/v4    : @ApplicationPath("/v4")
    -   BackendApiResource  implements  SystemResource
        -   SystemResource接口定义了全局入口的路径请求映射关系
        -   @Path 定义 当前 Resource的子path和对应的子Resource
        -   BaseBackendResource ：  包含了通用异常及异常处理、类型转换、国际化、validate、后缀参数处理(filter/follow/max)
            -   BackendResource : 包含了负责和Backend交互的逻辑，query/action/job/step
                -   AbstractBackendResource : 负责把db-model转换成rest-model，后台异步任务的结果状态跟踪，填充某个Query需要附加的数据，维护父资源和子资源关系(vms/:vmid/devices/:deviceid)，增加额外的link关系，更灵活的资源查询扩展等
                    -   AbstractBackendCollectionResource   资源列表，vms/hosts等
                    -   AbstractBackendSubResource      资源对象, vms/:vmid,hosts/:hostid等
    -   ExceptionMapper
        -   MalformedIdExceptionMapper
        -   JsonExceptionMapper
        -   MappingExceptionMapper
        -   IOExceptionMapper
        -   ValidationExceptionMapper

BackendApiResource:get() ==> 
-   /ovirt-engine/api 
-   /ovirt-engine/api?rsdl
-   /ovirt-engine/api?schema

## types

定义了 db-model  <==>  rest-model 的全部mapper和mapping过程中用到的工具类。BackendApiResource保存了所有的mapping关系，通过getMapper来使用

## webapp

定义了/ovirt-engine/api路径下的请求路由逻辑，执行顺序如下

-   CORSSupportFilter
-   CSRFProtectionFilter
-   RestApiSessionValidationFilter
-   SessionValidationFilter
-   SsoRestApiAuthFilter
-   SsoRestApiNegotiationFilter
-   EnforceAuthFilter
-   RestApiSessionMgmtFilter
-   CurrentFilter   为每个请求维护一个Current对象，在resource中可以通过getCurrent来使用
-   VersionFilter   处理版本相关信息，重定向到正确的resource上
-   NullServlet     处理 /ovirt-engine/api  ==>  /ovirt-engine/api/ 中间的302重新向问题
-   ModelServlet    resource ==> representation 

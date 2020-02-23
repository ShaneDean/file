# 前言 

ovirt-engine提供了rest的api接口，这里分析下rest中涉及到的代码 ， 3.5版本

# 项目
在ovirt-engine项目中 有一个restapi-parent项目(org.ovirt.engine.api)。包括4个module：

1. types : 包含[XXX]Mapper  用于 rest Model和 db Model的转换
2. jaxrs
3. webapp
4. interface


## jaxrs

## interface 

该包定义了engine中的

engine使用 [ovirt-engine-api-metamodel](https://github.com/oVirt/ovirt-engine-api-metamodel)项目来从api model来生成代码
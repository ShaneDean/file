# 前言

ovirt-engine是一个由maven组织起来java项目，其中也包括makefile、package或otopi plugin等其他手段来协助完成打包、验证、开发环境准备、初始化等工作，但主要的是maven，在分析梳理项目或导入项目的时候都可以以pom.xml为入口。一个大型项目通常都是由几个小项目或者模块组成的，通过pom.xml定义的关系和包含的mvn plugin可以快速的了解每个子项目的作用从而理解整个项目。

例如来make install-dev中出现错误的时候，一般应当找到对应报错的maven项目，切换到该项目目录，分析出错的maven命令的原因，这样就可以了解深层次的错误原因而不是看到报错一筹莫展。

# maven

maven的学习资料比较多，可以通过阅读[参考1](https://segmentfault.com/a/1190000014136187)、[参考2](https://juejin.im/entry/5b0fa70af265da090e3df499)、[参考3](http://jolestar.com/dependency-management-tools-maven-gradle/)、[参考4](http://www.cnblogs.com/davenkin/p/advanced-maven-multi-module-vs-inheritance.html)、[官网](http://maven.apache.org/guides/getting-started/index.html)和[书](https://item.jd.com/10476794.html)来学习。

个人感觉可以和npm类比的学习[参考5](https://codeday.me/bug/20181204/432991.html)

除了maven默认插件之外，熟练使用丰富的外部 plugin是学习maven的另一个重点。

每个plugin都可以通过mvn [plugin]:[action]的方式使用其提供的服务。

例如tomcat-maven-plugin：
```
mvn tomcat:deploy   --部署一个web war包
mvn tomcat:reload   --重新加载web war包
mvn tomcat:start    --启动tomcat
mvn tomcat:stop    --停止tomcat
mvn tomcat:undeploy --停止一个war包
mvn tomcat:run  --启动嵌入式tomcat ，并运行当前项目
```

# pom.xml

在engine项目中的root pom.xml中定义了5个module，
```
build-tools-root： 包含静态检查的一些通用规则配置文件,如checkstyle\findbugs
backend：   后台业务逻辑代码
frontend:   前台业务逻辑代码
ear：          定义jboss运行时的内外部依赖和业务逻辑代码中不同子项目的打包方式、URL映射关系
mavenmake:      执行make install-dev
```
也定义了所有子项目中依赖的版本的变量。

maven中的Profile用于在不同的环境下应用不同的配置，一套配置位一个profile。


# ovirt-jboss-modules-maven-plugin


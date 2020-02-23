# 前言

# maven 5分钟

## 默认命令
    
    validate    :   检测project是否正确和所有必须的信息是否可用
    compile     :   编译项目的源代码
    test        :   使用合适的单元测试框架去测试项目源代码。
    package     :   使用编译后的代码，打包成特定的格式，如jar
    integration-test    :   处理和部署package到新需要跑集成测试的环境
    verify      :   运行检查来验证包是否有效并且符合质量标准
    install     :   安装包到本地仓库，提供给其他项目作为依赖使用
    deploy      :   完成集成或发布环境，拷贝这最后的包到远程仓库提供给其他开发者
    clean       :   清除所有先前项目创建的artifacts
    site        :   为这个项目生成代码
    
## 生命周期

    validate、compile、test、package、verify、install、deploy
    
## 打包方式
    
    jar、war、ear、pom
    
## 项目继承

如果有多个Maven项目，并且都有相似的配置，可以抽象出相似的配置并制作成父项目，让其他的项目来继承该项目。

## 依赖
传递性依赖
- Dependency mediation
- Dependency management
- Dependency scope
- Excluded dependencies
- Optional dependencies

依赖范围
- compile


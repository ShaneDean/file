# 前言 
记录下学习[vue clie](https://cli.vuejs.org/zh/guide/)的一些笔记，加强记忆。

# 简介
Vue CLI 是一个基于 Vue.js 进行快速开发的完整系统，提供：

-   通过 @vue/cli 搭建交互式的项目脚手架。
-   通过 @vue/cli + @vue/cli-service-global 快速开始零配置原型开发。
-   一个运行时依赖 (@vue/cli-service)，该依赖：
    -   可升级；
    -   基于 webpack 构建，并带有合理的默认配置；
    -   可以通过项目内的配置文件进行配置；
    -   可以通过插件进行扩展。
-   一个丰富的官方插件集合，集成了前端生态中最好的工具。
-   一套完全图形化的创建和管理 Vue.js 项目的用户界面。

# 组件
## cli

CLI (@vue/cli) 是一个全局安装的 npm 包，提供了终端里的 vue 命令。它可以通过 vue create 快速创建一个新项目的脚手架，或者直接通过 vue serve 构建新想法的原型。你也可以通过 vue ui 通过一套图形化界面管理你的所有项目。我们会在接下来的指南中逐章节深入介绍。

# CLI 服务

CLI 服务 (@vue/cli-service) 是一个开发环境依赖。它是一个 npm 包，局部安装在每个 @vue/cli 创建的项目中。

CLI 服务是构建于 webpack 和 webpack-dev-server 之上的。它包含了：

加载其它 CLI 插件的核心服务；
一个针对绝大部分应用优化过的内部的 webpack 配置；
项目内部的 vue-cli-service 命令，提供 serve、build 和 inspect 命令。
如果你熟悉 create-react-app 的话，@vue/cli-service 实际上大致等价于 react-scripts，尽管功能集合不一样。

# CLI 插件

CLI 插件是向你的 Vue 项目提供可选功能的 npm 包，例如 Babel/TypeScript 转译、ESLint 集成、单元测试和 end-to-end 测试等。Vue CLI 插件的名字以 @vue/cli-plugin- (内建插件) 或 vue-cli-plugin- (社区插件) 开头，非常容易使用。

当你在项目内部运行 vue-cli-service 命令时，它会自动解析并加载 package.json 中列出的所有 CLI 插件。

插件可以作为项目创建过程的一部分，或在后期加入到项目中。它们也可以被归成一组可复用的 preset。
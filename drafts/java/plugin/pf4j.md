# intro

[home](https://pf4j.org) [code](https://github.com/pf4j/pf4j) [java doc](https://www.javadoc.io/doc/org.pf4j/pf4j/2.4.0/index.html)

A plugin is a way for a third party to extend the functionality of an application. A plugin implements extension points declared by application or other plugins. Also a plugin can define extension points.

With PF4J you can easily transform a monolithic java application in a modular application.

# 核心组件

- Plugin
  - 所有插件的基类
  - 每个插件都会单独加载避免冲突
- PluginManager
  - 用来管理插件的方方面面（加载、启动、停止）
  - 提供内置实现 DefaultPluginManager
  - 也可以自己实现 AbstractPluginManager
- PluginLoader
  - 加载插件信息
- ExtensionPoint
  - is a point in the application where custom code can be invoked.
  - 接口标记
  - 任何接口和虚类都可以被设定为extension point（implement it）
- Extension
  - extension point 的实现

# 起步

```java
public static void main(String[] args) {
    ...

    PluginManager pluginManager = new 	DefaultPluginManager();
    pluginManager.loadPlugins();
    pluginManager.startPlugins();

    ...
}
```

创建一个DefaultPluginManager来load、start插件，每个可用插件都会用不同的java class loader(PluginClassLoader)来加载 。



PluginClassLoader会在**PluginClasspath** （默认classes和lib文件夹）里面加载。 如果没有指定则默认返回： 

```java
System.getProperty("pf4j.pluginsDir", "plugins") 
```

plugins文件夹下：

- plugin1.zip(zip file)
- plugin2(folder)
  - classes(folder)
  - lib(folder, 可选，如果使用了第三方的依赖)

plugin manager通过**PluginDescriptorFinder**来找到插件元数据，默认使用ManifestPluginDescriptorFinder， 查找MANIFEST.MF文件

```makefile
#classes/META-INF/MANIFEST.MF
Manifest-Version: 1.0
Archiver-Version: Plexus Archiver
Created-By: Apache Maven
Built-By: decebal
Build-Jdk: 1.6.0_17
Plugin-Class: org.pf4j.demo.welcome.WelcomePlugin
Plugin-Dependencies: x, y, z
Plugin-Id: welcome-plugin
Plugin-Provider: Decebal Suiu
Plugin-Version: 0.0.1
```

上面的manifest文件描述了一个插件`welcome-plugin`，类名是`org.pf4j.demo.welcom.WelcomPlugin`，版本是`0.0.1` ，依赖 `x,y,z`。

所有插件的版本定义必须符合 [语义化版本](https://semver.org/lang/zh-CN/)的要求

使用者可以通过 `extends ExtensionPoint`来定义 扩展点。

```java
public interface Greeting extends ExtensionPoint {
    String getGreeting();
}
```

Another important internal component is **ExtensionFinder** that describes how the plugin manager discovers extensions for the extensions points.

**DefaultExtensionFinder** looks up extensions using ``@Extension``

DefaultExtensionFinder looks up extensions in all extensions index files `META-INF/extensions.idx`. PF4J uses Java Annotation Processing to process at compile time all classes annotated with @Extension and to produce the extensions index file.

```java
public class WelcomePlugin extends Plugin {
    public WelcomePlugin(PluginWrapper wrapper) {
        super(wrapper);
    }
    @Extension
    public static class WelcomeGreeting implements Greeting {
        public String getGreeting() {
            return "Welcome";
        }
    }
}
```

上面的代码增加`Greeting`扩展点 ， 可以通过下面的代码获取所有 extensions

```java
List<Greeting> greetings = pluginManager.getExtensions(Greeting.class);
for (Greeting greeting : greetings) {
    System.out.println(">>> " + greeting.getGreeting());
}
```

通过重载DefaultPluginManager中的`create...`方法来注入自己的component(PluginDescriptorFinder, ExtensionFinder, PluginClasspath)

每个插件代码中的必须包含`plugin.properties`文件

```properties
plugin.class=org.pf4j.demo.welcome.WelcomePlugin
plugin.dependencies=x, y, z
plugin.id=welcome-plugin
plugin.provider=Decebal Suiu
plugin.version=0.0.1
```

You can control extension instance creation overriding `createExtensionFactory` method from DefaultExtensionFinder. Also, you can control plugin instance creation overriding `createPluginFactory` method from DefaultExtensionFinder.



**NOTE:** If your application didn’t find extensions then make sure that you have a file with name `extensions.idx` generated by PF4J in the plugin jar. It’s most likely that they are some problems with the annotation processing mechanism from Java. One possible solution to resolve your problem is to add a configuration to your maven build. The `maven-compiler-plugin` can be configured to do this like so:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>2.5.1</version>
    <configuration>
        <annotationProcessors>
            <annotationProcessor>org.pf4j.processor.ExtensionAnnotationProcessor</annotationProcessor>
        </annotationProcessors>
    </configuration>
</plugin>
```

# 类加载

Class loaders are responsible for loading Java classes during runtime dynamically to the JVM。

PF4j使用 `PluginClassLoader`来加载插件， **each available plugin is loaded using a different `PluginClassLoader`**，One instance of `PluginClassLoader` should be created by plugin manager for every available plug-in.

调用`loadClass(String className)`后的流程

- java.开头，委托system class loader
- org.pf4j开头，使用父类加载器(ApplicationClassLoader)
  -  getParent().loadClass
- 尝试使用当前的插件加载器(PluginClassLoader)实例
  -  findLoadedClass
- 根据 ClassLoadingStrategy来加载 ( 根据 [代码](https://github.com/pf4j/pf4j/blob/4d08bc8c51386ee6bdde1322b6b291db1196b4b2/pf4j/src/main/java/org/pf4j/PluginClassLoader.java))
  - APPLICATION：super.loadClass
  - PLUGIN: findClass
  - DEPENDENCIES:  根据 PluginDependency来加载

可以通过重载 可以强制共用一个`PluginClassLoader`

# 插件打包

pf4j支持2中打包方式

- .jar(fat/shade/one-jar)
- .zip(with lib/classes)

需要把文件放到目录 `plugins`(pluginsRoot)中， 像下面的样子

```shell
$ tree plugins
plugins
├── disabled.txt
├── enabled.txt
├── demo-plugin1-2.4.0.zip
└── demo-plugin2-2.4.0.zip

# or

$ tree plugins
plugins
├── disabled.txt
├── enabled.txt
├── demo-plugin1-2.4.0.jar
└── demo-plugin2-2.4.0.jar

# or mix .jar with .zip

$ tree plugins
plugins
├── disabled.txt
├── enabled.txt
├── demo-plugin1-2.4.0.jar
└── demo-plugin2-2.4.0.zip
```

推荐使用.jar

所有的插件都是由`PluginManager` 从 `plugins`目录下加载的。

你可以通过以下方式来修改加载的目标目录

- ​	`-Dpf4j.pluginsDir=plugins`来修改环境变量`pf4j.pluginsDir`
- 手动创建`DefaultPluginManager`

# 插件

这里的plugin定义：一堆java 类和依赖库，能被PF4J在程序运行时加载。

如果你不需要在程序运行时加载和卸载特定java代码部分，你可以使用`extensions`或把编译好的class放到application classpath(`system extensions`)

## 定义插件

```JAVA
import org.pf4j.Plugin;
import org.pf4j.PluginException;
import org.pf4j.PluginWrapper;

public class MyPlugin extends Plugin {
    public MyPlugin(PluginWrapper wrapper) {
        super(wrapper);
    }
    @Override
    public void start() throws PluginException {
        // This method is called by the application when the plugin is started.
    }
    @Override
    public void stop() throws PluginException {
        // This method is called by the application when the plugin is stopped.
    }
    @Override
    public void delete() throws PluginException {
        // This method is called by the application when the plugin is deleted.
    }
}
```

plugin需要提供metadata来支持加载

- plugin的class 全部名称 `可选`
- 唯一标志
- 版本号
- application 版本`可选`
- 插件依赖`可选`
- 插件描述`可选`
- 供应商/作者名称`可选`
- license`可选`

metadata的提供方式

- 可以通过 `MANIFEST.MF` 文件提供

`META-INF/MANIFEST.MF` 文件示例

```properties
Plugin-Class: org.pf4j.demo.welcome.WelcomePlugin
Plugin-Id: welcome-plugin
Plugin-Version: 0.0.1
Plugin-Requires: 1.0.0
Plugin-Dependencies: x, y, z
Plugin-Description: My example plugin
Plugin-Provider: Decebal Suiu
Plugin-License: Apache License 2.0
```

- 也可以通过pom.xml来定义

maven-jar-plugin`示例

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <configuration>
        <archive>
            <manifest>
                <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
                <addDefaultSpecificationEntries>true</addDefaultSpecificationEntries>
            </manifest>
            <manifestEntries>
                <Plugin-Class>org.pf4j.demo.welcome.WelcomePlugin</Plugin-Class>
                <Plugin-Id>welcome-plugin</Plugin-Id>
                <Plugin-Version>0.0.1</Plugin-Version>
                <Plugin-Requires>1.0.0</Plugin-Requires>
                <Plugin-Dependencies>x, y, z</Plugin-Dependencies>
                <Plugin-Description>My example plugin</Plugin-Description>
                <Plugin-Provider>Decebal Suiu</Plugin-Provider>
                <Plugin-License>Apache License 2.0</Plugin-License>
            </manifestEntries>
        </archive>
    </configuration>
</plugin>
```

maven-assembly-plugin`示例

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <configuration>
        <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
        </descriptorRefs>
        <finalName>${project.artifactId}-${project.version}-plugin</finalName>
        <appendAssemblyId>false</appendAssemblyId>
        <attach>false</attach>
        <archive>
            <manifest>
                <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
                <addDefaultSpecificationEntries>true</addDefaultSpecificationEntries>
            </manifest>
            <manifestEntries>
                <Plugin-Class>org.pf4j.demo.welcome.WelcomePlugin</Plugin-Class>
                <Plugin-Id>welcome-plugin</Plugin-Id>
                <Plugin-Version>0.0.1</Plugin-Version>
                <Plugin-Requires>1.0.0</Plugin-Requires>
                <Plugin-Dependencies>x, y, z</Plugin-Dependencies>
                <Plugin-Description>My example plugin</Plugin-Description>
                <Plugin-Provider>Decebal Suiu</Plugin-Provider>
                <Plugin-License>Apache License 2.0</Plugin-License>
            </manifestEntries>
        </archive>
    </configuration>
    <executions>
        <execution>
            <id>make-assembly</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

- 提供`plugin.properties`

```properties
plugin.class=org.pf4j.demo.welcome.WelcomePlugin
plugin.id=welcome-plugin
plugin.version=0.0.1
plugin.requires=1.0.0
plugin.dependencies=x, y, z
plugin.description=My example plugin
plugin.provider=Decebal Suiu
plugin.license=Apache License 2.0
```

插件依赖的高级定义方法详见[here](https://pf4j.org/doc/plugins.html)

## 生命周期

预定义状态包括：

- `CREATED`
- `DISABLED`
- `RESOLVED`
- `STARTED`
- `STOPPED`

`DefaultPluginManager` 包含以下逻辑

- 所有插件都可以被解析和装在
- `DISABLED`插件不能自动被`startPlugins()`启动，但可以被手动调用`startPlugin(pluginId)`
- 只有`STARTED`的插件可以贡献extensions

`STARTED` 和`DISABLED`插件的区别

- `STARTED` 可以执行`Plugin.start()`， `DISABLED`不行
- `STARTED` 可以提供extension instances， `DISABLED`不行

`PluginManager`提供的状态操作

- load、unload
- enable、disable
- start、stop
- delete

## disable plugin

理论上，扩展点和其扩展的关系是1:N，但客户可以选择指定某个，将N变成1 ，这就需要我们提供方法来去掉不用的N-1部分，方法如下

- uninstall(移除插件的文件/文件夹)
- disable
  - 定义enable.txt和disabled.txt

示例如下

enabled.txt

```properties
########################################
# - load only these plugins
# - add one plugin id on each line
# - put this file in plugins folder
########################################
welcome-plugin
```

disabled.txt

```properties
########################################
# - load all plugins except these
# - add one plugin id on each line
# - put this file in plugins folder
########################################
welcome-plugin
```



# 定制PluginManager

提供的方法

- 实现 `PluginManager` interface
- 修改 内置实现 `DefaultPluginManager`
- 继承 `AbstractPluginManager` 基类

如果只有jar的插件，可以这样定制

```java
PluginManager pluginManager = new DefaultPluginManager() {
    @Override
    protected PluginLoader createPluginLoader() {
        // load only jar plugins 
        return new JarPluginLoader(this);
    }
    @Override
    protected PluginDescriptorFinder createPluginDescriptorFinder() {
        // read plugin descriptor from jar's manifest 
        return new ManifestPluginDescriptorFinder();
    }
}; 
```

# 运行模式

pf4j支持两种模式 `DEVELOPMENT` 和 `DEPLOYMENT`模式

- `DEPLOYMENT` 默认，workflow：
  - create a new maven module for each plugin
  - coding the plugin
  - pack the plugin in a zip file
  - deploy the zip file to plugins folder
- `DEVELOPMENT` 不需要pack/deploy 插件
  - 使用该模式方法 
    - change "pf4j.mode" 系统变量
    - 重载 `DefaultPluginManager.getRuntimeMode()`
  - development模式下的情况
    - pluginsDirectory  -> `../plugins`
    - `PropertiesPluginDescriptorFinder`
    - `DevelopmentPluginClasspath`
  - 可以输出调试信息

# Extension

## extension points

定义了特定行为的接口或类

```java
import javax.swing.JMenuBar;
import org.pf4j.ExtensionPoint;
interface MainMenuExtensionPoint extends ExtensionPoint {
    void buildMenuBar(JMenuBar menuBar);
}
```



```java
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import org.pf4j.Extension;

@Extension
public class MyMainMenuExtension implements MainMenuExtensionPoint {

    public void buildMenuBar(JMenuBar menuBar) {
        JMenu exampleMenu = new JMenu("Example");
        exampleMenu.add(new JMenuItem("Hello World"));
        menuBar.add(exampleMenu);
    }
}
```

extension 可以从application classpath加载 (system extensions) ，或者通过插件提供

```java
import javax.swing.JDialog;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import org.pf4j.DefaultPluginManager;
import org.pf4j.PluginManager;

public static void main(String[] args) {
    // Init the plugin environment.
    // This should be done once during the boot process of the application.
    final PluginManager pluginManager = new DefaultPluginManager();
    pluginManager.loadPlugins();
    pluginManager.startPlugins();

    // Launch Swing application.
    java.awt.EventQueue.invokeLater(new Runnable() {

        public void run() {
            // Build the menu bar by using the available extensions.
            JMenuBar mainMenu = new JMenuBar();
            for (MainMenuExtensionPoint extension : pluginManager.getExtensions(MainMenuExtensionPoint.class)) {
                extension.buildMenuBar(mainMenu);
            }

            // Create and show a dialog with the menu bar.
            JDialog dialog = new JDialog();
            dialog.setTitle("Example dialog");
            dialog.setSize(450,300);
            dialog.setJMenuBar(mainMenu);
            dialog.setVisible(true);
        }

    });

}
```

## 其他参数

@Extension

- ordering 顺序从1到N
- points 手动指定 extension
-  optional dependency on each other， discussion  [issue #266](https://github.com/pf4j/pf4j/issues/266)

## 实例化

PF4J使用 ExtensionFactory (默认DefaultExtensionFactory) 创建extension实例

```java
// 扩展
new DefaultPluginManager() {
    @Override
    protected ExtensionFactory createExtensionFactory() {
        return MyExtensionFactory();
    }
}
```

```java
plugin.getExtensions(MyExtensionPoint.class); //每次调用，每次创建
//如果需要每次调用返回单例
new DefaultPluginManager() {
    @Override
    protected ExtensionFactory createExtensionFactory() {
        return SingletonExtensionFactory();
    }
};
```

extension 可以不需要 `pluginManager.loadPlugins()`和`pluginManager.startPlugins()`

## 服务加载

支持`META-INF/services`(Java Service Provider mechanism) ， `ServiceProviderExtensionStorage`

支持`ExtensionAnnotationProcessor`中的`ExtensionStorage`来加载（默认`META-INF/extensions.idx`) ，示例如下：

```properties
org.pf4j.demo.HowdyGreeting
org.pf4j.demo.WhazzupGreeting
```

自定义`ExtensionAnnotationProcessor`中`ExtensionStorage`

- set annotation processor option  with key `pf4j.storageClassName`
- set system property with key `pf4j.storageClassName`

手动 开启加载 `META-INF/serices`的`ServiceLoaderExtensionFinder`

```java
final PluginManager pluginManager = new DefaultPluginManager() {
    protected ExtensionFinder createExtensionFinder() {
        DefaultExtensionFinder extensionFinder = (DefaultExtensionFinder) super.createExtensionFinder();
        extensionFinder.addServiceProviderExtensionFinder();
        return extensionFinder;
    }
};
```

# troubleshooting

## No Extensions Found

- see `extensions.idx`
- class loader issue ( same extension point in two different class loader)
-  put on `TRACE` level the logger for `PluginClassLoader` and `AbstractExtensionFinder` 

```properties
#
# Appenders
#
appender.console.type = Console
appender.console.name = console
appender.console.layout.type = PatternLayout
#appender.console.layout.pattern = %-5p - %-32.32c{1} - %m\n
appender.console.layout.pattern = %d %p %c - %m%n

#
# Loggers
#

# PF4J log
logger.pf4j.name = org.pf4j
logger.pf4j.level = debug
logger.pf4j.additivity = false
logger.pf4j.appenderRef.console.ref = console

# !!! Uncomment below loggers when you are in trouble
#logger.loader.name = org.pf4j.PluginClassLoader
#logger.loader.level = trace
#logger.finder.name = org.pf4j.AbstractExtensionFinder
#logger.finder.level = trace

rootLogger.level = debug
rootLogger.appenderRef.console.ref = console
```

# 开发

## maven

依赖

```xml
<dependency>
    <groupId>org.pf4j</groupId>
    <artifactId>pf4j</artifactId>
    <version>${pf4j.version}</version>
</dependency>
```

命令行

```bash
mvn archetype:generate \
  -DarchetypeGroupId=org.pf4j \
  -DarchetypeArtifactId=pf4j-quickstart \
  -DarchetypeVersion=3.1.0 \
  -DgroupId=com.mycompany \
  -DartifactId=myproject
```

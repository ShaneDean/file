# 前言
根据《[java web高级编程](https://item.jd.com/11723338.html)》一书，重新整理下java web相关的知识点。

## servlet


参考了下知乎上的[问题](https://www.zhihu.com/question/21416727)

借用这个[答案](https://www.zhihu.com/question/21416727/answer/233319801)来介绍Servlet（Server Applet），全称Java Servlet，未有中文译文。是用Java编写的服务器端程序。其主要功能在于交互式地浏览和修改数据，生成动态Web内容。狭义的Servlet是指Java语言实现的一个接口，广义的Servlet是指任何实现了这个Servlet接口的类，一般情况下，人们将Servlet理解为后者。

所有web应用程序的核心类，用来接收和响应终端用户的请求。除了被过滤器提前终止的请求，其他请求都会交到servlet手里。绝大多数的Servlet继承自javax.servlet.GenericServlet，它的子类HttpServlet也是我们常用的一个类。

从狭义的看，servlet就是一个接口
```java
public interface Servlet {
    void init(ServletConfig var1) throws ServletException;
    ServletConfig getServletConfig();
    void service(ServletRequest var1, ServletResponse var2) throws ServletException, IOException;
    String getServletInfo();
    void destroy();
}
```
接口代码结合下张图看
![servlet_calling_process](https://github.com/ShaneDean/file/blob/master/blog/java_web/servlet_calling_process.jpg?raw=true)

图中的4、5、8都是对应接口中的init、service、destory方法

广义上任何实现了这个接口的类都需要回答上面的3个方法的含义
- init:你初始化时要做什么
- destory:你销毁时要做什么
- service:你接受到请求时要做什么

只有servlet还不够完成响应http请求的流程，图中的1、2、3、6、7都还需要容器支持，比如tomcat。

tomcat它负责监听端口，当端口由请求过来后会根据url去决定将这个请求交给哪个servlet，在servlet处理完后它负责把response结果返回给客户端。


参考的资料还包括：[答案](https://www.zhihu.com/question/21416727/answer/339012081)，[An Introduction to Tomcat Servlet Interactions](https://www.mulesoft.com/tcat/tomcat-servlet),[How Spring Web MVC Really Works](https://stackify.com/spring-mvc/) 


参考[答案](https://www.zhihu.com/question/35225845/answer/61876681)从设计模式角度补充filter\interceptor\listener
- 过滤器（Filter）：当你有一堆东西的时候，你只希望选择符合你要求的某一些东西。定义这些要求的工具，就是过滤器。
- 拦截器（Interceptor）：在一个流程正在进行的时候，你希望干预它的进展，甚至终止它进行，这是拦截器做的事情。
- 监听器（Listener）：当一个事件发生的时候，你希望获得这个事件发生的详细信息，而并不想干预这个事件本身的进程，这就要用到监听器。

## ServletContext

[參考](https://www.zhihu.com/question/38481443/answer/76596017)

用來被Servlet程序和web容器通信的对象，每个web应用程序有一个context，被web应用内的程序共享。
作用包括：web应用范围内的数据共享，访问web应用静态数据，Servlet对象之间的通信


## 过滤器 filter

可以用作日志过滤器（记录应用程序日志)，验证过滤器（检查请求信息)，压缩和加密过滤器，错误处理过滤器。

filter可以通过url模式映射到servlet之前处理请求，一个请求只能由一个servlet但是可以有多个filter。filter不仅可以拦截Servlet请求，还可以拦截其他资源（js\css\img)。
filter还可以直接映射到某个servlet上，所有由这个servlet处理的请求都会交由filter提前处理。filter可以映射多个目标，也可以多个filter映射同一个目标

filter支持的dispatcher请求派发类型如下：
-   普通请求 REQUEST    这些请求来自客户端，包含了容器中特定的Web应用程序的url
-   转发请求 FORWARD    代码调用RequestDispatcher的forward方法时候出发这些请求。尽管它们被关联到原始请求，但是在内部它们会被作为单独的请求进行处理
-   包含请求 INCLUDE    代码调用RequestDispatcher的include方法，将会产生一个不同的、与原始请求相关的内部包含请求
-   错误资源请求 ERROR    这些实在访问处理HTTP错误的错误页面的请求
-   异步请求 ASYNC    在处理其他请求的过程中，由AsyncContext派发的请求

filter会在APP启动的时候init，可以调用ServletContext的方法注册和映射，由于这需要在ServletContext结束启动之前完成，所以需要在ServletContextListener的contextInitialized方法中实现（或onStartup中)

filter的顺序定义：匹配请求的过滤器将按照它们出现在部署描述符或编程配置中的顺序添加到过滤器链中，一般url方式>servlet方式


## 会话

是服务器或web应用程序管理的某些文件、内存片段、对象或者容器，它包含了分配给它的各种不同数据。通常会话会分配一个随机生成的字符串，称之为会话ID。

session-config用来配置http会话
-   session-timeout 会话最大保持的不活跃时间 分钟为单位，忽略话为容器默认的时间，如tomcat为30分钟
-   tracking-mode   用于表容器应该使用哪种技术追踪会话ID   
    -   URL     表示在url中嵌入sessionid
    -   COOKIE  表示在cookie中放入sessionid
    -   SSL     表示用ssl 会话id 作为 http的 会话id、
-   cookie-config  只有在tracking-mode中配置了cookie时  下面值才生效
    -   secure      true 表示浏览器只能通过ssl来传输cookie
    -   http-only   true 表示完全禁止js,flash或其他浏览器脚本或插件来获取cookeie内容
    -   name        自定义会话名称，默认JSESSIONID
    -   domain和path    web容器会自动设置对应的值
    -   max-age     表示cookie何时过期，不设置则关闭浏览器后过期，设置的值的单位是秒

request.getSession(boolean)
- true  如果会话存在返回会话，如果会话不存在创建一个新的会话
- false 如果会话存在返回会话，如果会话不存在则返回null

可以使用HttpSessionListener来监听session的操作事件，维护一个在线session的列表。

如果在集群中使用会话，需要使用粘滞会话，就是使负载均衡机制能够感知到会话，并且总是将来自同一会话的请求发送到相同的服务器。例如负载均衡器可以感知到cookie。例如使用Apache httpd时，配置jvmroute，该值会被加到所有的会话id末端，此时
连接器就能够识别出来这个会话属于哪个服务器。如果会话要在集群中复制，那么需要在部署描述符中添加 distributable标签。所有增加到会话中的对象可以实现HttpSessionActivationListener接口，当会话被序列化发送到其他服务器时，sessionWillPassivate会被调用，当在另一个容器中反序列化，sessionDidActive会被调用。


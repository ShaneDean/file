# 前言
参考[官网](https://router.vuejs.org/zh/guide/) , [api](https://router.vuejs.org/zh/api/) 做点笔记加强记忆

# 介绍
Vue Router 是 [Vue.js](http://cn.vuejs.org/) 官方的路由管理器。它和 Vue.js 的核心深度集成，让构建单页面应用变得易如反掌。包含的功能有：
-   嵌套的路由/视图表
-   模块化的、基于组件的路由配置
-   路由参数、查询、通配符
-   基于 Vue.js 过渡系统的视图过渡效果
-   细粒度的导航控制
-   带有自动激活的 CSS class 的链接
-   HTML5 历史模式或 hash 模式，在 IE9 中自动降级
-   自定义的滚动条行为

# 动态路由匹配
可以在 vue-router 的路由路径中使用“动态路径参数”(dynamic segment) ， 可以在一个路由中设置多段“路径参数”，对应的值都会设置到 $route.params 中


模式 | 匹配路径 | $route.params
---|--- | ---
/user/:username	|  /user/evan  |	{ username: 'evan' }
/user/:username/post/:post\_id | 	/user/evan/post/123	|  { username: 'evan', post\_id: '123' }

除了 $route.params 外，$route 对象还提供了其它有用的信息，例如，$route.query (如果 URL 中有查询参数)、$route.hash 等等。

注意： 当使用路由参数时，例如从 /user/foo 导航到 /user/bar，**原来的组件实例会被复用**。因为两个路由都渲染同个组件，比起销毁再创建，复用则显得更加高效。不过，这也意味着**组件的生命周期钩子不会再被调用**。复用组件时，想对路由参数的变化作出响应的话，可以简单地 watch (监测变化) $route 对象 , 使用 2.2 中引入的 beforeRouteUpdate.

使用\*匹配任意路径。当使用通配符路由时，请确保路由的顺序是正确的，也就是说含有通配符的路由应该放在最后。路由 { path: '*' } 通常用于客户端 404 错误。当使用一个通配符时，$route.params 内会自动添加一个名为 pathMatch 参数。它包含了 URL 通过通配符被匹配的部分。
```js
// 给出一个路由 { path: '/user-*' }
this.$router.push('/user-admin')
this.$route.params.pathMatch // 'admin'
// 给出一个路由 { path: '*' }
this.$router.push('/non-existing')
this.$route.params.pathMatch // '/non-existing'
```

vue-router 使用 [path-to-regexp](https://github.com/pillarjs/path-to-regexp) 作为路径匹配引擎，所以支持很多高级的匹配模式，例如：可选的动态路径参数、匹配零个或多个、一个或多个，甚至是自定义正则匹配。

有时候，同一个路径可以匹配多个路由，此时，匹配的优先级就按照路由的定义顺序：谁先定义的，谁的优先级就最高。

# 嵌套路由

要在嵌套的出口中渲染组件，需要在 VueRouter 的参数中使用 children 配置，children 配置就是像 routes 配置一样的路由配置数组。
要注意，以 / 开头的嵌套路径会被当作根路径。 这让你充分的使用嵌套组件而无须设置嵌套的路径。

# 编程式的导航

除了使用 <router-link>创建a标签来定义导航链接外，我们还可以用下面方式来实现。
```js
router.push(location , onComplete? , onAbort?)
```

注意：在 Vue 实例内部，你可以通过 $router 访问路由实例。因此你可以调用 this.$router.push。

想要导航到不同的 URL，则使用 router.push 方法。这个方法会向 history 栈添加一个新的记录，所以，当用户点击浏览器后退按钮时，则回到之前的 URL。

当你点击 <router-link> 时，这个方法会在内部调用，所以说，点击 <router-link :to="..."> 等同于调用 router.push(...)。

声明式 | 编程式
--- | ---
<router-link :to="...">  | 	router.push(...)

该方法的参数可以是一个字符串路径，或者一个描述地址的对象。

```js
// 字符串
router.push('home')

// 对象
router.push({ path: 'home' })

// 命名的路由
router.push({ name: 'user', params: { userId: '123' }})

// 带查询参数，变成 /register?plan=private
router.push({ path: 'register', query: { plan: 'private' }})
```

注意：如果提供了 path，params 会被忽略，上述例子中的 query 并不属于这种情况。取而代之的是下面例子的做法，你需要提供路由的 name 或手写完整的带有参数的 path
```js
const userId = '123'
router.push({ name: 'user', params: { userId }}) // -> /user/123
router.push({ path: `/user/${userId}` }) // -> /user/123
// 这里的 params 不生效
router.push({ path: '/user', params: { userId }}) // -> /user
```

可选的在 router.push 或 router.replace 中提供 onComplete 和 onAbort 回调作为第二个和第三个参数。这些回调将会在导航成功完成 (在所有的异步钩子被解析之后) 或终止 (导航到相同的路由、或在当前导航完成之前导航到另一个不同的路由) 的时候进行相应的调用。

注意： 如果目的地和当前路由相同，只有参数发生了改变 (比如从一个用户资料到另一个 /users/1 -> /users/2)，你需要使用 beforeRouteUpdate 来响应这个变化 (比如抓取用户信息)

router.replace 和 router.push一样，但是它不会向history添加新纪录。

router.go(n) 向history记录中前进或后退多少步，类似window.history.go(n)

Vue Router 的导航方法 (push、 replace、 go) 在各类路由模式 (history、 hash 和 abstract) 下表现一致。

# 命名路由
通过一个名称来标识一个路由显得更方便一些，特别是在链接一个路由，或者是执行一些跳转的时候。可以在创建 Router 实例的时候，在 routes 配置中给某个路由设置名称。
```js
const router = new VueRouter({
  routes: [
    {
      path: '/user/:userId',
      name: 'user',
      component: User
    }
  ]
})
//调用方式
<router-link :to="{ name: 'user', params: { userId: 123 }}">User</router-link>
router.push({ name: 'user', params: { userId: 123 }})
//这两种方式都会把路由导航到 /user/123 路径。
```
# 命名视图
同时（同级）显示多个视图， 而不是嵌套显示。 例如： sidebar和main两个视图同时显示的时候。

router-view的属性name如果没有设置那么默认为defualt

# 重定向和别名
```js
const router = new VueRouter({
  routes: [
    { path: '/a', redirect: '/b' } ,
    { path: '/b', redirect: { name : 'c' }},    //命名的路由
    { path: '/c', redirect: to => {
      // 方法接收 目标路由 作为参数
      // return 重定向的 字符串路径/路径对象
    }
     { path: '/d', component: D, alias: '/e' }  
     ///d 的别名是 /e，意味着，当用户访问 /e 时，URL 会保持为 /e，但是路由匹配则为 /d，就像用户访问 /d 一样。
  ]
})
```

# 路由组件传参

在组件中使用 $route 会使之与其对应路由形成高度耦合，从而使组件只能在某些特定的 URL 上使用，限制了其灵活性。可以使用 props 将组件和路由解耦

```js 

const User = {
  template: '<div>User {{ $route.params.id }}</div>'
}
const router = new VueRouter({
  routes: [
    { path: '/user/:id', component: User }
  ]
})
//通过 props 解耦
const User = {
  props: ['id'],
  template: '<div>User {{ id }}</div>'
}
const router = new VueRouter({
  routes: [
    { path: '/user/:id', component: User, props: true },  //如果 props 被设置为 true，route.params 将会被设置为组件属性。

    // 对于包含命名视图的路由，你必须分别为每个命名视图添加 `props` 选项：
    {
      path: '/user/:id',
      components: { default: User, sidebar: Sidebar },
      props: { default: true, sidebar: false }
    }
  ]
})
```
如果 props 是一个对象，它会被按原样设置为组件属性。当 props 是静态的时候有用。可以创建一个函数返回 props。这样你便可以将参数转换成另一种类型，将静态值与基于路由的值结合等等。

# 导航守卫
（导航表示路由正在发生变化）
参数或查询的改变并不会触发进入/离开的导航守卫 ， 可以使用 router.beforeEach 注册一个全局前置守卫

当一个导航触发时，全局前置守卫按照创建顺序调用。守卫是异步解析执行，此时导航在所有守卫 resolve 完之前一直处于 等待中。每个守卫接受3个参数
-   to: route    即将要进入的目标 路由对象
-   from: route     当前导航正要离开的路由
-   next: function      一定要调用该方法来 resolve 这个钩子。执行效果依赖 next 方法的调用参数。
    -   next(): 进行管道中的下一个钩子。如果全部钩子执行完了，则导航的状态就是 confirmed (确认的)
    -   next(false): 中断当前的导航。如果浏览器的 URL 改变了 (可能是用户手动或者浏览器后退按钮)，那么 URL 地址会重置到 from 路由对应的地址。
    -   next('/') 或者 next({ path: '/' }): 跳转到一个不同的地址。当前的导航被中断，然后进行一个新的导航。你可以向 next 传递任意位置对象，且允许设置诸如 replace: true、name: 'home' 之类的选项以及任何用在 router-link 的 to prop 或 router.push 中的选项。
    -   next(error): (2.4.0+) 如果传入 next 的参数是一个 Error 实例，则导航会被终止且该错误会被传递给 router.onError() 注册过的回调。

完整的导航解析流程
1.  导航被触发。
2.  在失活的组件里调用离开守卫。
3.  调用全局的 beforeEach 守卫。
4.  在重用的组件里调用 beforeRouteUpdate 守卫 (2.2+)。
5.  在路由配置里调用 beforeEnter。
6.  解析异步路由组件。
7.  在被激活的组件里调用 beforeRouteEnter。
8.  调用全局的 beforeResolve 守卫 (2.5+)。
9.  导航被确认。
10.  调用全局的 afterEach 钩子。
11.  触发 DOM 更新。
12.  用创建好的实例调用 beforeRouteEnter 守卫中传给 next 的回调函数。


# 路由元信息

定义路由的时候可以配置meta字段

首先，我们称呼 routes 配置中的每个路由对象为 路由记录。路由记录可以是嵌套的，因此，当一个路由匹配成功后，他可能匹配多个路由记录。一个路由匹配到的所有路由记录会暴露为 $route 对象 (还有在导航守卫中的路由对象) 的 $route.matched 数组。因此，我们需要遍历 $route.matched 来检查路由记录中的 meta 字段。

# 过度效果

<router-view> 是基本的动态组件，所以我们可以用 <transition> 组件给它添加一些过渡效果，[使用介绍](https://cn.vuejs.org/v2/guide/transitions.html)
```html
<transition>
  <router-view></router-view>
</transition>
```

#　数据获取
进入某个路由后，需要从服务器获取数据。例如，在渲染用户信息时，你需要从服务器获取用户的数据。我们可以通过两种方式来实现：

-   导航完成之后获取：先完成导航，然后在接下来的组件生命周期钩子中获取数据。在数据获取期间显示“加载中”之类的指示。
-   导航完成之前获取：导航完成前，在路由进入的守卫中获取数据，在数据获取成功后执行导航。

# 滚动行为

当创建一个 Router 实例，你可以提供一个 scrollBehavior 方法 ， scrollBehavior 方法接收 to 和 from 路由对象。第三个参数 savedPosition 当且仅当 popstate 导航 (通过浏览器的 前进/后退 按钮触发) 时才可用。

这个方法返回滚动位置的对象信息，长这样：

-   { x: number, y: number }
-   { selector: string, offset? : { x: number, y: number }} (offset 只在 2.6.0+ 支持)

```js
scrollBehavior (to, from, savedPosition) {
  return { x: 0, y: 0 } //页面滚动到顶部
}
scrollBehavior (to, from, savedPosition) {
  if (savedPosition) {
    return savedPosition        //返回 savedPosition，在按下 后退/前进 按钮时，就会像浏览器的原生表现那样
  } else {
    return { x: 0, y: 0 }
  }
}
scrollBehavior (to, from, savedPosition) {
  if (to.hash) {
    return {    
      selector: to.hash         //“滚动到锚点”
    }
  }
}

```

# 路由懒加载

当打包构建应用时，JavaScript 包会变得非常大，影响页面加载。如果我们能把不同路由对应的组件分割成不同的代码块，然后当路由被访问的时候才加载对应组件，这样就更加高效了。

结合 Vue 的异步组件和 Webpack 的代码分割功能，轻松实现路由组件的懒加载。

-   可以将异步组件定义为返回一个 Promise 的工厂函数
```js
const Foo = () => Promise.resolve({ /* 组件定义对象 */ })
```
-   在 Webpack 2 中，我们可以使用动态 import语法来定义代码分块点 (split point)
```js
import('./Foo.vue') // 返回 Promise
```
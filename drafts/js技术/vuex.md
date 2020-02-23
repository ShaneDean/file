# 前言

根据[官网材料](https://vuex.vuejs.org/zh/guide/)补充下这方面的知识内容

# start

每一个 Vuex 应用的核心就是 store（仓库）。“store”基本上就是一个容器，它包含着你的应用中大部分的状态 (state)。Vuex 和单纯的全局对象有以下两点不同：

1.  Vuex 的状态存储是响应式的。当 Vue 组件从 store 中读取状态的时候，若 store 中的状态发生变化，那么相应的组件也会相应地得到高效更新。
2.  你不能直接改变 store 中的状态。改变 store 中的状态的唯一途径就是显式地提交 (commit) mutation。这样使得我们可以方便地跟踪每一个状态的变化，从而让我们能够实现一些工具帮助我们更好地了解我们的应用。



# state
Vuex 使用单一状态树——是的，用一个对象就包含了全部的应用层级状态。每个应用将仅仅包含一个 store 实例。单一状态树让我们能够直接地定位任一特定的状态片段，在调试的过程中也能轻易地取得整个当前应用状态的快照。

由于store中的状态是响应式的，在组件中调用store中的状态简单到仅需要在计算属性中返回即可，触发变化也仅仅是在组件的methods中提交mutation。

Vuex 通过 store 选项，提供了一种机制将状态从根组件“注入”到每一个子组件中（需调用 Vue.use(Vuex)）。 完成注入后子组件可以通过this.$store来访问
```js
const Counter = {
  template: `<div>{{ count }}</div>`,
  computed: {
    count () {
      return this.$store.state.count
    }
  }
}
```
当一个组件需要获取多个状态时候,一个个声明的计算属性太过繁琐，使用mapState辅助函数来帮助生成计算属性
```js
// 在单独构建的版本中辅助函数为 Vuex.mapState
import { mapState } from 'vuex'

export default {
  // ...
  computed: mapState({
    // 箭头函数可使代码更简练
    count: state => state.count,

    // 传字符串参数 'count' 等同于 `state => state.count`
    countAlias: 'count',

    // 为了能够使用 `this` 获取局部状态，必须使用常规函数
    countPlusLocalState (state) {
      return state.count + this.localCount
    } 
  })
}
```
当映射的计算属性的名称与 state 的子节点名称相同时，我们也可以给 mapState 传一个字符串数组。

通过**对象展开运算符**展开mapState对象达到与局部计算属性混合使用的目标
```js
computed: {
  localComputed () { /* ... */ },
  // 使用对象展开运算符将此对象混入到外部对象中
  ...mapState({
    // ...
  })
}
```
# getter
Vuex允许在store中定义"getter"，用来加工/计算store中state的数据来返回结果，getter的返回值会根据它们的依赖来缓存起来，只有依赖值变化的时候才会重新加工/计算。Getter 会暴露为 store.getters对象，可以通过属性来访问值。getter支持其他的getter作为第二个参数。getter可以返回一个函数来接受传入的参数实现查询调用，如下所示：
```js
getters: {
  // ...
  getTodoById: (state) => (id) => {
    return state.todos.find(todo => todo.id === id)
  }
}
//call
store.getters.getTodoById(2) // -> { id: 2, text: '...', done: false }
```
注意，getter 在通过方法访问时，每次都会去进行调用，而不会缓存结果。

mapGetters 辅助函数可以将 store 中的 getter 映射到局部计算属性
```js
import { mapGetters } from 'vuex'

export default {
  // ...
  computed: {
  // 使用对象展开运算符将 getter 混入 computed 对象中
    ...mapGetters([  //也支持对象传入方式
      'doneTodosCount',
      'anotherGetter',
      // ...
    ])
  }
}
```

# Mutation
更改 Vuex 的 store 中的状态的唯一方法是提交 mutation。vuex 通过mutation的方式而非直接修改属性值是因为我们需要明确的追踪状态的变化。

Vuex 中的 mutation 非常类似于事件：每个 mutation 都有一个字符串的 事件类型 (type) 和 一个 回调函数 (handler)。

```js
const store = new Vuex.Store({
  state: {
    count: 1
  },
  mutations: {
   //事件类型 'increment'  
    increment (state , ...playload) {    //传入state和 参数
      // 变更状态
      state.count++                 //回调函数的主体内容
      console.log(...playload)         //输出载荷
    }
  }
})
//唤醒type是'increment'的事件 从而执行 handler
store.commit('increment' , 'playload')      //传入的参数是mutation的载荷
store.commit('increment' , {
    playload : 'object'                     //载荷一般应该是一个对象
})
store.commit({                              
    type :'increment',
    playload : 'object'
})
```

mutation的注意事项
-   最好提前在 store 中初始化好所有所需属性。
-   当需要在对象上添加新属性时，应该
    -   Vue.set(obj, 'newProp', 123)
    -   或以新对象替换老对象  state.obj = { ...state.obj, newProp: 123 }
-   Mutation事件可以使用const常量来代替名称，使用 ES2015 风格的计算属性命名功能来使用一个常量作为函数名
```js
...
    mutations: {
        [SOME_MUTATION] (state) {
            ...
        }
    }
...
```
-   Mutation 必须是同步函数


在组件中使用 this.$store.commit('xxx') 提交 mutation，或者使用 mapMutations 辅助函数将组件中的 methods 映射为 store.commit 调用（需要在根节点注入 store）。
```js
import { mapMutations } from 'vuex'

export default {
  // ...
  methods: {
    ...mapMutations([
      'increment', // 将 `this.increment()` 映射为 `this.$store.commit('increment')`

      // `mapMutations` 也支持载荷：
      'incrementBy' // 将 `this.incrementBy(amount)` 映射为 `this.$store.commit('incrementBy', amount)`
    ]),
    ...mapMutations({
      add: 'increment' // 将 `this.add()` 映射为 `this.$store.commit('increment')`
    })
  }
}
```

# Action
类似于mutation, 但不同在于：
-   Action 提交的是 mutation，而不是直接变更状态。
-   Action 可以包含任意异步操作。

Action 函数接受一个与 store 实例具有相同方法和属性的 context 对象，因此你可以调用 context.commit 提交一个 mutation，或者通过 context.state 和 context.getters 来获取 state 和 getters。
```js
const store = new Vuex.Store({
  state: {
    count: 0
  },
  mutations: {
    increment (state) {
      state.count++
    }
  },
  actions: {
    increment (context) {
      context.commit('increment')
    },
    destructuringIncrement ({ commit }){    //用 ES2015 的 参数解构 来简化代码
        commit('increment')
    },
    incrementAsync ({ commit }) {           //在action进行异步执行操作
        setTimeout(() => {
          commit('increment')
        }, 1000)
    }
    
  }
})
store.dispatch('increment')             //Action 通过 store.dispatch 方法触发
```
Actions 支持同样的载荷方式和对象方式进行分发

购物车示例，涉及到调用异步 API 和分发多重 mutation

```js
actions: {
  checkout ({ commit, state }, products) {
    // 把当前购物车的物品备份起来
    const savedCartItems = [...state.cart.added]
    // 发出结账请求，然后乐观地清空购物车
    commit(types.CHECKOUT_REQUEST)
    // 购物 API 接受一个成功回调和一个失败回调
    shop.buyProducts(
      products,
      // 成功操作
      () => commit(types.CHECKOUT_SUCCESS),
      // 失败操作
      () => commit(types.CHECKOUT_FAILURE, savedCartItems)
    )
  }
}
```

可以使用 mapActions 辅助函数将组件的 methods 映射为 store.dispatch 调用（需要先在根节点注入 store）：

```js
import { mapActions } from 'vuex'

export default {
  // ...
  methods: {
    ...mapActions([
      'increment', // 将 `this.increment()` 映射为 `this.$store.dispatch('increment')`

      // `mapActions` 也支持载荷：
      'incrementBy' // 将 `this.incrementBy(amount)` 映射为 `this.$store.dispatch('incrementBy', amount)`
    ]),
    ...mapActions({
      add: 'increment' // 将 `this.add()` 映射为 `this.$store.dispatch('increment')`
    })
  }
}
```

Action 通常是异步的 , 可以组合多个 action，以处理更加复杂的异步流程。

store.dispatch 可以处理被触发的 action 的处理函数返回的 Promise，并且 store.dispatch 仍旧返回 Promise
```js
// 假设 doAsycWork() 返回的是 Promise
actions: {
    async actionA ({ commit }) {
        commit('Muattion_A', await doAsycWork())
    },
    async actionB ({ dispatch, commit }) {
        await dispatch('actionA') // 等待 actionA 完成
        commit('Muattion_B', await doAsycWork())
    }
    async actionC ({commit , state} , playload ) {
        ...
    }
```
注意：一个 store.dispatch 在不同模块中可以触发多个 action 函数。在这种情况下，只有当所有触发函数完成后，返回的 Promise 才会执行。

# Module
由于使用单一状态树，应用的所有状态会集中到一个比较大的对象。当应用变得非常复杂时，store 对象就有可能变得相当臃肿。

为了解决以上问题，Vuex 允许我们将 store 分割成模块（module）。每个模块拥有自己的 state、mutation、action、getter、甚至是嵌套子模块——从上至下进行同样方式的分割：
```js
const moduleA = {
  state: { ... },
  mutations: { ... },
  actions: { ... },
  getters: { ... }
}

const moduleB = {
  state: { ... },
  mutations: { ... },
  actions: { ... }
}

const store = new Vuex.Store({
  modules: {
    a: moduleA,
    b: moduleB
  }
})

store.state.a // -> moduleA 的状态
store.state.b // -> moduleB 的状态
```

对于模块内部的 mutation 和 getter，接收的第一个参数是模块的局部状态对象。同样，对于模块内部的 action，局部状态通过 context.state 暴露出来，根节点状态则为 context.rootState。

对于模块内部的 getter，根节点状态会作为第三个参数暴露出来

默认情况下，模块内部的 action、mutation 和 getter 是注册在全局命名空间的——这样使得多个模块能够对同一 mutation 或 action 作出响应。

如果希望你的模块具有更高的封装度和复用性，你可以通过添加 namespaced: true 的方式使其成为带命名空间的模块。当模块被注册后，它的所有 getter、action 及 mutation 都会自动根据模块注册的路径调整命名。

启用了命名空间的 getter 和 action 会收到局部化的 getter，dispatch 和 commit。换言之，你在使用模块内容（module assets）时不需要在同一模块内额外添加空间名前缀。更改 namespaced 属性后不需要修改模块内的代码。

如果你希望使用全局 state 和 getter，rootState 和 rootGetter 会作为第三和第四参数传入 getter，也会通过 context 对象的属性传入 action。 若需要在全局命名空间内分发 action 或提交 mutation，将 { root: true } 作为第三参数传给 dispatch 或 commit 即可。

```js
modules: {
  foo: {
    namespaced: true,

    getters: {
      // 在这个模块的 getter 中，`getters` 被局部化了
      // 你可以使用 getter 的第四个参数来调用 `rootGetters`
      someGetter (state, getters, rootState, rootGetters) {
        getters.someOtherGetter // -> 'foo/someOtherGetter'
        rootGetters.someOtherGetter // -> 'someOtherGetter'
      },
      someOtherGetter: state => { ... }
    },

    actions: {
      // 在这个模块中， dispatch 和 commit 也被局部化了
      // 他们可以接受 `root` 属性以访问根 dispatch 或 commit
      someAction ({ dispatch, commit, getters, rootGetters }) {
        getters.someGetter // -> 'foo/someGetter'
        rootGetters.someGetter // -> 'someGetter'

        dispatch('someOtherAction') // -> 'foo/someOtherAction'
        dispatch('someOtherAction', null, { root: true }) // -> 'someOtherAction'

        commit('someMutation') // -> 'foo/someMutation'
        commit('someMutation', null, { root: true }) // -> 'someMutation'
      },
      someOtherAction (ctx, payload) { ... }
    }
  }
}
```
若需要在带命名空间的模块注册全局 action，你可添加 root: true，并将这个 action 的定义放在函数 handler 中。
```js
{
  actions: {
    someOtherAction ({dispatch}) {
      dispatch('someAction')
    }
  },
  modules: {
    foo: {
      namespaced: true,

      actions: {
        someAction: {
          root: true,
          handler (namespacedContext, payload) { ... } // -> 'someAction'
        }
      }
    }
  }
}
```

当使用 mapState, mapGetters, mapActions 和 mapMutations 这些函数来绑定带命名空间的模块时，可以将模块的空间名称字符串作为第一个参数传递给上述函数，这样所有绑定都会自动将该模块作为上下文。还通过使用 createNamespacedHelpers 创建基于某个命名空间辅助函数。它返回一个对象，对象里有新的绑定在给定命名空间值上的组件绑定辅助函数

在 store 创建之后，你可以使用 store.registerModule 方法注册模块。模块动态注册功能使得其他 Vue 插件可以通过在 store 中附加新模块的方式来使用 Vuex 管理状态。例如，[vuex-router-sync](https://github.com/vuejs/vuex-router-sync) 插件就是通过动态注册模块将 vue-router 和 vuex 结合在一起，实现应用的路由状态管理。

也可以使用 store.unregisterModule(moduleName) 来动态卸载模块。注意，你不能使用此方法卸载静态模块（即创建 store 时声明的模块）。

在注册一个新 module 时，你很有可能想保留过去的 state，例如从一个服务端渲染的应用保留 state。你可以通过 preserveState 选项将其归档：store.registerModule('a', module, { preserveState: true })。当你设置 preserveState: true 时，该模块会被注册，action、mutation 和 getter 会被添加到 store 中，但是 state 不会。这里假设 store 的 state 已经包含了这个 module 的 state 并且你不希望将其覆写。

使用一个函数来声明模块状态（仅 2.3.0+ 支持）来避免纯对象通过引用被共享时候导致的数据相互污染的问题， 类似Vue组件中的data.

# 项目结构

下面是vuex定义的一些需要遵守的规则：
-   应用层级的状态应该集中到单个 store 对象中
-   提交 mutation 是更改状态的唯一方法，并且这个过程是同步的
-   异步逻辑都应该封装到 action 里面

# 插件

Vuex 的 store 接受 plugins 选项，这个选项暴露出每次 mutation 的钩子。
```js
const myPlugin = store => {
  // 当 store 初始化后调用
  store.subscribe((mutation, state) => {
    // 每次 mutation 之后调用
    // mutation 的格式为 { type, payload }
  })
}
```

在插件中不允许直接修改状态——类似于组件，只能通过提交 mutation 来触发变化。通过提交 mutation，插件可以用来同步数据源到 store。

有时候插件需要获得状态的“快照”，比较改变的前后状态。想要实现这项功能，你需要对状态对象进行深拷贝。_.cloneDeep , 生成状态快照的插件应该只在开发阶段使用.

# 严格模式

开启严格模式，仅需在创建 store 的时候传入 strict: true, 在严格模式下，无论何时发生了状态变更且不是由 mutation 函数引起的，将会抛出错误。这能保证所有的状态变更都能被调试工具跟踪到。

不要在发布环境下启用严格模式！ 严格模式会深度监测状态树来检测不合规的状态变更——请确保在发布环境下关闭严格模式，以避免性能损失。
```js
//让构建工具来处理这种情况
const store = new Vuex.Store({
  // ...
  strict: process.env.NODE_ENV !== 'production'
})
```

# 表单处理

在严格模式下的vuex，直接对 state上使用v-model不支持， 解决方法是
```js
<input v-model='obj.message'>  // 在用户输入时，v-model 会试图直接修改 obj.message。在严格模式中，由于这个修改不是在 mutation 函数中执行的, 这里会抛出一个错误。

//给 <input> 中绑定 value，然后侦听 input 或者 change 事件，在事件回调中调用 action
<input :value="message" @input="updateMessage">
// ...
computed: {
  ...mapState({
    message: state => state.obj.message
  })
},
methods: {
  updateMessage (e) {
    this.$store.commit('updateMessage', e.target.value)
  }
}
// ...
mutations: {
  updateMessage (state, message) {
    state.obj.message = message
  }
}

//另一个方法是使用带有 setter 的双向绑定计算属性
<input v-model="message">
// ...
computed: {
  message: {
    get () {
      return this.$store.state.obj.message
    },
    set (value) {
      this.$store.commit('updateMessage', value)
    }
  }
}
```
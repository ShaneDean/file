## [Vue Genesis](https://fmfe.github.io/genesis-docs/)

`Genesis` 是一个轻量级的 Vue SSR 库

### 安装

为了减少生产依赖的大小，`Genesis` 特意拆分成两个包，`@fmfe/genesis-core` 负责核心的 SSR 渲染逻辑，`@fmfe/genesis-compiler` 负责在开发阶段和编译阶段使用，在生产环境中不需要它

```bash
npm install @fmfe/genesis-core
npm install @fmfe/genesis-compiler -D
```

#### TS 运行时

文档内所有的例子都基于 `ts` 进行编写，关于如何在 `Node` 运行 `ts` ，请了解 [ts-node](https://github.com/TypeStrong/ts-node)。如果你不想使用 `ts`，可以跳过这个步骤，只需要将文档的例子，修改成 `js` 语法即可

```bash
npm install ts-node typescript -g
```

#### HTTP 服务

因为 `Genesis` 只是一个 SSR 库，它不具备创建 HTTP 服务的能力，所以这里我们还需要安装 `Express` 。如果你选择了其它的框架，可以跳过这一步，并且将例子中的代码，转换成对应框架的代码即可

```bash
npm install express
```

- *可直接使用 [vue-genesis-template](https://github.com/fmfe/vue-genesis-template) 一个简单的，快速开发的例子*

### vue-genesis-template

#### 编写插件

在 `src` 中编写插件代码

![img](./img/vue-genesis-template1.png)

插件仪表盘界面

![img](./img/vue-genesis-template10.png)

与后台接口交互

![img](./img/vue-genesis-template11.png)

```vue
<template>
  <div class="drawer-container">
      <h3 class="drawer-title">插件界面</h3>

      <div class="drawer-item">
          <span>总内存</span>
          <span class="drawer-switch">{{totalMemory}} MB</span>
      </div>

      <div class="chart-wrapper">
          <pie-chart :freeMemory="freeMemory" :usedMemory="usedMemory" />
      </div>
      <div class="chart-wrapper">
          <bar-chart />
      </div>
  </div>
</template>

<script>
import axios from 'axios'
import Cookies from 'js-cookie'
import PieChart from './components/PieChart'
import BarChart from './components/BarChart'

export default {
    name: 'PluginDashboard',
    components: {
        PieChart,
        BarChart,
    },
    data() {
        return {
            freeMemory: '0',
            usedMemory: '0',
            totalMemory: '0',
        }
    },
    mounted() {
        this.getMemoryData();
        const _this = this;
        setInterval(function(){ _this.getMemoryData(); }, 5000)
    },
    methods: {
        getMemoryData() {
            const _this = this;
            axios({
                headers:{
                    'Authorization': 'Bearer ' + Cookies.get('Admin-Token')
                },
                method: 'get',
                url: 'http://192.168.131.140:8080/api/plugins/plugin1/getMemory',
            }).then(res => {
                console.log(res);
                _this.freeMemory = parseInt(res.data.freeMemory);
                _this.usedMemory = parseInt(res.data.usedMemory);
                _this.totalMemory = parseInt(res.data.totalMemory);
            })
                .catch((e) => {
                    console.log('plugins: 内存数据获取失败');
                });
        }
    }
}
</script>
```

执行 `npm run dev` ，打开浏览器进入 [localhost:3000](http://localhost:3000/) 查看效果

![img](./img/vue-genesis-template2.png)

#### 编译

修改 `genesis.build.ts` 文件编译代码

```ts
import path from 'path';
import fs from 'fs';
import { Build } from '@fmfe/genesis-compiler';
import { ssr } from './genesis';

const start = async () => {
    /**
     * 创建一个编译实例
     */
    const build = new Build(ssr);
    /**
     * 开始执行编译程序，构建生产环境应用包
     */
    await build.start();
    /**
     * 编译完成后，创建一个渲染器，输出远程组件所需的内容
     */
    const renderer = ssr.createRenderer();
    /**
     * CSR 渲染输出 JSON
     */
    const result = await renderer.render({ mode: 'csr-json' });
    /**
     * 将 JSON 保存到客户端目录
     */
    fs.writeFileSync(
        path.resolve(ssr.outputDirInClient, 'app.json'),
        JSON.stringify(result.data, null, 4),
        'utf8'
    );
};
start();
```

重复文件名会报重名错误，修改 `genesis.ts` 中创建 SSR 实例的参数

```ts
/**
 * 创建一个 SSR 实例
 */
export const ssr = new SSR({
    name: 'my-plugin'
});
```

原 `package.json` 的 `build` 代码中含有 `rm -rf` ，需要 Linux 环境。此处为 Windows 环境，修改并增加 `cross-env` 

![img](./img/vue-genesis-template3.png)

执行 `npm run build` ，`dist` 文件夹下生成编译后的插件的静态文件

![img](./img/vue-genesis-template4.png)

只需要将 `client` 目录的静态文件部署到服务器即可

### 老项目远程组件加载

假设静态资源的基本路径是 `/my-plugin/`，那么就可以通过 `/my-plugin/app.json` 访问到这个文件

![img](./img/vue-genesis-template5.png)

在老项目上安装远程组件

```bash
npm install @fmfe/genesis-remote axios
```

在对应的路由上，使用远程组件，加载此组件即可

```vue
<template>
    <div class="app">
        <RemoteView :fetch="fetch" />
    </div>
</template>
<script lang="ts">
import Vue from 'vue';
import axios from 'axios';
import { RemoteView } from '@fmfe/genesis-remote';

export default Vue.extend({
    components: {
        RemoteView
    },
    methods: {
        async fetch() {
            const res = await axios.get('/ssr-genesis/app.json');
            if (res.status === 200) {
                return res.data;
            }
            return null;
        }
    }
});
</script>
```

- *若有多个插件或需求控制插件的开启关闭，则需增加插件管理机制*

#### 增加插件管理

给远程组件增加插件的路径属性

![img](./img/vue-genesis-template6.png)

```vue
<template>
  <div class="plugin-container">
    <RemoteView :fetch="fetch" />
  </div>
</template>

<script>
import axios from 'axios';
import { RemoteView } from '@fmfe/genesis-remote';

export default {
  name: "PluginContainer",
  components: {
    RemoteView
  },
  props: ['pluginSrc'],
  methods: {
    async fetch() {
      const plugin_addr = this.pluginSrc;
      const res = await axios.get(plugin_addr);
      if (res.status === 200) {
        return res.data;
      }
      return null;
    }
  }
}
</script>
```

在主页中动态加载远程组件

![img](./img/vue-genesis-template7.png)

![img](./img/vue-genesis-template8.png)

```vue
<!-- ... -->
		<div v-for="plugin in plugins">
  			<PluginContainer :pluginSrc="plugin.src" />
		</div>
<!-- ... -->

<script>
import axios from 'axios';
import Cookies from 'js-cookie'
import PluginContainer from './components/PluginContainer'

export default {
  name: 'Layout',
  components: {
    PluginContainer
  },
  data() {
    return {
      plugins: []
    }
  },
  async mounted() {
    this.getPluginList();
  },
  methods: {
    getPluginList() {
      const _this = this;
      axios({
        headers:{
          'Authorization': 'Bearer ' + Cookies.get('Admin-Token')
        },
        method: 'get',
        url: 'http://192.168.131.140:8080/plugins/fronts',
      })
        .then(res => {
          console.log(res);
          if (res.status === 200) {
            _this.plugins = res.data.filter(item => item.enable == true)
          }
        })
        .catch((e) => {
          console.log('plugins: 插件列表获取失败');
        });
    }
  }
}
</script>
```

此处访问后台接口 `/plugins/fronts` 获取插件列表，根据插件列表动态加载远程组件

```json
{
  "data": [
    {
      "enable": true,
      "name": "myPlugin",
      "src": "/my-plugin/app.json"
    }
  ]
}
```

#### 效果预览

![img](./img/vue-genesis-template9.png)
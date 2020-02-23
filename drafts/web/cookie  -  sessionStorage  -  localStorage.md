# 前言

记录下3中web存储数据方式的不同。

[参考1](https://jerryzou.com/posts/cookie-and-web-storage/),[参考2](http://caibaojian.com/localstorage-sessionstorage.html)

# 简介

特性 | cookie | localStorage | sessionStorage
---|---|---|---
数据的生周期 | 一般由服务器生成，可设置失效时间。如果在浏览器端生成Cookie，默认是关闭浏览器后失效 | 除非被清除，否则永久保存 |  仅在当前会话下有效，关闭页面或浏览器后被清除
存放的数据大小 | 4K左右 | 5M左右 | 5M左右
服务器相关 | 每次都会携带在HTTP头中，发送给服务器 | 仅在客户端中保存，不发送 | 仅在客户端中保存，不发送

这里的sessionStorage的会话可以 理解为browser的tab标签使用访问的生命周期内，不发生关闭tab标签、切换域名、新开tab标签等情况，sessionStorage里面的数据就有效。

# webstorage

## 接口
localStorage 和 sessionStorage 有着统一的API接口，这为二者的操作提供了极大的便利，下面以webStorage分别代指两个存储
- 添加键值对：webStorage.setItem(key, value)
- 获取键值：webStorage.getItem(key)
- 删除键值对：webStorage.removeItem(key)
- 清除所有键值对：webStorage.clear()
- 获取 Storage 的属性名称(键名称)：webStorage.key(index)
- 获取 Storage 中保存的键值对的数量：webStorage.length


## 事件

storage [事件](https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent)当存储的数据发生变化时，会触发 storage 事件。但要注意的是它不同于click类的事件会事件捕获和冒泡，storage 事件更像是一个通知，不可取消。触发这个事件会调用同域下其他窗口的storage事件，不过触发storage的窗口（即当前窗口）不触发这个事件。

 ```js
function storageChanged() {
    console.log(arguments);
}

window.addEventListener('storage', storageChanged, false);
```
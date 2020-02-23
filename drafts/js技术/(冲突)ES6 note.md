# 前言

整理学习es6的语法,简单记录点内容加强记忆  [参考](http://es6.ruanyifeng.com) 
# 语法

## let  和  const
  
let 提供了块级作用域 (原来是 全局和函数级), { } , 也消除了立即执行函数(function(){ ... }());

let 提供了 暂时性死区(temporal dead zone) ,   只要进入当前作用域，所要使用的变量就已经存在，但是不可获取，只有等到声明变量的那一行代码出现，才可以获取和使用该变量。

声明式函数放在块作用域中的行为在es6中不和规范 , 我们可以转换成 函数表达式的方式使用{ let f = function(){ .. } }的方式.

const定义常量  类似 final , 作用域和let相似 , 但是 如果 const 指向的是一个 对象引用/对象指针 , const只能保证 不会指向其他的 对象引用/对象指针  , 而 该引用/指针 指向的对象内部属性 不受const影响, 

声明方式:
- var 
- function 
- let
- const
- import
- class

顶层对象 提供全局作用域 , 不同的实现的顶层对象也不一样
- 浏览器 : window (self 也是)
- Web Worker : self
- node : global

## 解构赋值
允许下面的赋值方式,类似python
    
    let [a,b,c] = [1,2,3]  // a = 1 , b = 2 , c = 3
    let [ , ,c] = [1,2,3]  // c = 3
    let [head , ...tail] = [1,2,3,4] // head = 1 , tail = [ 2,3,4 ]

本质上,这种写法属于'模式匹配' , 只要等号两边的模式相同,左边的变量就会被赋予对应的值.

如果解构不成功，变量的值就等于undefined。

    let [x, y, ...z] = ['a'] // x = a , y = undefined , z = []
    
解构方式的等号左边必须是可遍历结构(具有Iterator接口) , 不然则报错

解构赋值允许指定默认值 (注意 : ES6内部使用严格相等运算符（===），判断一个位置是否有值。所以，只有当一个数组成员严格等于undefined，默认值才会生效。)

    let [x, y = 'b'] = ['a', undefined]; // x='a', y='b'

如果默认值是一个表达式，只有在激活默认值得时候,才会执行。

    function val(){ console.log("val"); return "val";}
    let [x = val()] = [];           // val
    let [b = val()] = ["aaa"];      // aaa

在解构对象时候, 没有顺序因素,变量必须和对象属性同名才能取到正确的值. 这里的值 还可以是函数表达式. 如果变量名与属性名不一致 , 则需要使用下面的方式

    let { foo: baz } = { foo: 'aaa', bar: 'bbb' }; // baz  = "aaa"  , 这里的foo是解构目标对象的key
    let { foo: foo, bar: bar } = { foo: 'aaa', bar: 'bbb' };  // let {foo,bar} = ...  的简写

对象的解构赋值可以取到继承的属性

    const sub = {} , base = { foo:"bar"}
    Object.setPrototypeOf(sub,base)
    const {foo} = sub       // foo = "bar"

注意: 
    
    let arr = [1, 2, 3];
    let {0 : first, [arr.length - 1] : last} = arr; // first  = 1,last = 3
    // [ ... ] -> 属性名表达式  => 可以动态的决定解构的映射关系

支持对字符串的解构赋值,在面对 数字和布尔值的时候 , 会把其转换成 Number和Boolean对象,然后进行解构赋值操作.

函数的参数在传入的时候也会被解构赋值 , 并且 undefined 会触发函数参数的默认值。

    [1, undefined, 3].map((x = 'yes') => x);  // [ 1, 'yes', 3 ]
    
解构赋值中 的圆括号问题  [例子](http://es6.ruanyifeng.com/#docs/destructuring#不能使用圆括号的情况)

1. 不可以使用圆括号的情况
    - 变量声明语句
    - 函数参数
    - 赋值语句的模式部分
2. 可以使用圆括号的情况
    - 赋值语句的非模式部分

作用
- 交换变量
- 函数返回多个值
- 函数参数定义可以通过 K:V 对应的传入
- 直接抓取对象中的数据\属性,如json数据
- 函数支持默认值
- k,v方式 遍历 map
- 模块加载粒度精确到方法级


## 字符串的扩展

加强了Unicode , 可以使用 "\uxxxx"的表达方式 ,  xxxx  <= 0xFFFF , 超出的范围字符需要双字符 , 当使用 \u{xxxx}的表达方式时候, xxxx没了上面的限制 , es6会自动做处理

字符串支持 for ... of的循环遍历方式 , 这种方式 可以自动识别大于 0xFFFF的码点

JSON的 U+2028（行分隔符）和 U+2029（段分隔符）[问题](https://github.com/tc39/proposal-json-superset)

JSON.stringify() 在碰到 0xD800到0xDFFF 的码点,或者不存在的配对形式[问题](https://github.com/tc39/proposal-well-formed-stringify)，它会返回转义字符串，留给应用自己决定下一步的处理。

ES6 支持 ``(反引号) 形式的模板字符串 . 所有模板字符串的空格和换行，都是被保留的,可以通过trim消除, 嵌入的变量通过${变量名}的方式使用 , ${xxx}除了变量名外 还可以放js的任意表达式.

标签模板 : 模板字符串紧跟着一个函数名后面,改函数被调用来处理这个模板字符串.  这是函数调用的一种特殊形式 , 紧跟在函数名称后面的模板字符串就是调用该函数的参数.

标签模板可以用来过滤HTML内容,防止用户恶意 输入,还可以执行国际化转换.

ES2018 [放松](https://tc39.github.io/proposal-template-literal-revision/)了对标签模板里面的字符串转义的限制。如果遇到不合法的字符串转义，就返回undefined，而不是报错，并且从raw属性上面可以得到原始字符串。

## String新增方法


- String.fromCodePoint()  用于从 Unicode 码点返回对应字符,支持大于0xFFFF的字符,支持多个参数
- String.raw() 返回一个转义后的字符串, \ 的前面会加 \
- String.codePointAt()    返回的是码点的十进制值  
- String.normalize()    用来将字符的不同表示方法统一为同样的形式，这称为 Unicode 正规化, 支持多种模式,如下:
    - NFC，默认参数，表示“标准等价合成”（Normalization Form Canonical Composition），返回多个简单字符的合成字符。所谓“标准等价”指的是视觉和语义上的等价。
    - NFD，表示“标准等价分解”（Normalization Form Canonical Decomposition），即在标准等价的前提下，返回合成字符分解的多个简单字符。
    - NFKC，表示“兼容等价合成”（Normalization Form Compatibility Composition），返回合成字符。所谓“兼容等价”指的是语义上存在等价，但视觉上不等价，比如“囍”和“喜喜”。（这只是用来举例，normalize方法不能识别中文。）
    - NFKD，表示“兼容等价分解”（Normalization Form Compatibility Decomposition），即在兼容等价的前提下，返回合成字符分解的多个简单字符。
- str.includes()   返回boolean 表示是否找到了参数字符串
- str.startsWith()  返回boolean 表示参数字符串是否在源字符串的头部
- str.endsWith()    返回boolean 表示参数字符串是否在源字符串的尾部
- str.repeat()  返回字符串, 表示将源字符串重复n次 n>=0
- str.padStart() 和 str.padEnd()   一共接受两个参数，第一个参数是字符串补全生效的最大长度，第二个参数是用来补全的字符串 , 一个头一个尾
- str.trimStart() 和 str.trimEnd() , 效果和trim()一致  , 一个是尾部消除  一个是头部消除
- str.matchAll()  返回一个正则表达式在当前字符串的所有匹配


## 正则的扩展

es6 中RegExp 的构造方法的第二个参数可以在第一个参数是正则表达式的情况下生效为新的修饰符 ， ES5 则不支持


ES6把字符串的4个正则方法(match,replace,search,split)在语言内部让RegExp对象调用。

ES6增加了 **u** 修饰符，用于与 "Unicode模式" ,  **u**修饰符 会影响下面的一些行为
-  点字符  没有的话不能识别点码大于0xFFFF的值
-  字符表示法   不加u无法识别
-  量词     加了u后所有两次都会自动识别 点码大于0xFFFF的值
-  预定义模式
-  i 修饰符

正则实例对象增加了unicode属性来表示 是否设置了u修饰符

y 修饰符 又称 粘连(sticky)修饰符， 和g修饰符类似，也是全局匹配，但是后一次匹配都要从上一次成功的下一个位置开始 ,可以通过查看正则对象的sticky属性来表示是否设置了y修饰符

ES6 新增flags属性来返回正则表达式的修饰符。

    // todo  断言
    
js的组匹配使用exec方法可以取出结果来，结果的只能通过数字序号取出来。 ES2018  增加了具名匹配，可以为每个组指定一个名字，并返回一个引用对象。没有匹配到的属性值会是Undefined

    // todo 解构赋值与替换 
在具名组匹配中可以使用数字引用和\k<组名>的引用方式


## 数值的扩展

ES6提供了二进制和八进制的新写法，前缀是 0b和0o

ES6的Number对象提供了isFinite()和isNaN两个方法，一个用来判断是否有限，一个用来判断是否为NaN

http://es6.ruanyifeng.com/#docs/number
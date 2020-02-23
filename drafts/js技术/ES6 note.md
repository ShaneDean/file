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

ES6 提供了二进制和八进制数值的新的写法，分别用前缀0b（或0B）和0o（或0O）表示。

ES6 在Number对象上，新提供了Number.isFinite()和Number.isNaN()两个方法。 一个表示 是否为有限  一个表示是否为NaN . 相对于传统的全局方法,区别在于传统方法会先调用Number()将非数值转换为数值,再进行判断,而这两个新方法只对数值有效. Number.isFinite()对于非数值一律返回false, Number.isNaN()只有对于NaN才返回true，非NaN一律返回false

ES6 将全局方法parseInt()和parseFloat()，移植到Number对象上面，行为完全保持不变。这样做的目的，是逐步减少全局性方法，使得语言逐步模块化。

Number.isInteger()用来判断一个数值是否为整数。JavaScript 内部，整数和浮点数采用的是同样的储存方法，所以 25 和 25.0 被视为同一个值。

注意，由于 JavaScript 采用 IEEE 754 标准，数值存储为64位双精度格式，数值精度最多可以达到 53 个二进制位（1 个隐藏位与 52 个有效位）。如果数值的精度超过这个限度，第54位及后面的位就会被丢弃，这种情况下，Number.isInteger可能会误判。

     Number.isInteger(3.0000000000000002) // true

上面代码中，Number.isInteger的参数明明不是整数，但是会返回true。原因就是这个小数的精度达到了小数点后16个十进制位，转成二进制位超过了53个二进制位，导致最后的那个2被丢弃了。类似的情况还有，如果一个数值的绝对值小于Number.MIN_VALUE（5E-324），即小于 JavaScript 能够分辨的最小值，会被自动转为 0。这时，Number.isInteger也会误判。

    Number.isInteger(5E-324) // false
    Number.isInteger(5E-325) // true

总之,如果对数据精度的要求较高，不建议使用Number.isInteger()判断一个数值是否为整数。

ES6 在Number对象上面，新增一个极小的常量Number.EPSILON。根据规格，它表示 1 与大于 1 的最小浮点数之间的差。 对于 64 位浮点数来说，大于 1 的最小浮点数相当于二进制的1.00..001，小数点后面有连续 51 个零。这个值减去 1 之后，就等于 2 的 -52 次方。 Number.EPSILON实际上是 JavaScript 能够表示的最小精度。误差如果小于这个值，就可以认为已经没有意义了，即不存在误差了。引入一个这么小的量的目的，在于为浮点数计算，设置一个误差范围。我们知道浮点数计算是不精确的。

JavaScript 能够准确表示的整数范围在-2^53到2^53之间（不含两个端点），超过这个范围，无法精确表示这个值。ES6 引入了Number.MAX_ SAFE_ INTEGER和Number.MIN_ SAFE_ INTEGER这两个常量，用来表示这个范围的上下限。Number.isSafeInteger()则是用来判断一个整数是否落在这个范围之内

验证运算结果是否落在安全整数的范围内，不要只验证运算结果，而要同时验证参与运算的每个值。

ES6 在 Math 对象上新增了 17 个与数学相关的方法。所有这些方法都是静态方法，只能在 Math 对象上调用。
-   trunc    用于去除一个数的小数部分，返回整数部分。
-   sign    方法用来判断一个数到底是正数、负数、还是零。对于非数值，会先将其转换为数值。 有五种情况返回
    - 参数为正数，返回+1；
    - 参数为负数，返回-1；
    - 参数为 0，返回0；
    - 参数为-0，返回-0;
    - 其他值，返回NaN。
-   cbrt    用于计算一个数的立方根
-   clz32   将参数转为 32 位无符号整数的形式，然后这个 32 位值里面有多少个前导 0。
-   imul    回两个数以 32 位带符号整数形式相乘的结果，返回的也是一个 32 位的带符号整数。
-   fround  返回一个数的32位单精度浮点数形式。将64位双精度浮点数转为32位单精度浮点数。如果小数的精度超过24个二进制位，返回值就会不同于原值，否则返回值不变（即与64位双精度值一致）。
-   hypot   返回所有参数的平方和的平方根。
-   expm1   返回Math.exp(x) - 1 ,如下<html style="color: red;">e<sup>x</sup> - 1</html> 
-   log1p   返回 1 + x的自然对数
-   log10   返回以 10 为底的x的对数。如果x小于 0，则返回 NaN。
-   log2    返回以 2 为底的x的对数。如果x小于 0，则返回 NaN
-   sinh    返回x的双曲正弦
-   cosh    返回x的双曲余弦 
-   tanh    返回x的双曲正切
-   asinh   返回x的反双曲正弦
-   acosh   返回x的反双曲余弦
-   atanh   返回x的反双曲正切

ES2016 新增了一个指数运算符（**）。右结合. V8 引擎的指数运算符与Math.pow的实现不相同，对于特别大的运算结果，两者会有细微的差异。

## 函数扩展
ES6 增加了默认值, 参数变量是默认声明的，所以不能用let或const再次声明。参数默认值不是传值的，而是每次都重新计算默认值表达式的值。也就是说，参数默认值是惰性求值的。

参数默认值可以与解构赋值的默认值，结合起来使用。

通常情况下，定义了默认值的参数，应该是函数的尾参数。因为这样比较容易看出来，到底省略了哪些参数。如果非尾部的参数设置默认值，实际上这个参数是没法省略的。

指定了默认值以后，函数的length属性，将返回没有指定默认值的参数个数。也就是说，指定了默认值后，length属性将失真。
```
(function (a) {}).length // 1
(function (a = 5) {}).length // 0
(function (a, b, c = 5) {}).length // 2
```
length属性的含义是,该函数预期传入的参数个数。某个参数指定默认值以后，预期传入的参数个数就不包括这个参数了

一旦设置了参数的默认值，函数进行声明初始化时，参数会形成一个单独的作用域（context）。等到初始化结束，这个作用域就会消失。这种语法行为，在不设置参数默认值时，是不会出现的。

利用参数默认值，可以指定某一个参数不得省略，如果省略就抛出一个错误。
```js
function throwIfMissing() {throw new Error('Missing parameter');}
function foo(mustBeProvided = throwIfMissing()) {return mustBeProvided;}
foo()       // Error: Missing parameter
```
另外，可以将参数默认值设为undefined，表明这个参数是可以省略的。
```js
    function foo(optional = undefined ) { ··· }
```
ES6 引入 rest 参数（形式为...变量名），用于获取函数的多余参数，这样就不需要使用arguments对象了。rest 参数搭配的变量是一个数组，该变量将多余的参数放入数组中。注意，rest 参数之后不能再有其他参数（即只能是最后一个参数），否则会报错。函数的length属性，不包括 rest 参数。

ES2016 规定只要函数参数使用了默认值、解构赋值、或者扩展运算符，那么函数内部就不能显式设定为严格模式，否则会报错。

函数的name属性，返回该函数的函数名。Function构造函数返回的函数实例，name属性的值为anonymous。bind返回的函数，name属性值会加上bound前缀。

如果将一个具名函数赋值给一个变量，则 ES5 和 ES6 的name属性都返回这个具名函数原本的名字。

ES6 允许使用“箭头”（=>）定义函数。

箭头函数注意点
-   函数体内的this对象，就是定义时所在的对象，而不是使用时所在的对象。
-   不可以当作构造函数，也就是说，不可以使用new命令，否则会抛出一个错误。
-   不可以使用arguments对象，该对象在函数体内不存在。如果要用，可以用 rest 参数代替。
-   不可以使用yield命令，因此箭头函数不能用作 Generator 函数。

注意:箭头函数可以让this指向固定化，这种特性很有利于封装回调函数。this指向的固定化，并不是因为箭头函数内部有绑定this的机制，实际原因是箭头函数根本没有自己的this，导致内部的this就是外层代码块的this。正是因为它没有this，所以也就不能用作构造函数。除了this，以下三个变量在箭头函数之中也是不存在的，指向外层函数的对应变量：arguments、super、new.target。

由于箭头函数使得this从“动态”变成“静态”，下面两个场合不应该使用箭头函数。
-   定义对象的方法，且该方法内部包括this。
-   需要动态this的时候，也不应使用箭头函数

箭头嵌套函数
```js
let insert = (value) => ({
		into: (array) => ({
			after: (afterValue) => { 
				array.splice(array.indexOf(afterValue) + 1, 0, value);
				return array;
			}
		})
	});
insert(2).into([1, 3]).after(1); //[1, 2, 3]
```
管道机制(pipeline)
```js
const pipeline = (...funcs) =>
  val => funcs.reduce((a, b) => b(a), val);
const plus1 = a => a + 1;
const mult2 = a => a * 2;
const addThenMult = pipeline(plus1, mult2);

addThenMult(5)// 12
mult2(plus1(5)) // 12
```

尾调用(Tail Call) 某个函数的最后一步是调用另一个函数.“尾调用优化”（Tail call optimization），即只保留内层函数的调用帧。如果所有函数都是尾调用，那么完全可以做到每次执行时，调用帧只有一项，这将大大节省内存。注意，只有不再用到外层函数的内部变量，内层函数的调用帧才会取代外层函数的调用帧，否则就无法进行“尾调用优化”。

递归非常耗费内存，因为需要同时保存成千上百个调用帧，很容易发生“栈溢出”错误（stack overflow）。但对于尾递归来说，由于只存在一个调用帧，所以永远不会发生“栈溢出”错误。

尾递归的实现 , 把所有用到的内部变量改写成函数的参数.

柯里化（currying），意思是将多参数的函数转换成单参数的形式。

ES6 的尾调用优化只在严格模式下开启，正常模式是无效的。这是因为在正常模式下，函数内部有两个变量，可以跟踪函数的调用栈。
- func.arguments：返回调用时函数的参数。
- func.caller：返回调用当前函数的那个函数。

尾调用优化发生时，函数的调用栈会改写，因此上面两个变量就会失真。严格模式禁用这两个变量，所以尾调用模式仅在严格模式下生效。

 蹦床函数（trampoline）可以将递归执行转为循环执行.将原来的递归函数，改写为每一步返回另一个函数
 
 ES2017 允许函数的最后一个参数有尾逗号（trailing comma）。

## 数组的扩展

扩展运算符（spread）是三个点（...）。它好比 rest 参数的逆运算，将一个数组转为用逗号分隔的参数序列。注意，只有函数调用时，扩展运算符才可以放在圆括号中，否则会报错。

由于扩展运算符可以展开数组，所以不再需要apply方法，将数组转为函数的参数了。

数组是复合的数据类型，直接复制的话，只是复制了指向底层数据结构的指针，而不是克隆一个全新的数组。扩展运算符提供了复制数组的简便写法:
```js
const a1 = [1, 2];
const a2 = [...a1];// 写法一
const [...a2] = a1;// 写法二
```
扩展运算符提供了数组合并的新写法。
```js
const arr1 = ['a', 'b'];
const arr2 = ['c'];
const arr3 = ['d', 'e'];
// ES5 的合并数组
arr1.concat(arr2, arr3);  // [ 'a', 'b', 'c', 'd', 'e' ]
// ES6 的合并数组
[...arr1, ...arr2, ...arr3]  // [ 'a', 'b', 'c', 'd', 'e' ]
```
这两种方法都是浅拷贝，使用的时候需要注意

扩展运算符可以与解构赋值结合起来，用于生成数组。
```js
const [first, ...rest] = [1, 2, 3, 4, 5];
first // 1
rest  // [2, 3, 4, 5]

const [first, ...rest] = [];
first // undefined
rest  // []

const [first, ...rest] = ["foo"];
first  // "foo"
rest   // []
```
扩展运算符用于数组赋值，只能放在参数的最后一位，否则会报错。扩展运算符还可以将字符串转为真正的数组。

任何定义了遍历器（Iterator）接口的对象，都可以用扩展运算符转为真正的数组。展运算符内部调用的是数据结构的 Iterator 接口，因此只要具有 Iterator 接口的对象，都可以使用扩展运算符，比如 Map 结构.Generator 函数运行后，返回一个遍历器对象，因此也可以使用扩展运算符。

Array.from方法用于将两类对象转为真正的数组：类似数组的对象（array-like object）和可遍历（iterable）的对象（包括 ES6 新增的数据结构 Set 和 Map）。如果参数是一个真正的数组，Array.from会返回一个一模一样的新数组。扩展运算符（...）也可以将某些数据结构转为数组。
```js
// arguments对象
function foo() {
  const args = [...arguments];
}
```
任何有length属性的对象，都可以通过Array.from方法转为数组.Array.from还可以接受第二个参数，作用类似于数组的map方法，用来对每个元素进行处理，将处理后的值放入返回的数组。

Array.of方法用于将一组值，转换为数组。

    Array.of(3, 11, 8) // [3,11,8]

数组实例的copyWithin方法，在当前数组内部，将指定位置的成员复制到其他位置（会覆盖原有成员），然后返回当前数组。也就是说，使用这个方法，会修改当前数组. 它接受三个参数。
-   target（必需）：从该位置开始替换数据。如果为负值，表示倒数。
-   start（可选）：从该位置开始读取数据，默认为 0。如果为负值，表示倒数。
-   end（可选）：到该位置前停止读取数据，默认等于数组长度。如果为负值，表示倒数。

数组实例的find方法，用于找出第一个符合条件的数组成员。它的参数是一个回调函数，所有数组成员依次执行该回调函数，直到找出第一个返回值为true的成员，然后返回该成员。如果没有符合条件的成员，则返回undefined . 数组实例的findIndex方法的用法与find方法非常类似，返回第一个符合条件的数组成员的位置，如果所有成员都不符合条件，则返回-1。 这两个方法都可以发现NaN，弥补了数组的indexOf方法的不足。

```js
[NaN].indexOf(NaN)      // -1

[NaN].findIndex(y => Object.is(NaN, y))     // 0
```

fill方法使用给定值，填充一个数组。fill方法还可以接受第二个和第三个参数，用于指定填充的起始位置和结束位置。注意，如果填充的类型为对象，那么被赋值的是同一个内存地址的对象，而不是深拷贝对象。

ES6 提供三个新的方法——entries()，keys()和values()——用于遍历数组。它们都返回一个遍历器对象,可以用for...of循环或手动调用遍历器对象的Next方法进行遍历，唯一的区别是keys()是对键名的遍历、values()是对键值的遍历，entries()是对键值对的遍历。

Array.prototype.includes方法返回一个布尔值，表示某个数组是否包含给定的值，与字符串的includes方法类似。

另外，Map 和 Set 数据结构有一个has方法，需要注意与includes区分。

-   Map 结构的has方法，是用来查找键名的，比如Map.prototype.has(key)、WeakMap.prototype.has(key)、Reflect.has(target, propertyKey)。
-   Set 结构的has方法，是用来查找值的，比如Set.prototype.has(value)、WeakSet.prototype.has(value)。

数组的成员有时还是数组，Array.prototype.flat()用于将嵌套的数组“拉平”，变成一维的数组。该方法返回一个新数组，对原数据没有影响。

## 对象的扩展
es6允许了简洁的表述方式,可以直接写入变量 和函数,作为对象的属性和方法.commonJS模块输出一组变量就非常适合采用简洁的写法. 属性的赋值器setter和取值器getter也是这种写法

注意，简洁写法的属性名总是字符串，这会导致一些看上去比较奇怪的结果 ,下面代码中class是字符串,不属于关键字,所以不会导致语法解析错误

```js
const obj = {
  class () {}
};
//等同
var obj = {
    'class' : function( ) { }
}
```

如果某个方法的值是个Generator函数,前面需要加上星号.
```js
const obj = {
  * m() {
    yield 'hello world';
  }
};
```

ES6 允许字面量定义对象时候,使用表达式作为对象的属性名和方法名称. 但 注意，属性名表达式与简洁表示法，不能同时使用，会报错。

注意:属性名表达式如果是一个对象，默认情况下会自动将对象转为字符串
```js
const keyA = {a: 1};
const keyB = {b: 2};

const myObject = {
  [keyA]: 'valueA',
  [keyB]: 'valueB'
};

myObject // Object {[object Object]: "valueB"}
```
上面代码中，[keyA]和[keyB]得到的都是[object Object]，所以[keyB]会把[keyA]覆盖掉，而myObject最后只有一个[object Object]属性。

函数的name属性，返回函数名。对象方法也是函数，因此也有name属性。
如果对象的方法使用了取值函数（getter）和存值函数（setter），则name属性不是在该方法上面，而是该方法的属性的描述对象的get和set属性上面，返回值是方法名前加上get和set。

注意: bind方法创造的函数，name属性返回bound加上原函数的名字；Function构造函数创造的函数，name属性返回anonymous . 如果对象的方法是一个 Symbol 值，那么name属性返回的是这个 Symbol 值的描述。

对象的每个属性都有一个描述对象,用来控制该属性的行为.Object.getOwnPropertyDescriptor方法可以获取该属性的描述对象。描述对象的enumerable属性，称为“可枚举性”，如果该属性为false，就表示某些操作会忽略当前属性。其中4个操作会忽略enumerable为false的属性。
-   for...in循环：只遍历对象自身的和继承的可枚举的属性。(会返回继承的属性)
-   Object.keys()：返回对象自身的所有可枚举的属性的键名。
-   JSON.stringify()：只串行化对象自身的可枚举的属性。
-   Object.assign()： 忽略enumerable为false的属性，只拷贝对象自身的可枚举的属性。(ES6新增)

实际上，引入“可枚举”（enumerable）这个概念的最初目的，就是让某些属性可以规避掉for...in操作，不然所有内部属性和方法都会被遍历到。比如，对象原型的toString方法，以及数组的length属性，就通过“可枚举性”，从而避免被for...in遍历到。

另外，ES6 规定，所有 Class 的原型的方法都是不可枚举的。

es6的五种遍历对象的方法
-   for...in
-   Object.keys(obj)
-   Object.getOwnPropertyNames(obj)
-   Object.getOwnPropertySynmbols(obj)
-   Reflect.ownKeys(obj)

上面方法遍历对象的键名都那下面的规则排序
-   首先遍历所有数值键，按照数值升序排列。
-   其次遍历所有字符串键，按照加入时间升序排列。
-   最后遍历所有 Symbol 键，按照加入时间升序排列。

ES6增加super关键字,指向当前对象的原型对象 , 注意，super关键字表示原型对象时，只能用在对象的方法之中，用在其他地方都会报错。
```js
//成功 对象方法之中
const obj2 = {
	foo () {
    	return super.foo
    }
}
// 报错  属性里面
const obj = {
  foo: super.foo
}

// 报错 用在一个函数里面,然后复制给foo属性
const obj = {
  foo: () => super.foo
}

// 报错 用在一个函数里面,然后复制给foo属性
const obj = {
  foo: function () {
    return super.foo
  }
}
```
JavaScript 引擎内部，super.foo等同于Object.getPrototypeOf(this).foo（属性）或Object.getPrototypeOf(this).foo.call(this)（方法）。

对象的解构赋值用于从一个对象取值，相当于将目标对象自身的所有可遍历的（enumerable）、但尚未被读取的属性，分配到指定的对象上面。所有的键和它们的值，都会拷贝到新对象上面。由于解构赋值要求等号右边是一个对象，所以如果等号右边是undefined或null，就会报错，因为它们无法转为对象。

注意，解构赋值的拷贝是浅拷贝，即如果一个键的值是复合类型的值（数组、对象、函数）、那么解构赋值拷贝的是这个值的引用，而不是这个值的副本。另外，扩展运算符的解构赋值，不能复制继承自原型对象的属性。

对象的扩展运算符（...）用于取出参数对象的所有可遍历属性，拷贝到当前对象之中。


完整克隆一个对象，还拷贝对象原型的属性，可以采用下面的写法。
```js
// 写法一
const clone1 = {
  __proto__: Object.getPrototypeOf(obj),
  ...obj
};

// 写法二
const clone2 = Object.assign(
  Object.create(Object.getPrototypeOf(obj)),
  obj
);

// 写法三
const clone3 = Object.create(
  Object.getPrototypeOf(obj),
  Object.getOwnPropertyDescriptors(obj)
)
```
写法一的__proto__属性在非浏览器的环境不一定部署，因此推荐使用写法二和写法三

扩展运算符可以用于合并两个对象。
```js
let ab = { ...a, ...b };
// 等同于
let ab = Object.assign({}, a, b);
```
如果用户自定义的属性，放在扩展运算符后面，则扩展运算符内部的同名属性会被覆盖掉。
```js
let aWithOverrides = { ...a, x: 1, y: 2 };
// 等同于
let aWithOverrides = { ...a, ...{ x: 1, y: 2 } };
// 等同于
let x = 1, y = 2, aWithOverrides = { ...a, x, y };
// 等同于
let aWithOverrides = Object.assign({}, a, { x: 1, y: 2 });
```
上面代码中，a对象的x属性和y属性，拷贝到新对象后会被覆盖掉。

这用来修改现有对象部分的属性就很方便了。
```js
let newVersion = {
  ...previousVersion,
  name: 'New Name' // Override the name property
};
```
上面代码中，newVersion对象自定义了name属性，其他属性全部复制自previousVersion对象。

如果把自定义属性放在扩展运算符前面，就变成了设置新对象的默认属性值。

```js
let aWithDefaults = { x: 1, y: 2, ...a };
// 等同于
let aWithDefaults = Object.assign({}, { x: 1, y: 2 }, a);
// 等同于
let aWithDefaults = Object.assign({ x: 1, y: 2 }, a);
```
与数组的扩展运算符一样，对象的扩展运算符后面可以跟表达式。
```js
const obj = {
  ...(x > 1 ? {a: 1} : {}),
  b: 2,
};
```
扩展运算符的参数对象之中，如果有取值函数get，这个函数是会执行的。
```js
// 并不会抛出错误，因为 x 属性只是被定义，但没执行
let aWithXGetter = {
  ...a,
  get x() {
    throw new Error('not throw yet');
  }
};

// 会抛出错误，因为 x 属性被执行了
let runtimeError = {
  ...a,
  ...{
    get x() {
      throw new Error('throw now');
    }
  }
};
```
## 对象的新增方法
ES5 比较两个值是否相等，只有两个运算符：相等运算符（ == ）和严格相等运算符（ === ）。它们都有缺点，前者会自动转换数据类型，后者的NaN不等于自身，以及+0等于-0。JavaScript 缺乏一种运算，在所有环境中，只要两个值是一样的，它们就应该相等。

ES6 提出“Same-value equality”（同值相等）算法，用来解决这个问题。Object.is就是部署这个算法的新方法。它用来比较两个值是否严格相等，与严格比较运算符（===）的行为基本一致。
```js
+0 === -0 //true
NaN === NaN // false

Object.is(+0, -0) // false
Object.is(NaN, NaN) // true
```

Object.assign方法用于对象的合并，将源对象（source）的所有可枚举属性，复制到目标对象（target）。Object.assign方法的第一个参数是目标对象，后面的参数都是源对象。注意，如果目标对象与源对象有同名属性，或多个源对象有同名属性，则后面的属性会覆盖前面的属性。

如果只有一个参数，Object.assign会直接返回该参数。如果该参数不是对象，则会先转成对象，然后返回。由于undefined和null无法转成对象，所以如果它们作为参数，就会报错。

Object.assign注意点:
-   Object.assign方法实行的是浅拷贝，而不是深拷贝。也就是说，如果源对象某个属性的值是对象，那么目标对象拷贝得到的是这个对象的引用。
-   对于这种嵌套的对象，一旦遇到同名属性，Object.assign的处理方法是替换，而不是添加。
-   Object.assign可以用来处理数组，但是会把数组视为对象。这个对象的key是数组的序号
-   Object.assign只能进行值的复制，如果要复制的值是一个取值函数，那么将求值后再复制。

用途:
-   为对象添加属性
-   为对象添加方法
-   克隆对象 只能克隆原始对象,如果要克隆继承制的值,保持继承链使用下面的做法
```js
function clone(origin) {
  let originProto = Object.getPrototypeOf(origin);
  return Object.assign(Object.create(originProto), origin);
}
```
-   合并多个对象
```js
//将多个对象合并到某个对象。
const merge =
  (target, ...sources) => Object.assign(target, ...sources);
//如果希望合并后返回一个新对象，可以改写上面函数，对一个空对象合并。
const merge =
  (...sources) => Object.assign({}, ...sources);
```
-   为属性指定默认值

ES2017 引入了Object.getOwnPropertyDescriptors()方法，返回指定对象所有自身属性（非继承属性）的描述对象。该方法的引入目的，主要是为了解决Object.assign()无法正确拷贝get属性和set属性的问题。

__proto__属性（前后各两个下划线），用来读取或设置当前对象的prototype对象。目前，所有浏览器（包括 IE11）都部署了这个属性。新的代码最好认为这个属性是不存在的。因此，无论从语义的角度，还是从兼容性的角度，都不要使用这个属性，而是使用下面的Object.setPrototypeOf()（写操作）、Object.getPrototypeOf()（读操作）、Object.create()（生成操作）代替。

Object.setPrototypeOf方法的作用与__proto__相同，用来设置一个对象的prototype对象，返回参数对象本身。它是 ES6 正式推荐的设置原型对象的方法。

Object.getPrototypeOf()该方法与Object.setPrototypeOf方法配套，用于读取一个对象的原型对象。

Object.fromEntries()方法是Object.entries()的逆操作，用于将一个键值对数组转为对象。该方法的主要目的，是将键值对的数据结构还原为对象，因此特别适合将 Map 结构转为对象。


## Symbol 
ES6 引入了一种新的原始数据类型Symbol，表示独一无二的值。

Symbol函数可以接受一个字符串作为参数，表示对 Symbol 实例的描述，主要是为了在控制台显示，或者转为字符串时，比较容易区分。如果 Symbol 的参数是一个对象，就会调用该对象的toString方法，将其转为字符串，然后才生成一个 Symbol 值。注意，Symbol函数的参数只是表示对当前 Symbol 值的描述，因此相同参数的Symbol函数的返回值是不相等的。

Symbol 值可以显式转为字符串,也可以转为布尔值，但是不能转为数值,
ES2019 提供了一个实例属性description，直接返回 Symbol 的描述。

由于每一个 Symbol 值都是不相等的，这意味着 Symbol 值可以作为标识符，用于对象的属性名，就能保证不会出现同名的属性。这对于一个对象由多个模块构成的情况非常有用，能防止某一个键被不小心改写或覆盖。

在对象的内部，使用 Symbol 值定义属性时，Symbol 值必须放在方括号之中。如果s不放在方括号中，该属性的键名就是字符串s，而不是s所代表的那个 Symbol 值。

```js
let obj = {
  [s](arg) { ... }
};
```

有时，我们希望重新使用同一个 Symbol 值，Symbol.for方法可以做到这一点。它接受一个字符串作为参数，然后搜索有没有以该参数作为名称的 Symbol 值。如果有，就返回这个 Symbol 值，否则就新建并返回一个以该字符串为名称的 Symbol 值。

对象的Symbol.hasInstance属性，指向一个内部方法。当其他对象使用instanceof运算符，判断是否为该对象的实例时，会调用这个方法。比如，foo instanceof Foo在语言内部，实际调用的是Foo\[Symbol.hasInstance\](foo)。

对象的Symbol.isConcatSpreadable属性等于一个布尔值，表示该对象用于Array.prototype.concat()时，是否可以展开。

对象的Symbol.species属性，指向一个构造函数。创建衍生对象时，会使用该属性。

Symbol.species的作用在于，实例对象在运行过程中，需要再次调用自身的构造函数时，会调用该属性指定的构造函数。它主要的用途是，有些类库是在基类的基础上修改的，那么子类使用继承的方法时，作者可能希望返回基类的实例，而不是子类的实例。

对象的Symbol.toStringTag属性，指向一个方法。在该对象上面调用Object.prototype.toString方法时，如果这个属性存在，它的返回值会出现在toString方法返回的字符串之中，表示对象的类型。也就是说，这个属性可以用来定制[object Object]或[object Array]中object后面的那个字符串。

-   JSON[Symbol.toStringTag]：'JSON'
-   Math[Symbol.toStringTag]：'Math'
-   Module 对象M[Symbol.toStringTag]：'Module'
-   ArrayBuffer.prototype[Symbol.toStringTag]：'ArrayBuffer'
-   DataView.prototype[Symbol.toStringTag]：'DataView'
-   Map.prototype[Symbol.toStringTag]：'Map'
-   Promise.prototype[Symbol.toStringTag]：'Promise'
-   Set.prototype[Symbol.toStringTag]：'Set'
-   %TypedArray%.prototype[Symbol.toStringTag]：'Uint8Array'等
-   WeakMap.prototype[Symbol.toStringTag]：'WeakMap'
-   WeakSet.prototype[Symbol.toStringTag]：'WeakSet'
-   %MapIteratorPrototype%[Symbol.toStringTag]：'Map Iterator'
-   %SetIteratorPrototype%[Symbol.toStringTag]：'Set Iterator'
-   %StringIteratorPrototype%[Symbol.toStringTag]：'String Iterator'
-   Symbol.prototype[Symbol.toStringTag]：'Symbol'
-   Generator.prototype[Symbol.toStringTag]：'Generator'
-   GeneratorFunction.prototype[Symbol.toStringTag]：'GeneratorFunction'

## set 和 map

ES6 提供了新的数据结构 Set。它类似于数组，但是成员的值都是唯一的，没有重复的值。Set本身是一个构造函数，用来生成 Set 数据结构。
Set 结构不会添加重复的值。

```js
// 去除数组的重复成员
[...new Set(array)]
// 字符串驱虫
[...new Set('ababbc')].join('')
```

WeakSet , 和Set类似, 差别是 WeakSet的成员只能是对象. 其次，WeakSet 中的对象都是弱引用，即垃圾回收机制不考虑 WeakSet 对该对象的引用，也就是说 , 如果其他对象都不再引用该对象，那么垃圾回收机制会自动回收该对象所占用的内存，不考虑该对象还存在于 WeakSet 之中。

WeakSet 的一个用处，是储存 DOM 节点，而不用担心这些节点从文档移除时，会引发内存泄漏。

JavaScript 的对象（Object），本质上是键值对的集合（Hash 结构），但是传统上只能用字符串当作键。这给它的使用带来了很大的限制。为了解决这个问题，ES6 提供了 Map 数据结构。它类似于对象，也是键值对的集合，但是“键”的范围不限于字符串，各种类型的值（包括对象）都可以当作键。

Map 还有一个forEach方法，与数组的forEach方法类似，也可以实现遍历。forEach方法还可以接受第二个参数，用来绑定this。

```js
const reporter = {
  report: function(key, value) {
    console.log("Key: %s, Value: %s", key, value);
  }
};

map.forEach(function(value, key, map) {
  this.report(key, value);
}, reporter);
```

weakmap和map相同,只有一下两点区别:1,只接受对象作为键名（null除外），不接受其他类型的值作为键名。2,其次，WeakMap的键名所指向的对象，不计入垃圾回收机制。

主要用途是用来保存dom节点的属性状态.另外一个用处就是部署私有属性


## Proxy

proxy 用于修改某些操作的默认行为,等同于在语言层面做出修改,属于一种元编程.  Proxy 可以理解成，在目标对象之前架设一层“拦截”，外界对该对象的访问，都必须先通过这层拦截，因此提供了一种机制，可以对外界的访问进行过滤和改写。Proxy 这个词的原意是代理，用在这里表示由它来“代理”某些操作，可以译为“代理器”。 (切面?)

ES6 原生提供 Proxy 构造函数，用来生成 Proxy 实例。

    var proxy = new Proxy(target, handler);
target 表示要拦截的目标对象, Handler的参数也是一个对象,用来定义拦截行为.

可以将 Proxy 对象，设置到object.proxy属性，从而可以在object对象上调用。Proxy 实例也可以作为其他对象的原型对象。

Proxy支持的拦截操作共13种,如下:

-	get(target, propKey, receiver)：拦截对象属性的读取，比如proxy.foo和proxy['foo']。
-	set(target, propKey, value, receiver)：拦截对象属性的设置，比如proxy.foo = v或proxy['foo'] = v，返回一个布尔值。
-	has(target, propKey)：拦截propKey in proxy的操作，返回一个布尔值。
-	deleteProperty(target, propKey)：拦截delete proxy[propKey]的操作，返回一个布尔值。
-	ownKeys(target)：拦截Object.getOwnPropertyNames(proxy)、Object.getOwnPropertySymbols(proxy)、Object.keys(proxy)、for...in循环，返回一个数组。该方法返回目标对象所有自身的属性的属性名，而Object.keys()的返回结果仅包括目标对象自身的可遍历属性。
-	getOwnPropertyDescriptor(target, propKey)：拦截Object.getOwnPropertyDescriptor(proxy, propKey)，返回属性的描述对象。
-	defineProperty(target, propKey, propDesc)：拦截Object.defineProperty(proxy, propKey, propDesc）、Object.defineProperties(proxy, propDescs)，返回一个布尔值。
-	preventExtensions(target)：拦截Object.preventExtensions(proxy)，返回一个布尔值。
-	getPrototypeOf(target)：拦截Object.getPrototypeOf(proxy)，返回一个对象。
-	isExtensible(target)：拦截Object.isExtensible(proxy)，返回一个布尔值。
-	setPrototypeOf(target, proto)：拦截Object.setPrototypeOf(proxy, proto)，返回一个布尔值。如果目标对象是函数，那么还有两种额外操作可以拦截。
-	apply(target, object, args)：拦截 Proxy 实例作为函数调用的操作，比如proxy(...args)、proxy.call(object, ...args)、proxy.apply(...)。
-	construct(target, args)：拦截 Proxy 实例作为构造函数调用的操作，比如new proxy(...args)。

利用 Proxy，可以将读取属性的操作（get），转变为执行某个函数，从而实现属性的链式操作。

```js
var pipe = (function () {
  return function (value) {
    var funcStack = [];
    var oproxy = new Proxy({} , {
      get : function (pipeObject, fnName) {
        if (fnName === 'get') {
          return funcStack.reduce(function (val, fn) {
            return fn(val);
          },value);
        }
        funcStack.push(window[fnName]);
        return oproxy;
      }
    });

    return oproxy;
  }
}());

var double = n => n * 2;
var pow    = n => n * n;
var reverseInt = n => n.toString().split("").reverse().join("") | 0;

pipe(3).double.pow.reverseInt.get; // 63	
```

下面的例子则是利用proxy.get拦截，实现一个生成各种 DOM 节点的通用函数dom。

```js
const dom = new Proxy({}, {
  get(target, property) {
    return function(attrs = {}, ...children) {
      const el = document.createElement(property);
      for (let prop of Object.keys(attrs)) {
        el.setAttribute(prop, attrs[prop]);
      }
      for (let child of children) {
        if (typeof child === 'string') {
          child = document.createTextNode(child);
        }
        el.appendChild(child);
      }
      return el;
    }
  }
});

const el = dom.div({},
  'Hello, my name is ',
  dom.a({href: '//example.com'}, 'Mark'),
  '. I like:',
  dom.ul({},
    dom.li({}, 'The web'),
    dom.li({}, 'Food'),
    dom.li({}, '…actually that\'s it')
  )
);

document.body.appendChild(el);
```
下面是一个get方法的第三个参数的例子，它总是指向原始的读操作所在的那个对象，一般情况下就是 Proxy 实例。
```js
const proxy = new Proxy({}, {
  get: function(target, property, receiver) {
    return receiver;
  }
});
proxy.getReceiver === proxy // true
```

如果一个属性不可配置（configurable）且不可写（writable），则 Proxy 不能修改该属性，否则通过 Proxy 对象访问该属性会报错。

proxy.set方法用来拦截某个属性的赋值操作，可以接受四个参数，依次为目标对象、属性名、属性值和 Proxy 实例本身，其中最后一个参数可选。

我们会在对象上面设置内部属性，属性名的第一个字符使用下划线开头，表示这些属性不应该被外部使用。结合get和set方法，就可以做到防止这些内部属性被外部读写。

proxy.apply会拦截函数调用,call 和 apply 操作

proxy.has方法用来拦截HasProperty操作，即判断对象是否具有某个属性时，这个方法会生效。典型的操作就是in运算符。has方法可以接受两个参数，分别是目标对象、需查询的属性名。如果原对象不可配置或者禁止扩展，这时has拦截会报错。值得注意的是，has方法拦截的是HasProperty操作，而不是HasOwnProperty操作，即has方法不判断一个属性是对象自身的属性，还是继承的属性。虽然for...in循环也用到了in运算符，但是has拦截对for...in循环不生效。

proxy.construct 用于拦截new命令，下面是拦截对象的写法

proxy.deleteProperty方法用于拦截delete操作，如果这个方法抛出错误或者返回false，当前属性就无法被delete命令删除。

proxy.defineProperty方法拦截了Object.defineProperty操作。

proxy.getOwnPropertyDescriptor方法拦截Object.getOwnPropertyDescriptor()，返回一个属性描述对象或者undefined。

proxy.getPrototypeOf方法主要用来拦截获取对象原型。具体来说，拦截下面这些操作。

-   Object.prototype.\_\_proto__
-   Object.prototype.isPrototypeOf()
-   Object.getPrototypeOf()
-   Reflect.getPrototypeOf()
-   instanceof

proxy.isExtensible方法拦截Object.isExtensible操作。

proxy.ownKeys方法用来拦截对象自身属性的读取操作。具体来说，拦截以下操作。

-   Object.getOwnPropertyNames()
-   Object.getOwnPropertySymbols()
-   Object.keys()
-   for...in循环

proxy.setPrototypeOf方法主要用来拦截Object.setPrototypeOf方法。

Proxy.revocable方法返回一个可取消的 Proxy 实例。
Proxy.revocable的一个使用场景是，目标对象不允许直接访问，必须通过代理访问，一旦访问结束，就收回代理权，不允许再次访问。

虽然 Proxy 可以代理针对目标对象的访问，但它不是目标对象的透明代理，即不做任何拦截的情况下，也无法保证与目标对象的行为一致。主要原因就是在 Proxy 代理的情况下，目标对象内部的this关键字会指向 Proxy 代理。

```js
const target = {
  m: function () {
    console.log(this === proxy);
  }
};
const handler = {};

const proxy = new Proxy(target, handler);

target.m() // false
proxy.m()  // true
```
## Reflect

Reflect对象与Proxy对象一样，也是 ES6 为了操作对象而提供的新 API。Reflect对象的设计目的有这样几个。

1.  将Object对象的一些明显属于语言内部的方法（比如Object.defineProperty），放到Reflect对象上。现阶段，某些方法同时在Object和Reflect对象上部署，未来的新方法将只部署在Reflect对象上。也就是说，从Reflect对象上可以拿到语言内部的方法。

2.  修改某些Object方法的返回结果，让其变得更合理。比如，Object.defineProperty(obj, name, desc)在无法定义属性时，会抛出一个错误，而Reflect.defineProperty(obj, name, desc)则会返回false。

```js
// 老写法
try {
  Object.defineProperty(target, property, attributes);
  // success
} catch (e) {
  // failure
}

// 新写法
if (Reflect.defineProperty(target, property, attributes)) {
  // success
} else {
  // failure
}
```
3.  让Object操作都变成函数行为。某些Object操作是命令式，比如name in obj和delete obj[name]，而Reflect.has(obj, name)和Reflect.deleteProperty(obj, name)让它们变成了函数行为。

```js
// 老写法
'assign' in Object // true

// 新写法
Reflect.has(Object, 'assign') // true
```

4.  Reflect对象的方法与Proxy对象的方法一一对应，只要是Proxy对象的方法，就能在Reflect对象上找到对应的方法。这就让Proxy对象可以方便地调用对应的Reflect方法，完成默认行为，作为修改行为的基础。也就是说，不管Proxy怎么修改默认行为，你总可以在Reflect上获取默认行为。


Reflect一共13个静态方法.
-	Reflect.apply(target, thisArg, args)
-	Reflect.construct(target, args)
-	Reflect.get(target, name, receiver)
-	Reflect.set(target, name, value, receiver)
-	Reflect.defineProperty(target, name, desc)
-	Reflect.deleteProperty(target, name)
-	Reflect.has(target, name)
-	Reflect.ownKeys(target)
-	Reflect.isExtensible(target)
-	Reflect.preventExtensions(target)
-	Reflect.getOwnPropertyDescriptor(target, name)
-	Reflect.getPrototypeOf(target)
-	Reflect.setPrototypeOf(target, prototype)

## Promise
Promise 是异步编程的一种解决方案，比传统的解决方案——回调函数和事件——更合理和更强大。它由社区最早提出和实现，ES6 将其写进了语言标准，统一了用法，原生提供了Promise对象。

所谓Promise，简单说就是一个容器，里面保存着某个未来才会结束的事件（通常是一个异步操作）的结果。从语法上说，Promise 是一个对象，从它可以获取异步操作的消息。Promise 提供统一的 API，各种异步操作都可以用同样的方法进行处理。

Promise对象有以下两个特点。

-   对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：pending（进行中）、fulfilled（已成功）和rejected（已失败）。只有异步操作的结果，可以决定当前是哪一种状态，任何其他操作都无法改变这个状态。这也是Promise这个名字的由来，它的英语意思就是“承诺”，表示其他手段无法改变。
-   一旦状态改变，就不会再变，任何时候都可以得到这个结果。Promise对象的状态改变，只有两种可能：从pending变为fulfilled和从pending变为rejected。只要这两种情况发生，状态就凝固了，不会再变了，会一直保持这个结果，这时就称为 resolved（已定型）。如果改变已经发生了，你再对Promise对象添加回调函数，也会立即得到这个结果。这与事件（Event）完全不同，事件的特点是，如果你错过了它，再去监听，是得不到结果的。

有了Promise对象，就可以将异步操作以同步操作的流程表达出来，避免了层层嵌套的回调函数。此外，Promise对象提供统一的接口，使得控制异步操作更加容易。

Promise也有一些缺点。首先，无法取消Promise，一旦新建它就会立即执行，无法中途取消。其次，如果不设置回调函数，Promise内部抛出的错误，不会反应到外部。第三，当处于pending状态时，无法得知目前进展到哪一个阶段（刚刚开始还是即将完成）。

ES6 规定，Promise对象是一个构造函数，用来生成Promise实例。

```js
const promise = new Promise(function(resolve, reject) {
  // ... some code

  if (/* 异步操作成功 */){
    resolve(value);
  } else {
    reject(error);
  }
});
```
resolve函数的作用是，将Promise对象的状态从“未完成”变为“成功”（即从 pending 变为 resolved），在异步操作成功时调用，并将异步操作的结果，作为参数传递出去；reject函数的作用是，将Promise对象的状态从“未完成”变为“失败”（即从 pending 变为 rejected），在异步操作失败时调用，并将异步操作报出的错误，作为参数传递出去。Promise实例生成以后，可以用then方法分别指定resolved状态和rejected状态的回调函数。
```js
promise.then(function(value) {
  // success
}, function(error) {
  // failure
});
```
then方法可以接受两个回调函数作为参数。第一个回调函数是Promise对象的状态变为resolved时调用，第二个回调函数是Promise对象的状态变为rejected时调用。其中，第二个函数是可选的，不一定要提供。这两个函数都接受Promise对象传出的值作为参数。

下面是一个用Promise对象实现的 Ajax 操作的例子。
```js
const getJSON = function(url) {
  const promise = new Promise(function(resolve, reject){
    const handler = function() {
      if (this.readyState !== 4) {
        return;
      }
      if (this.status === 200) {
        resolve(this.response);
      } else {
        reject(new Error(this.statusText));
      }
    };
    const client = new XMLHttpRequest();
    client.open("GET", url);
    client.onreadystatechange = handler;
    client.responseType = "json";
    client.setRequestHeader("Accept", "application/json");
    client.send();

  });

  return promise;
};

getJSON("/posts.json").then(function(json) {
  console.log('Contents: ' + json);
}, function(error) {
  console.error('出错了', error);
});
```

注意，调用resolve或reject并不会终结 Promise 的参数函数的执行。
```js
new Promise((resolve, reject) => {
  resolve(1);
  console.log(2);
}).then(r => {
  console.log(r);
});
// 2
// 1
```

promise可以嵌套
```js
const p1 = new Promise(function (resolve, reject) {
  setTimeout(() => reject(new Error('fail')), 3000)
})

const p2 = new Promise(function (resolve, reject) {
  setTimeout(() => resolve(p1), 1000)
})

p2
  .then(result => console.log(result))
  .catch(error => console.log(error))
// Error: fail
```
上面代码中，p1和p2都是 Promise 的实例，但是p2的resolve方法将p1作为参数，即一个异步操作的结果是返回另一个异步操作。
注意，这时p1的状态就会传递给p2，也就是说，p1的状态决定了p2的状态。如果p1的状态是pending，那么p2的回调函数就会等待p1的状态改变；如果p1的状态已经是resolved或者rejected，那么p2的回调函数将会立刻执行。

Promise 实例具有then方法，也就是说，then方法是定义在原型对象Promise.prototype上的。它的作用是为 Promise 实例添加状态改变时的回调函数。前面说过，then方法的第一个参数是resolved状态的回调函数，第二个参数（可选）是rejected状态的回调函数。then方法返回的是一个新的Promise实例（注意，不是原来那个Promise实例）。因此可以采用链式写法，即then方法后面再调用另一个then方法。

采用链式的then，可以指定一组按照次序调用的回调函数。这时，前一个回调函数，有可能返回的还是一个Promise对象（即有异步操作），这时后一个回调函数，就会等待该Promise对象的状态发生变化，才会被调用。

Promise.prototype.catch方法是.then(null, rejection)或.then(undefined, rejection)的别名，用于指定发生错误时的回调函数。

一般来说，不要在then方法里面定义 Reject 状态的回调函数（即then的第二个参数），总是使用catch方法。

Promise 内部的错误不会影响到 Promise 外部的代码，通俗的说法就是“Promise 会吃掉错误”。Node 有一个unhandledRejection事件，专门监听未捕获的reject错误.unhandledRejection事件的监听函数有两个参数，第一个是错误对象，第二个是报错的 Promise 实例，它可以用来了解发生错误的环境信息。注意，Node 有计划在未来废除unhandledRejection事件。如果 Promise 内部有未捕获的错误，会直接终止进程，并且进程的退出码不为 0。

一般总是建议，Promise 对象后面要跟catch方法，这样可以处理 Promise 内部发生的错误。catch方法返回的还是一个 Promise 对象，因此后面还可以接着调用then方法。

Promise.prototype.finally方法用于指定不管 Promise 对象最后状态如何，都会执行的操作。该方法是 ES2018 引入标准的。

Promise.all方法用于将多个 Promise 实例，包装成一个新的 Promise 实例。
```js
const p = Promise.all([p1, p2, p3]);
```
上面代码中，Promise.all方法接受一个数组作为参数，p1、p2、p3都是 Promise 实例，如果不是，就会先调用Promise.resolve方法，将参数转为 Promise 实例，再进一步处理。（Promise.all方法的参数可以不是数组，但必须具有 Iterator 接口，且返回的每个成员都是 Promise 实例。）

p的状态由p1、p2、p3决定，分成两种情况。

1.  只有p1、p2、p3的状态都变成fulfilled，p的状态才会变成fulfilled，此时p1、p2、p3的返回值组成一个数组，传递给p的回调函数。

2.  只要p1、p2、p3之中有一个被rejected，p的状态就变成rejected，此时第一个被reject的实例的返回值，会传递给p的回调函数。

Promise.race方法同样是将多个 Promise 实例，包装成一个新的 Promise 实例。
```js
const p = Promise.race([p1, p2, p3]);
```
上面代码中，只要p1、p2、p3之中有一个实例率先改变状态，p的状态就跟着改变。那个率先改变的 Promise 实例的返回值，就传递给p的回调函数。

Promise.race方法的参数与Promise.all方法一样，如果不是 Promise 实例，就会先调用下面讲到的Promise.resolve方法，将参数转为 Promise 实例，再进一步处理。

下面是一个例子，如果指定时间内没有获得结果，就将 Promise 的状态变为reject，否则变为resolve。
```js
const p = Promise.race([
  fetch('/resource-that-may-take-a-while'),
  new Promise(function (resolve, reject) {
    setTimeout(() => reject(new Error('request timeout')), 5000)
  })
]);

p
.then(console.log)
.catch(console.error);
```

有时需要将现有对象转为 Promise 对象，Promise.resolve方法就起到这个作用。Promise.resolve方法的参数分成四种情况。
-   如果参数是 Promise 实例，那么Promise.resolve将不做任何修改、原封不动地返回这个实例。
-   thenable对象指的是具有then方法的对象，Promise.resolve方法会将这个对象转为 Promise 对象，然后就立即执行thenable对象的then方法。
-   参数不是具有then方法的对象，或根本就不是对象.则Promise.resolve方法返回一个新的 Promise 对象，状态为resolved。
-   Promise.resolve()方法允许调用时不带参数，直接返回一个resolved状态的 Promise 对象。需要注意的是，立即resolve()的 Promise 对象，是在本轮“事件循环”（event loop）的结束时执行，而不是在下一轮“事件循环”的开始时。

Promise.reject(reason)方法也会返回一个新的 Promise 实例，该实例的状态为rejected。Promise.reject()方法的参数，会原封不动地作为reject的理由，变成后续方法的参数。这一点与Promise.resolve方法不一致。

Generator 函数与 Promise 的结合
```js
function getFoo () {
  return new Promise(function (resolve, reject){
    resolve('foo');
  });
}

const g = function* () {
  try {
    const foo = yield getFoo();
    console.log(foo);
  } catch (e) {
    console.log(e);
  }
};

function run (generator) {
  const it = generator();

  function go(result) {
    if (result.done) return result.value;

    return result.value.then(function (value) {
      return go(it.next(value));
    }, function (error) {
      return go(it.throw(error));
    });
  }

  go(it.next());
}

run(g);
```
上面代码的 Generator 函数g之中，有一个异步操作getFoo，它返回的就是一个Promise对象。函数run用来处理这个Promise对象，并调用下一个next方法。

Promise.try 无论同步异步都封装在try.then.catch的流程中执行

## Iterator 和 for ... of循环

JavaScript 原有的表示“集合”的数据结构，主要是数组（Array）和对象（Object），ES6 又添加了Map和Set。
  
遍历器（Iterator）它是一种接口，为各种不同的数据结构提供统一的访问机制。任何数据结构只要部署 Iterator 接口，就可以完成遍历操作（即依次处理该数据结构的所有成员）。

Iterator 的作用有三个：一是为各种数据结构，提供一个统一的、简便的访问接口；二是使得数据结构的成员能够按某种次序排列；三是 ES6 创造了一种新的遍历命令for...of循环，Iterator 接口主要供for...of消费。

Iterator 的遍历过程是这样的。

1.  创建一个指针对象，指向当前数据结构的起始位置。也就是说，遍历器对象本质上，就是一个指针对象。
2.  第一次调用指针对象的next方法，可以将指针指向数据结构的第一个成员。
3.  第二次调用指针对象的next方法，指针就指向数据结构的第二个成员。
4.  不断调用指针对象的next方法，直到它指向数据结构的结束位置。

每一次调用next方法，都会返回数据结构的当前成员的信息。具体来说，就是返回一个包含value和done两个属性的对象。其中，value属性是当前成员的值，done属性是一个布尔值，表示遍历是否结束。

ES6 规定，默认的 Iterator 接口部署在数据结构的Symbol.iterator属性，或者说，一个数据结构只要具有Symbol.iterator属性，就可以认为是“可遍历的”（iterable）。

Symbol.iterator属性本身是一个函数，就是当前数据结构默认的遍历器生成函数。执行这个函数，就会返回一个遍历器。至于属性名Symbol.iterator，它是一个表达式，返回Symbol对象的iterator属性，这是一个预定义好的、类型为 Symbol 的特殊值，所以要放在方括号内

```js
const obj = {
  [Symbol.iterator] : function () {
    return {
      next: function () {
        return {
          value: 1,
          done: true
        };
      }
    };
  }
};
```

有些场合会默认调用Iterator接口
1.  解构赋值
2.  扩展运算符
3.  yield* 后面跟的是一个可遍历的结构，它会调用该结构的遍历器接口。
4.  其他场合
    -   for...of
    -   Array.from()
    -   Map(), Set(), WeakMap(), WeakSet()（比如new Map([['a',1],['b',2]])）
    -   Promise.all()
    -   Promise.race()

遍历器对象除了具有next方法，还可以具有return方法和throw方法。如果你自己写遍历器对象生成函数，那么next方法是必须部署的，return方法和throw方法是否部署是可选的。

return方法的使用场合是，如果for...of循环提前退出（通常是因为出错，或者有break语句），就会调用return方法。如果一个对象在完成遍历前，需要清理或释放资源，就可以部署return方法。注意，return方法必须返回一个对象，这是 Generator 规格决定的。throw方法主要是配合 Generator 函数使用，一般的遍历器对象用不到这个方法。

使用 for ... of ,Set 结构遍历时，返回的是一个值，而 Map 结构遍历时，返回的是一个数组，该数组的两个成员分别为当前 Map 成员的键名和键值。

有些数据结构是在现有数据结构的基础上，计算生成的。比如，ES6 的数组、Set、Map 都部署了以下三个方法，调用后都返回遍历器对象。
-   entries() 返回一个遍历器对象，用来遍历[键名, 键值]组成的数组。对于数组，键名就是索引值；对于 Set，键名与键值相同。Map 结构的 Iterator 接口，默认就是调用entries方法。
-   keys() 返回一个遍历器对象，用来遍历所有的键名。
-   values() 返回一个遍历器对象，用来遍历所有的键值。


对于普通的对象，for...of结构不能直接使用，会报错，必须部署了 Iterator 接口后才能使用。但是，这样情况下，for...in循环依然可以用来遍历键名。一种解决方法是，使用Object.keys方法将对象的键名生成一个数组，然后遍历这个数组。另一个方法是使用 Generator 函数将对象重新包装一下。

for...in循环主要是为遍历对象而设计的，不适用于遍历数组。


## Generator语法

Generator是ES6提供的一种异步编程解决方案. 语法上可以理解成一个状态机,封装了多个内部状态.

形式上，Generator 函数是一个普通函数，但是有两个特征。一是，function关键字与函数名之间有一个星号；二是，函数体内部使用yield表达式，定义不同的内部状态

yield表达式 是一个暂停的标志,yield表达式后面的表达式，只有当调用next方法、内部指针指向该语句时才会执行，因此等于为 JavaScript 提供了手动的“惰性求值”（Lazy Evaluation）的语法功能。

Generator 函数可以不用yield表达式，这时就变成了一个单纯的暂缓执行函数。

yield表达式只能用在 Generator 函数里面，用在其他地方都会报错。

Generator 函数执行后，返回一个遍历器对象。该对象本身也具有Symbol.iterator属性，执行后返回自身。

yield表达式本身没有返回值，或者说总是返回undefined。next方法可以带一个参数，该参数就会被当作上一个yield表达式的返回值。

Generator 函数从暂停状态到恢复运行，它的上下文状态（context）是不变的。通过next方法的参数，就有办法在 Generator 函数开始运行之后，继续向函数体内部注入值。也就是说，可以在 Generator 函数运行的不同阶段，从外部向内部注入不同的值，从而调整函数行为。

V8 引擎直接忽略第一次使用next方法时的参数，只有从第二次使用next方法开始，参数才是有效的。从语义上讲，第一个next方法用来启动遍历器对象，所以不用带有参数。

Generator 函数返回的遍历器对象，都有一个throw方法，可以在函数体外抛出错误，然后在 Generator 函数体内捕获。
```js
var g = function* () {
  try {
    yield;
  } catch (e) {
    console.log('内部捕获', e);
  }
};

var i = g();
i.next();

try {
  i.throw('a');
  i.throw('b');
} catch (e) {
  console.log('外部捕获', e);
}
// 内部捕获 a
// 外部捕获 b
```
上面代码中，遍历器对象i连续抛出两个错误。第一个错误被 Generator 函数体内的catch语句捕获。i第二次抛出错误，由于 Generator 函数内部的catch语句已经执行过了，不会再捕捉到这个错误了，所以这个错误就被抛出了 Generator 函数体，被函数体外的catch语句捕获。注意，不要混淆遍历器对象的throw方法和全局的throw命令

Generator 函数返回的遍历器对象，还有一个return方法，可以返回给定的值，并且终结遍历 Generator 函数。

next()、throw()、return()这三个方法本质上是同一件事，可以放在一起理解。它们的作用都是让 Generator 函数恢复执行，并且使用不同的语句替换yield表达式。
-   next()是将yield表达式替换成一个值。
-   throw()是将yield表达式替换成一个throw语句。
-   return()是将yield表达式替换成一个return语句。

ES6 提供了yield*表达式，作为解决办法，用来在一个 Generator 函数里面执行另一个 Generator 函数。

```js
function* gen(){
  yield ["a", "b"];
  yield* ["a", "b"];
}
for(let i of gen()){
    console.log(i);
}
/*
(2) ["a", "b"]
a
b
/*
```
上面代码中，yield命令后面如果不加星号，返回的是整个数组，加了星号就表示返回的是数组的遍历器对象。

yield可以方便的去处嵌套的数组的所有成员
```js
function* iterTree(tree) {
  if (Array.isArray(tree)) {
    for(let i=0; i < tree.length; i++) {
      yield* iterTree(tree[i]);
    }
  } else {
    yield tree;
  }
}

const tree = [ 'a', ['b', 'c'], ['d', 'e'] ];

for(let x of iterTree(tree)) {
  console.log(x);
}
// a
// b
// c
// d
// e
[...iterTree(tree)] // ["a", "b", "c", "d", "e"]
```

下面是一个稍微复杂的例子，使用yield*语句遍历完全二叉树。

```js
// 下面是二叉树的构造函数，
// 三个参数分别是左树、当前节点和右树
function Tree(left, label, right) {
  this.left = left;
  this.label = label;
  this.right = right;
}

// 下面是中序（inorder）遍历函数。
// 由于返回的是一个遍历器，所以要用generator函数。
// 函数体内采用递归算法，所以左树和右树要用yield*遍历
function* inorder(t) {
  if (t) {
    yield* inorder(t.left);
    yield t.label;
    yield* inorder(t.right);
  }
}

// 下面生成二叉树
function make(array) {
  // 判断是否为叶节点
  if (array.length == 1) return new Tree(null, array[0], null);
  return new Tree(make(array[0]), array[1], make(array[2]));
}
let tree = make([[['a'], 'b', ['c']], 'd', [['e'], 'f', ['g']]]);

// 遍历二叉树
var result = [];
for (let node of inorder(tree)) {
  result.push(node);
}

result
// ['a', 'b', 'c', 'd', 'e', 'f', 'g']
```

如果一个对象的属性是 Generator 函数，可以简写成下面的形式。
```js
let obj = {
  * myGeneratorMethod() {
    ···
  }
};
```

Generator 函数总是返回一个遍历器，ES6 规定这个遍历器是 Generator 函数的实例，也继承了 Generator 函数的prototype对象上的方法。

```js
function* gen() {
  this.a = 1;
  yield this.b = 2;
  yield this.c = 3;
}

function F() {
  return gen.call(gen.prototype);
}

var f = new F();

f.next();  // Object {value: 2, done: false}
f.next();  // Object {value: 3, done: false}
f.next();  // Object {value: undefined, done: true}

f.a // 1
f.b // 2
f.c // 3
```

 JavaScript 是单线程语言，只能保持一个调用栈.引入协程以后，每个任务可以保持自己的调用栈。这样做的最大好处，就是抛出错误的时候，可以找到原始的调用栈。不至于像异步操作的回调函数那样，一旦出错，原始的调用栈早就结束。
 
 Generator 函数是 ES6 对协程的实现，但属于不完全实现。Generator 函数被称为“半协程”（semi-coroutine），意思是只有 Generator 函数的调用者，才能将程序的执行权还给 Generator 函数。如果是完全执行的协程，任何函数都可以让暂停的协程继续执行。
 
 如果将 Generator 函数当作协程，完全可以将多个需要互相协作的任务写成 Generator 函数，它们之间使用yield表达式交换控制权。
 
 Generator 可以暂停函数执行，返回任意表达式的值。这种特点使得 Generator 有多种应用场景。
 1. 异步操作的同步化表达
 
 Generator 函数的暂停执行的效果，意味着可以把异步操作写在yield表达式里面，等到调用next方法时再往后执行。这实际上等同于不需要写回调函数了，因为异步操作的后续操作可以放在yield表达式下面，反正要等到调用next方法时再执行。所以，Generator 函数的一个重要实际意义就是用来处理异步操作，改写回调函数。
 ```js
 function* loadUI() {
  showLoadingScreen();
  yield loadUIDataAsynchronously();
  hideLoadingScreen();
}
var loader = loadUI();
// 加载UI
loader.next()

// 卸载UI
loader.next()
 ```
上面代码中，第一次调用loadUI函数时，该函数不会执行，仅返回一个遍历器。下一次对该遍历器调用next方法，则会显示Loading界面（showLoadingScreen），并且异步加载数据（loadUIDataAsynchronously）。等到数据加载完成，再一次使用next方法，则会隐藏Loading界面。可以看到，这种写法的好处是所有Loading界面的逻辑，都被封装在一个函数，按部就班非常清晰。

2.  控制流管理
3.  部署 Iterator 接口 , 利用 Generator 函数，可以在任意对象上部署 Iterator 接口
4.  Generator 可以看作是数据结构，更确切地说，可以看作是一个数组结构，因为 Generator 函数可以返回一系列的值，这意味着它可以对任意表达式，提供类似数组的接口。

```js
//如果有一个多步操作非常耗时，采用回调函数
step1(function (value1) {
  step2(value1, function(value2) {
    step3(value2, function(value3) {
      step4(value3, function(value4) {
        // Do something with value4
      });
    });
  });
});
//使用Promise
Promise.resolve(step1)
  .then(step2)
  .then(step3)
  .then(step4)
  .then(function (value4) {
    // Do something with value4
  }, function (error) {
    // Handle any error from step1 through step4
  })
  .done();
//使用 Generator
function* longRunningTask(value1) {
  try {
    var value2 = yield step1(value1);
    var value3 = yield step2(value2);
    var value4 = yield step3(value3);
    var value5 = yield step4(value4);
    // Do something with value4
  } catch (e) {
    // Handle any error from step1 through step4
  }
}
//Generator 下 使用一个函数，按次序自动执行所有步骤。 所有task只能是同步
scheduler(longRunningTask(initialValue));

function scheduler(task) {
  var taskObj = task.next(task.value);
  // 如果Generator函数未结束，就继续调用
  if (!taskObj.done) {
    task.value = taskObj.value
    scheduler(task);
  }
}
//todo  

```

Generator 函数可以暂停执行和恢复执行，这是它能封装异步任务的根本原因。除此之外，它还有两个特性，使它可以作为异步编程的完整解决方案：函数体内外的数据交换和错误处理机制。
next返回值的 value 属性，是 Generator 函数向外输出数据；next方法还可以接受参数，向 Generator 函数体内输入数据。Generator 函数内部还可以部署错误处理代码，捕获函数体外抛出的错误。

thunk函数是自动执行 Generator函数的一种方法 , 它是“传名调用”的一种实现策略，用来替换某个表达式。

JavaScript 语言是传值调用，它的 Thunk 函数含义有所不同。在 JavaScript 语言中，Thunk 函数替换的不是表达式，而是多参数函数，将其替换成一个只接受回调函数作为参数的单参数函数。

任何函数，只要参数有回调函数，就能写成 Thunk 函数的形式。下面是一个简单的 Thunk 函数转换器。
```js
const Thunk = function(fn) {
  return function (...args) {
    return function (callback) {
      return fn.call(this, ...args, callback);
    }
  };
};
```

以读取文件为例。下面的 Generator 函数封装了两个异步操作。

```
var fs = require('fs');
var thunkify = require('thunkify');
var readFileThunk = thunkify(fs.readFile);

var gen = function* (){
  var r1 = yield readFileThunk('/etc/fstab');
  console.log(r1.toString());
  var r2 = yield readFileThunk('/etc/shells');
  console.log(r2.toString());
};
```
上面代码中，yield命令用于将程序的执行权移出 Generator 函数，那么就需要一种方法，将执行权再交还给 Generator 函数。这种方法就是 Thunk 函数，因为它可以在回调函数里，将执行权交还给 Generator 函数。为了便于理解，我们先看如何手动执行上面这个 Generator 函数。
```js
var g = gen();

var r1 = g.next();
r1.value(function (err, data) {
  if (err) throw err;
  var r2 = g.next(data);
  r2.value(function (err, data) {
    if (err) throw err;
    g.next(data);
  });
});
```

co模块, Generator 函数只要传入co函数，就会自动执行, 函数会返回一个promise对象,因此可以用then方法添加回调函数.
```js
var gen = function* () {
    ...
}
var co = require('co');
co(gen).then(function (){
  console.log('Generator 函数执行完成');
});
```
co 模块其实就是将两种自动执行器（Thunk 函数和 Promise 对象），包装成一个模块。使用 co 的前提条件是，Generator 函数的yield命令后面，只能是 Thunk 函数或 Promise 对象。

## async

async函数是 Generator 函数的语法糖。进一步说，async函数完全可以看作多个异步操作，包装成的一个 Promise 对象，而await命令就是内部then命令的语法糖。

对 Generator 函数的改进，体现在以下四点。

-   内置执行器 : Generator 函数的执行必须靠执行器，所以才有了co模块，而async函数自带执行器。也就是说，async函数的执行，与普通函数一模一样，只要一行
-   更好的语义  :  async和await，比起星号和yield，语义更清楚了。async表示函数里有异步操作，await表示紧跟在后面的表达式需要等待结果。
-   更广的适用性 : co模块约定，yield命令后面只能是 Thunk 函数或 Promise 对象，而async函数的await命令后面，可以是 Promise 对象和原始类型的值（数值、字符串和布尔值，但这时会自动转成立即 resolved 的 Promise 对象）
-   返回值是 Promise : async函数的返回值是 Promise 对象，这比 Generator 函数的返回值是 Iterator 对象方便多了。你可以用then方法指定下一步的操作。

async函数返回一个 Promise 对象，可以使用then方法添加回调函数。当函数执行的时候，一旦遇到await就会先返回，等到异步操作完成，再接着执行函数体内后面的语句。

async 函数有多种使用形式。
```js
// 函数声明
async function foo() {}

// 函数表达式
const foo = async function () {};

// 对象的方法
let obj = { async foo() {} };
obj.foo().then(...)

// Class 的方法
class Storage {
  constructor() {
    this.cachePromise = caches.open('avatars');
  }

  async getAvatar(name) {
    const cache = await this.cachePromise;
    return cache.match(`/avatars/${name}.jpg`);
  }
}

const storage = new Storage();
storage.getAvatar('jake').then(…);

// 箭头函数
const foo = async () => {};
```

async函数内部return语句返回的值，会成为then方法回调函数的参数。async函数内部抛出错误，会导致返回的 Promise 对象变为reject状态。抛出的错误对象会被catch方法回调函数接收到。
```js
async function f(isError) {
  if(isError) throw new Error('error');
  return 'hello world';
}

f(isError).then(
  v => console.log(v),
  e => console.log(e)
  )
```

async函数返回的 Promise 对象，必须等到内部所有await命令后面的 Promise 对象执行完，才会发生状态改变，除非遇到return语句或者抛出错误。也就是说，只有async函数内部的异步操作执行完，才会执行then方法指定的回调函数。任何一个await语句后面的 Promise 对象变为reject状态，那么整个async函数都会中断执行。

我们希望即使前一个异步操作失败，也不要中断后面的异步操作。这时可以将第一个await放在try...catch结构里面，这样不管这个异步操作是否成功，第二个await都会执行。另一种方法是await后面的 Promise 对象再跟一个catch方法，处理前面可能出现的错误。

await命令后面是一个 Promise 对象，返回该对象的结果。如果不是 Promise 对象，就直接返回对应的值。另一种情况是，await命令后面是一个thenable对象（即定义then方法的对象），那么await会将其等同于 Promise 对象。

如果await后面的异步操作出错，那么等同于async函数返回的 Promise 对象被reject。

多个await命令后面的异步操作，如果不存在继发关系，最好让它们同时触发。await命令只能用在async函数之中，如果用在普通函数，就会报错

目前，esm模块加载器支持顶层await，即await命令可以不放在 async 函数里面，直接使用。

```js
// async 函数的写法
const start = async () => {
  const res = await fetch('google.com');
  return res.text();
};

start().then(console.log);

// 顶层 await 的写法 (脚本必须使用esm加载器，才会生效。)
const res = await fetch('google.com');
console.log(await res.text());
```

async 函数可以保留运行堆栈。
```js
const a = () => {
  b().then(() => c());
};
```
上面代码中，函数a内部运行了一个异步任务b()。当b()运行的时候，函数a()不会中断，而是继续执行。等到b()运行结束，可能a()早就运行结束了，b()所在的上下文环境已经消失了。如果b()或c()报错，错误堆栈将不包括a()。

现在将这个例子改成async函数。下面代码中，b()运行的时候，a()是暂停执行，上下文环境都保存着。一旦b()或c()报错，错误堆栈将包括a()。
```js
const a = async () => {
  await b();
  c();
};
```

async 函数的实现原理，就是将 Generator 函数和自动执行器，包装在一个函数里。
```js
async function fn(args) {
  // ...
}

// 等同于

function fn(args) {
  return spawn(function* () {
    // ...
  });
}
//下面给出spawn函数的实现，基本就是前文自动执行器的翻版。
function spawn(genF) {
  return new Promise(function(resolve, reject) {
    const gen = genF();
    function step(nextF) {
      let next;
      try {
        next = nextF();
      } catch(e) {
        return reject(e);
      }
      if(next.done) {
        return resolve(next.value);
      }
      Promise.resolve(next.value).then(function(v) {
        step(function() { return gen.next(v); });
      }, function(e) {
        step(function() { return gen.throw(e); });
      });
    }
    step(function() { return gen.next(undefined); });
  });
}
```

假定某个 DOM 元素上面，部署了一系列的动画，前一个动画结束，才能开始后一个。如果当中有一个动画出错，就不再往下执行，返回上一个成功执行的动画的返回值。

```js
//promise
function chainAnimationsPromise(elem, animations) {

  // 变量ret用来保存上一个动画的返回值
  let ret = null;

  // 新建一个空的Promise
  let p = Promise.resolve();

  // 使用then方法，添加所有动画
  for(let anim of animations) {
    p = p.then(function(val) {
      ret = val;
      return anim(elem);
    });
  }

  // 返回一个部署了错误捕捉机制的Promise
  return p.catch(function(e) {
    /* 忽略错误，继续执行 */
  }).then(function() {
    return ret;
  });
}

// Generator
function chainAnimationsGenerator(elem, animations) {

  return spawn(function*() {
    let ret = null;
    try {
      for(let anim of animations) {
        ret = yield anim(elem);
      }
    } catch(e) {
      /* 忽略错误，继续执行 */
    }
    return ret;
  });

}

//async 
async function chainAnimationsAsync(elem, animations) {
  let ret = null;
  try {
    for(let anim of animations) {
      ret = await anim(elem);
    }
  } catch(e) {
    /* 忽略错误，继续执行 */
  }
  return ret;
}
```

ES2018 引入了“异步遍历器”（Async Iterator），为异步操作提供原生的遍历器接口，即value和done这两个属性都是异步产生。异步遍历器的最大的语法特点，就是调用遍历器的next方法，返回的是一个 Promise 对象。

对象的异步遍历器接口，部署在Symbol.asyncIterator属性上面。不管是什么样的对象，只要它的Symbol.asyncIterator属性有值，就表示应该对它进行异步遍历。

由于异步遍历器的next方法，返回的是一个 Promise 对象。因此，可以把它放在await命令后面。

for await...of循环，则是用于遍历异步的 Iterator 接口。

## class

ES6 的class可以看作只是一个语法糖，它的绝大部分功能，ES5 都可以做到，新的class写法只是让对象原型的写法更加清晰、更像面向对象编程的语法而已。

toString方法是Point类内部定义的方法，它是不可枚举的。

constructor方法是类的默认方法，通过new命令生成对象实例时，自动调用该方法。一个类必须有constructor方法，如果没有显式定义，一个空的constructor方法会被默认添加。

constructor方法默认返回实例对象（即this），完全可以指定返回另外一个对象。

实例的属性除非显式定义在其本身（即定义在this对象上），否则都是定义在原型上（即定义在class上）。

类的所有实例共享一个原型对象。

在“类”的内部可以使用get和set关键字，对某个属性设置存值函数和取值函数，拦截该属性的存取行为。

存值函数和取值函数是设置在属性的 Descriptor 对象上的。

类的属性名，可以采用表达式。也可以采用 Class 表达式，可以写出立即执行的 Class。

注意点: 
类和模块的内部，默认就是严格模式.
必须保证子类在父类之后定义。
ES6 的类只是 ES5 的构造函数的一层包装，所以函数的许多特性都被Class继承，包括name属性。如果某个方法之前加上星号（*），就表示该方法是一个 Generator 函数. 类的方法内部如果含有this，它默认指向类的实例。但是，必须非常小心，一旦单独使用该方法，很可能报错。

```js
//使用箭头函数保留this
class Obj {
  constructor() {
    this.me = () => this;
  }
}

const myObj = new Obj();
myObj.me() === myObj // true
//使用Proxy，获取方法的时候，自动绑定this。
function selfish (target) {
  const cache = new WeakMap();
  const handler = {
    get (target, key) {
      const value = Reflect.get(target, key);
      if (typeof value !== 'function') {
        return value;
      }
      if (!cache.has(value)) {
        cache.set(value, value.bind(target));
      }
      return cache.get(value);
    }
  };
  const proxy = new Proxy(target, handler);
  return proxy;
}

const logger = selfish(new Logger());
```

给类定义的方法面前增加static表示这个是通过类直接调用的，如果这个静态方法中包含了this关键字，这个this指的就是类，而不是实例.

父类的静态方法可以被子类继承,父类的静态方法可以被子类通过super来调用.

实例属性除了定义在constructor方法里面的this上 也可以定义在类的最顶层

静态属性指的是class本身的属性,即 Class.propName , 而不是定义在实例对象this上的属性

ES6 为new命令引入了一个new.target属性，该属性一般用在构造函数之中，返回new命令作用于的那个构造函数。如果构造函数不是通过new命令或Reflect.construct()调用的，new.target会返回undefined，因此这个属性可以用来确定构造函数是怎么调用的。

Class 内部调用new.target，返回当前 Class。子类继承父类时，new.target会返回子类。
```js
//虚类的写法
class Shape {
  constructor() {
    if (new.target === Shape) {
      throw new Error('本类不能实例化');
    }
  }
}
```

class 可以通过extends关键字来继承,子类必须在constructor方法中调用super方法，否则新建实例时会报错。这是因为子类自己的this对象，必须先通过父类的构造函数完成塑造，得到与父类同样的实例属性和方法，然后再对其进行加工，加上子类自己的实例属性和方法。如果不调用super方法，子类就得不到this对象。

这是因为子类自己的this对象，必须先通过父类的构造函数完成塑造，得到与父类同样的实例属性和方法，然后再对其进行加工，加上子类自己的实例属性和方法。如果不调用super方法，子类就得不到this对象。

在子类的构造函数中，只有调用super之后，才可以使用this关键字，否则会报错。

Object.getPrototypeOf方法可以用来从子类上获取父类。

super这个关键字，既可以当作函数使用，也可以当作对象使用。super作为函数调用时，代表父类的构造函数。ES6 要求，子类的构造函数必须执行一次super函数。作为函数时，super()只能用在子类的构造函数之中，用在其他地方就会报错。super作为对象时，在普通方法中，指向父类的原型对象；在静态方法中，指向父类。由于super指向父类的原型对象，所以定义在父类实例上的方法或属性，是无法通过super调用的。

ES6 规定，在子类普通方法中通过super调用父类的方法时，方法内部的this指向当前的子类实例。由于this指向子类实例，所以如果通过super对某个属性赋值，这时super就是this，赋值的属性会变成子类实例的属性。如果super作为对象，用在静态方法之中，这时super将指向父类，而不是父类的原型对象。在子类的静态方法中通过super调用父类的方法时，方法内部的this指向当前的子类，而不是子类的实例。使用super的时候，必须显式指定是作为函数、还是作为对象使用，否则会报错。由于对象总是继承其他对象的，所以可以在任意一个对象中，使用super关键字。

Class 作为构造函数的语法糖，同时有prototype属性和\_\_proto__属性，因此同时存在两条继承链。
-   子类的\_\_proto__属性，表示构造函数的继承，总是指向父类。
-   子类prototype属性的\_\_proto__属性，表示方法的继承，总是指向父类的prototype属性

这两条继承链，可以这样理解：作为一个对象，子类（B）的原型（__proto__属性）是父类（A）；作为一个构造函数，子类（B）的原型对象（prototype属性）是父类的原型对象（prototype属性）的实例。

extends关键字后面可以跟多种类型的值。

```js
//A继承 Object
class A extends Object {
}

A.__proto__ === Object // true
A.prototype.__proto__ === Object.prototype // true
//没有任何继承
class A {
}

A.__proto__ === Function.prototype // true
A.prototype.__proto__ === Object.prototype // true
```

ES6 允许继承原生构造函数定义子类，因为 ES6 是先新建父类的实例对象this，然后再用子类的构造函数修饰this，使得父类的所有行为都可以继承。

下面是一个自定义Error子类的例子，可以用来定制报错时的行为。
```js
class ExtendableError extends Error {
  constructor(message) {
    super();
    this.message = message;
    this.stack = (new Error()).stack;
    this.name = this.constructor.name;
  }
}

class MyError extends ExtendableError {
  constructor(m) {
    super(m);
  }
}

var myerror = new MyError('ll');
myerror.message // "ll"
myerror instanceof Error // true
myerror.name // "MyError"
myerror.stack
// Error
//     at MyError.ExtendableError
//     ...
```

ES6 改变了Object构造函数的行为，一旦发现Object方法不是通过new Object()这种形式调用，ES6 规定Object构造函数会忽略参数。

Mixin 指的是多个对象合成一个新的对象，新对象具有各个组成成员的接口



## module

ES6 的模块自动采用严格模式, 顶层的this指向undefined，即不应该在顶层代码使用this。

ES6 模块 功能主要由2个命令构成:export和import。export命令用于规定模块的对外接口，import命令用于输入其他模块提供的功能。

export输出的变量就是本来的名字，但是可以使用as关键字重命名。

```js
function v1() { ... }
function v2() { ... }

export {
  v1 as streamV1,
  v2 as streamV2,
  v2 as streamLatestVersion
};
```

export命令规定的是对外的接口，必须与模块内部的变量建立一一对应关系。

import后面的from指定模块文件的位置，可以是相对路径，也可以是绝对路径，.js后缀可以省略。如果只是模块名，不带有路径，那么必须有配置文件，告诉 JavaScript 引擎该模块的位置。

import命令是编译阶段执行的，在代码运行之前。由于import是静态执行，所以不能使用表达式和变量，这些只有在运行时才能得到结果的语法结构。

通过 Babel 转码，CommonJS 模块的require命令和 ES6 模块的import命令，可以写在同一个模块里面，但是最好不要这样做。因为import在静态解析阶段执行，所以它是一个模块之中最早执行的。

除了指定加载某个输出值，还可以使用整体加载，即用星号（*）指定一个对象，所有输出值都加载在这个对象上面。

export default 为模块指定默认输出  
一个模块只能有一个默认输出，因此export default命令只能使用一次。所以，import命令后面才不用加大括号，因为只可能唯一对应export default命令。

require是运行时加载模块，import命令无法取代require的动态加载功能。

浏览器加载 ES6 模块，也使用<script>标签，但是要加入type="module"属性。

浏览器对于带有type="module"的<script>，都是异步加载，不会造成堵塞浏览器，即等到整个页面渲染完，再执行模块脚本，等同于打开了<script>标签的defer属性。

如果网页有多个<script type="module">，它们会按照在页面出现的顺序依次执行。

es6和 commonjs区别 :
-   CommonJS 模块输出的是一个值的拷贝，ES6 模块输出的是值的引用。
-   CommonJS 模块是运行时加载，ES6 模块是编译时输出接口。

 CommonJS 加载的是一个对象（即module.exports属性），该对象只有在脚本运行完才会生成。而 ES6 模块不是对象，它的对外接口只是一种静态定义，在代码静态解析阶段就会生成。
 
 
# 前言

[zh-doc](https://www.html.cn/doc/sass/#syntax)

Sass 是一个 CSS 的扩展，它在 CSS 语法的基础上，允许您使用变量 (variables), 嵌套规则 (nested rules), 混合 (mixins), 导入 (inline imports) 等功能，令 CSS 更加强大与优雅。使用 Sass 以及 Compass 样式库 有助于更好地组织管理样式文件，以及更高效地开发项目。

# css extensions

## 嵌套规则 (Nested Rules)

Sass 允许将一个 CSS样式嵌套进另一个样式中，内层样式仅适用于外层样式的选择器范围内。 这有助于避免父选择器重复，相对于复杂的CSS布局中多层嵌套的选择器 要简单得多。

## 引用父选择器:& (Referencing Parent Selectors: &)

&将替换为呈现在CSS文件中的父选择器。这意味着，如果你有一个多层嵌套的规则，父选择器将在被&替换之前完全分解。 

& 必须出现在的选择器的开头位置（注：也就是作为选择器的第一个字符），但可以跟随后缀，将被添加到父选择的后面。

## 嵌套属性 (Nested Properties)

CSS中有一些属性遵循相同的“命名空间”；比如，font-family, font-size, 和 font-weight都在font命名空间中。在CSS中，如果你想在同一个命名空间中设置一串属性，你必须每次都输出来。Sass为此提供了一个快捷方式：只需要输入一次命名空间，然后在其内部嵌套子属性。命名空间也可以有自己的属性值。

# SassScript

## 变量: $（Variables: $ ）

```scss
$width: 5em;
#sidebar {
  width: $width;
}
```

##　数据类型

-   数字
-   文本字符
-   颜色
-   布尔值
-   空值
-   列表
-   字典



##  运算

-   数字运算
    -   除法的情况
        -   如果该值，或值的任何部分，存储在一个变量中或通过函数返回。
        -   如果该值是由括号括起来的，除非这些括号是在一个列表（list）外部，并且值是括号内部。
        -   如果该值被用作另一个算术表达式的一部分。
    -   减法运算
        -   减法时候，总是在 \- 两侧保留空格
        -   在表示一个负数或一元运算时，在\- 前面包含一个空格，后面不加空
        -   如果在一个空格隔开的list中，可以将一元运算使用括号括起来\(\-$var\)
    -   \-的不同含义
        -   \- 作为标识符的一部分， 唯一依赖就是单位
        -   \- 在不带空格两个数字之间，这表明是个减法
        -   字面数字以\-开头。表明是一个负数
        -   \- 两个数字之间，无论是否带空格都表明是减法
        -   \- 在值之前，表明是一元运算符；该操作需要一个数字，并返回其负值
-   颜色运算
    -   使用color函数
-   布尔运算
    -   and/or/not
-   列表运算
    -   使用list函数
-   圆括号
    -   可以用来影响运算的顺序(优先级)
-   函数 
    -   [参考](https://sass-lang.com/documentation/modules)

## 其他

###　插值 #{}

通过 #{} 插值语法在选择器和属性名中使用 SassScript 变量

### & in SassScript

和选择器中的效果一样，指向当前父选择器

```scss
.foo.bar .baz.bang, .bip.qux {
  $selector: &;
}
```
此时$selector的值是  ((".foo.bar" ".baz.bang"), ".bip.qux")

如果没有父选择器，&的值将是空。这意味着你可以在一个mixin中使用它来检测父选择是否存在：

```scss
@mixin does-parent-exist {
  @if & {
    &:hover {
      color: red;
    }
  } @else {
    a {
      color: red;
    }
  }
}
```

### 默认变量 !default

```scss
$new_content: "First time reference" !default;
```

# @规则 和 指令 (@-Rules and Directives)

## @import 

Sass 扩展了 CSS @import规则，允许其导入 SCSS 或 Sass 文件。被导入的全部SCSS 或 Sass文件将一起合并到同一个 CSS 文件中。此外，被导入文件中所定义的任何变量或混入（mixins）都可以在主文件（注：主文件值的是导入其他文件的文件，即，A文件中导入了B文件，这里的主文件指的就是A文件）中使用。Sass 支持在一个 @import 规则中同时导入多个文件。

注： 导入规则中可能含有\#\{\} 插值，但存在一定的限制。不能通过变量动态导入Sass文件；\#\{\}插值仅适用于CSS导入规则。 

```scss
$family: unquote("Droid+Sans");
@import url("http://fonts.googleapis.com/css?family=#{$family}");
// 将编译为
@import url("http://fonts.googleapis.com/css?family=Droid+Sans");
```

如果你有一个 SCSS 或 Sass 文件要导入，但不希望将其编译到一个CSS文件，你可以在文件名的开头添加一个下划线。

\@import指令只允许出现在文档顶层（注：最外层，不在嵌套规则内），像\@mixin 或者 \@charset，在文件中，不允许被\@import导入到一个嵌套上下文中。

不允许在混人 (mixin) 或控制指令 (control directives) 中嵌套 \@import。

## @media

Sass 中 @media 指令的行为和纯 CSS 中一样，只是增加了一点额外的功能：它们可以嵌套在CSS规则。如果一个@media 指令出现在CSS规则中，它将被冒泡到样式表的顶层，并且包含规则内所有的选择器。这使得很容易地添加特定media样式，而不需要重复使用选择器，或打乱样式表书写流。

## @extend

扩展，支持链式、多重、复杂选择器

略

## 输出

-   @debug
-   @warning
-   @error


# 控制指令和表达式（Control Directives & Expressions）

-   if\(\)  ： 三元
-   \@if    ：true则返回内容，false或null则不返回
-   \@else\\\@else if 跟在\@if后面
-   \@for   
    -   \@for $var from <start> through <end> 
    -   \@for $var from <start> to <end>
-   \@each
    -   \@each $var in <list or map>
-   @while

# mixin

混入(mixin)允许您定义可以在整个样式表中重复使用的样式，而避免了使用无语意的类（class），比如 .float-left。混入(mixin)还可以包含所有的CSS规则，以及任何其他在Sass文档中被允许使用的东西。 

-   定义：  \@mixin
-   引用：  \@include
-   参数：  混入（mixin）可以用 SassScript 值作为参数，给定的参数被包括在混入（mixin）中并且作为为变量提供给混入（mixin）。
-   关键字参数：    混入（mixin）在引入（@include指令）的时候也可以使用明确的关键字参数。
-   可变参数：参数在声明混入（mixin）或函数（function）结束的地方，所有剩余的参数打包成一个列表。
    -  使用keywords($args)函数访问
-  变量的作用域和内容块


# JavaScript 核心



### 基础语法

[Array \- JavaScript \| MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array)



[JavaScript 类型转换](https://www.runoob.com/js/js-type-conversion.html)

[JavaScript 使用误区 | 数据类型忽略| 浮点数相加](https://www.runoob.com/js/js-mistakes.html)

[Js是怎样运行起来的？](https://mp.weixin.qq.com/s/x3ysXnGHrZB4C0YvovlxAA?from=singlemessage&isappinstalled=0&scene=1&clicktime=1625536111&enterid=1625536111)



#### vue 覆盖 less

[Vue2\.0 style样式scoped使用less时样式穿透覆盖\_啃火龙果的兔子的博客\-CSDN博客](https://blog.csdn.net/qq_43592064/article/details/105833712)







## null  undefined

**何时使用null?**

当使用完一个比较大的对象时，需要对其进行释放内存时，设置为 null。

**3、null 与 undefined 的异同点是什么呢？**

**共同点**：都是原始类型，保存在栈中变量本地。

不同点：

（1）undefined——表示变量声明过但并未赋过值。

它是所有未赋值变量默认值，例如：

```
var a;    // a 自动被赋值为 undefined
```

（2）null——表示一个变量将来可能指向一个对象。

一般用于主动释放指向对象的引用，例如：

```
var emps = ['ss','nn'];
emps = null;     // 释放指向数组的引用
```

[JavaScript typeof, null, 和 undefined \| 菜鸟教程](https://www.runoob.com/js/js-typeof.html)


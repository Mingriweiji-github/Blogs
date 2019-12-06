[toc]

# SwiftTip

##1、@autoclosure作用：将表达式自动封装成一个闭包

()->Void

####1.2 ??的底层实现是用的enum

####1.3 “闭包和循环引用”

**weak解决循环引用的正确写法：**

```Swift

var name: ()->() = {

[weak self] in

if let strongSelf = self {

print("The name is (strongSelf.name)")

}

}

```

## 2、值类型和引用类型的选择

- 数组和字典设计为值类型最大的考虑是为了线程安全.

- 另一个优点，那就是非常高效，因为 "一旦赋值就不太会变化" 这种使用情景在 Cocoa 框架中是占有绝大多数的，这有效减少了内存的分配和回收。

但是在少数情况下，我们显然也可能会在数组或者字典中存储非常多的东西，并且还要对其中的内容进行添加或者删除。”

- 在需要处理大量数据并且频繁操作 (增减) 其中元素时，选择 NSMutableArray 和 NSMutableDictionary 会更好，

- 对于容器内条目小而容器本身数目多的情况，应该使用 Swift 语言内建的 Array 和 Dictionary

## 3、@escaping的作用？

```Swift

class func animate(withDuration duration: TimeInterval, animations: @escaping () -&gt; Void, completion: ((Bool) -> Void)? = nil)

```

<img src="/Users/mac/Downloads/图像 2019-12-5，下午6.41.jpg" alt="图像 2019-12-5，下午6.41" style="zoom:50%;" />

## 4、defer的使用注意点

#### defer的作用域

**以前很单纯地认为 defer 是在函数退出的时候调用，并没有注意其实是当前 scope 退出的时候调用这个事实，造成了这个错误。在 if，guard，for，try 这些语句中使用 defer 时，应该要特别注意这一点。**

<img src="/Users/mac/Downloads/图像 2019-12-5，下午6.41-1.jpg" alt="图像 2019-12-5，下午6.41-1" style="zoom:150%;" />



## 5、@discardableResult

## 6、Result<T>

[Result<T, E: Error> 和 Result<T>](https://onevcat.com/2018/10/swift-result-error/)

## 7、Lazy的使用

```Swift

let data = 1...3

let result = data.lazy.map { (i: Int) -> Int in

print("准备处理(i)")

return i * 2

}

print("准备访问结果")

for i in result {

print("处理后的结果:(i)")

}

print("done")

```

打印结果：

> 准备访问结果

准备处理1

处理后的结果:2

准备处理2

处理后的结果:4

准备处理3

处理后的结果:6

done

## 8、Swift反射机制Mirror

> “通过 Mirror 初始化得到的结果中包含的元素的描述都被集合在 children 属性下，如果你有心可以到 Swift 标准库中查找它的定义，它实际上是一个 Child 的集合，而 Child 则是一对键值的多元组：

### 示例1

```Swift

struct Car {

let logo: String

var wheel: Int

let door: Int

}

let baoM = Car(logo: "BMW", wheel: 4, door: 2)

let mirror = Mirror(reflecting: baoM)

print("类型:(String(describing: mirror.displayStyle))")

///1、通过Mirror的children获取属性信息

print("属性个数:(mirror.children.count)")

mirror.children.map { (child) -> Any in

print("label: (String(describing: child.label)), value: (child.value)")

}

///2、通过Refletion的dump(Any)方法获取属性信息

dump(baoM)

```

### 示例2 获取property

```Swift

let homeProperty = Mirror(reflecting: self)

homeProperty.children.map {

LOG.D("home property:($0)")

}

```

## 9、iOS初始化核心原则

> iOS 的初始化最核心两条的规则：

> • 必须至少有一个指定初始化器，在指定初始化器里保证所有非可选类型属性都得到正确的初始化（有值）

> • 便利初始化器必须调用其他初始化器，使得最后肯定会调用指定初始化器

在Swift中千万不要用String的count方法计算文本长度。否则当文本中有emoji时，会计算出错。应当转成NSString再去求length。

## 10、



## Swift备忘录001 Array for-in使用

<img src="/Users/mac/Library/Application Support/typora-user-images/image-20191205151814435.png" alt="image-20191205151814435" style="zoom:50%;" />

#### 1.for in获取索引 index

```Swift
				let array = ["Apple", "Google", "Amazon"]
        for item in array {
          print("company name is :(item)")
        }
        ///配合array.enumerated()使用
        for (index, item) in array.enumerated() {
            print("index:(index), item:(item)")
        }
```



#### 2.array.firstIndex(of:)获取index

```Swift
				///配合array.firstIndex(of:)使用
        let googleIndex = array.firstIndex(of: "Google")
        print("googleIndex is : (googleIndex ?? 0)")
				///配合array.firstIndex(where:)使用
        if let index = array.firstIndex(where: { $0.hasPrefix("A") }) {
            print("array.firstIndex is (index)")
        }
        if let item = array.first(where: { $0.hasPrefix("A")}{
            print("array.first is :(item)")
        }
```

## Swift备忘录002 Array.forEach()

#### 2.1forEach()和函数式编程结合使用

```swift
				let array = ["1", "2", "3", "4", "5", "6"]
        ///使用forEach
        array.map { Int($0)! }.forEach { num in
            print(num)
        }
        //不使用forEach
        let map = array.map { Int($0)! }
        map.forEach {
            print($0)
        }
```

#### 2.2forEach()遍历optional集合会自动过滤nil

```Swift
				let optionalString: [String]? = nil
        //使用forEach强制解包option，会过滤
        optionalString?.forEach { str in
            print("str is (str)")
        }
        ///使用for-in强制解包optional，会crash
        for str in optionalString! {
            print("str is (str)")
        }
```

## Swift备忘录003 Array index



#### 3.1




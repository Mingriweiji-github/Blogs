[toc]

# Swift必备 Tips

##1、闭包

### 1.1@autoclosure作用：将表达式自动封装成一个闭包

```Swift
()->Void
```

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

## 10、Array遍历获取index

## Array for-in使用

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

## Array.forEach()

#### 2.1forEach()和函数式编程结合使用

```swift
				let array = ["1", "2", "3", "4", "5", "6"]
        ///使用forEach
        array.map { Int($0)! }.forEach { num in
            print(num)
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

## 11.Swift单利写法

```Swift
class MyManager  {
    static let shared = MyManager()
    private init() {}
}

```

> “这种写法不仅简洁，而且保证了单例的独一无二。在初始化类变量的时候，Apple 将会把这个初始化包装在一次 swift_once_block_invoke 中，以保证它的唯一性。不仅如此，对于所有的全局变量，Apple 都会在底层使用这个类似 dispatch_once 的方式来确保只以 lazy 的方式初始化一次。”
>
> 摘录来自: 王巍 (onevcat). “Swifter - Swift 必备 Tips (第四版)。” Apple Books. 

## 12.条件编译设置

```Swift
@IBAction func someButtonPressed(sender: AnyObject!) {
    #if FREE_VERSION
        // 弹出购买提示，导航至商店等
    #else
        // 实际功能
    #endif
}
```



“我们需要在项目的编译选项中进行设置，在项目的 Build Settings 中，找到 Swift Compiler - Custom Flags，并在其中的 Other Swift Flags 加上 -D FREE_VERSION 就可以了。”

**路径：Build Settings -> Swift Compiler -> Custom Flags**



## 13. 内存管理 weak unowned

### weak 解除强引用

```Swift
weak var a: A? = nil
```

**Unowned 解除抢引用**

```Swift
unowned var a: A? = nil
```

> “在 Swift 中除了 weak 以外，还有另一个冲着编译器叫喊着类似的 "不要引用我" 的标识符，那就是 unowned。它们的区别在哪里呢？如果您是一直写 Objective-C 过来的，那么从表面的行为上来说 unowned 更像以前的 unsafe_unretained，而 weak 就是以前的 weak。

用通俗的话说，就是 unowned 设置以后即使它原来引用的内容已经被释放了，它仍然会保持对被已经释放了的对象的一个 "无效的" 引用，它不能是 Optional 值，也不会被指向 nil。如果你尝试调用这个引用的方法或者访问成员属性的话，程序就会崩溃。而 weak 则友好一些，在引用的内容被释放后，标记为 weak 的成员将会自动地变成 nil (因此被标记为 @weak 的变量一定需要是 Optional 值)。

**关于两者使用的选择，Apple 给我们的建议是如果能够确定在访问时不会已被释放的话，尽量使用 unowned，如果存在被释放的可能，那就选择用 weak。**

#### weak使用场景一：delegate
“以 weak 的方式持有了 delegate，因为网络请求是一个异步过程，很可能会遇到用户不愿意等待而选择放弃的情况。这种情况下一般都会将 RequestManager 进行清理，所以我们其实是无法保证在拿到返回时作为 delegate 的 RequestManager 对象是一定存在的。因此我们使用了 weak 而非 unowned，并在调用前进行了判断。”

#### weak使用场景二：闭包
“闭包的情况稍微复杂一些：我们首先要知道，闭包中对任何其他元素的引用都是会被闭包自动持有的。如果我们在闭包中写了 self 这样的东西的话，那我们其实也就在闭包内持有了当前的对象。这里就出现了一个在实际开发中比较隐蔽的陷阱：如果当前的实例直接或者间接地对这个闭包又有引用的话，就形成了一个 **self -> 闭包 -> self** 的循环引用。”

```Swift
lazy var printName: ()->() = {[weak self] in
    if let strongSelf = self {
        print("The name is \(strongSelf.name)")
    }
}
```

这种在闭包参数的位置进行标注的语法结构是将要标注的内容放在原来参数的前面，并使用中括号括起来。如果有多个需要标注的元素的话，在同一个中括号内用逗号隔开，举个例子：

```Swift
// 标注前
{ (number: Int) -> Bool in
    //...
    return true
}

// 标注后
{ [unowned self, weak someObject] (number: Int) -> Bool in
    //...
    return true
}
```

## 14.Swift中使用autoreleasePoll

**Apple定义**

```swift
public func autoreleasepool<Result>(invoking body: () throws -> Result) rethrows -> Result

```

使用autoreleasepool闭包

```Swift
autoreleasepool {

}
```

## 15、值类型最佳实践

首先我们需要知道，Swift 的值类型，特别是数组和字典这样的容器，在内存管理上经过了精心的设计。**值类型的一个特点是在传递和赋值时进行复制**，每次复制肯定会产生额外开销，**但是在 Swift 中这个消耗被控制在了最小范围内，在没有必要复制的时候，值类型的复制都是不会发生的。也就是说，简单的赋值，参数的传递等等普通操作**，虽然我们可能用不同的名字来回设置和传递值类型，但是在内存上它们都是同一块内容。



为什么是值类型？

将数组和字典设计为**值类型最大的考虑是为了线程安全**，但是这样的设计在存储的元素或条目数量较少时，给我们带来了**另一个优点，那就是非常高效，因为 "一旦赋值就不太会变化" 这种使用情景在 Cocoa 框架中是占有绝大多数的，这有效减少了内存的分配和回收。**但是在少数情况下，我们显然也可能会在数组或者字典中存储非常多的东西，并且还要对其中的内容进行添加或者删除。在这时，Swift 内建的值类型的容器类型在每次操作时都需要复制一遍，即使是存储的都是引用类型，在复制时我们还是需要存储大量的引用，这个开销就变得不容忽视了。幸好我们还有 Cocoa 中的引用类型的容器类来对应这种情况，那就是 NSMutableArray 和 NSMutableDictionary。

#### 值类型最佳实践

**使用数组和字典时的最佳实践应该是，按照具体的数据规模和操作特点来决定到时是使用值类型的容器还是引用类型的容器：**

**1. 对于容器内条目小而容器本身数目多的情况，应该使用 Swift 语言内建的 Array 和 Dictionary。**

**2. 在需要处理大量数据并且频繁操作 (增减) 其中元素时，选择 NSMutableArray 和 NSMutableDictionary **

## 1、Range还是NSRange?

**1、将NSRange转成Range**

```Swift
extension String {
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
}
```

```Swift
let str = "Apple"
let nsRange = NSRange(location: 1, length: 2)
let newStr = str.replacingCharacters(in: str.toRange(nsRange)!, with: "bb")
print("newStr is \(newStr)") // Abble

```

replace字符串指定range为我们想要的字符串

## 1、String还是NSString?

    ```Swift
//or use NSString

let nsString = (str as NSString).replacingCharacters(in: nsRange, with: "bb")
print("nsString is \(nsString)") // Abble
    ```

## 18.UnsafeMutablePointer

**创建使用allocate+initialize**

```Swift
struct Pointer {
    let x: Double
    let y: Double
}
extension Pointer {
func toPointer() -> Pointer {
  return Pointer(x: self.x, y: self.y)
}

func toUnsafePointer() -> UnsafeMutablePointer<Pointer> {
  let pointer = UnsafeMutablePointer<Pointer>.allocate(capacity: 1)
  pointer.initialize(to: toPointer())
  return pointer
}
}
```

**销毁** deinitialize + deallocate

```Swift
let pointer = Pointer(x: 100.0, y: 112.0)
let unsafe = pointer.toUnsafePointer()

print("unsafe.pointee=\(unsafe.pointee)") 
// unsafe.pointee=Pointer(x: 100.0, y: 112.0)
 
unsafe.deinitialize(count: 1)
unsafe.deallocate()
```

## 19. GCD与延迟调用

```Swift
let workQueue = DispatchQueue.init(label: "workQueue")

workQueue.async {
    print("work")
    Thread.sleep(forTimeInterval: 3)

    DispatchQueue.main.async {
        print("main update UI")
    }
}

```

延迟调用delay

```Swift
    // MARK: - GCD

    typealias Task = (_ cancel : Bool) -> Void

    func delay(_ time: TimeInterval, task: @escaping ()->()) ->  Task? {

        func dispatch_later(block: @escaping ()->()) {
            let t = DispatchTime.now() + time
            DispatchQueue.main.asyncAfter(deadline: t, execute: block)
        }
        
        var closure: (()->Void)? = task
        var result: Task?

        let delayedClosure: Task = {
            cancel in
            if let internalClosure = closure {
                if (cancel == false) {
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }

        result = delayedClosure

        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }

        return result;
        
    }

    func cancel(_ task: Task?) {
        task?(true)
    }

```

```Swift
let task = delay(3) {
    print("delay 3 sec")
}

///仔细想想需要取消么？
cancel(task)


```



## 20.
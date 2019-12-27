[toc]
# Functional Programming in Swift

函数式编程介绍。版本：Swift 4.2, iOS 12, Xcode 10

在本部分中，您将介绍FP中的一些关键概念。许多讨论FP的论文都将不变状态和缺乏副作用视为FP的最重要方面，因此您将从这里开始。

## 不变性和副作用



无论您首先学习哪种编程语言，您可能要学习的最初概念之一就是变量代表数据或状态。如果您退一步考虑一下这个想法，变量似乎很奇怪。

术语“变量”表示随程序运行而变化的数量。从数学角度考虑数量问题，您已将时间作为软件行为的关键参数。通过更改变量，可以创建可变状态。



为了进行演示，请将以下代码添加到playground：

```Swift
var thing = 3
//some stuff
thing = 4

func superHero() {
  print("I'm batman")
  thing = 5
}

print("original state = \(thing)")
superHero()
print("mutated state = \(thing)")
```



神圣的神秘变化！为什么现在是5？这种变化称为副作用。函数superHero（）更改了一个甚至没有定义自己的变量。

单独或在简单系统中，可变状态不一定是问题。将许多对象连接在一起时（例如在大型的面向对象的系统中）会出现问题。可变状态会使人难以理解变量具有什么值以及该值随时间的变化而产生头痛。

例如，在为多线程系统编写代码时，如果两个或多个线程**同时访问同一变量**，则它们可能会**无序地修改或访问它**。这会导致意外的行为。**这种意外行为包括竞态条件，死锁和许多其他问题。**

试想一下，如果您可以编写状态永远不变的代码。并发系统中发生的所有问题都将消失。像这样工作的系统具有**不变的状态**，这意味着不允许状态在程序过程中进行更改。

使用不可变数据的主要好处是，使用不可变数据的代码单元没有副作用。代码中的函数不会更改其自身之外的元素，并且在发生函数调用时不会出现怪异的效果。您的程序可以正常运行，因为没有副作用，您可以轻松重现其预期的效果。

本教程从较高的层次介绍了FP，因此在实际情况下考虑这些概念会很有帮助。在这种情况下，假设您正在为游乐园构建应用程序，并且该游乐园的后端服务器通过REST API提供了行程数据。

## 创建Model

```Swift
enum RideCategory: String {
  case family
  case kids
  case thrill
  case scary
  case relaxing
  case water
}

typealias Minutes = Double
struct Ride {
  let name: String
  let categories: Set<RideCategory>
  let waitTime: Minutes
}

```

## Create some data using that model
```Swift
let parkRides = [
          Ride(name: "R45",
               categories: [.family, .thrill, .water],
               waitTime: 45.0),
          Ride(name: "R10", categories: [.family], waitTime: 10.0),
          Ride(name: "R15", categories: [.kids], waitTime: 15.0),
          Ride(name: "R30", categories: [.scary], waitTime: 30.0),
          Ride(name: "R60",
               categories: [.family, .thrill],
               waitTime: 60.0),
          Ride(name: "R15-2", categories: [.family, .kids], waitTime: 15.0),
          Ride(name: "R25", categories: [.family, .water], waitTime: 25.0),
          Ride(name: "R0",
               categories: [.family, .relaxing],
               waitTime: 0.0)
        ]
```
## 高阶函数: Filter Map Reduce

**Most languages that support FP will have the functions filter, map & reduce.**

### Map

> Map是将输入Collection中的每个Element转换为新Element。
>
> 使用map遍历一个集合，并对集合中的每个元素应用相同的操作。
>
>  map函数返回一个数组，其中包含对每个元素的映射或转换函数的结果。

#### map on array:
```Swift
let arrayOfInt = [1,2,3,4,5]
```
如果我们要对每个元素乘上10呢？我们以前可能要这样
```Swift
var newArr: [Int] = []
for value in arrayOfInt {
    newArr.append(value * 10)
}
print(newArr)
```
现在有map()后我们可以这样：
```Swift
let mapArr = arrayOfInt.map { $0 * 10 }
print(mapArr)
```
> Working of map: The map function has a single argument which is a closure (a function) that it calls as it loops over the collection. This closure takes the element from the collection as an argument and returns a result. The map function returns these results in an array.

#### map on nil 
> The output of map became a collection of optional int ([Int?]) only because the array had nil — value in it. Otherwise it would have been an Int array.
```Swift
 let array = [1, nil, 3, 4, nil]
 print(array.map{ $0 })
```
`print: [Optional(1), nil, Optional(3), Optional(4), nil]`
#### map on Dictionary

```Swift
let book = ["A": 100, "B": 80, "C": 90]
let mapedBook = book.map { (key, value) in
    key.capitalized
}
print(mapedBook) //["C", "B", "A"]

```
#### map on Set

```Swift
let lengthInmeter: Set = [1,3,5]
let km  = lengthInmeter.map { meter in meter * 1000 }
print(km) // [1000, 5000, 3000]

```



#### map同时获取array.Index ?

```Swift
let nums = [1,2,3,4,5]
let newNums = nums.enumerated().map { (index, num) in
    return num * 10
}
print("newNums:\(newNums)")

```
### Filter

Filter函数的作用是过滤集合，返回符合条件的集合。

#### ilter on Array

```Swift
let filterArray = [2,4,6,1,5,7]
let newFilterArray = filterArray.filter { num -> Bool in
    num % 2 == 0
}
print(newFilterArray)
```

#### filter on Dictionary

```Swift
let book = ["A": 100, "B": 80, "C": 90]
let bookFilter = book.filter { (key, value) in
    value > 80
}
print(bookFilter)
```

**简化**

```Swift
let book = ["A": 100, "B": 80, "C": 90]
let bookFilter = book.filter {
    $1 > 80
}
```

> $0是key
>
> $1是value

#### filter on Set

```Swift
let setNums = [4.9,5.5,8.6]
let newSet = setNums.filter {
    $0 > 5.0
}
print(newSet)
```

**重要：返回类型是数组**

### Reduce

> Use `reduce` to combine all items in a collection to create a single new value.

> 使用*reduce*可以合并集合中的所有元素来创建一个新的value

Apple文档声明reduce()

```Swift
func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result
```

**reduce**函数有两个参数：

- 第一个参数 **initial value**用来存储初始值或者结果（每次迭代器的结果）
- 第二个是带有两个参数的闭包，Result是初始值或迭代器的结果，Element是集合中的下一个元素。

#### educe on Array

```Swift
let numbers = [1,2,3,4,5,6]
let sum = numbers.reduce(0) { x, y in
    x + y
}
print(sum)
```

简化版本：使用$0代表result

```Swift
let reducedSum = numbers.reduce(0) { $0 + $1 }
print(reducedSum)
///等价
let reducedSum = numbers.reduce(0, +)
print(reducedSum)

```

乘法

```Swift
let produceNum = numbers.reduce(1) { x, y in
    x * y
}
print(produceNum)
///等价
let produceNum = numbers.reduce(1, *)
print(produceNum)

```

#### Reduce + 连接字符串

```Swift
let charactors = ["abc","def","hijk"]
let newCharactor = charactors.reduce("", +)
print(newCharactor) // abcdefhijk
```

#### reduce on Dictionary

```Swift

let dict = ["A": 20, "B": 100]

// Reduce on value
let reducedNum = dict.reduce(5) { result, dic in
    return result + dic.value
}
print("reduc on value is \(reducedNum)") 
// reduc on value is 125

// Reduce on key
let reducedName = dict.reduce("Charactor are ") { (result, dic) in
    return result + dic.key + " "
}
print("reduce on key is <\(reducedName)>") 
//reduce on key is <Charactor are A B >

```

简化

```Swift

let reducedNameOnDic = dict.reduce("Charater are ") { $0 + $1.key + " "}

```

#### feduce on Set

```Swift
// Reduce on Set
let lengthMeters = [3.4,1.6]
let reducedMeters = lengthMeters.reduce(0.0) {
    $0 + $1
}
print("reduced meters :\(reducedMeters)") // 5.0
```

### FlatMap

#### FlatMap作用



Flatmap is used to flatten a collection of collections . But before flattening the collection, we can apply map to each elements.

> **Apple docs says**: Returns an array containing the concatenated results of calling the given transformation with each element of this sequence.

###### 1.flatmap用于展平包含集合的集合。

 但是在展平集合之前，我们可以将map应用于每个集合元素。

```Swift
let charaters = ["abc","def","ghi"]
let newCharaters = charaters.flatMap { $0 }
print(newCharaters)
//["a", "b", "c", "d", "e", "f", "g", "h", "i"]

let codes = [["abc","def","ghi"], ["jkl","mno","pqr"],["stu","vwx","yz"] ]
let newCodes = codes.flatMap {$0.map { $0 } }
print(newCodes)
// ["abc", "def", "ghi", "jkl", "mno", "pqr", "stu", "vwx", "yz"]

```

###### 2.flatmap可以过滤nil，Swift3后开始启用`compactMap`替代`flatMap`来过滤

```Swift
let nilArray = [2,3,nil]
print(nilArray.flatMap { $0 }) // [2,3]
// warning: 'flatMap' is deprecated: Please use compactMap(_:) for the case where closure returns an optional value
print(nilArray.compactMap { $0 }) // [2,3]
```

##### flatmap on array

```Swift
let numberForFlatMap = [[1,2,3], [4,5,6]]
let flatMapOfNumbers = numberForFlatMap.flatMap { $0 }
print("flatMapOfNumbers:\(flatMapOfNumbers)") 
// flatMapOfNumbers:[1, 2, 3, 4, 5, 6]

```

#### flatmap on dictionary

```Swift
    let dictArrayForFlatMap = [["key1":"value1","key2":"value2"]]
    let flatMapForDict = dictArrayForFlatMap.flatMap { $0 }
    print("flatMapForDict:\(flatMapForDict)")

    //flatMapForDict:[(key: "key2", value: "value2"), (key: "key1", value: "value1")]

    var dict = [String: String]()
    flatMapForDict.forEach {
        dict[$0.0] = $0.1
    }
    print("dict:\(dict)")

  //dict:["key1": "value1", "key2": "value2"]

```

#### flatMap on Set

```Swift
    let numberSet: Set = [Set([1,2,3]), Set([4,5,6])]
    let flatMapForSet = numberSet.flatMap { $0 }
    print("flatMapForSet:\(flatMapForSet)")
    //flatMapForSet:[2, 3, 1, 4, 6, 5]

```
#### flatMap优势
深入挖掘下flatMap的优势在哪里：
##### 过滤optionals
> Even more usefully it knows about optionals and will remove them from a collection.
>
多说无益，show me code:
```Swift
let numberOfOptionals = [1,2,nil,4,5,6]
let valid = numberOfOptionals.flatMap { $0 }
print("valid:\(valid)")
//valid:[1, 2, 4, 5, 6]
```

#### 组合filter/map使用
flatMap可以用在集合中包含集合的情况下，类似[[array1],[array2],[array3]]这种多维数组会被flatMap展开成一维数组。`flatmap闭包`中的参数$0即是一个数组集合，拿到$0后我们可以用来filter或者map。

show me code:
```Swift
        let collectionWithCollections = [[6,5,4], [3,2] , [8,9,7]]
        let onlyEven = collectionWithCollections.flatMap {
            $0.filter { $0 % 2 == 0 }
        }
        print(onlyEven)
        //[6, 4, 2, 8]


```

#### 函数式（map+filter+reduce）
> The working principle behind the chaining is simple. The map and filter methods act on a collection and returns another collection . And now, we can again apply another higher order function on this collection. It’s that simple.

我们来看看组合使用的效果

```Swift
let arrayOfArrays = [[1,2,3,4], [5,6,7,8]]
let mixArrayOperation = arrayOfArrays.flatMap{$0}.filter{ $0 % 2 == 0 }.map{ $0 * $0 }
let reducdArray = mixArrayOperation.reduce(0, +)
print(reducdArray) // 120
```



等价于下面

```Swift
        let arrayOfArrays = [[1,2,3,4], [5,6,7,8]]
        var sequence = arrayOfArrays.flatMap{ $0 }
        sequence = sequence.filter{ $0 % 2 == 0}
        sequence = sequence.map{ $0 * $0 }
        let reducedSeq = sequence.reduce(0, +)

```

```Swift
			  //sequence flatMap:[4, 16, 36, 64]
        //sequence filter:[4, 16, 36, 64]
        //sequence map:[4, 16, 36, 64]
        //sequence reduce:120
```



## compactMap()

#### compactMap on array 可以过滤nil
```Swift
  let array = [1,2, nil, nil ,5,6]
  print(array.compactMap{ $0 }) 
  //[1, 2, 5, 6]
```
#### compactMap on dictionary 不能过滤nil

```Swift
  let dict = ["1": nil, "2":"10"]
  print(dict.compactMap{ $0 })
```
`print:  //[(key: "2", value: Optional("10")), (key: "1", value: nil)]`
#### `compactMapValues()` on dictionary 可以过滤nil

```Swift
let dict = ["1": nil, "2":"10"]
print(dict.compactMapValues{ $0 })
//["2": "10"]
```

## 总结

看到这里，你已经掌握了Swift高阶函数了

尽可能使用高阶函数的目的：

1. 提高Swift使用技巧
2. 增强代码可读性
3. 更加的函数式更加的Swift

我们的目标是星辰大海（Less Code more life）

希望你喜欢。done



拓展阅读：[Map VS flatMap](https://swiftcafe.io/2016/03/28/about-map/)
# iOS底层原理

- 1、一个NSObject对象占用多少内存？
- 2、对象的isa指针指向哪里？
- 3、OC的类信息存放在哪里？
- 4、KVO的本质是什么？
- 5、如何手动触发KVO？(如何自己实现KVO?)
- 6、如果直接修改成员变量会不会触发KVO?
- 7、通过KVC修改属性会触发KVO么？
- 8、KVC的取值和赋值的过程是什么？KVC的原理是什么？
- 9、Catery实现原理是什么？
- 10、Category和 Class Extension的区别是什么？
- 11、Category的使用场合是什么？
- 12、Category中有没有load方法？有的话load()方法什么时候调用的？load方法能继承么？
- 13、load和initialize方法的区别是什么？它们在category中调用顺序？以及出现继承时它们调用顺序？
- 14、Category能否添加成员变量？如果可以如何添加成员变量？
- 15、block的原理是什么？本质是什么？
- 16、__block的作用是什么？有什么需要注意的地方？
- 17、block的属性修饰为什么是copy? 使用block有哪些需要注意的地方？
- 18、block修改NSMutableArray时，需要添加__block么？
- 19、Objective-C对象和类主要是基于C的什么数据结构实现的？结构体
- 20、一个OC对象在内存中是如何布局的？
- 21、一个OC对象占用多少内存空间？
- 22、创建一个实例对象，至少需要多少内存？实际上系统分配了多少内存？
- 23、OC对象分类主要是哪三种？OC对象中存放了哪些信息？
- 24、isa指针是什么？它有什么用处？
- 25、objc_class是什么？存放了哪些信息？
- 

---

1、一个NSObject对象占用多少内存？
系统分配了16个字节给NSObject对象（通过malloc_size函数获得）
但NSObject对象内部只使用了8个字节的空间（64bit环境下，可以通过class_getInstanceSize函数获得）

2、instance的isa对象指向class,class对象的isa指向meta-class，meta-class对象的isa指向基类的meta-class。

3、OC实例变量直接存在对象本身的结构体内存


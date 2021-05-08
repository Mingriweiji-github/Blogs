# App优化

1、二进制：https://github.com/facebookincubator/BOLT

[2、今日头条优化实践:iOS 包大小二进制优化，一行代码减少 60 MB 下载大小](https://mp.weixin.qq.com/s/TnqAqpmuXsGFfpcSUqZ9GQ)

- __TEXT 段迁移
- **减少App Store下载大小的原理**
- **在实践过程中遇到的问题，并从源码的角度详细分析了问题产生的根本原因以及解决方式，解答了相关疑问和上线后遇到的问题。**

[苹果在 iOS 13 已经对下载大小做了优化，所以本方案无法再对 iOS 13 的设备的下载大小进一步优化。

即，若用户的设备 < iOS 13，那么本方案可以减少该设备上 App 32~34%的下载大小；

若用户的设备 >= iOS 13，本方案不会对该设备的 App 的下载大小有进一步优化，也不会有负面影响。

因此，如果你看到 App Store Connect 后台展示的下载大小从 iPhone 11 开始大幅减小，不要惊讶，这是因为 iPhone 11 开始默认搭载的是 iOS 13+ 的系统。

目前推测苹果在 iOS 13 也是在针对压缩做了优化，可能是移除了加密或者是先压缩后加密。]



# iOS+思维 进阶篇 

### 原理篇

第一节：《Objective-C 高级编程》学习笔记    
[Objective-C之GCD多线程(一)](https://larrycal.coding.me/2017/02/09/Objective-C之多线程/)   
[Objective-C之GCD多线程（二)](https://larrycal.coding.me/2017/02/13/Objective-C之GCD多线程（二）/)   
[Objective-C之Blocks（三）](https://larrycal.coding.me/2017/02/03/Objective-C之Blocks（三）/)   
[Objective-C之Blocks（二）](https://larrycal.coding.me/2017/01/28/Objective-C之Blocks（二）/)   
[Objective-C之Blocks（三）](https://larrycal.coding.me/2017/02/03/Objective-C之Blocks（三）/)   
[Objective-C之Blocks-四](https://larrycal.coding.me/2017/03/27/Objective-C之Blocks-四/)   

第二节：底层实现原理
[iOS底层解析Weak实现原理](http://www.jianshu.com/p/13c4fb1cedea)        
[weak singleton](https://zhuanlan.zhihu.com/p/27832890)   

[关于iOS离屏渲染的深入研究](https://zhuanlan.zhihu.com/p/72653360)

[深入浅出GCD](https://xiaozhuanlan.com/u/3785694919)
[深入浅出GCD之dispatch_group](https://xiaozhuanlan.com/topic/0863519247)

[RunLoop要点](http://aaaboom.com/?p=37)   
[RunLoop系列之源码分析](http://aaaboom.com/?p=34#wow1)   
[Runloop面试与总结](https://juejin.im/post/5c9e28ddf265da307261efff)
[Runloop实战](https://juejin.im/post/5cacb2baf265da03904bf93b)

第三节：HTTPS原理   
[看完还不懂HTTPS我直播吃翔](http://www.jianshu.com/p/ca7df01a9041) 

[图解HTTPS](https://mp.weixin.qq.com/s/3gI8avaaaEaBJjOKitN7Fw)

[SDWebImage 图片下载缓存框架 常用方法及原理](http://www.jianshu.com/p/4191017c8b39)  

[iOS数据库升级](http://www.jianshu.com/p/e1bd870b4ac2)   

第四节：Swift3.0
[Swift3特性](http://www.jianshu.com/p/5d911fae5b2f)

### 面试篇   
[iOS中级面试题](http://mrpeak.cn/ios/2016/01/07/push)  
[iOS面试题练习(二)](https://larrycal.coding.me/2017/02/27/iOS面试题-二/)  
[招聘一个靠谱的iOS](http://blog.sunnyxx.com/2015/07/04/ios-interview/)     
[招聘一个靠谱的iOS参考答案（上）](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（上）.md)    
[招聘一个靠谱的iOS参考答案（下）](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（下）.md)                    

### 突破性思维
[刻意练习](https://book.douban.com/subject/26895993/)       

[拆掉思维里的墙](https://www.amazon.cn/拆掉思维里的墙-原来我还可以这样活-古典/dp/B009P4OW6U/ref=sr_1_2?s=digital-text&ie=UTF8&qid=1503646401&sr=1-2&keywords=拆掉思维里的墙)    

[你的生命有什么可能](https://www.amazon.cn/你的生命有什么可能-古典/dp/B00SIOKLMM/ref=pd_sim_351_3?ie=UTF8&psc=1&refRID=2X0YEEB59NM2X633X420)




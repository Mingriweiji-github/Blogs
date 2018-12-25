### 问题1.library not found for -lstdc++.6.0.9
### 
`报错原因：自iOS12.0中去掉了lstdc++.6.0.9.tbd动态库，全部采用libc++代替lstdc++的动态库.`

#### 解决方法：下载[压缩包](https://github.com/Mingriweiji-github/iOS-Advance-Blog/blob/master/libstdc%2B%2B.6.0.9.tbd.zip)解压后用libstdc++.6.0.9.tbd 分别替换以下真机和模拟器libstdc++.6.0.9.tbd文件，路径如下
###### 真机路径：
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS12.0.sdk/usr/lib
###### 模拟器路径：
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator12.0.sdk/usr/lib

### 问题2: no suitable image found.  Did find:
### /usr/lib/libstdc++.6.dylib: mach-o, but not built for iOS simulator

#### 解决方法： 下载[压缩包](https://github.com/Mingriweiji-github/iOS-Advance-Blog/blob/master/libstdc%2B%2B.6.0.9.tbd.zip)，使用压缩包中的libstdc++.6.dylib复制到下面路径即可
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib






# iOS+思维 进阶篇 

### 原理篇

第一节：《Objective-C 高级编程》学习笔记    
[Objective-C之GCD多线程(一)](https://larrycal.coding.me/2017/02/09/Objective-C之多线程/)   
[Objective-C之GCD多线程（二)](https://larrycal.coding.me/2017/02/13/Objective-C之GCD多线程（二）/)   
[Objective-C之Blocks（三）](https://larrycal.coding.me/2017/02/03/Objective-C之Blocks（三）/)   
[Objective-C之Blocks（二）](https://larrycal.coding.me/2017/01/28/Objective-C之Blocks（二）/)   
[Objective-C之Blocks（三）](https://larrycal.coding.me/2017/02/03/Objective-C之Blocks（三）/)   
[Objective-C之Blocks-四](https://larrycal.coding.me/2017/03/27/Objective-C之Blocks-四/)   

第二节：weak的实现原理,RunLoop的真相        
[iOS底层解析Weak实现原理](http://www.jianshu.com/p/13c4fb1cedea)        
[weak singleton](https://zhuanlan.zhihu.com/p/27832890)   
[RunLoop要点](http://aaaboom.com/?p=37)   
[RunLoop系列之源码分析](http://aaaboom.com/?p=34#wow1)   

第三节：HTTPS原理、数据库升级、SDWebImage    
[iOS数据库升级](http://www.jianshu.com/p/e1bd870b4ac2)   
[看完还不懂HTTPS我直播吃翔](http://www.jianshu.com/p/ca7df01a9041)    
[SDWebImage 图片下载缓存框架 常用方法及原理](http://www.jianshu.com/p/4191017c8b39)    

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

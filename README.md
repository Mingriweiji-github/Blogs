
# 端智能
[轻松玩转移动AI，一键集成的端智能框架Pitaya](https://mp.weixin.qq.com/s/XF2k9MGcbY_hqlLEjl0hhw)

# 效率&工具
[一款可让大型iOS工程编译速度提升50%的工具](https://mp.weixin.qq.com/s/uBpkelG8q_xmskWPYyWONA)


# Flutter
[字节跳动为什么选用Flutter：并非跨平台终极之选，但它可能是不一样的未来](https://mp.weixin.qq.com/s/OlSEpK-KKfpypwQFnJ4kfQ)
[西瓜视频UME - 丰富的Flutter调试工具](https://mp.weixin.qq.com/s/9GjXB9Eu-OP3fIjdQWKklg)
[美团外卖Flutter动态化实践](https://mp.weixin.qq.com/s/wjEvtvexYytzSy5RwqGQyw)
[Flutter包大小治理上的探索与实践](https://mp.weixin.qq.com/s/adC-YUWd-xuUlzeAPHzJoQ)
[外卖客户端容器化架构的演进](https://mp.weixin.qq.com/s/kW5wu7GM7pMRRvN-dQvE2g)
[让 Flutter 在鸿蒙系统上跑起来](https://mp.weixin.qq.com/s/vTWZRaxvsOS_VRjfh6l4FQ)
[Flutter Web在美团外卖的实践](https://mp.weixin.qq.com/s/GjFC5_85pIk9EbKPJXZsXg)



# App优化

1、二进制：https://github.com/facebookincubator/BOLT


[2.1 今日头条优化实践:iOS 包大小二进制优化，一行代码减少 60 MB 下载大小](https://mp.weixin.qq.com/s/TnqAqpmuXsGFfpcSUqZ9GQ)

- **针对Mach-O中__TEXT 段迁移**
- **减少App Store下载大小的原理**
- **在实践过程中遇到的问题，并从源码的角度详细分析了问题产生的根本原因以及解决方式，解答了相关疑问和上线后遇到的问题。**

[苹果在 iOS 13 已经对下载大小做了优化，所以本方案无法再对 iOS 13 的设备的下载大小进一步优化。

即，若用户的设备 < iOS 13，那么本方案可以减少该设备上 App 32~34%的下载大小；

若用户的设备 >= iOS 13，本方案不会对该设备的 App 的下载大小有进一步优化，也不会有负面影响。]

[2.2 抖音品质建设 - iOS 安装包大小优化实践篇](https://mp.weixin.qq.com/s/LSP8kC09zjb-sDjgZaikbg)

[2.3今日头条 iOS 安装包大小优化 - 新阶段、新实践](https://mp.weixin.qq.com/s/oyqAa8wKdioI5ZDG5LjkfA)



[3.1 今日头条品质优化 - 图文详情页秒开实践](https://mp.weixin.qq.com/s/Xqr6rQBbx7XPoBESEFuXJw)
[3.2 抖音品质建设 - iOS启动优化《原理篇》](https://mp.weixin.qq.com/s/3-Sbqe9gxdV6eI1f435BDg)


[4.1 iOS性能优化实践：头条抖音如何实现OOM崩溃率下降50%+](https://mp.weixin.qq.com/s/4-4M9E8NziAgshlwB7Sc6g)
[4.2 iOS 稳定性问题治理：卡死崩溃监控原理及最佳实践](https://mp.weixin.qq.com/s/cEfIZGtUojKKbhIfUyhTMw)


[5 在线教室 iOS 端声音问题综合解决方案](https://mp.weixin.qq.com/s/yFNb0zvPtEjHAtED7-jT0w)



# App架构
### 抖音 iOS 工程架构演进
[抖音 iOS 工程架构演进](https://mp.weixin.qq.com/s/HHH5_IEbsR8iSmXSIdeutw)
#### 1.抖音项目一开始是单体架构+Cocoapods，业务代码、工程配置、资源文件全部放在一个大业务仓库。由 Podfile 文件描述第三方仓库的依赖版本。
![](https://mmbiz.qpic.cn/mmbiz_png/5EcwYhllQOgxv4BKibbw6cq7h91kLkCLaGiaIIC7gHZfcc6j8KBCUv4XIqGXRk1L3OIEba1my7JHZo5kDIhRyUZQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)
#### 阶段二：分离壳工程后的工程架构（After splitting of host shell pod）
![2.分离壳工程后，工程配置、部分系统资源、工程主入口被拆分到主宿主壳工程。](https://mmbiz.qpic.cn/mmbiz_png/5EcwYhllQOgxv4BKibbw6cq7h91kLkCLaicPQCz56N51ickoJsKk0vcpsibyOpvGM8UFSLCZETTSjvynjQtH3Z46cw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)
#### 阶段三：单仓多组件工程架构（Multicomponents in single repo）
![](https://mmbiz.qpic.cn/mmbiz_png/5EcwYhllQOgxv4BKibbw6cq7h91kLkCLaJdrzvWg2lPMoQaic7M974BDneCzrdV7KQdCSoEicF5OQia7gHBlEyUd4g/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)
#### 阶段四：Example 子壳工程架构（Subshell for bizcomponent in example project）
![](https://mmbiz.qpic.cn/mmbiz_png/5EcwYhllQOgxv4BKibbw6cq7h91kLkCLaBc5HX9hONLz7yZvzzSgdGkypVFiaZas0KZ7KiahazjEdZBz4ze72zsaw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

# 底层原理

[从预编译的角度理解Swift与Objective-C及混编机制](https://mp.weixin.qq.com/s/gI9vL1KlHuMzMoWWf2tnIw)

[从汇编层面探索 KVO 本质](https://mp.weixin.qq.com/s/0Yfb-FYorH5GZ3ZB6bMCUQ)

[一招搞定 iOS 14.2 的 libffi crash](https://mp.weixin.qq.com/s/XLqcCfcNhpCA8Tg6LknBCQ)

# 技术拓展
[抖音BoostMultiDex优化实践：Android低版本上APP首次启动时间减少80%（一）](https://mp.weixin.qq.com/s/jINCbTJ5qMaD6NdeGBHEwQ)
[抖音BoostMultiDex优化实践：Android低版本上APP首次启动时间减少80%（二）](https://mp.weixin.qq.com/s/ILDTykAwR0xIkW-d1YzRHw)
[抖音Android团队-抖音包大小优化-资源优化](https://mp.weixin.qq.com/s/xxrvRKXXDquJaezjrOlLwA)
[今日头条 Android '秒' 级编译速度优化](https://mp.weixin.qq.com/s/e1L6gB_s5H38unSfhf4c6A)
[字节跳动在 Go 网络库上的实践](https://mp.weixin.qq.com/s/wSaJYg-HqnYY4SdLA2Zzaw)

[美团万亿级 KV 存储架构与实践](https://mp.weixin.qq.com/s/1woExb3V_PjnrhHYH5Jksg)

# 思维拓展
[工程师的基本功是什么？该如何练习？听听美团技术大咖怎么说](https://mp.weixin.qq.com/s/vOZb2PUdqMUj17ReMA43GA)


[资源帖丨字节跳动技术 Leader 们推荐的学习资源](https://mp.weixin.qq.com/s/mNZHlBcpJDaBkR5J4ay4Tg)
[推荐收藏 | 美团技术团队的书单](https://mp.weixin.qq.com/s/okG7ZglLB2PPVM_Wz0PFUg)



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




# Mac的一切





## macbook 外接显示器关闭内置屏幕

mac使用外接显示器作为主屏幕 mac显示器熄灭的

> 将mac慢慢合，合到夹角很小的时候会短暂黑一下然后外接显示器就成主屏幕了，
>
> 这时候我们可以将mac完全合上后竖立放置在一旁

参考：
1 [将显示器连接到 Mac \- Apple 支持](https://support.apple.com/zh-cn/HT202351)
2 [macbook 外接显示器关闭内置屏幕 \- V2EX](https://www.v2ex.com/t/579253)



## macbook 外接键盘多任务多窗口控制

#### 方法一：**使用Alfed的快速启动hotKey功能，快速启动mac系统自带的Misssion Control**

<img src="https://raw.githubusercontent.com/Mingriweiji-github/ImageBed/master/img/20210619162320.png" alt="image-20210619162317288" style="zoom: 67%;" />

推荐直接使用快捷键F3控制Mission Control和mac原生体验保持一致

![image-20210619163002458](https://raw.githubusercontent.com/Mingriweiji-github/ImageBed/master/img/20210619163006.png)



#### 方法二：Mac-设置-桌面与屏幕保护程序-屏幕保护程序-选择你想要的屏幕角（以桌面右下角为例）设置为调度中心



![image-20210619165937167](https://raw.githubusercontent.com/Mingriweiji-github/ImageBed/master/img/20210619165938.png)

## [第三方键盘hhkb没法在 mac 上开机登录](https://www.v2ex.com/t/683490)

开启 FileVault 的情况下，HHKB 双模无法在开机或重启时输入登录密码”，苹果自家的妙控键盘是可以的

HHKB 在开启 Filevault 的前提下，Filco 双模没问题，GANSS 不行。

## 2 、Mac软件推荐



1、Snipaste 「截图贴图软件」 

2、Magnet「桌面窗口整理软件」 

3、BetterZip「桌面窗口整理软件」 

4、IINA「超好用的播放器软件」 

5、Downie3「从数千个不同的站点轻松下载视频」 

6、Paste「剪贴板神器」 

7、Text Scanner「将图片上的文字内容，直接转换为可编辑文本」 

8、ScreenFlow「MacOS苹果系统独占的最好的屏幕录像和视频编辑软件」 

通过软件[soundflower](https://link.zhihu.com/?target=https%3A//soundflower.en.softonic.com/mac)来解决详细可以参看：

[【Mac/OBS/直播】Mac电脑如何使用OBS直播](https://pic2.zhimg.com/v2-e03891afbaf4229c2b675ad3af6a0675_180x120.jpg)](https://link.zhihu.com/?target=https%3A//www.bilibili.com/video/av33784118/)



10.15.2版本时候soundflower失效，然后使用一个叫**IshowU**的软件来解决，详细可以查看：

iShowU 链接:[https://pan.baidu.com/s/1zNVTmzqOcC-B5_znLbyFqA](https://link.zhihu.com/?target=https%3A//pan.baidu.com/s/1zNVTmzqOcC-B5_znLbyFqA) 密码:dzgi

[【Mac/OBS/Catalina】MacOS升级到Catalina之后不能使用OBS？不只是你的打开方式不对而已，使用iShowU来捕获系统的声音](https://pic2.zhimg.com/v2-7ce018b9dbd998d9dbb95072e0b5f505_180x120.jpg)](https://link.zhihu.com/?target=https%3A//www.bilibili.com/video/av78168177/)



作者：浮生甲第
链接：https://www.zhihu.com/question/20251726/answer/957730579
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

9、Aimersoft video Converter Uitimate「转码软件」



10、iterm2 + oh my zsh

## 安装 iTerm2

和普通软件一样下载安装。

下载地址 [iterm2.com/]()。

## 安装配置 oh-my-zsh

安装，curl 和 wget 两种方式，这个安装需要基于 Xcode，没有 Xcode 在 App Store 先装下，Xcode 有点大(也就 6.1 G)需要一段时间。

via curl

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

via wget

```
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/instal
```

安装完成重启 iTerm2 

### 修改主题

终端输入

```
open ~/.zshrc
```

ZSH_THEME 这个就是主题配置，这里修改主题为 ys ，改完之后保存重启 iTerm2 

[其他主题](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)


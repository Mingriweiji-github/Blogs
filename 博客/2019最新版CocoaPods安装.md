Cocoapds报错
````Error fetching http://gems.ruby-china.org/:
    bad response Not Found 404 (https://gems.ruby-china.org/specs.4.8.gz)
````
1. 在升级之前我们需要了解当前安装的Ruby源地址：
gem source -l

2.https://ruby.taobao.org/淘宝的源已经不再维护
https://gems.ruby-china.org/腾讯的这个org的源也不存在了
![屏幕快照 2019-04-22 上午9.48.36.png](https://upload-images.jianshu.io/upload_images/1132062-3907721454a22eab.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3.更换为：https://gems.ruby-china.com
````
gem sources --remove https://gems.ruby-china.org/
gem sources -l
gem sources -a https://gems.ruby-china.com
````
4.再次安装CocoaPods
````
sudo gem install cocoapods
````
5. 查看下CocoaPods的版本
pod --version




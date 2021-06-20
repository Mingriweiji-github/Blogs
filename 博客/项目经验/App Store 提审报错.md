## App Store 提审报错

ERROR ITMS-90062: "This bundle is invalid. The value for key CFBundleShortVersionString [1.5.0] in the Info.plist file must contain a higher version than that of the previously approved version [1.5.0]. Please find more information about CFBundleShortVersionString at https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleshortversionstring"

#### 原因：

从上面的报错信息可以看出，苹果后台已经有某个版本的一个应用通过了审核(approved)，而且它正在等待开发者的发布(pending developer release)，所以当开发者继续提交一个版本和等待开发者发布的应用的版本相同的时候，苹果后台就不让继续提交了。

#### 解决方案有两种：

1、修改1.5.0以上版本号(CFBundleShortVersionString)，然后重新打包继续提交。

2、版本号不变，取消苹果后台里等待开发者发布的版本，然后重新提交之前被拒的版本。

![image-20210518112922139](https://raw.githubusercontent.com/Mingriweiji-github/ImageBed/master/img/20210518112935.png)
## Finder显示隐藏文件.gitignore

1.在终端中输入`defaults write com.apple.finder AppleShowAllFiles -bool true`

2.重启Finder

## 删除untracked files

> git clean -fd

## 解决.gitignore不生效的问题。



当我们将 .gitignore 文件配置好后，却往往不能失效。这是因为 .gitignore 只能忽略那些没有被追踪(track)的文件，因为 git 存在本地缓存，如果文件已经纳入了版本管理，那么修改 .gitignore 是不能失效的。那么解决方案就是要将 git 的本地缓存删除，然后重新提交。

```
git rm -r --cached .
git add .
git commit -m "update .gitignore"
```



附上Objective-C中常用文件，更新日期2019-12-12

```objective-c
# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/

## compatibility with Xcode 8 and earlier (ignoring not required starting Xcode 9)
*.xcscmblueprint
*.xccheckout

## compatibility with Xcode 3 and earlier (ignoring not required starting Xcode 4)
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3

## Obj-C/Swift specific
*.hmap

## App packaging
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
#
# Add this line if you want to avoid checking in source code from Swift Package Manager dependencies.
# Packages/
# Package.pins
# Package.resolved
# *.xcodeproj
#
# Xcode automatically generates this directory with a .xcworkspacedata file and xcuserdata
# hence it is not needed unless you have added a package configuration file to your project
# .swiftpm

.build/

# CocoaPods
#
# We recommend against adding the Pods directory to your .gitignore. However
# you should judge for yourself, the pros and cons are mentioned at:
# https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control
#
# Pods/
#
# Add this line if you want to avoid checking in source code from the Xcode workspace
# *.xcworkspace

# Carthage
#
# Add this line if you want to avoid checking in source code from Carthage dependencies.
# Carthage/Checkouts

Carthage/Build/

# Accio dependency management
Dependencies/
.accio/

# fastlane
#
# It is recommended to not store the screenshots in the git repo.
# Instead, use fastlane to re-generate the screenshots whenever they are needed.
# For more information about the recommended setup visit:
# https://docs.fastlane.tools/best-practices/source-control/#source-control

fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
#
# After new code Injection tools there's a generated folder /iOSInjectionProject
# https://github.com/johnno1962/injectionforxcode

iOSInjectionProject/
```

[OC最新版](https://github.com/github/gitignore/blob/master/Objective-C.gitignore)

[Swift版本](https://github.com/github/gitignore/blob/master/Swift.gitignore)


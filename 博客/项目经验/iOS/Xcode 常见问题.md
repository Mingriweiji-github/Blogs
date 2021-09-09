## Xcode 常见问题

### ld: library not found for 



原因是路径问题，解决方法是 Xcode- "Build Settings > Other Linker Flags"修改如下，参考 [StackOverflow 问题](https://stackoverflow.com/questions/11358591/xcode-library-not-found)



```javascript
  $(inherited)
  -ObjC
```





### Xcode11 代码提示

解决方案： File -> project setting -> building system -> Legecy building system -> 重启xcode

### Module compiled with Swift 5.1 cannot be imported by the Swift 5.1.2 compiler | module compiled with Swift 5.3.2 cannot be imported by the Swift 5.4 compiler
时间：2021.5.16

场景： Xcode 12.4升级Xcode12.5


1.最新版Xcode12.5重新报错的编译xxx module库

2.pod repo update

3.pod install --repo-update




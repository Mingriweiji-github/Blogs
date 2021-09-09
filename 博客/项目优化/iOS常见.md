# iOS常见



## 打开任意App设置界面

```objc
@interface LSApplicationWorkspaceHook : NSObject

+ (instancetype)defaultWorkspace;
- (void)openURL:(NSURL *)url;

@end

void openWeChat() {
    // 调用 LSApplicationWorkspace 的单例方法
    Class aClass = NSClassFromString(@"LSApplicationWorkspace");
    LSApplicationWorkspaceHook *hook = [aClass defaultWorkspace];
    // 调用 LSApplicationWorkspace 的 `openURL:` 方法
    [hook openURL:[NSURL URLWithString:@"app-prefs:com.tencent.xin"]];
}
```



![image-20210622134118812](https://raw.githubusercontent.com/Mingriweiji-github/ImageBed/master/img/20210622134124.png)




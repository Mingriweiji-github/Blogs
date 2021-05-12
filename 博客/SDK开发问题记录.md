## SDK开发问题记录



### viewDidLoad注册通知App在进入前台后，通知调用多次

> Apple recommends that observers should be registered in viewWillAppear: and unregistered in viewWillDissapear:

### 解决：NotificationCenter注册和销毁分别放到viewWillAppear和viewDidDisappear中



```swift
 override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        debugPrint("APP进入前台>>>>>>>>>")
    }
```


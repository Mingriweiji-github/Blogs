# Swift语法风格

## 尽可能不用if-else

#### 捕捉错误

```swift
// DON'T
func playVideo()
  if video.url == nil {
  } else {
    /* your code here */
  }
// DO!
func playVideo() {
  guard video.url != nil else { return }
  /* your code here */
}
```



#### UI布局

```swift
// DON'T
class UserProfilePictureViewController {
override func viewDidLayoutSubviews() {
  super.viewDidLayoutSubviews()
  if (isUserActive) {
    /* layout user profile */
  } else {
    /* layout */
  }
}
```



#### 多状态管理

```swift
// DON'T!
let label = UILabel()
if (isInEditor) {
  label.text = "Edit your Photo"
} else {
  label.text = "Publish your Photo"
}

// DO!
enum PhotoEditingState {
    case editor
    case publish

    var title : String {
        get {
            switch self {
            case .editor:
                return "Edit your Photo"
            case .publish:
                return "Publish your Photo"
            }
        }
    }
}
```


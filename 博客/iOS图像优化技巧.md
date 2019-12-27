# [iOS图像优化技巧](https://swift.gg/2019/11/01/image-resizing/)

## 图像渲染优化的时机和理由

在开始之前，让我们先讨论一下*为什么*需要对图像进行渲染优化。毕竟，`UIImageView` 会自动根据 [`contentmode` 属性](https://developer.apple.com/documentation/uikit/uiview/1622619-contentmode) 规定的行为缩放和裁剪图像。在绝大多数情况下，`.scaleAspectFit`、`.scaleAspectFill` 或 `.scaleToFill` 已经完全满足你的所需。

```
imageView.contentMode = .scaleAspectFit
imageView.image = image
```

------

那么，什么时候对图像进行渲染优化才有意义呢？

**当它明显大于** **`UIImageView`** **显示尺寸的时候**

想要完整渲染这张宽高为 12,000 px 的图片，需要高达 20 MB 的空间。对于当今的硬件来说，你可能不会在意这么少兆字节的占用。但那只是它压缩后的尺寸。要展示它，`UIImageView` 首先需要把 JPEG 数据解码成位图（bitmap），如果要在一个 `UIImageView` 上按原样设置这张全尺寸图片，你的应用内存占用将会激增到**几百兆**，对用户明显没有什么好处（毕竟，屏幕能显示的像素有限）。但只要在设置 `UIImageView` 的 `image` 属性之前，将图像渲染的尺寸调整成 `UIImageView` 的大小，你用到的内存就会少一个数量级：

|          | 内存消耗 *(MB)* |
| :------- | :-------------- |
| 无下采样 | 220.2           |
| 下采样   | 23.7            |

这个技巧就是众所周知的*下采样（downsampling）*，在这些情况下，它可以有效地优化你应用的性能表现。如果你想了解更多关于下采样的知识或者其它图形图像的最佳实践，请参照 [来自 WWDC 2018 的精彩课程](https://developer.apple.com/videos/play/wwdc2018/219/)。

而现在，很少有应用程序会尝试一次性加载这么大的图像了，但是也跟我从设计师那里拿到的图片资源不会差*太*多。*（认真的吗？一张颜色渐变的* *PNG* *图片要* *3* *MB?）* 考虑到这一点，让我们来看看有什么不同的方法，可以让你用来对图像进行优化或者下采样。

> 不用说，这里所有从 URL 加载的示例图像都是针对**本地**文件。记住，在应用的主线程同步使用网络请求图像**绝不**是什么好主意。

------

## 图像渲染优化技巧

优化图像渲染的方法有很多种，每种都有不同的功能和性能特性。我们在本文看到的这些例子，架构层次跨度上从底层的 Core Graphics、vImage、Image I/O 到上层的 Core Image 和 UIKit 都有。

1. [绘制到 UIGraphicsImageRenderer 上](https://swift.gg/2019/11/01/image-resizing/#technique-1-drawing-to-a-uigraphicsimagerenderer)
2. [绘制到 Core Graphics Context 上](https://swift.gg/2019/11/01/image-resizing/#technique-2-drawing-to-a-core-graphics-context)
3. [使用 Image I/O 创建缩略图像](https://swift.gg/2019/11/01/image-resizing/#technique-3-creating-a-thumbnail-with-image-io)
4. [使用 Core Image 进行 Lanczos 重采样](https://swift.gg/2019/11/01/image-resizing/#technique-4-lanczos-resampling-with-core-image)
5. [使用 vImage 优化图片渲染](https://swift.gg/2019/11/01/image-resizing/#technique-5-image-scaling-with-vimage)



下面的这些数字是多次迭代加载、优化、渲染之前那张 [超大地球图片](https://visibleearth.nasa.gov/view.php?id=78314) 的平均时间：

|                            | 耗时 *(seconds)* |
| :------------------------- | :--------------- |
| 技巧 #1: `UIKit`           | 0.1420           |
| 技巧 #2: `Core Graphics` 1 | 0.1722           |
| 技巧 #3: `Image I/O`       | 0.1616           |
| 技巧 #4: `Core Image` 2    | 2.4983           |
| 技巧 #5: `vImage`          | 2.3126           |

1 
设置不同的 `CGInterpolationQuality` 值出来的结果是一致的，在性能上的差异可以忽略不计。

2 
若在 `CIContext` 创建时设置 `kCIContextUseSoftwareRenderer` 的值为 `true`，会导致耗时相比基础结果慢一个数量级。

### 技巧 #1: 绘制到 UIGraphicsImageRenderer 上

图像渲染优化的最上层 API 位于 UIKit 框架中。给定一个 `UIImage`，你可以绘制到 `UIGraphicsImageRenderer` 的上下文（context）中以渲染缩小版本的图像：

```
import UIKit

// 技巧 #1
func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    guard let image = UIImage(contentsOfFile: url.path) else {
        return nil
    }

    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
}
```

[`UIGraphicsImageRenderer`](https://developer.apple.com/documentation/uikit/uigraphicsimagerenderer) 是一项相对较新的技术，在 iOS 10 中被引入，用以取代旧版本的 `UIGraphicsBeginImageContextWithOptions` / `UIGraphicsEndImageContext` API。你通过指定以 `point` 计量的 `size` 创建了一个 `UIGraphicsImageRenderer`。`image` 方法带有一个闭包参数，返回的是一个经过闭包处理后的位图。最终，原始图像便会在缩小到指定的范围内绘制。

### 技巧 #2：绘制到 Core Graphics Context 中

Core Graphics / Quartz 2D 提供了一系列底层 API 让我们可以进行更多高级的配置。

给定一个 `CGImage` 作为暂时的位图上下文，使用 `draw(_:in:)` 方法来绘制缩放后的图像：

```
import UIKit
import CoreGraphics

// 技巧 #2
func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else {
        return nil
    }

    let context = CGContext(data: nil,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: image.bitsPerComponent,
                            bytesPerRow: image.bytesPerRow,
                            space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: image.bitmapInfo.rawValue)
    context?.interpolationQuality = .high
    context?.draw(image, in: CGRect(origin: .zero, size: size))

    guard let scaledImage = context?.makeImage() else { return nil }

    return UIImage(cgImage: scaledImage)
}
```

这个 `CGContext` 初始化方法接收了几个参数来构造一个上下文，包括了必要的宽高参数，还有在给出的色域范围内每个颜色通道所需要的内存大小。在这个例子中，这些参数都是通过 `CGImage` 这个对象获取的。下一步，设置 `interpolationQuality` 属性为 `.high` 指示上下文在保证一定的精度上填充像素。`draw(_:in:)` 方法则是在给定的宽高和位置绘制图像，可以让图片在特定的边距下裁剪，也可以适用于一些像是人脸识别之类的图像特性。最后 `makeImage()` 从上下文获取信息并且渲染到一个 `CGImage` 值上（之后会用来构造 `UIImage` 对象）。



### 技巧 #3：使用 Image I/O 创建缩略图像

Image I/O 是一个强大（却鲜有人知）的图像处理框架。抛开 Core Graphics 不说，它可以读写许多不同图像格式，访问图像的元数据，还有执行常规的图像处理操作。这个框架通过先进的缓存机制，提供了平台上最快的图片编码器和解码器，甚至可以增量加载图片。

这个重要的 `CGImageSourceCreateThumbnailAtIndex` 提供了一个带有许多不同配置选项的 API，比起在 Core Graphics 中等价的处理操作要简洁得多：

```
import ImageIO

// 技巧 #3
func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
    ]

    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    else {
        return nil
    }

    return UIImage(cgImage: image)
}
```

给定一个 `CGImageSource` 和一系列配置选项，`CGImageSourceCreateThumbnailAtIndex(_:_:_:)` 函数创建了一个图像的缩略图。优化尺寸大小的操作是通过 `kCGImageSourceThumbnailMaxPixelSize` 完成的，它根据图像原始宽高比指定的最大尺寸来缩放图像。通过设定 `kCGImageSourceCreateThumbnailFromImageIfAbsent` 或 `kCGImageSourceCreateThumbnailFromImageAlways` 选项，Image I/O 可以自动缓存优化后的结果以便后续调用。

## 总结

- **UIKit**, **Core** **Graphics**, 和 **Image** **I/O** 都能很好地用于大部分图片的优化操作。
- 如果（在 iOS 平台，至少）要选择一个的话，`UIGraphicsImageRenderer` 是你最佳的选择。
- **Core** **Image** 在图像优化渲染操作方面性能表现优越。实际上，根据 Apple 官方 [*Core* *Image* *编程规范中的性能最佳实践单元*](https://developer.apple.com/library/mac/documentation/graphicsimaging/Conceptual/CoreImaging/ci_performance/ci_performance.html#//apple_ref/doc/uid/TP30001185-CH10-SW1)，你应该使用 Core Graphics 或 Image I/O 对图像进行裁剪和下采样，而不是用 Core Image。
- 除非你已经在使用 **`vImage`**，否则在大多数情况下用到底层的 Accelerate API 所需的额外工作可能是不合理的。

> 本文由 SwiftGG 翻译组翻译，已经获得作者翻译授权，最新文章请访问 [http://swift.gg](http://swift.gg/)。


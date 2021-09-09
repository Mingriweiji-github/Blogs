# Flutter 报错

## CustomScrollView: A RenderViewport expected a child of type RenderSliver but received a child of type RenderPadding

![image-20210630184303404](https://raw.githubusercontent.com/Mingriweiji-github/ImageBed/master/img/20210630184317.png)

**slivers中的 widget 必须是SliverToBoxAdapter的 child**

```dart
List<Widget> _initChilds() {
    tabs.add(SliverToBoxAdapter(
        child: Container(),
      ));
}
```


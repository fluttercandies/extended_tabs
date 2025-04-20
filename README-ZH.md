# extended_tabs

[![pub package](https://img.shields.io/pub/v/extended_tabs.svg)](https://pub.dartlang.org/packages/extended_tabs) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/issues) <a href="https://qm.qq.com/q/ZyJbSVjfSU"><img src="https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffluttercandies%2F.github%2Frefs%2Fheads%2Fmain%2Fdata.yml&query=%24.qq_group_number&style=for-the-badge&label=QQ%E7%BE%A4&logo=qq&color=1DACE8" /></a>

语言: [English](README.md) | 中文简体

强大的官方 Tab/TabBar/TabView 扩展组件, 支持 TabView 嵌套滚动，支持设置滚动方向和缓存大小。

[在线例子](https://fluttercandies.github.io/extended_tabs/)

[Flutter 扩展的联动Tabs](https://juejin.im/post/5c34b87ef265da61553b01a8)

![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_tab/link.gif)

![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_tab/scrollDirection.gif) 

- [extended_tabs](#extended_tabs)
  - [使用](#使用)
    - [传送带指示器](#传送带指示器)
    - [色块指示器](#色块指示器)
    - [嵌套滚动](#嵌套滚动)
    - [滚动方向](#滚动方向)
    - [缓存大小](#缓存大小)
    - [ShouldIgnorePointerWhenScrolling](#shouldignorepointerwhenscrolling)
  - [☕️Buy me a coffee](#️buy-me-a-coffee)

## 使用

``` yaml
dependencies:
  flutter:
    sdk: flutter
  extended_tabs: any
```

### 传送带指示器
``` dart
   CarouselIndicator(
     controller: _controller,
     selectedColor: Colors.white,
     unselectedColor: Colors.grey,
     strokeCap: StrokeCap.round,
     indicatorPadding: const EdgeInsets.all(5),
   ),
```
### 色块指示器

``` dart
    TabBar(
      indicator: ColorTabIndicator(Colors.blue),
      labelColor: Colors.black,
      tabs: [
        Tab(text: "Tab0"),
        Tab(text: "Tab1"),
      ],
      controller: tabController,
    )
```
### 嵌套滚动
``` dart
  /// 如果开启，当当前TabBarView不能滚动的时候，会去查看父和子TabBarView是否能滚动，
  /// 如果能滚动就会直接滚动父和子
  /// 默认开启
  final bool link;
  
  ExtendedTabBarView(
    children: <Widget>[
      List("Tab000"),
      List("Tab001"),
      List("Tab002"),
      List("Tab003"),
    ],
    controller: tabController2,
    link: true,
  )
```

### 滚动方向

``` dart
  /// 滚动方向
  /// 默认为水平滚动
  final Axis scrollDirection;

  Row(
    children: <Widget>[
      ExtendedTabBar(
        indicator: const ColorTabIndicator(Colors.blue),
        labelColor: Colors.black,
        scrollDirection: Axis.vertical,
        tabs: const <ExtendedTab>[
          ExtendedTab(
            text: 'Tab0',
            scrollDirection: Axis.vertical,
          ),
          ExtendedTab(
            text: 'Tab1',
            scrollDirection: Axis.vertical,
          ),
        ],
        controller: tabController,
      ),
      Expanded(
        child: ExtendedTabBarView(
          children: <Widget>[
            const ListWidget(
              'Tab1',
              scrollDirection: Axis.horizontal,
            ),
            const ListWidget(
              'Tab1',
              scrollDirection: Axis.horizontal,
            ),
          ],
          controller: tabController,
          scrollDirection: Axis.vertical,
        ),
      )
    ],
  )
``` 
### 缓存大小
``` dart
  /// 缓存页面的个数
  /// 默认为0
  /// 如果设置为1，那么意味内存里面有两页
  final int cacheExtent;
  
  ExtendedTabBarView(
    children: <Widget>[
      List("Tab000"),
      List("Tab001"),
      List("Tab002"),
      List("Tab003"),
    ],
    controller: tabController2,
    cacheExtent: 1,
  )  
```

### ShouldIgnorePointerWhenScrolling

当 Scrollable 滚动未停止的时候，是默认阻止其内容获得 hittest， 这就会导致在快速切换 tab 的时候，
给人一种不能马上操作内容的感觉。

为了解决这个问题你可以通过下面2种方式来处理：

1. 将 ShouldIgnorePointerWhenScrolling 设置成false，这样的话 Scrollable 在滚动中也不会阻止内容获得 hittest
2. 可以设置 LessSpringClampingScrollPhysics 让滚动动画更快结束

``` dart
  /// Whether the contents of the widget should ignore [PointerEvent] inputs.
  ///
  /// Setting this value to true prevents the use from interacting with the
  /// contents of the widget with pointer events. The widget itself is still
  /// interactive.
  ///
  /// For example, if the scroll position is being driven by an animation, it
  /// might be appropriate to set this value to ignore pointer events to
  /// prevent the user from accidentally interacting with the contents of the
  /// widget as it animates. The user will still be able to touch the widget,
  /// potentially stopping the animation.
  ///
  ///
  /// if true, child can't accept event before [ExtendedPageView],[ExtendedScrollable] stop scroll.
  ///
  ///
  /// if false, child can accept event before [ExtendedPageView],[ExtendedScrollable] stop scroll.
  /// notice: we don't know there are any issues if we don't ignore [PointerEvent] inputs when it's scrolling.
  ///
  ///
  /// Two way to solve issue that child can't hittest before [PageView] stop scroll.
  /// 1. set [shouldIgnorePointerWhenScrolling] false
  /// 2. use LessSpringClampingScrollPhysics to make animation quickly
  ///
  /// default is true.
  final bool shouldIgnorePointerWhenScrolling;
  
  ExtendedTabBarView(
    children: <Widget>[
      List("Tab000"),
      List("Tab001"),
      List("Tab002"),
      List("Tab003"),
    ],
    controller: tabController2,
    shouldIgnorePointerWhenScrolling: false,
    cacheExtent: 1,
  )  
```

## ☕️Buy me a coffee

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)

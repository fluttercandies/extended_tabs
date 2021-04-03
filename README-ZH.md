# extended_tabs

[![pub package](https://img.shields.io/pub/v/extended_tabs.svg)](https://pub.dartlang.org/packages/extended_tabs) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

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

## ☕️Buy me a coffee

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)

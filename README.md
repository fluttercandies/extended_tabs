# extended_tabs

[![pub package](https://img.shields.io/pub/v/extended_tabs.svg)](https://pub.dartlang.org/packages/extended_tabs) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: English | [中文简体](README-ZH.md)


A powerful official extension library of Tab/TabBar/TabView, which support to scroll ancestor or child Tabs when current is overscroll, and set scroll direction and cache extent.

[Web demo for ExtendedTabs](https://fluttercandies.github.io/extended_tabs/)


![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_tab/link.gif)

![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_tab/scrollDirection.gif) 

- [extended_tabs](#extended_tabs)
  - [Usage](#usage)
    - [CarouselIndicator](#carouselindicator)
    - [ColorTabIndicator](#colortabindicator)
    - [Link](#link)
    - [ScrollDirection](#scrolldirection)
    - [CacheExtent](#cacheextent)

## Usage

``` yaml
dependencies:
  flutter:
    sdk: flutter
  extended_tabs: any
```

### CarouselIndicator
Show tab indicator  as Carousel style
``` dart
   CarouselIndicator(
     controller: _controller,
     selectedColor: Colors.white,
     unselectedColor: Colors.grey,
     strokeCap: StrokeCap.round,
     indicatorPadding: const EdgeInsets.all(5),
   ),
```
### ColorTabIndicator
Show tab indicator with color fill
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
### Link
``` dart
  /// if link is true and current tabbarview over scroll,
  /// it will check and scroll ancestor or child tabbarView.
  /// default is true
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

### ScrollDirection

``` dart
  /// The axis along which the tab bar and tab view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
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
### CacheExtent
``` dart
  /// cache page count
  /// default is 0.
  /// if cacheExtent is 1, it has two pages in cache
  final int cacheExtent;
  
  ExtendedTabBarView(
    children: <Widget>[
      List("Tab000"),
      List("Tab001"),
      List("Tab002"),
      List("Tab003"),
    ],
    controller: tabController2,
    linkWithAncestor: true,
    cacheExtent: 1,
  )  
```
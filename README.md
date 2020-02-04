# extended_tabs

[![pub package](https://img.shields.io/pub/v/extended_tabs.svg)](https://pub.dartlang.org/packages/extended_tabs) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_tabs)](https://github.com/fluttercandies/extended_tabs/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

extended tab bar view include color tabIndicator,linkWithAncestor(scroll ancestor tabbarView when current is over scroll),page cache extent

[Web demo for ExtendedTabs](https://fluttercandies.github.io/extended_tabs/)

[Chinese blog](https://juejin.im/post/5c34b87ef265da61553b01a8)

![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_tab/extended_tab.gif)

## Usage

To use this plugin, add `extended_tabs` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

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
### linkWithAncestor
``` dart
  ///if linkedParentTabBarView is true and current tabbarview over scroll,
  ///it will check whether ancestor tabbarView can be scroll
  ///then scroll ancestor tabbarView
  final bool linkWithAncestor;
  
  
  ExtendedTabBarView(
   children: <Widget>[
   List("Tab000"),
   List("Tab001"),
   List("Tab002"),
   List("Tab003"),
   ],
   controller: tabController2,
   linkWithAncestor: true,
   )
```

### cacheExtent
``` dart
  /// cache page count
  /// default is 0.
  /// if cacheExtent is 1, it has two pages in cache
  /// null is infinity, it will cache all pages
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

Please see the example app of this plugin for a full example.

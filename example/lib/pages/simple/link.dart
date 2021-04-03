import 'package:example/widget/list.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://link',
  routeName: 'Link',
  description:
      'if link is true and current tabbarview over scroll,it will check and scroll ancestor or child tabbarView.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class LinkDemo extends StatefulWidget {
  @override
  _LinkDemoState createState() => _LinkDemoState();
}

class _LinkDemoState extends State<LinkDemo> with TickerProviderStateMixin {
  late TabController tabController;
  late TabController tabController1;
  late TabController tabController2;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController1 = TabController(length: 3, vsync: this);
    tabController2 = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    tabController1.dispose();
    tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: <Widget>[
          TabBar(
            indicator: const ColorTabIndicator(Colors.blue),
            labelColor: Colors.black,
            tabs: const <Tab>[
              Tab(text: 'Tab0'),
              Tab(text: 'Tab1'),
            ],
            controller: tabController,
          ),
          Expanded(
            child: ExtendedTabBarView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    TabBar(
                      indicator: const ColorTabIndicator(Colors.red),
                      labelColor: Colors.black,
                      tabs: const <Tab>[
                        Tab(text: 'Tab00'),
                        Tab(text: 'Tab01'),
                        Tab(text: 'Tab02'),
                      ],
                      controller: tabController1,
                    ),
                    Expanded(
                      child: ExtendedTabBarView(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              TabBar(
                                indicator:
                                    const ColorTabIndicator(Colors.green),
                                labelColor: Colors.black,
                                //indicatorSize: TabBarIndicatorSize.label,
                                tabs: const <Tab>[
                                  Tab(text: 'Tab000'),
                                  Tab(text: 'Tab001'),
                                  Tab(text: 'Tab002'),
                                  Tab(text: 'Tab003'),
                                ],
                                controller: tabController2,
                              ),
                              Expanded(
                                child: ExtendedTabBarView(
                                  children: const <Widget>[
                                    ListWidget('Tab000'),
                                    ListWidget('Tab001'),
                                    ListWidget('Tab002'),
                                    ListWidget('Tab003'),
                                  ],
                                  controller: tabController2,

                                  /// if link is true and current tabbarview over scroll,
                                  /// it will check and scroll ancestor or child tabbarView.
                                  link: true,

                                  /// cache page count
                                  /// default is 0.
                                  /// if cacheExtent is 1, it has two pages in cache
                                  /// null is infinity, it will cache all pages
                                  cacheExtent: 1,
                                ),
                              )
                            ],
                          ),
                          const ListWidget('Tab01'),
                          const ListWidget('Tab02'),
                        ],
                        controller: tabController1,
                      ),
                    )
                  ],
                ),
                const ListWidget('Tab1')
              ],
              controller: tabController,
            ),
          )
        ],
      ),
    );
  }
}

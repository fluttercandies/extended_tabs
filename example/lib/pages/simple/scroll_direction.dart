import 'package:example/widget/list.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://scroll_direction',
  routeName: 'ScrollDirection',
  description: 'set scroll direction of tabbar and tabView',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 1,
  },
)
class SrollDirectionDemo extends StatefulWidget {
  @override
  _SrollDirectionDemoState createState() => _SrollDirectionDemoState();
}

class _SrollDirectionDemoState extends State<SrollDirectionDemo>
    with TickerProviderStateMixin {
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
      child: Row(
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
                Row(
                  children: <Widget>[
                    ExtendedTabBar(
                      indicator: const ColorTabIndicator(Colors.red),
                      labelColor: Colors.black,
                      scrollDirection: Axis.vertical,
                      tabs: const <ExtendedTab>[
                        ExtendedTab(
                          text: 'Tab00',
                          scrollDirection: Axis.vertical,
                        ),
                        ExtendedTab(
                          text: 'Tab01',
                          scrollDirection: Axis.vertical,
                        ),
                        ExtendedTab(
                          text: 'Tab02',
                          scrollDirection: Axis.vertical,
                        ),
                      ],
                      controller: tabController1,
                    ),
                    Expanded(
                      child: ExtendedTabBarView(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              ExtendedTabBar(
                                indicator:
                                    const ColorTabIndicator(Colors.green),
                                labelColor: Colors.black,
                                scrollDirection: Axis.vertical,
                                //indicatorSize: TabBarIndicatorSize.label,
                                tabs: const <ExtendedTab>[
                                  ExtendedTab(
                                    text: 'Tab000',
                                    scrollDirection: Axis.vertical,
                                    //size: 48,
                                  ),
                                  ExtendedTab(
                                    text: 'Tab001',
                                    scrollDirection: Axis.vertical,
                                  ),
                                  ExtendedTab(
                                    text: 'Tab002',
                                    scrollDirection: Axis.vertical,
                                  ),
                                  ExtendedTab(
                                    text: 'Tab003',
                                    scrollDirection: Axis.vertical,
                                  ),
                                ],
                                controller: tabController2,
                              ),
                              Expanded(
                                child: ExtendedTabBarView(
                                  children: const <Widget>[
                                    ListWidget(
                                      'Tab000',
                                      scrollDirection: Axis.horizontal,
                                    ),
                                    ListWidget(
                                      'Tab001',
                                      scrollDirection: Axis.horizontal,
                                    ),
                                    ListWidget(
                                      'Tab002',
                                      scrollDirection: Axis.horizontal,
                                    ),
                                    ListWidget(
                                      'Tab003',
                                      scrollDirection: Axis.horizontal,
                                    ),
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
                                  scrollDirection: Axis.vertical,
                                ),
                              )
                            ],
                          ),
                          const ListWidget(
                            'Tab01',
                            scrollDirection: Axis.horizontal,
                          ),
                          const ListWidget(
                            'Tab02',
                            scrollDirection: Axis.horizontal,
                          ),
                        ],
                        controller: tabController1,
                        scrollDirection: Axis.vertical,
                      ),
                    )
                  ],
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
      ),
    );
  }
}

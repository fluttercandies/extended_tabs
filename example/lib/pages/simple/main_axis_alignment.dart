import 'package:extended_tabs/extended_tabs.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://MainAxisAlignment',
  routeName: 'MainAxisAlignment',
  description: 'set MainAxisAlignment for ExtendedTabBar',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 3,
  },
)
class MainAxisAlignmentDemo extends StatefulWidget {
  const MainAxisAlignmentDemo({super.key});

  @override
  State<MainAxisAlignmentDemo> createState() => _MainAxisAlignmentDemoState();
}

class _MainAxisAlignmentDemoState extends State<MainAxisAlignmentDemo>
    with TickerProviderStateMixin {
  late TabController _controller;
  TextDirection _textDirection = TextDirection.ltr;
  MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.spaceBetween;
  TabBarIndicatorSize _tabBarIndicatorSize = TabBarIndicatorSize.label;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _textDirection,
      child: Column(
        children: <Widget>[
          DropdownButton<TextDirection>(
            items: TextDirection.values
                .map(
                  (TextDirection textDirection) =>
                      DropdownMenuItem<TextDirection>(
                    value: textDirection,
                    child: Text(textDirection.toString()),
                  ),
                )
                .toList(),
            value: _textDirection,
            onChanged: (TextDirection? textDirection) {
              setState(() {
                _textDirection = textDirection!;
              });
            },
          ),
          DropdownButton<MainAxisAlignment>(
            items: MainAxisAlignment.values
                .map(
                  (MainAxisAlignment mainAxisAlignment) =>
                      DropdownMenuItem<MainAxisAlignment>(
                    value: mainAxisAlignment,
                    child: Text(mainAxisAlignment.toString()),
                  ),
                )
                .toList(),
            value: _mainAxisAlignment,
            onChanged: (MainAxisAlignment? mainAxisAlignment) {
              setState(() {
                _mainAxisAlignment = mainAxisAlignment!;
              });
            },
          ),
          DropdownButton<TabBarIndicatorSize>(
            items: TabBarIndicatorSize.values
                .map(
                  (tabBarIndicatorSize) =>
                      DropdownMenuItem<TabBarIndicatorSize>(
                    value: tabBarIndicatorSize,
                    child: Text(tabBarIndicatorSize.toString()),
                  ),
                )
                .toList(),
            value: _tabBarIndicatorSize,
            onChanged: (TabBarIndicatorSize? tabBarIndicatorSize) {
              setState(() {
                _tabBarIndicatorSize = tabBarIndicatorSize!;
              });
            },
          ),
          // DropdownButton<int>(
          //   items: const <DropdownMenuItem<int>>[
          //     DropdownMenuItem<int>(
          //       child: Text('5 tabs'),
          //       value: 5,
          //     ),
          //     DropdownMenuItem<int>(
          //       child: Text('15 tabs'),
          //       value: 15,
          //     ),
          //   ],
          //   value: _controller.length,
          //   onChanged: (int? count) {
          //     setState(() {
          //       _controller.dispose();
          //       _controller = TabController(length: count!, vsync: this);
          //     });
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ExtendedTabBar(
              tabs: List<Widget>.generate(
                _controller.length,
                (int index) => Tab(
                  text: 'Tab$index',
                ),
              ).toList(),
              controller: _controller,
              labelPadding: EdgeInsets.zero,
              labelColor: Colors.blue,
              isScrollable: _controller.length > 5,
              indicatorSize: _tabBarIndicatorSize,
              mainAxisAlignment: _mainAxisAlignment,
              indicator: const ExtendedUnderlineTabIndicator(
                //size: 31,
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: List<Widget>.generate(
                _controller.length,
                (int index) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                  ),
                  margin: const EdgeInsets.all(
                    15,
                  ),
                  alignment: Alignment.center,
                  child: Text('I\'m tab $index'),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

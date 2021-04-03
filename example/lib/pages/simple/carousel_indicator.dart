import 'package:extended_tabs/extended_tabs.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://CarouselIndicator',
  routeName: 'CarouselIndicator',
  description: 'Carousel Indicator',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 2,
  },
)
class CarouselIndicatorDemo extends StatefulWidget {
  @override
  _CarouselIndicatorDemoState createState() => _CarouselIndicatorDemoState();
}

class _CarouselIndicatorDemoState extends State<CarouselIndicatorDemo>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
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
    return ColoredBox(
      color: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: <Widget>[
            Expanded(
                child: ExtendedTabBarView(
              controller: _controller,
              children: <Widget>[
                Container(color: Colors.red),
                Container(color: Colors.green),
                Container(color: Colors.blue),
                Container(color: Colors.yellow),
                Container(color: Colors.purple),
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CarouselIndicator(
                controller: _controller,
                selectedColor: Colors.white,
                unselectedColor: Colors.grey,
                strokeCap: StrokeCap.round,
                indicatorPadding: const EdgeInsets.all(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

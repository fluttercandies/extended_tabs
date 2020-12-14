import 'package:flutter/material.dart';

class ListWidget extends StatelessWidget {
  const ListWidget(this.tabKey, {this.scrollDirection = Axis.vertical});
  final String tabKey;
  final Axis scrollDirection;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext c, int i) {
        return Container(
            //decoration: BoxDecoration(border: Border.all(color: Colors.orange,width: 1.0)),
            alignment: Alignment.center,
            height: 60.0,
            child: Text('$tabKey : List$i'));
      },
      itemCount: 100,
      scrollDirection: scrollDirection,
    );
  }
}

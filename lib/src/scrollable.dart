import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Provide a way for contents get hit test when it's scrolling
class ExtendedScrollable extends Scrollable {
  const ExtendedScrollable({
    Key? key,
    AxisDirection axisDirection = AxisDirection.down,
    ScrollController? controller,
    ScrollPhysics? physics,
    required ViewportBuilder viewportBuilder,
    ScrollIncrementCalculator? incrementCalculator,
    bool excludeFromSemantics = false,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    String? restorationId,
    ScrollBehavior? scrollBehavior,
    this.shouldIgnorePointerWhenScrolling = true,
  }) : super(
          key: key,
          axisDirection: axisDirection,
          controller: controller,
          physics: physics,
          viewportBuilder: viewportBuilder,
          incrementCalculator: incrementCalculator,
          excludeFromSemantics: excludeFromSemantics,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          restorationId: restorationId,
          scrollBehavior: scrollBehavior,
        );
  final bool shouldIgnorePointerWhenScrolling;

  @override
  ExtendedScrollableState createState() => ExtendedScrollableState();
}

class ExtendedScrollableState extends ScrollableState {
  @override
  void setIgnorePointer(bool value) {
    final scrollable = widget as ExtendedScrollable;
    if (scrollable.shouldIgnorePointerWhenScrolling) {
      super.setIgnorePointer(value);
    }
  }
}

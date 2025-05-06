import 'package:flutter/material.dart';

/// Provide a way for contents get hit test when it's scrolling
class ExtendedScrollable extends Scrollable {
  const ExtendedScrollable({
    super.key,
    super.axisDirection,
    super.controller,
    super.physics,
    required super.viewportBuilder,
    super.incrementCalculator,
    super.excludeFromSemantics,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.restorationId,
    super.scrollBehavior,
    this.shouldIgnorePointerWhenScrolling = true,
  });

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

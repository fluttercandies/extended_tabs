import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'tab_bar.dart';

class CarouselIndicator extends StatelessWidget {
  const CarouselIndicator({
    this.controller,
    this.size = const Size(20, 5),
    this.unselectedColor,
    this.selectedColor,
    this.strokeCap = StrokeCap.square,
    this.indicatorPadding = const EdgeInsets.symmetric(horizontal: 5),
    this.tapEnable = false,
  });

  /// Coordinates tab selection between a [CarouselIndicator] and a [TabBarView].
  final TabController? controller;

  /// The Size of indicator
  final Size size;

  /// The color of the indicator that appears below the selected tab.
  final Color? unselectedColor;

  /// The color of the indicator that appears below the unselected tab.
  final Color? selectedColor;

  /// Styles to use for indicator endings.
  final StrokeCap strokeCap;

  /// The padding for the indicator that appears below the selected tab.
  final EdgeInsets indicatorPadding;

  final bool tapEnable;
  @override
  Widget build(BuildContext context) {
    final TabController? controller =
        this.controller ?? DefaultTabController.of(context);
    assert(() {
      if (controller == null) {
        throw FlutterError('No TabController for $runtimeType.\n'
            'When creating a $runtimeType, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the $runtimeType.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());
    final TabBarTheme tabBarTheme = TabBarTheme.of(context);
    final Color selectedColor =
        this.selectedColor ?? Theme.of(context).indicatorColor;
    final Color unselectedColor = this.unselectedColor ??
        tabBarTheme.unselectedLabelColor ??
        selectedColor.withOpacity(0.3);
    return IntrinsicWidth(
      child: IgnorePointer(
        ignoring: !tapEnable,
        child: _TabBar(
          indicator: _UnderlineTabIndicator(
            borderSide: BorderSide(
              width: size.height,
              color: selectedColor,
            ),
            strokeCap: strokeCap,
            insets: indicatorPadding.copyWith(left: 0, right: 0),
          ),
          controller: controller!,
          tabs: List<Widget>.filled(
            controller.length,
            CustomPaint(
              painter: _UnSelectedIndicatorPainter(
                unselectedColor,
                strokeCap,
              ),
              size: size,
            ),
          ),
          size: size,
          indicatorPadding: indicatorPadding,
        ),
      ),
    );
  }
}

class _TabBar extends ExtendedTabBar {
  const _TabBar({
    Key? key,
    required List<Widget> tabs,
    required TabController controller,
    EdgeInsetsGeometry indicatorPadding = EdgeInsets.zero,
    Decoration? indicator,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    MouseCursor? mouseCursor,
    ScrollPhysics? physics,
    this.size,
  }) : super(
          key: key,
          tabs: tabs,
          controller: controller,
          isScrollable: false,
          indicatorPadding: indicatorPadding,
          indicator: indicator,
          labelPadding: indicatorPadding,
          indicatorSize: TabBarIndicatorSize.label,
          dragStartBehavior: dragStartBehavior,
          mouseCursor: mouseCursor,
          physics: physics,
          foregroundIndicator: true,
        );
  final Size? size;

  @override
  Size get preferredSize => size ?? super.preferredSize;
}

class _UnSelectedIndicatorPainter extends CustomPainter {
  const _UnSelectedIndicatorPainter(
    this.color,
    this.strokeCap,
  );
  final Color color;
  final StrokeCap strokeCap;
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomRight,
      Paint()
        ..color = color
        ..strokeCap = strokeCap
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height,
    );
  }

  @override
  bool shouldRepaint(covariant _UnSelectedIndicatorPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeCap != strokeCap;
  }
}

/// Used with [TabBar.indicator] to draw a horizontal line below the
/// selected tab.
///
/// The selected tab underline is inset from the tab's boundary by [insets].
/// The [borderSide] defines the line's color and weight.
///
/// The [TabBar.indicatorSize] property can be used to define the indicator's
/// bounds in terms of its (centered) widget with [TabBarIndicatorSize.label],
/// or the entire tab with [TabBarIndicatorSize.tab].
class _UnderlineTabIndicator extends Decoration {
  /// Create an underline style selected tab indicator.
  ///
  /// The [borderSide] and [insets] arguments must not be null.
  const _UnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.strokeCap = StrokeCap.square,
  });

  /// The color and weight of the horizontal line drawn below the selected tab.
  final BorderSide borderSide;

  /// Locates the selected tab's underline relative to the tab's boundary.
  ///
  /// The [TabBar.indicatorSize] property can be used to define the tab
  /// indicator's bounds in terms of its (centered) tab widget with
  /// [TabBarIndicatorSize.label], or the entire tab with
  /// [TabBarIndicatorSize.tab].
  final EdgeInsetsGeometry insets;

  /// Styles to use for line endings.
  final StrokeCap strokeCap;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is _UnderlineTabIndicator) {
      return _UnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is _UnderlineTabIndicator) {
      return _UnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return Rect.fromLTWH(
      indicator.left,
      indicator.top,
      indicator.width,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  final _UnderlineTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration._indicatorRectFor(rect, textDirection);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = decoration.strokeCap;
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}

import 'package:flutter/material.dart';

class ColorTabIndicator extends Decoration {
  const ColorTabIndicator(this.color);

  /// The color and weight of the horizontal line drawn below the selected tab.
  final Color color;

  @override
  Decoration lerpFrom(Decoration a, double t) {
    return super.lerpFrom(a, t);
  }

  @override
  Decoration lerpTo(Decoration b, double t) {
    return super.lerpTo(b, t);
  }

  @override
  _ColorPainter createBoxPainter([VoidCallback onChanged]) {
    return _ColorPainter(this, onChanged);
  }
}

class _ColorPainter extends BoxPainter {
  _ColorPainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  final ColorTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final Paint paint = Paint();
    paint.color = decoration.color;
    canvas.drawRect(rect, paint);
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
class ExtendedUnderlineTabIndicator extends Decoration {
  /// Create an underline style selected tab indicator.
  ///
  /// The [borderSide] and [insets] arguments must not be null.
  const ExtendedUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.scrollDirection = Axis.horizontal,
    this.strokeCap = StrokeCap.square,
  })  : assert(borderSide != null),
        assert(insets != null);

  /// The color and weight of the horizontal line drawn below the selected tab.
  final BorderSide borderSide;

  /// Locates the selected tab's underline relative to the tab's boundary.
  ///
  /// The [TabBar.indicatorSize] property can be used to define the tab
  /// indicator's bounds in terms of its (centered) tab widget with
  /// [TabBarIndicatorSize.label], or the entire tab with
  /// [TabBarIndicatorSize.tab].
  final EdgeInsetsGeometry insets;

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Styles to use for line endings.
  final StrokeCap strokeCap;

  @override
  Decoration lerpFrom(Decoration a, double t) {
    if (a is ExtendedUnderlineTabIndicator) {
      return ExtendedUnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t),
        scrollDirection: a.scrollDirection,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration lerpTo(Decoration b, double t) {
    if (b is ExtendedUnderlineTabIndicator) {
      return ExtendedUnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
        scrollDirection: b.scrollDirection,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(
      Rect rect, TextDirection textDirection, Axis scrollDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);

    return scrollDirection == Axis.horizontal
        ? Rect.fromLTWH(
            indicator.left,
            indicator.bottom - borderSide.width,
            indicator.width,
            borderSide.width,
          )
        : Rect.fromLTWH(
            textDirection == TextDirection.rtl
                ? indicator.left
                : indicator.right - borderSide.width,
            indicator.top,
            borderSide.width,
            indicator.height,
          );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()
      ..addRect(_indicatorRectFor(rect, textDirection, scrollDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  final ExtendedUnderlineTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    final Rect indicator = decoration
        ._indicatorRectFor(rect, textDirection, decoration.scrollDirection)
        .deflate(decoration.borderSide.width / 2.0);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = decoration.strokeCap;
    switch (decoration.scrollDirection) {
      case Axis.horizontal:
        canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
        break;
      case Axis.vertical:
        canvas.drawLine(indicator.topRight, indicator.bottomRight, paint);
        break;
      default:
    }
  }
}

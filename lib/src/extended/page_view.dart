import 'package:extended_tabs/src/extended/scrollable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

part 'package:extended_tabs/src/official/page_view.dart';

class ExtendedPageView extends _PageView {
  ExtendedPageView({
    super.key,
    super.scrollDirection = Axis.horizontal,
    super.reverse = false,
    super.controller,
    super.physics,
    super.pageSnapping = true,
    super.onPageChanged,
    super.children = const <Widget>[],
    super.dragStartBehavior = DragStartBehavior.start,
    super.allowImplicitScrolling = false,
    super.restorationId,
    super.clipBehavior = Clip.hardEdge,
    super.scrollBehavior,
    super.padEnds = true,
    this.cacheExtent = 0,
    this.shouldIgnorePointerWhenScrolling = true,
  });

  ExtendedPageView.builder({
    super.key,
    super.scrollDirection = Axis.horizontal,
    super.reverse = false,
    super.controller,
    super.physics,
    super.pageSnapping = true,
    super.onPageChanged,
    required super.itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.dragStartBehavior = DragStartBehavior.start,
    super.allowImplicitScrolling = false,
    super.restorationId,
    super.clipBehavior = Clip.hardEdge,
    super.scrollBehavior,
    super.padEnds = true,
    this.cacheExtent = 0,
    this.shouldIgnorePointerWhenScrolling = true,
  }) : super.builder();

  ExtendedPageView.custom({
    super.key,
    super.scrollDirection = Axis.horizontal,
    super.reverse = false,
    super.controller,
    super.physics,
    super.pageSnapping = true,
    super.onPageChanged,
    required super.childrenDelegate,
    super.dragStartBehavior = DragStartBehavior.start,
    super.allowImplicitScrolling = false,
    super.restorationId,
    super.clipBehavior = Clip.hardEdge,
    super.scrollBehavior,
    super.padEnds = true,
    this.cacheExtent = 0,
    this.shouldIgnorePointerWhenScrolling = true,
  }) : super.custom();

  /// cache page count
  /// default is 0.
  /// if cacheExtent is 1, it has two pages in cache
  /// null is infinity, it will cache all pages
  final int cacheExtent;

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
  State<ExtendedPageView> createState() => _ExtendedPageViewState();
}

class _ExtendedPageViewState extends _PageViewState<ExtendedPageView> {
  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = _ForceImplicitScrollPhysics(
      allowImplicitScrolling: widget.allowImplicitScrolling,
    ).applyTo(
      widget.pageSnapping
          ? _kPagePhysics.applyTo(
              widget.physics ??
                  widget.scrollBehavior?.getScrollPhysics(context),
            )
          : widget.physics ?? widget.scrollBehavior?.getScrollPhysics(context),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            widget.onPageChanged != null &&
            notification is ScrollUpdateNotification) {
          final PageMetrics metrics = notification.metrics as PageMetrics;
          final int currentPage = metrics.page!.round();
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged!(currentPage);
          }
        }
        return false;
      },
      child: ExtendedScrollable(
        // zmtzawqlp
        shouldIgnorePointerWhenScrolling:
            widget.shouldIgnorePointerWhenScrolling,
        dragStartBehavior: widget.dragStartBehavior,
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        restorationId: widget.restorationId,
        scrollBehavior: widget.scrollBehavior ??
            ScrollConfiguration.of(context).copyWith(scrollbars: false),
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            // TODO(dnfield): we should provide a way to set cacheExtent
            // independent of implicit scrolling:
            // https://github.com/flutter/flutter/issues/45632
            // zmtzawqlp
            cacheExtent: widget.cacheExtent > 0
                ? widget.cacheExtent.toDouble()
                : (widget.allowImplicitScrolling ? 1.0 : 0.0),
            cacheExtentStyle: CacheExtentStyle.viewport,
            axisDirection: axisDirection,
            offset: position,
            clipBehavior: widget.clipBehavior,
            slivers: <Widget>[
              SliverFillViewport(
                viewportFraction: widget.controller.viewportFraction,
                delegate: widget.childrenDelegate,
                padEnds: widget.padEnds,
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:extended_tabs/src/extended/page_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sync_scroll_library/sync_scroll_library.dart';
part 'package:extended_tabs/src/official/tabs.dart';

const ScrollPhysics _defaultScrollPhysics = NeverScrollableScrollPhysics();

class ExtendedTabBarView extends _TabBarView {
  const ExtendedTabBarView({
    super.key,
    required super.children,
    super.controller,
    super.physics,
    super.dragStartBehavior = DragStartBehavior.start,
    super.viewportFraction = 1.0,
    super.clipBehavior = Clip.hardEdge,
    this.cacheExtent = 0,
    this.link = true,
    this.pageController,
    this.shouldIgnorePointerWhenScrolling = true,
    this.scrollDirection = Axis.horizontal,
  });

  /// cache page count
  /// default is 0.
  /// if cacheExtent is 1, it has two pages in cache
  final int cacheExtent;

  /// if link is true and current tabbarview over scroll,
  /// it will check and scroll ancestor or child tabbarView.
  /// default is true
  final bool link;

  /// The PageController inside, [PageController.initialPage] should the same as [TabController.initialIndex]
  final LinkPageController? pageController;

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

  /// The axis along which the tab view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  @override
  State<ExtendedTabBarView> createState() => ExtendedTabBarViewState();
}

class ExtendedTabBarViewState extends _TabBarViewState<ExtendedTabBarView> {
  @override
  bool get link => widget.link;

  @override
  LinkScrollControllerMixin get linkScrollController =>
      _pageController as LinkPageController;

  @override
  ScrollPhysics? get physics => widget.physics;

  @override
  Axis get scrollDirection => widget.scrollDirection;

  @override
  void didChangeDependencies() {
    _updateTabController();
    _currentIndex = _controller!.index;
    _pageController = widget.pageController ??
        LinkPageController(
          initialPage: _currentIndex ?? 0,
          viewportFraction: widget.viewportFraction,
        );
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ExtendedTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.pageController != null &&
            widget.pageController != oldWidget.pageController) ||
        widget.viewportFraction != oldWidget.viewportFraction) {
      _pageController = widget.pageController ??
          LinkPageController(
            initialPage: _currentIndex ?? 0,
            viewportFraction: widget.viewportFraction,
          );
    }

    if (widget.physics != oldWidget.physics) {
      updatePhysics();
    }

    if (oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.physics != widget.physics) {
      initGestureRecognizers();
    }
  }

  @override
  ScrollPhysics? getScrollPhysics() {
    return _defaultScrollPhysics.applyTo(
      widget.physics == null
          ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
          : const PageScrollPhysics().applyTo(widget.physics),
    );
  }

  @override
  // ignore: unnecessary_overrides
  void linkParent<S extends StatefulWidget, T extends LinkScrollState<S>>() {
    super.linkParent<ExtendedTabBarView, ExtendedTabBarViewState>();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.children.length) {
        throw FlutterError(
            'Controller\'s length property (${_controller!.length}) does not match the \n'
            'number of tabs (${widget.children.length}) present in TabBar\'s tabs property.');
      }
      return true;
    }());

    final result = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: ExtendedPageView(
          dragStartBehavior: widget.dragStartBehavior,
          controller: _pageController,
          cacheExtent: widget.cacheExtent,
          scrollDirection: widget.scrollDirection,
          physics: usedScrollPhysics,
          shouldIgnorePointerWhenScrolling:
              widget.shouldIgnorePointerWhenScrolling,
          children: _childrenWithKey,
        ),
      ),
    );

    return buildGestureDetector(child: result);
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth == 0 &&
        !(_pageController as LinkPageController).isSelf) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }
}

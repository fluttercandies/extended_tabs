// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:extended_tabs/src/page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:sync_scroll_library/sync_scroll_library.dart';

const ScrollPhysics _defaultScrollPhysics = NeverScrollableScrollPhysics();

/// A page view that displays the widget which corresponds to the currently
/// selected tab.
///
/// This widget is typically used in conjunction with a [TabBar].
///
/// If a [TabController] is not provided, then there must be a [DefaultTabController]
/// ancestor.
///
/// The tab controller's [TabController.length] must equal the length of the
/// [children] list and the length of the [TabBar.tabs] list.
///
/// To see a sample implementation, visit the [TabController] documentation.
class ExtendedTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const ExtendedTabBarView({
    Key? key,
    required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    this.cacheExtent = 0,
    this.link = true,
    this.scrollDirection = Axis.horizontal,
    this.pageController,
    this.shouldIgnorePointerWhenScrolling = true,
    this.viewportFraction = 1.0,
  }) : super(key: key);

  /// cache page count
  /// default is 0.
  /// if cacheExtent is 1, it has two pages in cache
  final int cacheExtent;

  /// if link is true and current tabbarview over scroll,
  /// it will check and scroll ancestor or child tabbarView.
  /// default is true
  final bool link;

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// One widget per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<Widget> children;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// The axis along which the tab view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

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

  /// {@macro flutter.widgets.pageview.viewportFraction}
  final double viewportFraction;

  @override
  ExtendedTabBarViewState createState() => ExtendedTabBarViewState();
}

class ExtendedTabBarViewState extends LinkScrollState<ExtendedTabBarView> {
  TabController? _controller;
  late LinkPageController _pageController;
  List<Widget>? _children;
  List<Widget>? _childrenWithKey;
  int? _currentIndex;
  int _warpUnderwayCount = 0;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError('No TabController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid)
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    _controller = newController;
    if (_controller != null)
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
  }

  @override
  ScrollPhysics? getScrollPhysics() {
    return _defaultScrollPhysics.applyTo(widget.physics == null
        ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
        : const PageScrollPhysics().applyTo(widget.physics));
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

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

    assert(_currentIndex == _pageController.initialPage);
  }

  @override
  void linkParent<S extends StatefulWidget, T extends LinkScrollState<S>>() {
    super.linkParent<ExtendedTabBarView, ExtendedTabBarViewState>();
  }

  @override
  void didUpdateWidget(ExtendedTabBarView oldWidget) {
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
      _currentIndex = _controller?.index;
    }
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
    if (widget.children != oldWidget.children && _warpUnderwayCount == 0)
      _updateChildren();

    if (oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.physics != widget.physics) {
      initGestureRecognizers();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controllerIsValid)
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    _controller = null;
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _updateChildren() {
    _children = widget.children;
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  void _handleTabControllerAnimationTick() {
    if (_warpUnderwayCount > 0 || !_controller!.indexIsChanging)
      return; // This widget is driving the controller's animation.

    if (_controller!.index != _currentIndex) {
      _currentIndex = _controller!.index;
      _warpToCurrentIndex();
    }
  }

  Future<void> _warpToCurrentIndex() async {
    if (!mounted) {
      return Future<void>.value();
    }

    if (_pageController.page == _currentIndex!.toDouble())
      return Future<void>.value();

    final int previousIndex = _controller!.previousIndex;
    if ((_currentIndex! - previousIndex).abs() == 1) {
      _warpUnderwayCount += 1;
      await _pageController.animateToPage(_currentIndex!,
          duration: kTabScrollDuration, curve: Curves.ease);
      _warpUnderwayCount -= 1;
      return Future<void>.value();
    }

    assert((_currentIndex! - previousIndex).abs() > 1);
    final int initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;
    final List<Widget>? originalChildren = _childrenWithKey;
    setState(() {
      _warpUnderwayCount += 1;

      _childrenWithKey = List<Widget>.from(_childrenWithKey!, growable: false);
      final Widget temp = _childrenWithKey![initialPage];
      _childrenWithKey![initialPage] = _childrenWithKey![previousIndex];
      _childrenWithKey![previousIndex] = temp;
    });
    _pageController.jumpToPage(initialPage);

    await _pageController.animateToPage(_currentIndex!,
        duration: kTabScrollDuration, curve: Curves.ease);
    if (!mounted) {
      return Future<void>.value();
    }
    setState(() {
      _warpUnderwayCount -= 1;
      if (widget.children != _children) {
        _updateChildren();
      } else {
        _childrenWithKey = originalChildren;
      }
    });
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_warpUnderwayCount > 0) {
      return false;
    }

    if (notification.depth != 0) {
      return false;
    }
    _warpUnderwayCount += 1;
    if (notification is ScrollUpdateNotification &&
        !_controller!.indexIsChanging) {
      if ((_pageController.page! - _controller!.index).abs() > 1.0) {
        _controller!.index = _pageController.page!.round();
        _currentIndex = _controller!.index;
      }
      _controller!.offset =
          (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
    } else if (notification is ScrollEndNotification) {
      _controller!.index = _pageController.page!.round();
      _currentIndex = _controller!.index;
      if (!_controller!.indexIsChanging) {
        _controller!.offset =
            (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
      }
    }
    _warpUnderwayCount -= 1;

    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth == 0 && !_pageController.isSelf) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  // bool _disallowGlow(bool leading, _ExtendedTabBarViewState? state) {
  //   if (state?._position == null) {
  //     return false;
  //   }

  //   return (leading &&
  //           state!._pageController.offset !=
  //               state._pageController.position.minScrollExtent) ||
  //       (!leading &&
  //           state!._pageController.offset !=
  //               state._pageController.position.maxScrollExtent);
  // }

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

    final Widget result = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: ExtendedPageView(
          dragStartBehavior: widget.dragStartBehavior,
          controller: _pageController,
          cacheExtent: widget.cacheExtent,
          scrollDirection: widget.scrollDirection,
          physics: usedScrollPhysics,
          children: _childrenWithKey!,
          shouldIgnorePointerWhenScrolling:
              widget.shouldIgnorePointerWhenScrolling,
        ),
      ),
    );

    return buildGestureDetector(child: result);
  }

  @override
  ScrollPhysics? get physics => widget.physics;

  @override
  Axis get scrollDirection => widget.scrollDirection;

  @override
  LinkScrollControllerMixin get linkScrollController => _pageController;

  @override
  bool get link => widget.link;
}

// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:extended_tabs/src/page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const ScrollPhysics _defaultScrollPhysics = NeverScrollableScrollPhysics();

final PageMetrics _testPageMetrics = PageMetrics(
  axisDirection: AxisDirection.down,
  minScrollExtent: 0,
  maxScrollExtent: 10,
  pixels: 5,
  viewportDimension: 10,
  viewportFraction: 1.0,
);

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
  final PageController? pageController;

  @override
  _ExtendedTabBarViewState createState() => _ExtendedTabBarViewState();
}

class _ExtendedTabBarViewState extends State<ExtendedTabBarView> {
  TabController? _controller;
  PageController? _pageController;
  PageController? get pageController => _pageController;
  _ExtendedTabBarViewState? _ancestor;
  _ExtendedTabBarViewState? _child;
  List<Widget>? _children;
  List<Widget>? _childrenWithKey;
  int? _currentIndex;
  int _warpUnderwayCount = 0;
  ScrollPhysics? _physics;
  late bool _canDrag;
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

  void _updatePhysics() {
    _physics = _defaultScrollPhysics.applyTo(widget.physics == null
        ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
        : const PageScrollPhysics().applyTo(widget.physics));

    if (widget.physics == null) {
      _canDrag = true;
    } else {
      _canDrag = widget.physics!.shouldAcceptUserOffset(_testPageMetrics);
    }
  }

  @override
  void initState() {
    super.initState();
    _updatePhysics();
    _updateChildren();
    _initGestureRecognizers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAncestor();
    _updateTabController();
    _currentIndex = _controller?.index;
    final int currentIndex = _currentIndex ?? 0;
    _pageController =
        widget.pageController ?? PageController(initialPage: currentIndex);
    assert(currentIndex == _pageController!.initialPage);
  }

  void _updateAncestor() {
    if (_ancestor != null) {
      _ancestor!._child = null;
      _ancestor = null;
    }
    if (widget.link) {
      _ancestor = context.findAncestorStateOfType<_ExtendedTabBarViewState>();
      _ancestor?._child = this;
    }
  }

  @override
  void didUpdateWidget(ExtendedTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.link != oldWidget.link) {
      _updateAncestor();
    }
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }
    if (widget.physics != oldWidget.physics) {
      _updatePhysics();
    }
    if (widget.children != oldWidget.children && _warpUnderwayCount == 0)
      _updateChildren();

    _initGestureRecognizers(oldWidget);
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

    if (_pageController!.page == _currentIndex!.toDouble())
      return Future<void>.value();

    final int previousIndex = _controller!.previousIndex;
    if ((_currentIndex! - previousIndex).abs() == 1) {
      _warpUnderwayCount += 1;
      await _pageController!.animateToPage(_currentIndex!,
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
    _pageController!.jumpToPage(initialPage);

    await _pageController!.animateToPage(_currentIndex!,
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
      if ((_pageController!.page! - _controller!.index).abs() > 1.0) {
        _controller!.index = _pageController!.page!.floor();
        _currentIndex = _controller!.index;
      }
      _controller!.offset =
          (_pageController!.page! - _controller!.index).clamp(-1.0, 1.0);
    } else if (notification is ScrollEndNotification) {
      _controller!.index = _pageController!.page!.round();
      _currentIndex = _controller!.index;
      if (!_controller!.indexIsChanging) {
        _controller!.offset =
            (_pageController!.page! - _controller!.index).clamp(-1.0, 1.0);
      }
    }
    _warpUnderwayCount -= 1;

    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth == 0 &&
        (_disallowGlow(notification.leading, _ancestor) ||
            _disallowGlow(notification.leading, _child))) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  bool _disallowGlow(bool leading, _ExtendedTabBarViewState? state) {
    if (state?._position == null) {
      return false;
    }

    return (leading &&
            state!._pageController!.offset !=
                state._pageController!.position.minScrollExtent) ||
        (!leading &&
            state!._pageController!.offset !=
                state._pageController!.position.maxScrollExtent);
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

    Widget result = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: ExtendedPageView(
          dragStartBehavior: widget.dragStartBehavior,
          controller: _pageController,
          cacheExtent: widget.cacheExtent,
          scrollDirection: widget.scrollDirection,
          physics: _physics,
          children: _childrenWithKey!,
        ),
      ),
    );

    if (_canDrag) {
      result = RawGestureDetector(
        gestures: _gestureRecognizers!,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }
    return result;
  }

  void _initGestureRecognizers([ExtendedTabBarView? oldWidget]) {
    if (oldWidget == null ||
        oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.physics != widget.physics) {
      if (_canDrag) {
        switch (widget.scrollDirection) {
          case Axis.vertical:
            _gestureRecognizers = <Type, GestureRecognizerFactory>{
              VerticalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
                (VerticalDragGestureRecognizer instance) {
                  instance
                    ..onDown = _handleDragDown
                    ..onStart = _handleDragStart
                    ..onUpdate = _handleDragUpdate
                    ..onEnd = _handleDragEnd
                    ..onCancel = _handleDragCancel
                    ..minFlingDistance = widget.physics?.minFlingDistance
                    ..minFlingVelocity = widget.physics?.minFlingVelocity
                    ..maxFlingVelocity = widget.physics?.maxFlingVelocity;
                },
              ),
            };
            break;
          case Axis.horizontal:
            _gestureRecognizers = <Type, GestureRecognizerFactory>{
              HorizontalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
                (HorizontalDragGestureRecognizer instance) {
                  instance
                    ..onDown = _handleDragDown
                    ..onStart = _handleDragStart
                    ..onUpdate = _handleDragUpdate
                    ..onEnd = _handleDragEnd
                    ..onCancel = _handleDragCancel
                    ..minFlingDistance = widget.physics?.minFlingDistance
                    ..minFlingVelocity = widget.physics?.minFlingVelocity
                    ..maxFlingVelocity = widget.physics?.maxFlingVelocity;
                },
              ),
            };
            break;
        }
      } else {
        _gestureRecognizers = null;
        _hold?.cancel();
        _drag?.cancel();
      }
    }
  }

  Drag? _drag;
  ScrollHoldController? _hold;
  ScrollPosition? get _position =>
      _pageController!.hasClients ? _pageController!.position : null;
  Map<Type, GestureRecognizerFactory>? _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};
  void _handleDragDown(DragDownDetails? details) {
    if (_drag != null) {
      _drag!.cancel();
    }
    assert(_drag == null);
    assert(_hold == null);

    _hold = _position!.hold(_disposeHold);
    //_ancestor?._handleDragDown(details);
  }

  void _handleDragStart(DragStartDetails details) {
    if (_drag != null) {
      _drag!.cancel();
    }
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = _position!.drag(details, _disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _handleAncestorOrChild(details, _ancestor);

    _handleAncestorOrChild(details, _child);

    // TODO(zmtzawqlp): if there are two drag, how to do we do?
    assert(!(_ancestor?._drag != null && _child?._drag != null));
    if (_ancestor?._drag != null) {
      _ancestor!._drag!.update(details);
    } else if (_child?._drag != null) {
      _child!._drag!.update(details);
    } else {
      _drag?.update(details);
    }
  }

  bool _handleAncestorOrChild(
      DragUpdateDetails details, _ExtendedTabBarViewState? state) {
    if (state?._position != null) {
      final double delta = widget.scrollDirection == Axis.horizontal
          ? details.delta.dx
          : details.delta.dy;

      if ((delta < 0 &&
              _position!.extentAfter == 0 &&
              state!._position!.extentAfter != 0) ||
          (delta > 0 &&
              _position!.extentBefore == 0 &&
              state!._position!.extentBefore != 0)) {
        if (state._drag == null && state._hold == null) {
          state._handleDragDown(null);
        }

        if (state._drag == null) {
          state._handleDragStart(DragStartDetails(
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
            sourceTimeStamp: details.sourceTimeStamp,
          ));
        }
        //state._handleDragUpdate(details);
        return true;
      }
    }

    return false;
  }

  void _handleDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);

    _ancestor?._drag?.end(details);
    _child?._drag?.end(details);
    _drag?.end(details);

    assert(_drag == null);
  }

  void _handleDragCancel() {
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _ancestor?._hold?.cancel();
    _ancestor?._drag?.cancel();
    _child?._hold?.cancel();
    _child?._drag?.cancel();
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }
}

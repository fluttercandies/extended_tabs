// ignore_for_file: unused_element

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'package:extended_tabs/src/official/tab_bar.dart';

class ExtendedTab extends _Tab {
  const ExtendedTab({
    super.key,
    super.text,
    super.icon,
    super.iconMargin = const EdgeInsets.only(bottom: 10.0),
    super.height,
    super.child,
    this.scrollDirection = Axis.horizontal,
  });

  /// The axis along which the tab bar scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis? scrollDirection;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    final double calculatedHeight;
    final Widget label;
    if (icon == null) {
      calculatedHeight = _kTabHeight;
      label = _buildLabelText();
    } else if (text == null && child == null) {
      calculatedHeight = _kTabHeight;
      label = icon!;
    } else {
      calculatedHeight = _kTextAndIconTabHeight;
      label = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: iconMargin,
            child: icon,
          ),
          _buildLabelText(),
        ],
      );
    }

    return SizedBox(
      width: scrollDirection == Axis.horizontal
          ? null
          : height ?? calculatedHeight,
      height: scrollDirection == Axis.horizontal
          ? height ?? calculatedHeight
          : null,
      child: Center(
        widthFactor: 1.0,
        child: label,
      ),
    );
  }

  @override
  Size get preferredSize {
    if (height != null) {
      return scrollDirection == Axis.horizontal
          ? Size.fromHeight(height!)
          : Size.fromWidth(height!);
    } else if ((text != null || child != null) && icon != null) {
      return scrollDirection == Axis.horizontal
          ? const Size.fromHeight(_kTextAndIconTabHeight)
          : const Size.fromWidth(_kTextAndIconTabHeight);
    } else {
      return scrollDirection == Axis.horizontal
          ? const Size.fromHeight(_kTabHeight)
          : const Size.fromWidth(_kTabHeight);
    }
  }
}

class _ExtendedIndicatorPainter extends _IndicatorPainter {
  _ExtendedIndicatorPainter({
    required super.controller,
    required super.indicator,
    required super.indicatorSize,
    required super.tabKeys,
    required super.old,
    required super.indicatorPadding,
    required super.labelPaddings,
    super.dividerColor,
    this.scrollDirection,
    this.mainAxisAlignment,
  });

  final Axis? scrollDirection;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Rect indicatorRect(Size tabBarSize, int tabIndex) {
    assert(_currentTabOffsets != null);
    assert(_currentTextDirection != null);
    assert(_currentTabOffsets!.isNotEmpty);
    assert(tabIndex >= 0);
    assert(tabIndex <= maxTabIndex);
    late double tabLeft, tabRight;
    switch (_currentTextDirection!) {
      case TextDirection.rtl:
        tabLeft = _currentTabOffsets![tabIndex + 1];
        tabRight = _currentTabOffsets![tabIndex];
        break;
      case TextDirection.ltr:
        tabLeft = _currentTabOffsets![tabIndex];
        tabRight = _currentTabOffsets![tabIndex + 1];
        break;
    }
    final tabWidth = scrollDirection == Axis.horizontal
        ? tabKeys[tabIndex].currentContext!.size!.width
        : tabKeys[tabIndex].currentContext!.size!.height;

    void handleLabel() {
      if (indicatorSize == TabBarIndicatorSize.label) {
        final labelPadding = tabKeys[tabIndex]
            .currentContext!
            .findAncestorRenderObjectOfType<RenderPadding>()!
            .padding;
        final edgeInsets = labelPadding.resolve(_currentTextDirection);
        tabRight -= scrollDirection == Axis.horizontal
            ? edgeInsets.right
            : edgeInsets.bottom;
        tabLeft += scrollDirection == Axis.horizontal
            ? edgeInsets.left
            : edgeInsets.top;
      }
    }

    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        if (_currentTextDirection == TextDirection.ltr &&
            tabIndex == maxTabIndex) {
          tabRight = tabLeft + tabWidth + _getLabelPadding(tabIndex);
        }

        handleLabel();
        break;
      case MainAxisAlignment.end:
        if (_currentTextDirection == TextDirection.rtl && tabIndex == 0) {
          tabRight = tabLeft + tabWidth + _getLabelPadding(tabIndex);
        }
        handleLabel();
        break;
      case MainAxisAlignment.center:
        if ((_currentTextDirection == TextDirection.ltr &&
                tabIndex == maxTabIndex) ||
            (_currentTextDirection == TextDirection.rtl && tabIndex == 0)) {
          tabRight = tabLeft + tabWidth + _getLabelPadding(tabIndex);
        }
        handleLabel();
        break;
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceEvenly:
        if (indicatorSize == TabBarIndicatorSize.label) {
          tabRight = tabLeft + tabWidth;
        } else {
          double delta =
              ((tabRight - tabLeft) - tabWidth - _getLabelPadding(tabIndex)) /
                  2.0;
          tabRight -= delta;

          switch (mainAxisAlignment) {
            case MainAxisAlignment.spaceBetween:
              if (tabIndex != 0 && _currentTextDirection == TextDirection.ltr) {
                if (tabIndex == maxTabIndex) {
                  final preTabLeft = _currentTabOffsets![tabIndex - 1];
                  final preTabWidth = scrollDirection == Axis.horizontal
                      ? tabKeys[tabIndex - 1].currentContext!.size!.width
                      : tabKeys[tabIndex - 1].currentContext!.size!.height;
                  delta = (tabLeft - preTabLeft - preTabWidth) / 2;
                }
                tabLeft -= delta;
              } else if (tabIndex != maxTabIndex &&
                  _currentTextDirection == TextDirection.rtl) {
                if (tabIndex == 0) {
                  final preTabLeft = _currentTabOffsets![tabIndex + 2];
                  final preTabWidth = scrollDirection == Axis.horizontal
                      ? tabKeys[tabIndex + 2].currentContext!.size!.width
                      : tabKeys[tabIndex + 2].currentContext!.size!.height;

                  delta = (tabLeft - preTabLeft - preTabWidth) / 2;
                }
                tabLeft -= delta;
              }
              break;
            case MainAxisAlignment.spaceAround:
              tabLeft -= delta;
              if ((tabIndex == maxTabIndex &&
                      _currentTextDirection == TextDirection.ltr) ||
                  (tabIndex == 0 &&
                      _currentTextDirection == TextDirection.rtl)) {
                tabRight += delta;
                tabLeft -= delta;
              }
              break;
            case MainAxisAlignment.spaceEvenly:
              tabLeft -= delta;

              break;
            default:
          }
        }
        break;
      default:
        if (indicatorSize == TabBarIndicatorSize.label) {
          final labelPadding = tabKeys[tabIndex]
              .currentContext!
              .findAncestorRenderObjectOfType<RenderPadding>()!
              .padding;
          final insets = labelPadding.resolve(_currentTextDirection);
          final delta =
              ((tabRight - tabLeft) - (tabWidth + insets.horizontal)) / 2.0;
          tabLeft += delta + insets.left;
          tabRight = tabLeft + tabWidth;
        }
    }
    final insets = indicatorPadding.resolve(_currentTextDirection);

    final rect = scrollDirection == Axis.horizontal
        ? Rect.fromLTWH(tabLeft, 0.0, tabRight - tabLeft, tabBarSize.height)
        : Rect.fromLTWH(0, tabLeft, tabBarSize.width, tabRight - tabLeft);

    if (!(rect.size >= insets.collapsedSize)) {
      throw FlutterError(
        'indicatorPadding insets should be less than Tab Size\n'
        'Rect Size : ${rect.size}, Insets: ${insets.toString()}',
      );
    }

    return insets.deflateRect(rect);
  }

  // zmtzawqlp
  double _getLabelPadding(int tabIndex) {
    final labelPadding = tabKeys[tabIndex]
        .currentContext!
        .findAncestorRenderObjectOfType<RenderPadding>()!
        .padding;
    final edgeInsets = labelPadding.resolve(_currentTextDirection);
    return scrollDirection == Axis.horizontal
        ? edgeInsets.horizontal
        : edgeInsets.vertical;
  }
}

class ExtendedTabBar extends _TabBar {
  const ExtendedTabBar({
    super.key,
    required super.tabs,
    super.controller,
    super.isScrollable = false,
    super.padding,
    super.indicatorColor,
    super.automaticIndicatorColorAdjustment = true,
    super.indicatorWeight = 2.0,
    super.indicatorPadding = EdgeInsets.zero,
    super.indicator,
    super.indicatorSize,
    super.dividerColor,
    super.labelColor,
    super.labelStyle,
    super.labelPadding,
    super.unselectedLabelColor,
    super.unselectedLabelStyle,
    super.dragStartBehavior = DragStartBehavior.start,
    super.overlayColor,
    super.mouseCursor,
    super.enableFeedback,
    super.onTap,
    super.physics,
    super.splashFactory,
    super.splashBorderRadius,
    this.scrollDirection = Axis.horizontal,
    this.mainAxisAlignment,
    this.foregroundIndicator = false,
  });

  /// The axis along which the tab bar scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// The MainAxisAlignment of Tabs
  /// if this is not null, we will not add Exapnded for Tab when [isScrollable] is false
  final MainAxisAlignment? mainAxisAlignment;

  /// Whether the indicator is foreground
  final bool foregroundIndicator;

  @override
  // ignore: library_private_types_in_public_api
  State<_TabBar> createState() => _ExtendedTabBarState();
}

class _ExtendedTabBarState extends _TabBarState {
  ExtendedTabBar get extendedWidget => widget as ExtendedTabBar;

  @override
  void didUpdateWidget(covariant ExtendedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // zmtzawqlp
    // _tabKeys and _labelPaddings should be updated before _initIndicatorPainter
    final bool didInitIndicatorPainter =
        widget.controller != oldWidget.controller ||
            widget.indicatorColor != oldWidget.indicatorColor ||
            widget.indicatorWeight != oldWidget.indicatorWeight ||
            widget.indicatorSize != oldWidget.indicatorSize ||
            widget.indicator != oldWidget.indicator;
    if (!didInitIndicatorPainter ||
        extendedWidget.mainAxisAlignment != oldWidget.mainAxisAlignment ||
        extendedWidget.scrollDirection != oldWidget.scrollDirection) {
      _initIndicatorPainter();
    }
  }

  @override
  void _initIndicatorPainter() {
    final ThemeData theme = Theme.of(context);
    final tabBarTheme = TabBarTheme.of(context);
    _indicatorPainter = !_controllerIsValid
        ? null
        : _ExtendedIndicatorPainter(
            controller: _controller!,
            indicator: _getIndicator(),
            indicatorSize: widget.indicatorSize ??
                tabBarTheme.indicatorSize ??
                _defaults.indicatorSize!,
            indicatorPadding: widget.indicatorPadding,
            tabKeys: _tabKeys,
            old: _indicatorPainter,
            dividerColor: theme.useMaterial3
                ? widget.dividerColor ??
                    tabBarTheme.dividerColor ??
                    _defaults.dividerColor
                : null,
            labelPaddings: _labelPaddings,
            scrollDirection: extendedWidget.scrollDirection,
            mainAxisAlignment: extendedWidget.mainAxisAlignment,
          );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    assert(_debugScheduleCheckHasValidTabsCount());

    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    if (_controller!.length == 0) {
      return extendedWidget.scrollDirection == Axis.horizontal
          ? Container(
              height: _kTabHeight + widget.indicatorWeight,
            )
          : Container(
              width: _kTabHeight + widget.indicatorWeight,
            );
    }

    final tabBarTheme = TabBarTheme.of(context);

    final List<Widget> wrappedTabs =
        List<Widget>.generate(widget.tabs.length, (int index) {
      const double verticalAdjustment =
          (_kTextAndIconTabHeight - _kTabHeight) / 2.0;
      EdgeInsetsGeometry? adjustedPadding;

      if (widget.tabs[index] is PreferredSizeWidget) {
        final PreferredSizeWidget tab =
            widget.tabs[index] as PreferredSizeWidget;
        if (widget.tabHasTextAndIcon &&
            tab.preferredSize.height == _kTabHeight) {
          if (widget.labelPadding != null || tabBarTheme.labelPadding != null) {
            adjustedPadding = (widget.labelPadding ?? tabBarTheme.labelPadding!)
                .add(const EdgeInsets.symmetric(vertical: verticalAdjustment));
          } else {
            adjustedPadding = const EdgeInsets.symmetric(
              vertical: verticalAdjustment,
              horizontal: 16.0,
            );
          }
        }
      }

      _labelPaddings[index] = adjustedPadding ??
          widget.labelPadding ??
          tabBarTheme.labelPadding ??
          kTabLabelPadding;

      return Center(
        heightFactor: 1.0,
        child: Padding(
          padding: _labelPaddings[index],
          child: KeyedSubtree(
            key: _tabKeys[index],
            child: widget.tabs[index],
          ),
        ),
      );
    });

    // If the controller was provided by DefaultTabController and we're part
    // of a Hero (typically the AppBar), then we will not be able to find the
    // controller during a Hero transition. See https://github.com/flutter/flutter/issues/213.
    if (_controller != null) {
      final int previousIndex = _controller!.previousIndex;

      if (_controller!.indexIsChanging) {
        // The user tapped on a tab, the tab controller's animation is running.
        assert(_currentIndex != previousIndex);
        final Animation<double> animation = _ChangeAnimation(_controller!);
        wrappedTabs[_currentIndex!] = _buildStyledTab(
          wrappedTabs[_currentIndex!],
          true,
          animation,
          _defaults,
        );
        wrappedTabs[previousIndex] = _buildStyledTab(
          wrappedTabs[previousIndex],
          false,
          animation,
          _defaults,
        );
      } else {
        // The user is dragging the TabBarView's PageView left or right.
        final int tabIndex = _currentIndex!;
        final Animation<double> centerAnimation =
            _DragAnimation(_controller!, tabIndex);
        wrappedTabs[tabIndex] = _buildStyledTab(
          wrappedTabs[tabIndex],
          true,
          centerAnimation,
          _defaults,
        );
        if (_currentIndex! > 0) {
          final int tabIndex = _currentIndex! - 1;
          final Animation<double> previousAnimation =
              ReverseAnimation(_DragAnimation(_controller!, tabIndex));
          wrappedTabs[tabIndex] = _buildStyledTab(
            wrappedTabs[tabIndex],
            false,
            previousAnimation,
            _defaults,
          );
        }
        if (_currentIndex! < widget.tabs.length - 1) {
          final int tabIndex = _currentIndex! + 1;
          final Animation<double> nextAnimation =
              ReverseAnimation(_DragAnimation(_controller!, tabIndex));
          wrappedTabs[tabIndex] = _buildStyledTab(
            wrappedTabs[tabIndex],
            false,
            nextAnimation,
            _defaults,
          );
        }
      }
    }

    // Add the tap handler to each tab. If the tab bar is not scrollable,
    // then give all of the tabs equal flexibility so that they each occupy
    // the same share of the tab bar's overall width.
    final int tabCount = widget.tabs.length;
    for (int index = 0; index < tabCount; index += 1) {
      final Set<MaterialState> selectedState = <MaterialState>{
        if (index == _currentIndex) MaterialState.selected,
      };

      final MouseCursor effectiveMouseCursor =
          MaterialStateProperty.resolveAs<MouseCursor?>(
                widget.mouseCursor,
                selectedState,
              ) ??
              tabBarTheme.mouseCursor?.resolve(selectedState) ??
              MaterialStateMouseCursor.clickable.resolve(selectedState);

      final MaterialStateProperty<Color?> defaultOverlay =
          MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          final Set<MaterialState> effectiveStates = selectedState
            ..addAll(states);
          return _defaults.overlayColor?.resolve(effectiveStates);
        },
      );
      wrappedTabs[index] = InkWell(
        mouseCursor: effectiveMouseCursor,
        onTap: () {
          _handleTap(index);
        },
        enableFeedback: widget.enableFeedback ?? true,
        overlayColor:
            widget.overlayColor ?? tabBarTheme.overlayColor ?? defaultOverlay,
        splashFactory: widget.splashFactory ??
            tabBarTheme.splashFactory ??
            _defaults.splashFactory,
        borderRadius: widget.splashBorderRadius,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.indicatorWeight),
          child: Stack(
            children: <Widget>[
              wrappedTabs[index],
              Semantics(
                selected: index == _currentIndex,
                label: localizations.tabLabel(
                  tabIndex: index + 1,
                  tabCount: tabCount,
                ),
              ),
            ],
          ),
        ),
      );
      // zmtzawqlp
      if (!widget.isScrollable &&
          (widget as ExtendedTabBar).mainAxisAlignment == null) {
        wrappedTabs[index] = Expanded(child: wrappedTabs[index]);
      }
    }

    Widget tabBar = CustomPaint(
      // zmtzawqlp
      painter: extendedWidget.foregroundIndicator ? null : _indicatorPainter,
      foregroundPainter:
          extendedWidget.foregroundIndicator ? _indicatorPainter : null,
      child: _TabStyle(
        animation: kAlwaysDismissedAnimation,
        isSelected: false,
        isPrimary: widget._isPrimary,
        labelColor: widget.labelColor,
        unselectedLabelColor: widget.unselectedLabelColor,
        labelStyle: widget.labelStyle,
        unselectedLabelStyle: widget.unselectedLabelStyle,
        defaults: _defaults,
        // zmtzawqlp
        child: _ExtendedTabLabelBar(
          onPerformLayout: _saveTabOffsets,
          scrollDirection: extendedWidget.scrollDirection,
          mainAxisAlignment:
              extendedWidget.mainAxisAlignment ?? MainAxisAlignment.start,
          children: wrappedTabs,
        ),
      ),
    );

    if (widget.isScrollable) {
      _scrollController ??= _TabBarScrollController(this);
      tabBar = ScrollConfiguration(
        // The scrolling tabs should not show an overscroll indicator.
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          dragStartBehavior: widget.dragStartBehavior,
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          padding: widget.padding,
          physics: widget.physics,
          child: tabBar,
        ),
      );
    } else if (widget.padding != null) {
      tabBar = Padding(
        padding: widget.padding!,
        child: tabBar,
      );
    }

    return tabBar;
  }
}

class _ExtendedTabLabelBar extends _TabLabelBar {
  const _ExtendedTabLabelBar({
    super.children,
    required super.onPerformLayout,
    required Axis scrollDirection,
    super.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(
          crossAxisAlignment: scrollDirection == Axis.horizontal
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          direction: scrollDirection,
        );

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _ExtendedTabLabelBarRenderer(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context)!,
      verticalDirection: verticalDirection,
      onPerformLayout: onPerformLayout,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlex renderObject) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = getEffectiveTextDirection(context)
      ..verticalDirection = verticalDirection
      ..textBaseline = textBaseline
      ..clipBehavior = clipBehavior;

    (renderObject as _ExtendedTabLabelBarRenderer).onPerformLayout =
        onPerformLayout;
  }
}

class _ExtendedTabLabelBarRenderer extends RenderFlex {
  _ExtendedTabLabelBarRenderer({
    super.children,
    required super.direction,
    required super.mainAxisSize,
    required super.mainAxisAlignment,
    required super.crossAxisAlignment,
    required TextDirection super.textDirection,
    required super.verticalDirection,
    required this.onPerformLayout,
  }) : assert(onPerformLayout != null);

  _LayoutCallback? onPerformLayout;

  @override
  void performLayout() {
    super.performLayout();
    // xOffsets will contain childCount+1 values, giving the offsets of the
    // leading edge of the first tab as the first value, of the leading edge of
    // the each subsequent tab as each subsequent value, and of the trailing
    // edge of the last tab as the last value.
    RenderBox? child = firstChild;
    final List<double> xOffsets = <double>[];

    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      xOffsets.add(
        direction == Axis.horizontal
            ? childParentData.offset.dx
            : childParentData.offset.dy,
      );
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    assert(textDirection != null);
    // not work for TextDirection
    if (direction == Axis.vertical) {
      xOffsets.add(direction == Axis.horizontal ? size.width : size.height);
    } else {
      switch (textDirection!) {
        case TextDirection.rtl:
          xOffsets.insert(
            0,
            direction == Axis.horizontal ? size.width : size.height,
          );
          break;
        case TextDirection.ltr:
          xOffsets.add(direction == Axis.horizontal ? size.width : size.height);
          break;
      }
    }

    onPerformLayout!(
      xOffsets,
      textDirection!,
      direction == Axis.horizontal ? size.width : size.height,
    );
  }
}

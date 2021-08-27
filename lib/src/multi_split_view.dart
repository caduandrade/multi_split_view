import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/theme_data.dart';
import 'package:multi_split_view/src/theme_widget.dart';

/// A widget to provides horizontal or vertical multiple split view.
class MultiSplitView extends StatefulWidget {
  static const Axis defaultAxis = Axis.horizontal;
  static const double defaultMinimalWeight = .01;
  static const double minimalWidgetWeightLowerLimit = 0.01;
  static const double minimalWidgetWeightUpperLimit = 0.9;

  /// Creates an [MultiSplitView].
  ///
  /// The default value for [axis] argument is [Axis.horizontal].
  /// The [children] argument is required.

  MultiSplitView(
      {Key? key,
      this.axis = MultiSplitView.defaultAxis,
      required this.children,
      this.controller,
      this.minimalWeight,
      this.minimalSize,
      this.onSizeChange,
      this.resizable = true})
      : super(key: key) {
    if (minimalWeight != null &&
        (minimalWeight! < MultiSplitView.minimalWidgetWeightLowerLimit ||
            minimalWeight! > MultiSplitView.minimalWidgetWeightUpperLimit)) {
      throw Exception('The minimum weight must be between ' +
          MultiSplitView.minimalWidgetWeightLowerLimit.toString() +
          ' and ' +
          MultiSplitView.minimalWidgetWeightUpperLimit.toString() +
          '.');
    }
  }

  final Axis axis;
  final List<Widget> children;
  final MultiSplitViewController? controller;

  /// Indicates whether it is resizable. The default value is [TRUE].
  final bool resizable;

  /// Defines the minimal weight for each child. The default value is defined by [MultiSplitView.defaultMinimalWeight] constant.
  final double? minimalWeight;

  /// Defines the minimal size in pixels for each child.
  /// It will be used if [minimalWeight] has not been set.
  /// The size will be converted into weight and will respect the limit
  /// defined by the [MultiSplitView.defaultMinimalWeight] constant,
  /// allowing all children to be visible.
  final double? minimalSize;
  // Function to listen any children size change.
  final OnSizeChange? onSizeChange;

  @override
  State createState() => _MultiSplitViewState();
}

/// State for [MultiSplitView]
class _MultiSplitViewState extends State<MultiSplitView> {
  late MultiSplitViewController _controller;
  double _initialDragPos = 0;
  double _initialChild1Weight = 0;
  double _initialChild2Weight = 0;
  double _initialChild1Size = 0;

  int? _highlightedDividerIndex;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller != null
        ? widget.controller!
        : MultiSplitViewController();
    _stateHashCodeValidation();
  }

  @override
  void deactivate() {
    _controller.stateHashCode = null;
    super.deactivate();
  }

  @override
  void didUpdateWidget(MultiSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else if (oldWidget.controller != null) {
      _controller = oldWidget.controller!;
    }
    _stateHashCodeValidation();
  }

  /// Updates and checks a controller's [stateHashCode] to identify if it is
  /// not being shared by another instance of [MultiSplitView].
  void _stateHashCodeValidation() {
    if (_controller.stateHashCode != null &&
        _controller.stateHashCode != hashCode) {
      throw StateError(
          'It is not allowed to share MultiSplitViewController between MultiSplitView instances.');
    }
    _controller.stateHashCode = hashCode;
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitViewThemeData themeData = MultiSplitViewTheme.of(context);
    double totalDividerSize =
        (widget.children.length - 1) * themeData.dividerThickness;
    if (widget.children.length > 0) {
      return LayoutBuilder(builder: (context, constraints) {
        double minimalWeight = _minimalWeight(constraints, totalDividerSize);
        _controller.validateAndAdjust(widget.children.length);
        List<Widget> children = [];
        if (widget.axis == Axis.horizontal) {
          _populateHorizontalChildren(
              context: context,
              constraints: constraints,
              totalDividerSize: totalDividerSize,
              children: children,
              minimalWeight: minimalWeight,
              themeData: themeData);
        } else {
          _populateVerticalChildren(
              context: context,
              constraints: constraints,
              totalDividerSize: totalDividerSize,
              children: children,
              minimalWeight: minimalWeight,
              themeData: themeData);
        }

        return Stack(children: children);
      });
    }
    return Container();
  }

  /// Calculates the minimum weight. Used when the pixel size has been set.
  double _minimalWeight(BoxConstraints constraints, double totalDividerSize) {
    if (widget.minimalWeight != null) {
      return widget.minimalWeight!;
    } else if (widget.minimalSize != null) {
      double remainingWidth = constraints.maxWidth - totalDividerSize;
      double minimalWeight = widget.minimalSize! / remainingWidth;
      minimalWeight =
          math.max(minimalWeight, MultiSplitView.defaultMinimalWeight);
      minimalWeight = math.min(minimalWeight, 1 / widget.children.length);
      return minimalWeight;
    }
    return MultiSplitView.defaultMinimalWeight;
  }

  /// Updates the highlighted divider index.
  void _updatesHighlightedDividerIndex(
      {int? index, required MultiSplitViewThemeData themeData}) {
    if (_highlightedDividerIndex != index && themeData.dividerPainter != null) {
      setState(() {
        _highlightedDividerIndex = index;
      });
    }
  }

  /// Applies the horizontal layout
  void _populateHorizontalChildren(
      {required BuildContext context,
      required BoxConstraints constraints,
      required double totalDividerSize,
      required List<Widget> children,
      required double minimalWeight,
      required MultiSplitViewThemeData themeData}) {
    double totalChildrenSize = constraints.maxWidth - totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      double childWeight = _controller.getWeight(childIndex);
      totalRemainingWeight -= childWeight;

      childDistance.right = _distanceOnTheOppositeSide(
          childIndex: childIndex,
          totalChildrenSize: totalChildrenSize,
          totalRemainingWeight: totalRemainingWeight,
          themeData: themeData);

      children.add(_buildPositioned(
          distance: childDistance, child: widget.children[childIndex]));

      if (childIndex < widget.children.length - 1) {
        double childSize = totalChildrenSize * childWeight;

        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.left = childDistance.left + childSize;
        dividerDistance.right =
            childDistance.right - themeData.dividerThickness;

        Widget dividerWidget = _buildDividerWidget(
            axis: Axis.vertical, childIndex: childIndex, themeData: themeData);
        if (widget.resizable) {
          dividerWidget = MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            onEnter: (event) => _updatesHighlightedDividerIndex(
                index: childIndex, themeData: themeData),
            onExit: (event) =>
                _updatesHighlightedDividerIndex(themeData: themeData),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (detail) {
                  final pos = _position(context, detail.globalPosition);
                  _updateInitialValues(childIndex, pos.dx, totalChildrenSize);
                },
                onHorizontalDragUpdate: (detail) {
                  final pos = _position(context, detail.globalPosition);
                  double diffX = pos.dx - _initialDragPos;
                  _updateDifferentWeights(childIndex, diffX, minimalWeight);
                },
                child: dividerWidget),
          );
        }
        children.add(
            _buildPositioned(distance: dividerDistance, child: dividerWidget));
        childDistance.left = dividerDistance.left + themeData.dividerThickness;
      }
    }
  }

  /// Applies the vertical layout
  void _populateVerticalChildren(
      {required BuildContext context,
      required BoxConstraints constraints,
      required double totalDividerSize,
      required List<Widget> children,
      required double minimalWeight,
      required MultiSplitViewThemeData themeData}) {
    double totalChildrenSize = constraints.maxHeight - totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      double childWeight = _controller.getWeight(childIndex);
      totalRemainingWeight -= childWeight;

      childDistance.bottom = _distanceOnTheOppositeSide(
          childIndex: childIndex,
          totalChildrenSize: totalChildrenSize,
          totalRemainingWeight: totalRemainingWeight,
          themeData: themeData);

      children.add(_buildPositioned(
          distance: childDistance, child: widget.children[childIndex]));

      if (childIndex < widget.children.length - 1) {
        double childSize = totalChildrenSize * childWeight;

        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.top = childDistance.top + childSize;
        dividerDistance.bottom =
            childDistance.bottom - themeData.dividerThickness;

        Widget dividerWidget = _buildDividerWidget(
            axis: Axis.horizontal,
            childIndex: childIndex,
            themeData: themeData);
        if (widget.resizable) {
          dividerWidget = MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            onEnter: (event) => _updatesHighlightedDividerIndex(
                index: childIndex, themeData: themeData),
            onExit: (event) =>
                _updatesHighlightedDividerIndex(themeData: themeData),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: (detail) {
                  final pos = _position(context, detail.globalPosition);
                  _updateInitialValues(childIndex, pos.dy, totalChildrenSize);
                },
                onVerticalDragUpdate: (detail) {
                  final pos = _position(context, detail.globalPosition);
                  double diffY = pos.dy - _initialDragPos;
                  _updateDifferentWeights(childIndex, diffY, minimalWeight);
                },
                child: dividerWidget),
          );
        }
        children.add(
            _buildPositioned(distance: dividerDistance, child: dividerWidget));
        childDistance.top = dividerDistance.top + themeData.dividerThickness;
      }
    }
  }

  /// Builds a widget for the divider depending on whether [dividerPainter]
  /// has been set.
  Widget _buildDividerWidget(
      {required Axis axis,
      required int childIndex,
      required MultiSplitViewThemeData themeData}) {
    if (themeData.dividerPainter != null) {
      return ClipRect(
          child: CustomPaint(
              child: Container(color: themeData.dividerColor),
              painter: _DividerPainterWrapper(
                  axis,
                  widget.resizable,
                  _highlightedDividerIndex == childIndex,
                  themeData.dividerPainter!)));
    }
    return Container(color: themeData.dividerColor);
  }

  void _updateInitialValues(
      int childIndex, double pos, double totalChildrenSize) {
    _initialDragPos = pos;
    _initialChild1Weight = _controller.getWeight(childIndex);
    _initialChild2Weight = _controller.getWeight(childIndex + 1);
    _initialChild1Size = totalChildrenSize * _initialChild1Weight;
  }

  /// Calculates the new weights and sets if they are different from the current one.
  void _updateDifferentWeights(
      int childIndex, double diffPos, double minimalWeight) {
    double newChild1Weight =
        ((_initialChild1Size + diffPos) * _initialChild1Weight) /
            _initialChild1Size;

    double maxChild1Weight =
        _initialChild1Weight + _initialChild2Weight - minimalWeight;

    newChild1Weight = math.max(minimalWeight, newChild1Weight);
    newChild1Weight = math.min(maxChild1Weight, newChild1Weight);

    if (newChild1Weight < minimalWeight) {
      return;
    }
    double newChild2Weight =
        _initialChild1Weight + _initialChild2Weight - newChild1Weight;

    if (newChild2Weight < minimalWeight) {
      return;
    }

    if (_controller.getWeight(childIndex) != newChild1Weight) {
      setState(() {
        _controller.setWeight(childIndex, newChild1Weight);
        _controller.setWeight(childIndex + 1, newChild2Weight);
      });
      if (widget.onSizeChange != null) {
        widget.onSizeChange!(childIndex, childIndex + 1);
      }
    }
  }

  /// Builds an [Offset] for cursor position.
  Offset _position(BuildContext context, Offset globalPosition) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    return container.globalToLocal(globalPosition);
  }

  double _distanceOnTheOppositeSide(
      {required int childIndex,
      required double totalChildrenSize,
      required double totalRemainingWeight,
      required MultiSplitViewThemeData themeData}) {
    int amountRemainingDividers = widget.children.length - 1 - childIndex;
    return (amountRemainingDividers * themeData.dividerThickness) +
        (totalChildrenSize * totalRemainingWeight);
  }

  /// Builds a [Positioned] using the [_DistanceFrom] parameters.
  Positioned _buildPositioned(
      {required _DistanceFrom distance, required Widget child}) {
    return Positioned(
        top: distance.top,
        left: distance.left,
        right: distance.right,
        bottom: distance.bottom,
        child: child);
  }
}

/// Defines distance from edges.
class _DistanceFrom {
  double top;
  double left;
  double right;
  double bottom;

  _DistanceFrom({this.top = 0, this.left = 0, this.right = 0, this.bottom = 0});
}

typedef OnSizeChange = Function(int childIndex1, int childIndex2);

/// Defines the custom painter for the divider using a [DividerPainter].
class _DividerPainterWrapper extends CustomPainter {
  _DividerPainterWrapper(
      this.axis, this.resizable, this.highlighted, this.dividerPainter);

  /// The divider axis
  final Axis axis;
  final bool resizable;
  final bool highlighted;
  final DividerPainter dividerPainter;

  @override
  void paint(Canvas canvas, Size size) {
    dividerPainter(axis, resizable, highlighted, canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Defines a painter for the divider.
typedef DividerPainter = Function(
    Axis axis, bool resizable, bool highlighted, Canvas canvas, Size size);

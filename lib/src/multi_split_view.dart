import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_split_view/src/controller.dart';

/// A widget to provides horizontal or vertical multiple split view.
class MultiSplitView extends StatefulWidget {
  static const Axis defaultAxis = Axis.horizontal;
  static const double defaultDividerThickness = 5.0;
  static const double defaultMinimalWeight = .01;
  static const double minimalWidgetWeightLowerLimit = 0.01;
  static const double minimalWidgetWeightUpperLimit = 0.9;

  /// Creates an [MultiSplitView].
  ///
  /// The default value for [axis] argument is [Axis.horizontal].
  /// The [children] argument is required.
  /// The [dividerThickness] argument must also be positive.
  MultiSplitView(
      {Key? key,
      this.axis = MultiSplitView.defaultAxis,
      required this.children,
      this.controller,
      this.dividerThickness = MultiSplitView.defaultDividerThickness,
      this.dividerColor,
      this.minimalWeight,
      this.minimalSize,
      this.onSizeChange,
      this.dividerPainter,
      this.resizable = true})
      : super(key: key) {
    if (dividerThickness <= 0) {
      throw Exception('The thickness of the divider must be positive.');
    }
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
  final double dividerThickness;

  /// Defines the divider color. The default value is [NULL].
  final Color? dividerColor;

  /// Defines a divider painter. The default value is [NULL].
  final DividerPainter? dividerPainter;

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
  late double _totalDividerSize;
  late MultiSplitViewController _controller;
  double _initialDragPos = 0;
  double _initialChild1Weight = 0;
  double _initialChild2Weight = 0;
  double _initialChild1Size = 0;

  int? _highlightedDividerIndex;

  @override
  void initState() {
    super.initState();
    _totalDividerSize = (widget.children.length - 1) * widget.dividerThickness;
    _controller = widget.controller != null
        ? widget.controller!
        : MultiSplitViewController();
  }

  @override
  void didUpdateWidget(MultiSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _totalDividerSize = (widget.children.length - 1) * widget.dividerThickness;
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else if (oldWidget.controller != null) {
      _controller = oldWidget.controller!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.length > 0) {
      return LayoutBuilder(builder: (context, constraints) {
        double minimalWeight = _minimalWeight(constraints);
        _controller.validateAndAdjust(widget.children.length);
        List<Widget> children = [];
        if (widget.axis == Axis.horizontal) {
          _populateHorizontalChildren(
              context, constraints, children, minimalWeight);
        } else {
          _populateVerticalChildren(
              context, constraints, children, minimalWeight);
        }

        return Stack(children: children);
      });
    }
    return Container();
  }

  /// Calculates the minimum weight. Used when the pixel size has been set.
  double _minimalWeight(BoxConstraints constraints) {
    if (widget.minimalWeight != null) {
      return widget.minimalWeight!;
    } else if (widget.minimalSize != null) {
      double dividersSize =
          (widget.children.length - 1) * widget.dividerThickness;
      double remainingWidth = constraints.maxWidth - dividersSize;
      double minimalWeight = widget.minimalSize! / remainingWidth;
      minimalWeight =
          math.max(minimalWeight, MultiSplitView.defaultMinimalWeight);
      minimalWeight = math.min(minimalWeight, 1 / widget.children.length);
      return minimalWeight;
    }
    return MultiSplitView.defaultMinimalWeight;
  }

  /// Updates the highlighted divider index.
  _updatesHighlightedDividerIndex(int? index) {
    if (_highlightedDividerIndex != index && widget.dividerPainter != null) {
      setState(() {
        _highlightedDividerIndex = index;
      });
    }
  }

  /// Applies the horizontal layout
  _populateHorizontalChildren(BuildContext context, BoxConstraints constraints,
      List<Widget> children, double minimalWeight) {
    double totalChildrenSize = constraints.maxWidth - _totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      double childWeight = _controller.getWeight(childIndex);
      totalRemainingWeight -= childWeight;

      childDistance.right = _distanceOnTheOppositeSide(
          childIndex, totalChildrenSize, totalRemainingWeight);

      children.add(_buildPositioned(
          distance: childDistance, child: widget.children[childIndex]));

      if (childIndex < widget.children.length - 1) {
        double childSize = totalChildrenSize * childWeight;

        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.left = childDistance.left + childSize;
        dividerDistance.right = childDistance.right - widget.dividerThickness;

        Widget dividerWidget = _buildDividerWidget(Axis.vertical, childIndex);
        if (widget.resizable) {
          dividerWidget = MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            onEnter: (event) => _updatesHighlightedDividerIndex(childIndex),
            onExit: (event) => _updatesHighlightedDividerIndex(null),
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
        childDistance.left = dividerDistance.left + widget.dividerThickness;
      }
    }
    return Stack(children: children);
  }

  /// Applies the vertical layout
  _populateVerticalChildren(BuildContext context, BoxConstraints constraints,
      List<Widget> children, double minimalWeight) {
    double totalChildrenSize = constraints.maxHeight - _totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      double childWeight = _controller.getWeight(childIndex);
      totalRemainingWeight -= childWeight;

      childDistance.bottom = _distanceOnTheOppositeSide(
          childIndex, totalChildrenSize, totalRemainingWeight);

      children.add(_buildPositioned(
          distance: childDistance, child: widget.children[childIndex]));

      if (childIndex < widget.children.length - 1) {
        double childSize = totalChildrenSize * childWeight;

        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.top = childDistance.top + childSize;
        dividerDistance.bottom = childDistance.bottom - widget.dividerThickness;

        Widget dividerWidget = _buildDividerWidget(Axis.horizontal, childIndex);
        if (widget.resizable) {
          dividerWidget = MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            onEnter: (event) => _updatesHighlightedDividerIndex(childIndex),
            onExit: (event) => _updatesHighlightedDividerIndex(null),
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
        childDistance.top = dividerDistance.top + widget.dividerThickness;
      }
    }
  }

  /// Builds a widget for the divider depending on whether [dividerPainter]
  /// has been set.
  Widget _buildDividerWidget(Axis axis, int childIndex) {
    if (widget.dividerPainter != null) {
      return ClipRect(
          child: CustomPaint(
              child: Container(color: widget.dividerColor),
              painter: _DividerPainterWrapper(
                  axis,
                  widget.resizable,
                  _highlightedDividerIndex == childIndex,
                  widget.dividerPainter!)));
    }
    return Container(color: widget.dividerColor);
  }

  _updateInitialValues(int childIndex, double pos, double totalChildrenSize) {
    _initialDragPos = pos;
    _initialChild1Weight = _controller.getWeight(childIndex);
    _initialChild2Weight = _controller.getWeight(childIndex + 1);
    _initialChild1Size = totalChildrenSize * _initialChild1Weight;
  }

  /// Calculates the new weights and sets if they are different from the current one.
  _updateDifferentWeights(
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
      int childIndex, double totalChildrenSize, double totalRemainingWeight) {
    int amountRemainingDividers = widget.children.length - 1 - childIndex;
    return (amountRemainingDividers * widget.dividerThickness) +
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

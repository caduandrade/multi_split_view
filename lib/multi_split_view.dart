library multi_split_view;

import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MultiSplitView extends StatefulWidget {
  static const Color defaultDividerColor = Colors.white;
  static const double defaultDividerThickness = 5.0;
  static const double defaultMinimalWeight = .05;
  static const double minimalWidgetWeightLowerLimit = 0.01;
  static const double minimalWidgetWeightUpperLimit = 0.9;

  final bool _horizontal;
  final List<Widget> children;
  final MultiSplitViewController? controller;
  final double dividerThickness;

  /// Defines the divider color. The default value is defined by [MultiSplitView.defaultDividerColor] constant.
  final Color? dividerColor;

  /// Defines the minimal weight for each child. The default value is defined by [MultiSplitView.defaultMinimalWeight] constant.
  final double minimalWeight;
  // Function to listen any children size change.
  final OnSizeChange? _onSizeChange;

  MultiSplitView._(
    this._horizontal,
    this.children,
    this.controller,
    this.dividerThickness,
    this.dividerColor,
    this.minimalWeight,
    this._onSizeChange,
  ) {
    if (dividerThickness <= 0) {
      throw Exception('The thickness of the divider must be positive.');
    }
    if (minimalWeight < MultiSplitView.minimalWidgetWeightLowerLimit ||
        minimalWeight > MultiSplitView.minimalWidgetWeightUpperLimit) {
      throw Exception('The minimum weight must be between ' +
          MultiSplitView.minimalWidgetWeightLowerLimit.toString() +
          ' and ' +
          MultiSplitView.minimalWidgetWeightUpperLimit.toString() +
          '.');
    }
  }

  /// Creates a horizontal split view
  factory MultiSplitView.horizontal(
      {required List<Widget> children,
      MultiSplitViewController? controller,
      double dividerThickness = MultiSplitView.defaultDividerThickness,
      Color dividerColor = MultiSplitView.defaultDividerColor,
      double minimalWeight = MultiSplitView.defaultMinimalWeight,
      OnSizeChange? onSizeChange}) {
    return MultiSplitView._(true, children, controller, dividerThickness,
        dividerColor, minimalWeight, onSizeChange);
  }

  /// Creates a vertical split view
  factory MultiSplitView.vertical(
      {required List<Widget> children,
      MultiSplitViewController? controller,
      double dividerThickness = MultiSplitView.defaultDividerThickness,
      Color dividerColor = MultiSplitView.defaultDividerColor,
      double minimalWeight = MultiSplitView.defaultMinimalWeight,
      OnSizeChange? onSizeChange}) {
    return MultiSplitView._(false, children, controller, dividerThickness,
        dividerColor, minimalWeight, onSizeChange);
  }

  @override
  State createState() => _MultiSplitViewState();

  bool get horizontal => _horizontal;
  bool get vertical => !_horizontal;
}

class _MultiSplitViewState extends State<MultiSplitView> {
  late double _totalDividerSize;
  late MultiSplitViewController _controller;
  double _initialDragPos = 0;
  double _initialChild1Weight = 0;
  double _initialChild2Weight = 0;
  double _initialChild1Size = 0;

  @override
  void initState() {
    super.initState();
    _totalDividerSize = (widget.children.length - 1) * widget.dividerThickness;
    _controller = widget.controller != null
        ? widget.controller!
        : MultiSplitViewController();
    _controller._validateAndAdjust(
        widget.children.length, widget.minimalWeight);
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
    _controller._validateAndAdjust(
        widget.children.length, widget.minimalWeight);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.length > 0) {
      return LayoutBuilder(builder: (context, constraints) {
        List<Widget> children = List.empty(growable: true);
        if (widget.dividerColor != null) {
          children
              .add(Positioned(child: Container(color: widget.dividerColor)));
        }
        if (widget.horizontal) {
          _populateHorizontalChildren(context, constraints, children);
        } else {
          _populateVerticalChildren(context, constraints, children);
        }

        return Stack(children: children);
      });
    }
    return Container();
  }

  _populateHorizontalChildren(
      BuildContext context, BoxConstraints constraints, List<Widget> children) {
    double totalChildrenSize = constraints.maxWidth - _totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      double childWeight = _controller._weights[childIndex];
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

        children.add(_buildPositioned(
          distance: dividerDistance,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (detail) {
                final pos = _position(context, detail.globalPosition);
                _updateInitialValues(childIndex, pos.dx, totalChildrenSize);
              },
              onHorizontalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffX = pos.dx - _initialDragPos;
                _updateDifferentWeights(childIndex, diffX);
              },
              child: Container(color: widget.dividerColor),
            ),
          ),
        ));
        childDistance.left = dividerDistance.left + widget.dividerThickness;
      }
    }
    return Stack(children: children);
  }

  _populateVerticalChildren(
      BuildContext context, BoxConstraints constraints, List<Widget> children) {
    double totalChildrenSize = constraints.maxHeight - _totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      double childWeight = _controller._weights[childIndex];
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

        children.add(_buildPositioned(
          distance: dividerDistance,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (detail) {
                final pos = _position(context, detail.globalPosition);
                _updateInitialValues(childIndex, pos.dy, totalChildrenSize);
              },
              onVerticalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffY = pos.dy - _initialDragPos;
                _updateDifferentWeights(childIndex, diffY);
              },
              child: Container(color: widget.dividerColor),
            ),
          ),
        ));
        childDistance.top = dividerDistance.top + widget.dividerThickness;
      }
    }
  }

  _updateInitialValues(int childIndex, double pos, double totalChildrenSize) {
    _initialDragPos = pos;
    _initialChild1Weight = _controller._weights[childIndex];
    _initialChild2Weight = _controller._weights[childIndex + 1];
    _initialChild1Size = totalChildrenSize * _initialChild1Weight;
  }

  _updateDifferentWeights(int childIndex, double diffPos) {
    double newChild1Weight =
        ((_initialChild1Size + diffPos) * _initialChild1Weight) /
            _initialChild1Size;

    double maxChild1Weight =
        _initialChild1Weight + _initialChild2Weight - widget.minimalWeight;

    newChild1Weight = max(widget.minimalWeight, newChild1Weight);
    newChild1Weight = min(maxChild1Weight, newChild1Weight);

    double newChild2Weight =
        _initialChild1Weight + _initialChild2Weight - newChild1Weight;

    if (_controller._weights[childIndex] != newChild1Weight) {
      setState(() {
        _controller._weights[childIndex] = newChild1Weight;
        _controller._weights[childIndex + 1] = newChild2Weight;
      });
      if (widget._onSizeChange != null) {
        widget._onSizeChange!(childIndex, childIndex + 1);
      }
    }
  }

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

class MultiSplitViewController {
  static const double _lowerPrecision = 0.9999999999999;
  static const double _higherPrecision = 1.0000000000001;

  List<double> _weights;

  MultiSplitViewController._(this._weights);

  factory MultiSplitViewController({List<double>? weights}) {
    if (weights == null) {
      weights = List.empty(growable: true);
    }
    return MultiSplitViewController._(weights);
  }

  UnmodifiableListView<double> get weights => UnmodifiableListView(_weights);

  _validateAndAdjust(int childrenCount, double minimalWeight) {
    List<double> adjustedWeights = List.empty(growable: true);

    double weightSum = 0;
    for (int i = 0; i < weights.length && i < childrenCount; i++) {
      double weight = weights[i];
      if (weight <= 0) {
        throw Exception('Weight needs to be positive: $weight');
      }
      adjustedWeights.add(weight);
      weightSum += weight;
    }

    if (adjustedWeights.length == childrenCount &&
        weightSum > MultiSplitViewController._higherPrecision) {
      throw Exception('The sum of the weights cannot exceed 1: $weightSum');
    }
    if (adjustedWeights.length < childrenCount) {
      if (weightSum >= MultiSplitViewController._lowerPrecision) {
        // new child has been added. Set the minimum weight for it, removing an equal amount of the others that have available weight.
        int addedChildrenCount = childrenCount - adjustedWeights.length;

        while (addedChildrenCount > 0) {
          double totalAvailableWeight = 0;
          for (int i = 0; i < adjustedWeights.length; i++) {
            if (adjustedWeights[i] > minimalWeight) {
              totalAvailableWeight += adjustedWeights[i] - minimalWeight;
            }
          }

          if (totalAvailableWeight < minimalWeight) {
            throw Exception('There is no space available for the widgets.');
          }

          double remainingWeight = minimalWeight;

          for (int i = adjustedWeights.length - 1;
              i >= 0 && remainingWeight > 0;
              i--) {
            if (adjustedWeights[i] > minimalWeight) {
              double excessWeight = adjustedWeights[i] - minimalWeight;
              double weightToBeRemoved = min(excessWeight, remainingWeight);
              adjustedWeights[i] -= weightToBeRemoved;
              remainingWeight -= weightToBeRemoved;
            }
          }

          adjustedWeights.add(minimalWeight);

          addedChildrenCount--;
        }
      } else {
        // filling the missing weights if the number of children is less than the number of weights
        double availableWeight = 1 - weightSum;
        int missingWeightsCount = childrenCount - adjustedWeights.length;
        double generatedWeight = availableWeight / missingWeightsCount;
        for (int i = 0; i < missingWeightsCount; i++) {
          weightSum += generatedWeight;
          adjustedWeights.add(generatedWeight);
        }
      }
    } else if (weightSum < 1 && adjustedWeights.length > 0) {
      // increasing the last weight if the total sum is less than 1 and the number of children is equal to the number of weights
      double lastWeight = adjustedWeights[adjustedWeights.length - 1];
      adjustedWeights[adjustedWeights.length - 1] =
          lastWeight + (1 - weightSum);
    }

    this._weights = adjustedWeights;
  }
}

class _DistanceFrom {
  double top;
  double left;
  double right;
  double bottom;

  _DistanceFrom({this.top = 0, this.left = 0, this.right = 0, this.bottom = 0});
}

typedef OnSizeChange = Function(int childIndex1, int childIndex2);

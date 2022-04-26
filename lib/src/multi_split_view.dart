import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_split_view/src/divider_widget.dart';
import 'package:multi_split_view/src/theme_data.dart';
import 'package:multi_split_view/src/theme_widget.dart';

/// Controller for [MultiSplitView].
///
/// It is not allowed to share this controller between [MultiSplitView]
/// instances.
class MultiSplitViewController extends ChangeNotifier {
  static const double _higherPrecision = 1.0000000000001;

  MultiSplitViewController._(this._weights);

  /// Creates an [MultiSplitViewController].
  ///
  /// The sum of the [weights] cannot exceed 1.
  factory MultiSplitViewController({List<double>? weights}) {
    return MultiSplitViewController._(
        weights != null ? List.from(weights) : []);
  }

  List<double> _weights;
  UnmodifiableListView<double> get weights => UnmodifiableListView(_weights);

  set weights(List<double> weights) {
    _weights = List.from(weights);
    notifyListeners();
  }

  /// Gets the weight of a given widget.
  double getWeight(int index) {
    return _weights[index];
  }

  void _setWeight(int index, double value) {
    if (value < 0) {
      throw Exception('Weight needs to be positive: $value');
    }
    _weights[index] = value;
  }

  /// Adjusts the weights according to the number of children.
  /// New children will receive a percentage of current children.
  /// Excluded children will distribute their weights to the existing ones.
  @visibleForTesting
  void validateAndAdjust(int childrenCount) {
    childrenCount = math.max(childrenCount, 0);

    double weightSum = 0;
    for (int i = 0; i < _weights.length; i++) {
      double weight = _weights[i];
      if (weight <= 0) {
        throw Exception('Weight needs to be positive: $weight');
      }
      weightSum += weight;
    }

    if (weightSum > MultiSplitViewController._higherPrecision) {
      throw Exception('The sum of the weights cannot exceed 1: $weightSum');
    }

    if (_weights.length == childrenCount) {
      _fillWeightsEqually(childrenCount, weightSum);
      return;
    } else if (_weights.length < childrenCount) {
      // children has been added.
      int addedChildrenCount = childrenCount - _weights.length;
      double newWeight = 0;
      if (weightSum < 1) {
        newWeight = (1 - weightSum) / addedChildrenCount;
      } else {
        for (int i = 0; i < _weights.length; i++) {
          double r = _weights[i] / childrenCount;
          _weights[i] -= r;
          newWeight += r / addedChildrenCount;
        }
      }
      for (int i = 0; i < addedChildrenCount; i++) {
        _weights.add(newWeight);
      }
    } else {
      // children has been removed.
      double removedWeight = 0;
      while (_weights.length > childrenCount) {
        removedWeight += _weights.removeLast();
      }
      if (_weights.isNotEmpty) {
        double w = removedWeight / _weights.length;
        for (int i = 0; i < _weights.length; i++) {
          _weights[i] += w;
        }
      }
    }

    weightSum = 0;
    _weights.forEach((weight) {
      weightSum += weight;
    });

    _fillWeightsEqually(childrenCount, weightSum);
  }

  /// Fills equally the missing weights
  void _fillWeightsEqually(int childrenCount, double weightSum) {
    if (weightSum < 1) {
      double availableWeight = 1 - weightSum;
      if (availableWeight > 0) {
        double w = availableWeight / childrenCount;
        for (int i = 0; i < _weights.length; i++) {
          _weights[i] += w;
        }
      }
    }
  }

  /// Stores the hashCode of the state to identify if a controller instance
  /// is being shared by multiple [MultiSplitView]. The application must not
  /// manipulate this attribute, it is for the internal use of the package.
  int? _stateHashCode;
}

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
  /// The sum of the [initialWeights] cannot exceed 1.
  /// The [initialWeights] parameter will be ignored if the [controller]
  /// has been provided.
  MultiSplitView(
      {Key? key,
      this.axis = MultiSplitView.defaultAxis,
      required this.children,
      this.controller,
      this.globalMinimalWeight,
      List<double>? minimalWeights,
      this.dividerBuilder,
      this.globalMinimalSize,
      List<double>? minimalSizes,
      this.onSizeChange,
      this.resizable = true,
      this.antiAliasingWorkaround = true,
      List<double>? initialWeights})
      : this.initialWeights =
            initialWeights != null ? List.from(initialWeights) : null,
        this.minimalWeights =
            minimalWeights != null ? List.from(minimalWeights) : null,
        this.minimalSizes =
            minimalSizes != null ? List.from(minimalSizes) : null,
        super(key: key) {
    if (globalMinimalWeight != null &&
        (globalMinimalWeight! < MultiSplitView.minimalWidgetWeightLowerLimit ||
            globalMinimalWeight! >
                MultiSplitView.minimalWidgetWeightUpperLimit)) {
      throw Exception(
          'The global minimum weight must be between ${MultiSplitView.minimalWidgetWeightLowerLimit} and ${MultiSplitView.minimalWidgetWeightUpperLimit}.');
    }
    if (minimalWeights != null) {
      minimalWeights.forEach((value) {
        if (value < MultiSplitView.minimalWidgetWeightLowerLimit ||
            value > MultiSplitView.minimalWidgetWeightUpperLimit) {
          throw Exception(
              'The minimum weight must be between ${MultiSplitView.minimalWidgetWeightLowerLimit} and ${MultiSplitView.minimalWidgetWeightUpperLimit}.');
        }
      });
    }
  }

  final Axis axis;
  final List<Widget> children;
  final MultiSplitViewController? controller;
  final List<double>? initialWeights;

  /// Defines a builder of dividers. Overrides the default divider
  /// created by the theme.
  final DividerBuilder? dividerBuilder;

  /// Indicates whether it is resizable. The default value is [TRUE].
  final bool resizable;

  /// Defines the global minimal weight for all children. The default value is defined by [MultiSplitView.defaultMinimalWeight] constant.
  /// It will be used if [minimalWeights] has not been set.
  final double? globalMinimalWeight;

  /// Defines the minimal weight for each child.
  final List<double>? minimalWeights;

  /// Defines the global minimal size in pixels for all children.
  /// It will be used if [minimalSizes] has not been set.
  /// The size will be converted into weight and will respect the limit
  /// defined by the [MultiSplitView.defaultMinimalWeight] constant,
  /// allowing all children to be visible.
  /// The value [zero] is ignored and indicates that no size has been set.
  final double? globalMinimalSize;

  /// Defines the minimal size in pixels for each child.
  /// It will be used if [globalMinimalWeight] has not been set.
  /// The size will be converted into weight and will respect the limit
  /// defined by the [MultiSplitView.defaultMinimalWeight] constant,
  /// allowing all children to be visible.
  /// The value [zero] is ignored and indicates that no size has been set.
  final List<double>? minimalSizes;

  /// Function to listen any children size change.
  final OnSizeChange? onSizeChange;

  /// Enables a workaround for https://github.com/flutter/flutter/issues/14288
  final bool antiAliasingWorkaround;

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
  int? _draggingDividerIndex;
  int? _hoverDividerIndex;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller != null
        ? widget.controller!
        : MultiSplitViewController(weights: widget.initialWeights);
    _stateHashCodeValidation();
    _controller._stateHashCode = hashCode;
    _controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  void deactivate() {
    _controller._stateHashCode = null;
    super.deactivate();
  }

  @override
  void didUpdateWidget(MultiSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != _controller) {
      List<double> weights = _controller.weights;
      _controller._stateHashCode = null;
      _controller.removeListener(_rebuild);

      _controller = widget.controller != null
          ? widget.controller!
          : MultiSplitViewController(weights: weights);
      _stateHashCodeValidation();
      _controller._stateHashCode = hashCode;
      _controller.addListener(_rebuild);
    }
  }

  /// Checks a controller's [_stateHashCode] to identify if it is
  /// not being shared by another instance of [MultiSplitView].
  void _stateHashCodeValidation() {
    if (_controller._stateHashCode != null &&
        _controller._stateHashCode != hashCode) {
      throw StateError(
          'It is not allowed to share MultiSplitViewController between MultiSplitView instances.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.length > 0) {
      MultiSplitViewThemeData themeData = MultiSplitViewTheme.of(context);
      double totalDividerSize =
          (widget.children.length - 1) * themeData.dividerThickness;

      return LayoutBuilder(builder: (context, constraints) {
        _controller.validateAndAdjust(widget.children.length);
        List<Widget> children = [];
        if (widget.axis == Axis.horizontal) {
          double availableArea = constraints.maxWidth - totalDividerSize;
          _populateHorizontalChildren(
              context: context,
              constraints: constraints,
              totalDividerSize: totalDividerSize,
              children: children,
              availableArea: availableArea,
              themeData: themeData);
        } else {
          double availableArea = constraints.maxHeight - totalDividerSize;
          _populateVerticalChildren(
              context: context,
              constraints: constraints,
              totalDividerSize: totalDividerSize,
              children: children,
              availableArea: availableArea,
              themeData: themeData);
        }

        return Stack(children: children);
      });
    }
    return Container();
  }

  /// Calculates the minimum weight. Used when the pixel size has been set.
  double _minimalWeight(
      {required int childIndex, required double availableArea}) {
    if (widget.minimalWeights != null &&
        childIndex < widget.minimalWeights!.length) {
      return widget.minimalWeights![childIndex];
    } else if (widget.globalMinimalWeight != null) {
      return widget.globalMinimalWeight!;
    }

    if (widget.minimalSizes != null &&
        childIndex < widget.minimalSizes!.length) {
      double size = math.max(0, widget.minimalSizes![childIndex]);
      if (size > 0) {
        return _sizeToWeight(size: size, availableArea: availableArea);
      }
    }

    if (widget.globalMinimalSize != null) {
      double size = math.max(0, widget.globalMinimalSize!);
      if (size > 0) {
        return _sizeToWeight(size: size, availableArea: availableArea);
      }
    }
    return MultiSplitView.defaultMinimalWeight;
  }

  /// Calculates a weight given a size in pixels.
  double _sizeToWeight({required double size, required double availableArea}) {
    double minimalWeight = size / availableArea;
    minimalWeight =
        math.max(minimalWeight, MultiSplitView.defaultMinimalWeight);
    minimalWeight = math.min(minimalWeight, 1 / widget.children.length);
    return minimalWeight;
  }

  /// Updates the hover divider index.
  void _updatesHoverDividerIndex(
      {int? index, required MultiSplitViewThemeData themeData}) {
    if (_hoverDividerIndex != index &&
        (themeData.dividerPainter != null || widget.dividerBuilder != null)) {
      setState(() {
        _hoverDividerIndex = index;
      });
    }
  }

  /// Applies the horizontal layout
  void _populateHorizontalChildren(
      {required BuildContext context,
      required BoxConstraints constraints,
      required double totalDividerSize,
      required List<Widget> children,
      required double availableArea,
      required MultiSplitViewThemeData themeData}) {
    double totalChildrenSize = constraints.maxWidth - totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      bool highlighted = (_draggingDividerIndex == childIndex ||
          (_draggingDividerIndex == null && _hoverDividerIndex == childIndex));
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

        Widget dividerWidget = widget.dividerBuilder != null
            ? widget.dividerBuilder!(
                Axis.vertical,
                childIndex,
                widget.resizable,
                _draggingDividerIndex == childIndex,
                highlighted,
                themeData)
            : DividerWidget(
                axis: Axis.vertical,
                index: childIndex,
                themeData: themeData,
                highlighted: highlighted,
                resizable: widget.resizable,
                dragging: _draggingDividerIndex == childIndex);
        if (widget.resizable) {
          dividerWidget = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (detail) {
                setState(() {
                  _draggingDividerIndex = childIndex;
                });
                final pos = _position(context, detail.globalPosition);
                _updateInitialValues(childIndex, pos.dx, totalChildrenSize);
              },
              onHorizontalDragEnd: (detail) {
                setState(() {
                  _draggingDividerIndex = null;
                });
              },
              onHorizontalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffX = pos.dx - _initialDragPos;

                _updateDifferentWeights(
                    childIndex: childIndex,
                    diffPos: diffX,
                    availableArea: availableArea);
              },
              child: dividerWidget);
          dividerWidget = _mouseRegion(
              index: childIndex,
              axis: Axis.vertical,
              dividerWidget: dividerWidget,
              themeData: themeData);
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
      required double availableArea,
      required MultiSplitViewThemeData themeData}) {
    double totalChildrenSize = constraints.maxHeight - totalDividerSize;
    double totalRemainingWeight = 1;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      bool highlighted = (_draggingDividerIndex == childIndex ||
          (_draggingDividerIndex == null && _hoverDividerIndex == childIndex));
      double childWeight = _controller.getWeight(childIndex);
      totalRemainingWeight -= childWeight;

      childDistance.bottom = _distanceOnTheOppositeSide(
          childIndex: childIndex,
          totalChildrenSize: totalChildrenSize,
          totalRemainingWeight: totalRemainingWeight,
          themeData: themeData);

      children.add(_buildPositioned(
          distance: childDistance,
          child: widget.children[childIndex],
          last: childIndex == widget.children.length - 1));

      if (childIndex < widget.children.length - 1) {
        double childSize = totalChildrenSize * childWeight;

        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.top = childDistance.top + childSize;
        dividerDistance.bottom =
            childDistance.bottom - themeData.dividerThickness;

        Widget dividerWidget = widget.dividerBuilder != null
            ? widget.dividerBuilder!(
                Axis.horizontal,
                childIndex,
                widget.resizable,
                _draggingDividerIndex == childIndex,
                highlighted,
                themeData)
            : DividerWidget(
                axis: Axis.horizontal,
                index: childIndex,
                themeData: themeData,
                highlighted: highlighted,
                resizable: widget.resizable,
                dragging: _draggingDividerIndex == childIndex);
        if (widget.resizable) {
          dividerWidget = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (detail) {
                setState(() {
                  _draggingDividerIndex = childIndex;
                });
                final pos = _position(context, detail.globalPosition);
                _updateInitialValues(childIndex, pos.dy, totalChildrenSize);
              },
              onVerticalDragEnd: (detail) {
                setState(() {
                  _draggingDividerIndex = null;
                });
              },
              onVerticalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffY = pos.dy - _initialDragPos;
                _updateDifferentWeights(
                    childIndex: childIndex,
                    diffPos: diffY,
                    availableArea: availableArea);
              },
              child: dividerWidget);
          dividerWidget = _mouseRegion(
              index: childIndex,
              axis: Axis.horizontal,
              dividerWidget: dividerWidget,
              themeData: themeData);
        }
        children.add(
            _buildPositioned(distance: dividerDistance, child: dividerWidget));
        childDistance.top = dividerDistance.top + themeData.dividerThickness;
      }
    }
  }

  /// Wraps the divider widget with a [MouseRegion].
  Widget _mouseRegion(
      {required int index,
      required Axis axis,
      required Widget dividerWidget,
      required MultiSplitViewThemeData themeData}) {
    MouseCursor cursor = axis == Axis.horizontal
        ? SystemMouseCursors.resizeRow
        : SystemMouseCursors.resizeColumn;
    return MouseRegion(
        cursor: cursor,
        onEnter: (event) =>
            _updatesHoverDividerIndex(index: index, themeData: themeData),
        onExit: (event) => _updatesHoverDividerIndex(themeData: themeData),
        child: dividerWidget);
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
      {required int childIndex,
      required double diffPos,
      required double availableArea}) {
    double minimalWeight1 =
        _minimalWeight(childIndex: childIndex, availableArea: availableArea);
    double minimalWeight2 = _minimalWeight(
        childIndex: childIndex + 1, availableArea: availableArea);

    double newChild1Weight =
        ((_initialChild1Size + diffPos) * _initialChild1Weight) /
            _initialChild1Size;

    //double maxChild1Weight = _initialChild1Weight + _initialChild2Weight - minimalWeight1;

    newChild1Weight = math.max(minimalWeight1, newChild1Weight);
    //newChild1Weight = math.min(maxChild1Weight, newChild1Weight);

    if (newChild1Weight < minimalWeight1) {
      return;
    }
    double newChild2Weight =
        _initialChild1Weight + _initialChild2Weight - newChild1Weight;

    if (newChild2Weight < minimalWeight2) {
      return;
    }

    if (_controller.getWeight(childIndex) != newChild1Weight &&
        _controller.getWeight(childIndex + 1) != newChild2Weight) {
      setState(() {
        _controller._setWeight(childIndex, newChild1Weight);
        _controller._setWeight(childIndex + 1, newChild2Weight);
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
      {required _DistanceFrom distance,
      required Widget child,
      bool last = false}) {
    return Positioned(
        top: _convert(distance.top, last),
        left: _convert(distance.left, last),
        right: _convert(distance.right, last),
        bottom: _convert(distance.bottom, last),
        child: child);
  }

  /// This is a workaround for https://github.com/flutter/flutter/issues/14288
  /// The problem minimizes by avoiding the use of coordinates with
  /// decimal values.
  double _convert(double value, bool last) {
    if (widget.antiAliasingWorkaround) {
      if (last) {
        return value.roundToDouble();
      }
      return value.floorToDouble();
    }
    return value;
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

typedef OnSizeChange = void Function(int childIndex1, int childIndex2);

typedef DividerBuilder = Widget Function(Axis axis, int index, bool resizable,
    bool dragging, bool highlighted, MultiSplitViewThemeData themeData);

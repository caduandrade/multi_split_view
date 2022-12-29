import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/divider_tap_typedefs.dart';
import 'package:multi_split_view/src/divider_widget.dart';
import 'package:multi_split_view/src/sizes_cache.dart';
import 'package:multi_split_view/src/theme_data.dart';
import 'package:multi_split_view/src/theme_widget.dart';

/// Controller for [MultiSplitView].
///
/// It is not allowed to share this controller between [MultiSplitView]
/// instances.
class MultiSplitViewController extends ChangeNotifier {
  static const double _higherPrecision = 1.0000000000001;

  /// Creates an [MultiSplitViewController].
  ///
  /// The sum of the [weights] cannot exceed 1.
  factory MultiSplitViewController({List<Area>? areas}) {
    return MultiSplitViewController._(areas != null ? List.from(areas) : []);
  }

  MultiSplitViewController._(this._areas);

  List<Area> _areas;

  UnmodifiableListView<Area> get areas => UnmodifiableListView(_areas);

  set areas(List<Area> areas) {
    _areas = List.from(areas);
    notifyListeners();
  }

  /// Gets the area of a given widget index.
  Area getArea(int index) {
    return _areas[index];
  }

  /// Sum of all weights.
  double _weightSum() {
    double sum = 0;
    _areas.forEach((area) {
      sum += area.weight ?? 0;
    });
    return sum;
  }

  /// Adjusts the weights according to the number of children.
  /// New children will receive a percentage of current children.
  /// Excluded children will distribute their weights to the existing ones.
  @visibleForTesting
  void fixWeights(
      {required int childrenCount,
      required double fullSize,
      required double dividerThickness}) {
    childrenCount = math.max(childrenCount, 0);

    final double totalDividerSize = (childrenCount - 1) * dividerThickness;
    final double availableSize = fullSize - totalDividerSize;

    int nullWeightCount = 0;
    for (int i = 0; i < _areas.length; i++) {
      Area area = _areas[i];
      if (area.size != null) {
        _areas[i] = area.copyWithNewWeight(weight: area.size! / availableSize);
      }
      if (area.weight == null) {
        nullWeightCount++;
      }
    }

    double weightSum = _weightSum();

    // fill null weights
    if (nullWeightCount > 0) {
      double r = 0;
      if (weightSum < MultiSplitViewController._higherPrecision) {
        r = (1 - weightSum) / nullWeightCount;
      }
      for (int i = 0; i < _areas.length; i++) {
        Area area = _areas[i];
        if (area.weight == null) {
          _areas[i] = area.copyWithNewWeight(weight: r);
        }
      }
      weightSum = _weightSum();
    }

    // removing over weight...
    if (weightSum > MultiSplitViewController._higherPrecision) {
      final over = weightSum - 1;
      double r = over / weightSum;
      for (int i = 0; i < _areas.length; i++) {
        Area area = _areas[i];
        _areas[i] =
            area.copyWithNewWeight(weight: area.weight! - (area.weight! * r));
      }
    }

    if (_areas.length == childrenCount) {
      _fillWeightsEqually(childrenCount, weightSum);
      _applyMinimal(availableSize: availableSize);
      return;
    } else if (_areas.length < childrenCount) {
      // children has been added.
      int addedChildrenCount = childrenCount - _areas.length;
      double newWeight = 0;
      if (weightSum < 1) {
        newWeight = (1 - weightSum) / addedChildrenCount;
      } else {
        for (int i = 0; i < _areas.length; i++) {
          Area area = _areas[i];
          double r = area.weight! / childrenCount;
          _areas[i] = area.copyWithNewWeight(weight: area.weight! - r);
          newWeight += r / addedChildrenCount;
        }
      }
      for (int i = 0; i < addedChildrenCount; i++) {
        _areas.add(Area(weight: newWeight));
      }
    } else {
      // children has been removed.
      double removedWeight = 0;
      while (_areas.length > childrenCount) {
        removedWeight += _areas.removeLast().weight!;
      }
      if (_areas.isNotEmpty) {
        double w = removedWeight / _areas.length;
        for (int i = 0; i < _areas.length; i++) {
          Area area = _areas[i];
          _areas[i] = area.copyWithNewWeight(weight: area.weight! + w);
        }
      }
    }
    _fillWeightsEqually(childrenCount, _weightSum());
    _applyMinimal(availableSize: availableSize);
  }

  /// Fills equally the missing weights
  void _fillWeightsEqually(int childrenCount, double weightSum) {
    if (weightSum < 1) {
      double availableWeight = 1 - weightSum;
      if (availableWeight > 0) {
        double w = availableWeight / childrenCount;
        for (int i = 0; i < _areas.length; i++) {
          Area area = _areas[i];
          _areas[i] = area.copyWithNewWeight(weight: area.weight! + w);
        }
      }
    }
  }

  /// Fix the weights to the minimal size/weight.
  void _applyMinimal({required double availableSize}) {
    double totalNonMinimalWeight = 0;
    double totalMinimalWeight = 0;
    int minimalCount = 0;
    for (int i = 0; i < _areas.length; i++) {
      Area area = _areas[i];
      if (area.minimalSize != null) {
        double minimalWeight = area.minimalSize! / availableSize;
        totalMinimalWeight += minimalWeight;
        minimalCount++;
      } else if (area.minimalWeight != null) {
        totalMinimalWeight += area.minimalWeight!;
        minimalCount++;
      } else {
        totalNonMinimalWeight += area.weight!;
      }
    }
    if (totalMinimalWeight > 0) {
      double reducerMinimalWeight = 0;
      if (totalMinimalWeight > 1) {
        reducerMinimalWeight = ((totalMinimalWeight - 1) / minimalCount);
        totalMinimalWeight = 1;
      }
      double totalReducerNonMinimalWeight = 0;
      if (totalMinimalWeight + totalNonMinimalWeight > 1) {
        totalReducerNonMinimalWeight =
            (totalMinimalWeight + totalNonMinimalWeight - 1);
      }
      for (int i = 0; i < _areas.length; i++) {
        Area area = _areas[i];
        if (area.minimalSize != null) {
          double minimalWeight = math.max(
              0, (area.minimalSize! / availableSize) - reducerMinimalWeight);
          if (area.weight! < minimalWeight) {
            _areas[i] = area.copyWithNewWeight(weight: minimalWeight);
          }
        } else if (area.minimalWeight != null) {
          double minimalWeight =
              math.max(0, area.minimalWeight! - reducerMinimalWeight);
          if (area.weight! < minimalWeight) {
            _areas[i] = area.copyWithNewWeight(weight: minimalWeight);
          }
        } else if (totalReducerNonMinimalWeight > 0) {
          double reducer = totalReducerNonMinimalWeight *
              area.weight! /
              totalNonMinimalWeight;
          double newWeight = math.max(0, area.weight! - reducer);
          _areas[i] = area.copyWithNewWeight(weight: newWeight);
        }
      }
    }
  }

  /// Stores the hashCode of the state to identify if a controller instance
  /// is being shared by multiple [MultiSplitView]. The application must not
  /// manipulate this attribute, it is for the internal use of the package.
  int? _stateHashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiSplitViewController &&
          runtimeType == other.runtimeType &&
          _areas == other._areas;

  @override
  int get hashCode => _areas.hashCode;

  int get weightsHashCode => Object.hashAll(_WeightIterable(areas));
}

class _WeightIterable extends Iterable<double?> {
  _WeightIterable(this.areas);

  final List<Area> areas;

  @override
  Iterator<double?> get iterator => _WeightIterator(areas);
}

class _WeightIterator extends Iterator<double?> {
  _WeightIterator(this.areas);

  final List<Area> areas;
  int _index = -1;

  @override
  double? get current => areas[_index].weight;

  @override
  bool moveNext() {
    _index++;
    return _index > -1 && _index < areas.length;
  }
}

/// A widget to provides horizontal or vertical multiple split view.
class MultiSplitView extends StatefulWidget {
  static const Axis defaultAxis = Axis.horizontal;

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
      this.dividerBuilder,
      this.onWeightChange,
      this.onDividerTap,
      this.onDividerDoubleTap,
      this.resizable = true,
      this.antiAliasingWorkaround = true,
      List<Area>? initialAreas})
      : this.initialAreas =
            initialAreas != null ? List.from(initialAreas) : null,
        super(key: key);

  final Axis axis;
  final List<Widget> children;
  final MultiSplitViewController? controller;
  final List<Area>? initialAreas;

  /// Signature for when a divider tap has occurred.
  final DividerTapCallback? onDividerTap;

  /// Signature for when a divider double tap has occurred.
  final DividerTapCallback? onDividerDoubleTap;

  /// Defines a builder of dividers. Overrides the default divider
  /// created by the theme.
  final DividerBuilder? dividerBuilder;

  /// Indicates whether it is resizable. The default value is [TRUE].
  final bool resizable;

  /// Function to listen children weight change.
  /// The listener will run on the parent's resize or
  /// on the dragging end of the divisor.
  final OnWeightChange? onWeightChange;

  /// Enables a workaround for https://github.com/flutter/flutter/issues/14288
  final bool antiAliasingWorkaround;

  @override
  State createState() => _MultiSplitViewState();
}

/// State for [MultiSplitView]
class _MultiSplitViewState extends State<MultiSplitView> {
  late MultiSplitViewController _controller;
  _InitialDrag? _initialDrag;

  int? _draggingDividerIndex;
  int? _hoverDividerIndex;
  SizesCache? _sizesCache;
  int? _weightsHashCode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller != null
        ? widget.controller!
        : MultiSplitViewController(areas: widget.initialAreas);
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
    setState(() {
      _sizesCache = null;
    });
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
      List<Area> areas = _controller._areas;
      _controller._stateHashCode = null;
      _controller.removeListener(_rebuild);

      _controller = widget.controller != null
          ? widget.controller!
          : MultiSplitViewController(areas: areas);
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
        List<Widget> children = [];
        if (widget.axis == Axis.horizontal) {
          _controller.fixWeights(
              childrenCount: widget.children.length,
              fullSize: constraints.maxWidth,
              dividerThickness: themeData.dividerThickness);
          if (_sizesCache == null ||
              _sizesCache!.childrenCount != widget.children.length ||
              _sizesCache!.fullSize != constraints.maxWidth) {
            _sizesCache = SizesCache(
                areas: _controller._areas,
                fullSize: constraints.maxWidth,
                dividerThickness: themeData.dividerThickness);
          }
          _populateHorizontalChildren(
              context: context,
              constraints: constraints,
              totalDividerSize: totalDividerSize,
              children: children,
              fullSize: constraints.maxWidth,
              themeData: themeData);
        } else {
          _controller.fixWeights(
              childrenCount: widget.children.length,
              fullSize: constraints.maxHeight,
              dividerThickness: themeData.dividerThickness);
          if (_sizesCache == null ||
              _sizesCache!.childrenCount != widget.children.length ||
              _sizesCache!.fullSize != constraints.maxHeight) {
            _sizesCache = SizesCache(
                areas: _controller._areas,
                fullSize: constraints.maxHeight,
                dividerThickness: themeData.dividerThickness);
          }
          _populateVerticalChildren(
              context: context,
              constraints: constraints,
              totalDividerSize: totalDividerSize,
              children: children,
              fullSize: constraints.maxHeight,
              themeData: themeData);
        }

        if (widget.onWeightChange != null) {
          int newWeightsHashCode = _controller.weightsHashCode;
          if (_weightsHashCode != null &&
              _weightsHashCode != newWeightsHashCode) {
            Future.microtask(widget.onWeightChange!);
          }
          _weightsHashCode = newWeightsHashCode;
        }

        return Stack(children: children);
      });
    }
    return Container();
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
      required double fullSize,
      required MultiSplitViewThemeData themeData}) {
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      bool highlighted = (_draggingDividerIndex == childIndex ||
          (_draggingDividerIndex == null && _hoverDividerIndex == childIndex));

      final double childSize = _sizesCache!.sizes[childIndex];
      childDistance.right = fullSize - childSize - childDistance.left;

      children.add(_buildPositioned(
          distance: childDistance, child: widget.children[childIndex]));

      if (childIndex < widget.children.length - 1) {
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
              onTap: () => _onDividerTap(childIndex),
              onDoubleTap: () => _onDividerDoubleTap(childIndex),
              onHorizontalDragStart: (detail) {
                setState(() {
                  _draggingDividerIndex = childIndex;
                });
                final pos = _position(context, detail.globalPosition);
                _updateInitialDrag(childIndex, pos.dx);
              },
              onHorizontalDragEnd: (detail) => _onDragEnd(),
              onHorizontalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffX = pos.dx - _initialDrag!.initialDragPos;

                _updateDifferentWeights(
                    childIndex: childIndex,
                    diffPos: diffX,
                    fullSize: fullSize,
                    pos: pos.dx);
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

  void _onDividerTap(int index) {
    if (widget.onDividerTap != null) {
      widget.onDividerTap!(index);
    }
  }

  void _onDividerDoubleTap(int index) {
    if (widget.onDividerDoubleTap != null) {
      widget.onDividerDoubleTap!(index);
    }
  }

  /// Applies the vertical layout
  void _populateVerticalChildren(
      {required BuildContext context,
      required BoxConstraints constraints,
      required double totalDividerSize,
      required List<Widget> children,
      required double fullSize,
      required MultiSplitViewThemeData themeData}) {
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      bool highlighted = (_draggingDividerIndex == childIndex ||
          (_draggingDividerIndex == null && _hoverDividerIndex == childIndex));

      final double childSize = _sizesCache!.sizes[childIndex];
      childDistance.bottom = fullSize - childSize - childDistance.top;

      children.add(_buildPositioned(
          distance: childDistance,
          child: widget.children[childIndex],
          last: childIndex == widget.children.length - 1));

      if (childIndex < widget.children.length - 1) {
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
                _updateInitialDrag(childIndex, pos.dy);
              },
              onVerticalDragEnd: (detail) => _onDragEnd(),
              onVerticalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffY = pos.dy - _initialDrag!.initialDragPos;
                _updateDifferentWeights(
                    childIndex: childIndex,
                    diffPos: diffY,
                    fullSize: fullSize,
                    pos: pos.dy);
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

  void _onDragEnd() {
    for (int i = 0; i < _controller._areas.length; i++) {
      Area area = _controller._areas[i];
      double size = _sizesCache!.sizes[i];
      _controller._areas[i] =
          area.copyWithNewWeight(weight: size / _sizesCache!.childrenSize);
    }

    setState(() {
      _draggingDividerIndex = null;
    });
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

  void _updateInitialDrag(int childIndex, double initialDragPos) {
    final double initialChild1Size = _sizesCache!.sizes[childIndex];
    final double initialChild2Size = _sizesCache!.sizes[childIndex + 1];
    final double minimalChild1Size = _sizesCache!.minimalSizes[childIndex];
    final double minimalChild2Size = _sizesCache!.minimalSizes[childIndex + 1];
    final double sumMinimals = minimalChild1Size + minimalChild2Size;
    final double sumSizes = initialChild1Size + initialChild2Size;

    double posLimitStart = 0;
    double posLimitEnd = 0;
    double child1Start = 0;
    double child2End = 0;
    for (int i = 0; i <= childIndex; i++) {
      if (i < childIndex) {
        child1Start += _sizesCache!.sizes[i];
        child1Start += _sizesCache!.dividerThickness;
        child2End += _sizesCache!.sizes[i];
        child2End += _sizesCache!.dividerThickness;
        posLimitStart += _sizesCache!.sizes[i];
        posLimitStart += _sizesCache!.dividerThickness;
        posLimitEnd += _sizesCache!.sizes[i];
        posLimitEnd += _sizesCache!.dividerThickness;
      } else if (i == childIndex) {
        posLimitStart += _sizesCache!.minimalSizes[i];
        posLimitEnd += _sizesCache!.sizes[i];
        posLimitEnd += _sizesCache!.dividerThickness;
        posLimitEnd += _sizesCache!.sizes[i + 1];
        child2End += _sizesCache!.sizes[i];
        child2End += _sizesCache!.dividerThickness;
        child2End += _sizesCache!.sizes[i + 1];
        posLimitEnd = math.max(
            posLimitStart, posLimitEnd - _sizesCache!.minimalSizes[i + 1]);
      }
    }

    _initialDrag = _InitialDrag(
        initialDragPos: initialDragPos,
        initialChild1Size: initialChild1Size,
        initialChild2Size: initialChild2Size,
        minimalChild1Size: minimalChild1Size,
        minimalChild2Size: minimalChild2Size,
        sumMinimals: sumMinimals,
        sumSizes: sumSizes,
        child1Start: child1Start,
        child2End: child2End,
        posLimitStart: posLimitStart,
        posLimitEnd: posLimitEnd);
    _initialDrag!.posBeforeMinimalChild1 = initialDragPos < posLimitStart;
    _initialDrag!.posAfterMinimalChild2 = initialDragPos > posLimitEnd;
  }

  /// Calculates the new weights and sets if they are different from the current one.
  void _updateDifferentWeights(
      {required int childIndex,
      required double diffPos,
      required double pos,
      required double fullSize}) {
    if (diffPos == 0) {
      return;
    }

    if (_initialDrag!.sumMinimals >= _initialDrag!.sumSizes) {
      // minimals already smaller than available space. Ignoring...
      return;
    }

    double newChild1Size;
    double newChild2Size;

    if (diffPos.isNegative) {
      // divider moving on left/top from initial mouse position
      if (_initialDrag!.posBeforeMinimalChild1) {
        // can't shrink, already smaller than minimal
        return;
      }
      newChild1Size = math.max(_initialDrag!.minimalChild1Size,
          _initialDrag!.initialChild1Size + diffPos);
      newChild2Size = _initialDrag!.sumSizes - newChild1Size;

      if (_initialDrag!.posAfterMinimalChild2) {
        if (newChild2Size > _initialDrag!.minimalChild2Size) {
          _initialDrag!.posAfterMinimalChild2 = false;
        }
      } else if (newChild2Size < _initialDrag!.minimalChild2Size) {
        double diff = _initialDrag!.minimalChild2Size - newChild2Size;
        newChild2Size += diff;
        newChild1Size -= diff;
      }
    } else {
      // divider moving on right/bottom from initial mouse position
      if (_initialDrag!.posAfterMinimalChild2) {
        // can't shrink, already smaller than minimal
        return;
      }
      newChild2Size = math.max(_initialDrag!.minimalChild2Size,
          _initialDrag!.initialChild2Size - diffPos);
      newChild1Size = _initialDrag!.sumSizes - newChild2Size;

      if (_initialDrag!.posBeforeMinimalChild1) {
        if (newChild1Size > _initialDrag!.minimalChild1Size) {
          _initialDrag!.posBeforeMinimalChild1 = false;
        }
      } else if (newChild1Size < _initialDrag!.minimalChild1Size) {
        double diff = _initialDrag!.minimalChild1Size - newChild1Size;
        newChild1Size += diff;
        newChild2Size -= diff;
      }
    }
    if (newChild1Size >= 0 && newChild2Size >= 0) {
      setState(() {
        _sizesCache!.sizes[childIndex] = newChild1Size;
        _sizesCache!.sizes[childIndex + 1] = newChild2Size;
      });
    }
  }

  /// Builds an [Offset] for cursor position.
  Offset _position(BuildContext context, Offset globalPosition) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    return container.globalToLocal(globalPosition);
  }

  /// Builds a [Positioned] using the [_DistanceFrom] parameters.
  Positioned _buildPositioned(
      {required _DistanceFrom distance,
      required Widget child,
      bool last = false}) {
    Positioned positioned = Positioned(
        key: child.key,
        top: _convert(distance.top, last),
        left: _convert(distance.left, last),
        right: _convert(distance.right, last),
        bottom: _convert(distance.bottom, last),
        child: ClipRect(child: child));
    return positioned;
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
  double top = 0;
  double left = 0;
  double right = 0;
  double bottom = 0;

  _DistanceFrom();
}

class _InitialDrag {
  _InitialDrag(
      {required this.initialDragPos,
      required this.initialChild1Size,
      required this.initialChild2Size,
      required this.minimalChild1Size,
      required this.minimalChild2Size,
      required this.sumMinimals,
      required this.sumSizes,
      required this.child1Start,
      required this.child2End,
      required this.posLimitStart,
      required this.posLimitEnd});

  final double initialDragPos;
  final double initialChild1Size;
  final double initialChild2Size;
  final double minimalChild1Size;
  final double minimalChild2Size;
  final double sumMinimals;
  final double sumSizes;
  final double child1Start;
  final double child2End;
  final double posLimitStart;
  final double posLimitEnd;
  bool posBeforeMinimalChild1 = false;
  bool posAfterMinimalChild2 = false;
}

/// Signature for when a weight area is changed.
typedef OnWeightChange = void Function();

typedef DividerBuilder = Widget Function(Axis axis, int index, bool resizable,
    bool dragging, bool highlighted, MultiSplitViewThemeData themeData);

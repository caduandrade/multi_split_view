import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';

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

  Object _areasUpdateHash = Object();

  /// Hash to identify [areas] setter usage.
  @internal
  Object get areasUpdateHash => _areasUpdateHash;

  set areas(List<Area> areas) {
    _areas = List.from(areas);
    _areasUpdateHash = Object();
    notifyListeners();
  }

  int get areasLength => _areas.length;

  @internal
  void setAreaAt(int index, Area area) {
    _areas[index] = area;
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
  @internal
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
  @internal
  int? stateHashCode;

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

import 'dart:math' as math;
import 'dart:collection';
import 'package:meta/meta.dart';

/// Controller for [MultiSplitView].
///
/// It is not allowed to share this controller between [MultiSplitView]
/// instances.
class MultiSplitViewController {
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

  /// Gets the weight of a given widget.
  double getWeight(int index) {
    return _weights[index];
  }

  @internal
  void setWeight(int index, double value) {
    if (value < 0) {
      throw Exception('Weight needs to be positive: $value');
    }
    _weights[index] = value;
  }

  /// Adjusts the weights according to the number of children.
  /// New children will receive a percentage of current children.
  /// Excluded children will distribute their weights to the existing ones.
  @internal
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
  @internal
  int? stateHashCode;
}

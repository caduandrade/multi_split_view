import 'package:meta/meta.dart';

/// Child area in the [MultiSplitView].
///
/// The area may have a [size] defined in pixels or [weight]
/// between 0 and 1.
/// Both [weight] and [minimalWeight] values will be multiplied by the total
/// size available ignoring the thickness of the dividers.
/// Before being visible for the first time, the [size] will be converted
/// to [weight] according to the size of the widget.
class Area {
  Area({double? size, double? weight, this.minimalWeight, this.minimalSize})
      : _size = size,
        _weight = weight {
    if (size != null && weight != null) {
      throw Exception('Cannot provide both a size and a weight.');
    }
    if (minimalWeight != null && minimalSize != null) {
      throw Exception('Cannot provide both a minimalWeight and a minimalSize.');
    }

    if (minimalWeight != null && (minimalWeight! < 0 || minimalWeight! > 1)) {
      throw Exception('The minimum weight must be between 0 and 1.');
    }
    _check('size', size);
    _check('weight', weight);
    _check('minimalWeight', minimalWeight);
    _check('minimalSize', minimalSize);
  }

  final double? minimalWeight;
  final double? minimalSize;

  double? _size;
  double? get size => _size;

  double? _weight;
  double? get weight => _weight;

  @internal
  void updateWeight(double value) {
    _size = null;
    _weight = value;
  }

  bool get hasMinimal => minimalSize != null || minimalWeight != null;

  void _check(String argument, double? value) {
    if (value != null) {
      if (value.isNaN) {
        throw Exception('$argument cannot be NaN');
      }
      if (value.isInfinite) {
        throw Exception('$argument cannot be Infinite');
      }
      if (value < 0) {
        throw Exception('$argument cannot be negative: $value');
      }
    }
  }

  static List<Area> sizes(List<double> sizes) {
    List<Area> list = [];
    sizes.forEach((size) => list.add(Area(size: size)));
    return list;
  }

  static List<Area> weights(List<double> weights) {
    List<Area> list = [];
    weights.forEach((weight) => list.add(Area(weight: weight)));
    return list;
  }
}

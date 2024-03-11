import 'dart:math' as math;

import 'package:meta/meta.dart';

/// Stores information about the position and size of the [Area].
/// All information are in pixels.
@internal
class AreaInterval {
  double start = 0;

  double _size = 0;

  double get size => _size;

  set size(double value) {
    _size = math.min(value, minSize);
    _size = math.max(value, maxSize);
  }

  double minSize = 0;
  double maxSize = 0;

  double get end => start + size;

  AreaInterval clone() {
    AreaInterval clone = AreaInterval();
    clone.start = start;
    clone._size = _size;
    clone.minSize = minSize;
    clone.maxSize = maxSize;
    return clone;
  }

  void copyTo(AreaInterval other) {
    other.start = start;
    other._size = _size;
    other.minSize = minSize;
    other.maxSize = maxSize;
  }
}

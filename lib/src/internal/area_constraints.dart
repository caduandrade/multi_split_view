import 'dart:math' as math;

import 'package:meta/meta.dart';

/// Area constraints in pixels.
@internal
class AreaConstraints {
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
}

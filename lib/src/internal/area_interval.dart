import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/internal/num_util.dart';

/// Stores information about the position and size of the [Area].
/// All information are in pixels.
@internal
class AreaInterval {
  double startPos = 0;

  double _size = 0;

  double get size => _size;

  set size(double value) {
    value = NumUtil.fix('value', value);
    if (minSize != null) {
      value = math.max(minSize!, value);
    }
    if (maxSize != null) {
      value = math.min(maxSize!, value);
    }
    _size = value;
  }

  double? minSize;
  double? maxSize;

  double get endPos => startPos + size;

  double get availableSizeToShrink =>
      endPos - startPos - (minSize != null ? minSize! : 0);

  double get availableSizeToGrow => math.max(maxSize! - (endPos - startPos), 0);

  AreaInterval clone() {
    AreaInterval clone = AreaInterval();
    clone.startPos = startPos;
    clone._size = _size;
    clone.minSize = minSize;
    clone.maxSize = maxSize;
    return clone;
  }

  void copyTo(AreaInterval other) {
    other.startPos = startPos;
    other._size = _size;
    other.minSize = minSize;
    other.maxSize = maxSize;
  }
}

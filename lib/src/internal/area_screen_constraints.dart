import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/internal/num_util.dart';

/// Stores information about the position and size of the [Area] on the screen.
/// All information are in pixels.
@internal
class AreaScreenConstraints {
  double startPos = 0;

  double _size = 0;

  double get size => _size;

  set size(double value) {
    _size = NumUtil.fix('value', value);
  }

  double? minSize;
  double? maxSize;

  double get endPos => startPos + size;

  double get availableSizeToShrink =>
      endPos - startPos - (minSize != null ? minSize! : 0);

  double? get availableSizeToMax =>
      maxSize == null ? null : math.max(maxSize! - size, 0);

  void reset() {
    startPos = 0;
    _size = 0;
    minSize = null;
    maxSize = null;
  }
}

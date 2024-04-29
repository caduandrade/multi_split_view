import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:multi_split_view/src/internal/num_util.dart';

/// Child area in the [MultiSplitView].
///
/// The area may have a [size] defined in pixels or [flex] factor to define
/// the filling of the available space.
///
/// The [flex] has a default value of 1 if the [size] is null.
///
/// The available size will be the size of the widget minus the thickness
/// of the dividers.
///
/// Before becoming visible for the first time, the area may be adjusted
/// to resolve the following inconsistencies:
///
/// * If all areas are using size, they will all be converted to use flex.
class Area {
  Area(
      {double? size,
      double? flex,
      double? min,
      double? max,
      this.data,
      this.widget,
      this.builder})
      : _size = size,
        _flex = flex,
        _min = min,
        _max = max {
    if (size != null && flex != null) {
      throw ArgumentError('Cannot provide both a size and a flex.');
    }
    NumUtil.validateDouble('size', size);
    NumUtil.validateDouble('flex', flex);
    NumUtil.validateDouble('min', min);
    NumUtil.validateDouble('max', max);
    if (size == null && flex == null) {
      _flex = 1;
    }
    if (min != null && max != null && max < min) {
      throw ArgumentError('The max needs to be greater than min.');
    }
    if (_flex != null) {
      if (min != null) {
        _flex = math.max(_flex!, min);
      }
      if (max != null) {
        _flex = math.min(_flex!, max);
      }
    } else if (_size != null) {
      if (min != null) {
        _size = math.max(_size!, min);
      }
      if (max != null) {
        _size = math.min(_size!, max);
      }
    }
  }

  double? _min;

  double? get min => _min;

  double? _max;

  double? get max => _max;

  double? _size;

  double? get size => _size;

  double? _flex;

  double? get flex => _flex;

  /// Any data associated with the area.
  dynamic data;

  UniqueKey _key = UniqueKey();

  WidgetBuilder? builder;

  Widget? widget;
}

@internal
class AreaHelper {
  static Key keyFrom({required Area area}) {
    return area._key;
  }

  static void setFlex({required Area area, required double flex}) {
    flex = NumUtil.fix('flex', flex);
    if (area.min != null) {
      flex = math.max(flex, area.min!);
    }
    area._flex = flex;
  }

  static void setSize({required Area area, required double? size}) {
    if (size != null) {
      size = NumUtil.fix('size', size);
    }
    area._size = size;
  }

  static void setMin({required Area area, required double? min}) {
    if (min != null) {
      min = math.max(0, min);
    }
    area._min = min;
  }

  static void setMax({required Area area, required double? max}) {
    area._max = max;
  }
}

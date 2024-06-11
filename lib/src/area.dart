import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area_widget_builder.dart';
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
      dynamic id,
      this.data,
      this.builder})
      : this.id = id != null ? id : _AreaId(),
        _size = size,
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

  int _index = -1;

  int get index => _index;

  double? _min;

  /// The min flex or size.
  double? get min => _min;

  double? _max;

  /// The max flex or size.
  double? get max => _max;

  double? _size;

  /// Size value in pixels.
  double? get size => _size;

  double? _flex;

  double? get flex => _flex;

  /// Any data associated with the area.
  dynamic data;

  /// Used as an internal Key and facilitates reconfiguration of the layout
  /// while maintaining the state of the widget.
  /// It will never be null and must be unique in the layout.
  final dynamic id;

  /// The widget builder.
  AreaWidgetBuilder? builder;
}

@internal
class AreaHelper {
  /// Sets the area flex value.
  static void setFlex({required Area area, required double flex}) {
    flex = NumUtil.fix('flex', flex);
    if (area.min != null) {
      flex = math.max(flex, area.min!);
    }
    area._flex = flex;
  }

  /// Sets the area size value.
  static void setSize({required Area area, required double? size}) {
    if (size != null) {
      size = NumUtil.fix('size', size);
    }
    area._size = size;
  }

  /// Sets the area min value.
  static void setMin({required Area area, required double? min}) {
    if (min != null) {
      min = math.max(0, min);
    }
    area._min = min;
  }

  /// Sets the area max value.
  static void setMax({required Area area, required double? max}) {
    area._max = max;
  }

  /// Sets the area index.
  static void setIndex({required Area area, required int index}) {
    area._index = index;
  }
}

/// Default area id object
class _AreaId {
  @override
  String toString() {
    return 'area id: $hashCode';
  }
}

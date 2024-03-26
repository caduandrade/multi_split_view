import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/internal/area_screen_constraints.dart';
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
  Area({double? size, double? flex, double? min, double? max, this.data})
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
  final dynamic data;

  AreaScreenConstraints _screenConstraints = AreaScreenConstraints();

  Area clone() {
    return Area(size: size, flex: flex, max: max, min: min, data: data);
  }

  static List<Area> sizes(List<double> sizes) {
    List<Area> list = [];
    sizes.forEach((size) => list.add(Area(size: size)));
    return list;
  }

  static List<Area> flexes(List<double> flexes) {
    List<Area> list = [];
    flexes.forEach((flex) => list.add(Area(flex: flex)));
    return list;
  }
}

@internal
class AreaHelper {
  static AreaScreenConstraints screenConstraintsOf(Area area) =>
      area._screenConstraints;

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

  static void testArea(Area area,
      {required dynamic data,
      required double? flex,
      required double? size,
      required double? min,
      required double? max}) {
    expect(area.data, data, reason: 'data');
    expect(area.min, min, reason: 'min');
    expect(area.max, max, reason: 'max');
    expect(area.flex, flex, reason: 'flex');
    expect(area.size, size, reason: 'size');
  }

  static void testScreenConstraints(AreaScreenConstraints constraints,
      {required double startPos,
      required double endPos,
      required double size,
      required double? minSize,
      required double? maxSize}) {
    expect(constraints.startPos, startPos, reason: 'startPos');
    expect(constraints.endPos, endPos, reason: 'endPos');
    expect(constraints.size, size, reason: 'size');
    expect(constraints.minSize, minSize, reason: 'minSize');
    expect(constraints.maxSize, maxSize, reason: 'maxSize');
  }

  static void testScreenConstraintsSize(AreaScreenConstraints constraints,
      {required double size,
      required double? minSize,
      required double? maxSize}) {
    expect(constraints.size, size, reason: 'size');
    expect(constraints.minSize, minSize, reason: 'minSize');
    expect(constraints.maxSize, maxSize, reason: 'maxSize');
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
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
class Area extends ChangeNotifier {
  Area(
      {double? size,
      double? flex,
      double? min,
      double? max,
      dynamic id,
      this.data,
      this.builder})
      : this.id = id != null ? id : _AreaId() {
    if (size != null && flex != null) {
      throw ArgumentError('Cannot provide both a size and a flex.');
    }
    if (size == null && flex == null) {
      flex = 1;
    }
    _setMinWithoutNotify(min);
    _setMaxWithoutNotify(max);
    _setFlexWithoutNotify(value: flex, useMin: true, useMax: true);
    _setSizeWithoutNotify(value: size, useMin: true, useMax: true);
  }

  void _checkMinMax() {
    if (_min != null && _max != null && _max! < _min!) {
      throw ArgumentError(
          'The max($_max) needs to be greater than min($_min).');
    }
  }

  /// Function used to change the hash in the controller
  Function? _hashChanger;

  int _index = -1;

  int get index => _index;

  /// The min flex or size.
  double? get min => _min;
  double? _min;

  /// Sets the area min value and notify listeners.
  void set min(double? value) {
    _setMinWithoutNotify(value);
    notifyListeners();
  }

  /// Sets the area min value without notify listeners.
  void _setMinWithoutNotify(double? value) {
    NumUtil.validateDouble('min', value);
    if (_min != value) {
      _min = value;
      _checkMinMax();
      if (_hashChanger != null) {
        _hashChanger!();
      }
    }
  }

  /// The max flex or size.
  double? get max => _max;
  double? _max;

  /// Sets the area max value and notify listeners.
  void set max(double? value) {
    _setMaxWithoutNotify(value);
    notifyListeners();
  }

  /// Sets the area max value without notify listeners.
  void _setMaxWithoutNotify(double? value) {
    NumUtil.validateDouble('max', value);
    if (_max != value) {
      _max = value;
      _checkMinMax();
      if (_hashChanger != null) {
        _hashChanger!();
      }
    }
  }

  double? _size;

  /// Size value in pixels.
  double? get size => _size;

  /// Sets the area size value and notify listeners.
  void set size(double? value) {
    if (_flex != null) {
      throw ArgumentError('Cannot provide both a size and a flex.');
    }
    _setSizeWithoutNotify(value: value, useMin: true, useMax: true);
    notifyListeners();
  }

  /// Sets the area size value without notify listeners.
  void _setSizeWithoutNotify(
      {required double? value, required bool useMin, required bool useMax}) {
    NumUtil.validateDouble('size', value);
    if (value != null) {
      value = NumUtil.fix('size', value);
    }
    if (_size != value) {
      _size = value;
      if (_size != null) {
        if (useMin && min != null) {
          _size = math.max(_size!, min!);
        }
        if (useMax && max != null) {
          _size = math.min(_size!, max!);
        }
      }
      if (_hashChanger != null) {
        _hashChanger!();
      }
    }
  }

  /// The flex value
  double? _flex;

  double? get flex => _flex;

  /// Sets the area flex value and notify listeners.
  void set flex(double? value) {
    if (_size != null) {
      throw ArgumentError('Cannot provide both a size and a flex.');
    }
    _setFlexWithoutNotify(value: value, useMin: true, useMax: true);
    notifyListeners();
  }

  /// Sets the area flex value without notify listeners.
  void _setFlexWithoutNotify(
      {required double? value, required bool useMin, required bool useMax}) {
    NumUtil.validateDouble('flex', value);
    if (value != null) {
      value = NumUtil.fix('flex', value);
    }
    if (_flex != value) {
      _flex = value;
      if (_flex != null) {
        if (useMin && min != null) {
          _flex = math.max(_flex!, min!);
        }
        if (useMax && max != null) {
          _flex = math.min(_flex!, max!);
        }
      }
      if (_hashChanger != null) {
        _hashChanger!();
      }
    }
  }

  /// Any data associated with the area.
  dynamic data;

  /// Used as an internal Key and facilitates reconfiguration of the layout
  /// while maintaining the state of the widget.
  /// It will never be null and must be unique in the layout.
  final dynamic id;

  /// The widget builder.
  AreaWidgetBuilder? builder;

  /// Creates a copy of this [Area] with the given fields replaced with their.
  Area copyWith({
    dynamic Function()? id,
    double? Function()? size,
    double? Function()? flex,
    double? Function()? min,
    double? Function()? max,
    dynamic Function()? data,
    AreaWidgetBuilder? Function()? builder,
  }) {
    return Area(
      id: id == null ? this.id : id(),
      size: size == null ? this.size : size(),
      flex: flex == null ? this.flex : flex(),
      min: min == null ? this.min : min(),
      max: max == null ? this.max : max(),
      data: data == null ? this.data : data(),
      builder: builder == null ? this.builder : builder(),
    );
  }
}

@internal
class AreaHelper {
  /// Sets the area flex value without notify listeners.
  static void setFlex({required Area area, required double flex}) {
    flex = math.max(0, flex);
    area._setFlexWithoutNotify(value: flex, useMin: true, useMax: false);
  }

  /// Sets the area size value without notify listeners.
  static void setSize({required Area area, required double? size}) {
    area._setSizeWithoutNotify(value: size, useMin: false, useMax: false);
  }

  /// Sets the area min value without notify listeners.
  static void setMinWithoutNotify({required Area area, required double? min}) {
    area._setMinWithoutNotify(min);
  }

  /// Sets the area max value without notify listeners.
  static void setMaxWithoutNotify({required Area area, required double? max}) {
    area._setMaxWithoutNotify(max);
  }

  /// Sets the area index.
  static void setIndex({required Area area, required int index}) {
    area._index = index;
  }

  static void setHashChanger(
      {required Area area, required Function? function}) {
    area._hashChanger = function;
  }
}

/// Default area id object
class _AreaId {
  @override
  String toString() {
    return 'area id: $hashCode';
  }
}

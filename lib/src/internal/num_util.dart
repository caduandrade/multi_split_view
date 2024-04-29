import 'dart:math' as math;

import 'package:meta/meta.dart';

@internal
class NumUtil {
  static double fix(String argument, double value) {
    value = math.max(0, value);
    NumUtil.validateDouble(argument, value);
    return NumUtil.round(value);
  }

  static void validateDouble(String argument, double? value) {
    if (value != null) {
      if (value.isNaN) {
        throw ArgumentError('Cannot be NaN', argument);
      }
      if (value.isInfinite) {
        throw ArgumentError('Cannot be Infinite', argument);
      }
      if (value < 0) {
        throw ArgumentError.value(value, argument, 'Cannot be negative');
      }
    }
  }

  static void validateInt(String argument, int? value) {
    if (value != null) {
      if (value.isNaN) {
        throw ArgumentError('Cannot be NaN', argument);
      }
      if (value.isInfinite) {
        throw ArgumentError('Cannot be Infinite', argument);
      }
      if (value < 0) {
        throw ArgumentError('Cannot be negative: $value', argument);
      }
    }
  }

  static double round(double value) {
    int places = 6;
    num mod = math.pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

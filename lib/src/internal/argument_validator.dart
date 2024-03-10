import 'package:meta/meta.dart';

@internal
class ArgumentValidator {
  static void validateDouble(String argument, double? value) {
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
}

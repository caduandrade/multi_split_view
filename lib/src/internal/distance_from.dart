import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Defines distance from edges.
@internal
class DistanceFrom {

  DistanceFrom();

  double top = 0;
  double left = 0;
  double right = 0;
  double bottom = 0;

  /// Builds a [Positioned] using the [DistanceFrom] parameters.
  Positioned buildPositioned(
      {  required bool antiAliasingWorkaround,   required Widget child,
        bool last = false}) {
    Positioned positioned = Positioned(
        key: child.key,
        top: _convert(antiAliasingWorkaround,top, last),
        left: _convert(antiAliasingWorkaround,left, last),
        right: _convert(antiAliasingWorkaround,right, last),
        bottom: _convert(antiAliasingWorkaround,bottom, last),
        child: ClipRect(child: child));
    return positioned;
  }

  /// This is a workaround for https://github.com/flutter/flutter/issues/14288
  /// The problem minimizes by avoiding the use of coordinates with
  /// decimal values.
  double _convert( bool antiAliasingWorkaround,double value, bool last) {
    if (antiAliasingWorkaround) {
      if (last) {
        //  return value.roundToDouble();
      }
      //return value.floorToDouble();
      return value.ceilToDouble();
      //return value.roundToDouble();
    }
    return value;
  }
}

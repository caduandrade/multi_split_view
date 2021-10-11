import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The divider painter factory.
class DividerPainters {
  /// Builds a simple divider painter.
  static DividerPainter simple(
      {bool animationEnabled = DividerPainter.defaultAnimationEnabled,
      Color? backgroundColor,
      Color? highlightedBackgroundColor}) {
    return DividerPainter(
        animationEnabled: animationEnabled,
        backgroundColor: backgroundColor,
        highlightedBackgroundColor: highlightedBackgroundColor);
  }

  /// Builds a dashed divider painter.
  static DividerPainter dashed(
      {double size = _DashedDividerPainter.defaultSize,
      double gap = _DashedDividerPainter.defaultGap,
      Color? backgroundColor,
      Color? highlightedBackgroundColor,
      bool animationEnabled = DividerPainter.defaultAnimationEnabled,
      Color color = _DashedDividerPainter.defaultColor,
      Color? highlightedColor,
      StrokeCap strokeCap = _DashedDividerPainter.defaultStrokeCap,
      double thickness = _DashedDividerPainter.defaultThickness,
      double? highlightedThickness,
      double? highlightedGap,
      double? highlightedSize}) {
    return _DashedDividerPainter(
        size: size,
        gap: gap,
        backgroundColor: backgroundColor,
        highlightedBackgroundColor: highlightedBackgroundColor,
        animationEnabled: animationEnabled,
        color: color,
        highlightedColor: highlightedColor,
        strokeCap: strokeCap,
        thickness: thickness,
        highlightedThickness: highlightedThickness,
        highlightedGap: highlightedGap,
        highlightedSize: highlightedSize);
  }

  /// Builds a grooved divider painter.
  static DividerPainter grooved1(
      {double size = _GroovedDividerPainter1.defaultSize,
      Color? backgroundColor,
      Color? highlightedBackgroundColor,
      bool animationEnabled = DividerPainter.defaultAnimationEnabled,
      Color color = _GroovedDividerPainter1.defaultColor,
      Color? highlightedColor,
      StrokeCap strokeCap = _GroovedDividerPainter1.defaultStrokeCap,
      double thickness = _GroovedDividerPainter1.defaultThickness,
      double? highlightedThickness,
      double? highlightedSize}) {
    return _GroovedDividerPainter1(
        size: size,
        backgroundColor: backgroundColor,
        highlightedBackgroundColor: highlightedBackgroundColor,
        animationEnabled: animationEnabled,
        color: color,
        highlightedColor: highlightedColor,
        strokeCap: strokeCap,
        thickness: thickness,
        highlightedThickness: highlightedThickness,
        highlightedSize: highlightedSize);
  }
}

/// The default painter for the divider.
class DividerPainter {
  static const int backgroundKey = 0;

  static const bool defaultAnimationEnabled = true;

  DividerPainter(
      {this.backgroundColor,
      this.highlightedBackgroundColor,
      this.animationEnabled = DividerPainter.defaultAnimationEnabled});

  final bool animationEnabled;
  final Color? backgroundColor;
  final Color? highlightedBackgroundColor;

  /// Builds a tween map for animations.
  Map<int, Tween> buildTween() {
    Map<int, Tween> map = Map<int, Tween>();
    if (animationEnabled &&
        backgroundColor != null &&
        highlightedBackgroundColor != null) {
      map[DividerPainter.backgroundKey] =
          ColorTween(begin: backgroundColor, end: highlightedBackgroundColor);
    }
    return map;
  }

  /// Paints the divider.
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required Map<int, dynamic> animatedValues}) {
    Color? color;
    if (animationEnabled && animatedValues.containsKey(backgroundKey)) {
      color = animatedValues[backgroundKey];
    } else {
      color = highlighted ? highlightedBackgroundColor : backgroundColor;
    }

    if (color != null) {
      var paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color
        ..isAntiAlias = true;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, dividerSize.width, dividerSize.height), paint);
    }
  }
}

/// Divider with dashes.
class _DashedDividerPainter extends DividerPainter {
  static const int colorKey = 1;
  static const int thicknessKey = 2;

  static const double defaultSize = 10;
  static const double defaultGap = 5;
  static const double defaultThickness = 1;
  static const StrokeCap defaultStrokeCap = StrokeCap.square;
  static const Color defaultColor = Colors.black;

  _DashedDividerPainter(
      {this.size = defaultSize,
      this.gap = defaultGap,
      Color? backgroundColor,
      Color? highlightedBackgroundColor,
      bool animationEnabled = DividerPainter.defaultAnimationEnabled,
      this.color = defaultColor,
      this.highlightedColor,
      this.strokeCap = defaultStrokeCap,
      this.thickness = defaultThickness,
      this.highlightedThickness,
      this.highlightedGap,
      this.highlightedSize})
      : super(
            animationEnabled: animationEnabled,
            backgroundColor: backgroundColor,
            highlightedBackgroundColor: highlightedBackgroundColor) {
    if (size <= 0) {
      throw Exception('The size parameter must be positive: $size');
    }
    if (gap <= 0) {
      throw Exception('The gap parameter must be positive: $gap');
    }
    if (thickness <= 0) {
      throw Exception('The thickness parameter must be positive: $thickness');
    }
    if (highlightedThickness != null && highlightedThickness! <= 0) {
      throw Exception(
          'The highlightedThickness parameter must be positive: $highlightedThickness');
    }
    if (highlightedGap != null && highlightedGap! <= 0) {
      throw Exception(
          'The highlightedGap parameter must be positive: $highlightedGap');
    }
    if (highlightedSize != null && highlightedSize! <= 0) {
      throw Exception(
          'The highlightedSize parameter must be positive: $highlightedSize');
    }
  }

  final double size;
  final double? highlightedSize;
  final double gap;
  final double? highlightedGap;
  final Color color;
  final Color? highlightedColor;
  final StrokeCap strokeCap;
  final double thickness;
  final double? highlightedThickness;

  @override
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required Map<int, dynamic> animatedValues}) {
    super.paint(
        dividerAxis: dividerAxis,
        resizable: resizable,
        highlighted: highlighted,
        canvas: canvas,
        dividerSize: dividerSize,
        animatedValues: animatedValues);
    Color? _color;
    if (animationEnabled && animatedValues.containsKey(colorKey)) {
      _color = animatedValues[colorKey];
    } else if (highlighted && highlightedColor != null) {
      _color = highlightedColor!;
    } else {
      _color = color;
    }

    if (_color != null) {
      double _thickness = thickness;
      if (animationEnabled && animatedValues.containsKey(thicknessKey)) {
        _thickness = animatedValues[thicknessKey];
      } else if (highlighted && highlightedThickness != null) {
        _thickness = highlightedThickness!;
      }
      var paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = _color
        ..strokeWidth = _thickness
        ..strokeCap = strokeCap
        ..isAntiAlias = true;
      if (dividerAxis == Axis.vertical) {
        double startY = 0;
        while (startY < dividerSize.height) {
          canvas.drawLine(Offset(dividerSize.width / 2, startY),
              Offset(dividerSize.width / 2, startY + size), paint);
          startY += size + gap;
        }
      } else {
        double startX = 0;
        while (startX < dividerSize.width) {
          canvas.drawLine(Offset(startX, dividerSize.height / 2),
              Offset(startX + size, dividerSize.height / 2), paint);
          startX += size + gap;
        }
      }
    }
  }

  @override
  Map<int, Tween> buildTween() {
    Map<int, Tween> map = super.buildTween();
    if (animationEnabled) {
      if (highlightedColor != null) {
        map[colorKey] = ColorTween(begin: color, end: highlightedColor);
      }
      if (highlightedThickness != null) {
        map[thicknessKey] =
            Tween<double>(begin: thickness, end: highlightedThickness);
      }
    }
    return map;
  }
}

/// Divider with grooves (style 1).
class _GroovedDividerPainter1 extends DividerPainter {
  static const int colorKey = 1;
  static const int thicknessKey = 2;
  static const int sizeKey = 3;

  static const double defaultSize = 25;
  static const double defaultThickness = 2;
  static const StrokeCap defaultStrokeCap = StrokeCap.round;
  static const Color defaultColor = Colors.black;

  _GroovedDividerPainter1(
      {this.size = defaultSize,
      Color? backgroundColor,
      Color? highlightedBackgroundColor,
      bool animationEnabled = DividerPainter.defaultAnimationEnabled,
      this.color = defaultColor,
      this.highlightedColor,
      this.strokeCap = defaultStrokeCap,
      this.thickness = defaultThickness,
      this.highlightedThickness,
      this.highlightedSize})
      : super(
            animationEnabled: animationEnabled,
            backgroundColor: backgroundColor,
            highlightedBackgroundColor: highlightedBackgroundColor) {
    if (size <= 0) {
      throw Exception('The size parameter must be positive: $size');
    }
    if (thickness <= 0) {
      throw Exception('The thickness parameter must be positive: $thickness');
    }
    if (highlightedThickness != null && highlightedThickness! <= 0) {
      throw Exception(
          'The highlightedThickness parameter must be positive: $highlightedThickness');
    }
    if (highlightedSize != null && highlightedSize! <= 0) {
      throw Exception(
          'The highlightedSize parameter must be positive: $highlightedSize');
    }
  }

  final double size;
  final double? highlightedSize;
  final Color color;
  final Color? highlightedColor;
  final StrokeCap strokeCap;
  final double thickness;
  final double? highlightedThickness;

  @override
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required Map<int, dynamic> animatedValues}) {
    super.paint(
        dividerAxis: dividerAxis,
        resizable: resizable,
        highlighted: highlighted,
        canvas: canvas,
        dividerSize: dividerSize,
        animatedValues: animatedValues);
    Color? _color;
    if (animationEnabled && animatedValues.containsKey(colorKey)) {
      _color = animatedValues[colorKey];
    } else if (highlighted && highlightedColor != null) {
      _color = highlightedColor!;
    } else {
      _color = color;
    }

    if (_color != null) {
      double _thickness = thickness;
      if (animationEnabled && animatedValues.containsKey(thicknessKey)) {
        _thickness = animatedValues[thicknessKey];
      } else if (highlighted && highlightedThickness != null) {
        _thickness = highlightedThickness!;
      }
      double _size = size;
      if (animationEnabled && animatedValues.containsKey(sizeKey)) {
        _size = animatedValues[sizeKey];
      } else if (highlighted && highlightedSize != null) {
        _size = highlightedSize!;
      }
      var paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = _color
        ..strokeWidth = _thickness
        ..strokeCap = strokeCap
        ..isAntiAlias = true;
      if (dividerAxis == Axis.vertical) {
        double startY = (dividerSize.height - _size) / 2;
        canvas.drawLine(Offset(dividerSize.width / 2, startY),
            Offset(dividerSize.width / 2, startY + _size), paint);
      } else {
        double startX = (dividerSize.width - _size) / 2;
        canvas.drawLine(Offset(startX, dividerSize.height / 2),
            Offset(startX + _size, dividerSize.height / 2), paint);
      }
    }
  }

  @override
  Map<int, Tween> buildTween() {
    Map<int, Tween> map = super.buildTween();
    if (animationEnabled) {
      if (highlightedColor != null) {
        map[colorKey] = ColorTween(begin: color, end: highlightedColor);
      }
      if (highlightedThickness != null) {
        map[thicknessKey] =
            Tween<double>(begin: thickness, end: highlightedThickness);
      }
      if (highlightedSize != null) {
        map[sizeKey] = Tween<double>(begin: size, end: highlightedSize);
      }
    }
    return map;
  }
}

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The default painter for the divider.
class DividerPainter {
  static const int backgroundKey = 0;

  DividerPainter(
      {this.backgroundColor,
      this.highlightedBackgroundColor,
      bool? animationEnabled})
      : this.animationEnabled =
            animationEnabled != null ? animationEnabled : true;

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
    if (animationEnabled &&
        animatedValues.containsKey(DividerPainter.backgroundKey)) {
      color = animatedValues[DividerPainter.backgroundKey];
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
class DashDivider extends DividerPainter {
  static const int colorKey = 1;
  static const int thicknessKey = 2;

  DashDivider(
      {double size = 10,
      double gap = 5,
      Color? backgroundColor,
      Color? highlightedBackgroundColor,
      bool? animationEnabled,
      this.color = Colors.black,
      this.highlightedColor,
      this.strokeCap = StrokeCap.square,
      double thickness = 1,
      double? highlightedThickness})
      : this.size = math.max(0, size),
        this.gap = math.max(0, gap),
        this.thickness = math.max(0, thickness),
        this.highlightedThickness = (highlightedThickness != null)
            ? math.max(0, highlightedThickness)
            : highlightedThickness,
        super(
            animationEnabled: animationEnabled,
            backgroundColor: backgroundColor,
            highlightedBackgroundColor: highlightedBackgroundColor);

  final double size;
  final double gap;
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
    if (animationEnabled && animatedValues.containsKey(DashDivider.colorKey)) {
      _color = animatedValues[DashDivider.colorKey];
    } else if (highlighted && highlightedColor != null) {
      _color = highlightedColor!;
    } else {
      _color = color;
    }

    if (_color != null) {
      double _thickness = thickness;
      if (animationEnabled &&
          animatedValues.containsKey(DashDivider.thicknessKey)) {
        _thickness = animatedValues[DashDivider.thicknessKey];
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
        map[DashDivider.colorKey] =
            ColorTween(begin: color, end: highlightedColor);
      }
      if (highlightedThickness != null) {
        map[DashDivider.thicknessKey] =
            Tween<double>(begin: thickness, end: highlightedThickness);
      }
    }
    return map;
  }
}

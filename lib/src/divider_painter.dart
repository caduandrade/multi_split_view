import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The default painter for the divider.
class DividerPainter {
  DividerPainter(
      {this.backgroundColor,
      this.highlightedBackgroundColor,
      bool? animationEnabled})
      : this.animationEnabled =
            animationEnabled != null ? animationEnabled : true;

  final bool animationEnabled;
  final Color? backgroundColor;
  final Color? highlightedBackgroundColor;

  /// Paints the divider.
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required double? animatedDoubleValue,
      required Color? animatedBackgroundColor,
      required Color? animatedForegroundColor}) {
    Color? color;
    if (animationEnabled) {
      color = animatedBackgroundColor;
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

  Tween<double>? buildDoubleTween() {
    if (animationEnabled) {
      return Tween<double>(begin: 0, end: 1);
    }
    return null;
  }

  ColorTween? buildBackgroundColorTween() {
    if (animationEnabled) {
      return ColorTween(
          begin: backgroundColor, end: highlightedBackgroundColor);
    }
    return null;
  }

  ColorTween? buildForegroundColorTween() {
    return null;
  }
}

/// Divider with dashes.
class DashDivider extends DividerPainter {
  DashDivider(
      {double size = 10,
      double gap = 5,
      Color? backgroundColor,
      Color? highlightedBackgroundColor,
      bool? animationEnabled,
      this.color = Colors.black,
      this.highlightedColor,
      this.strokeCap = StrokeCap.square,
      this.highlightedStrokeCap,
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
  final StrokeCap? highlightedStrokeCap;
  final double thickness;
  final double? highlightedThickness;

  @override
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required double? animatedDoubleValue,
      required Color? animatedBackgroundColor,
      required Color? animatedForegroundColor}) {
    super.paint(
        dividerAxis: dividerAxis,
        resizable: resizable,
        highlighted: highlighted,
        canvas: canvas,
        dividerSize: dividerSize,
        animatedDoubleValue: animatedDoubleValue,
        animatedBackgroundColor: animatedBackgroundColor,
        animatedForegroundColor: animatedForegroundColor);
    Color _color = color;
    if (highlighted && highlightedColor != null) {
      _color = highlightedColor!;
    }
    StrokeCap _strokeCap = strokeCap;
    if (highlighted && highlightedStrokeCap != null) {
      _strokeCap = highlightedStrokeCap!;
    }
    double _thickness = thickness;
    if (highlighted && highlightedThickness != null) {
      _thickness = highlightedThickness!;
    }
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _color
      ..strokeWidth = _thickness
      ..strokeCap = _strokeCap
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

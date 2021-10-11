import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:multi_split_view/src/divider_painter.dart';
import 'package:multi_split_view/src/theme_data.dart';

/// The divider widget.
@internal
class DividerWidget extends StatefulWidget {
  const DividerWidget(
      {required this.axis,
      required this.index,
      required this.themeData,
      required this.resizable,
      required this.dragging,
      required this.highlighted});

  final Axis axis;
  final int index;
  final bool resizable;
  final bool dragging;
  final bool highlighted;
  final MultiSplitViewThemeData themeData;

  @override
  State<StatefulWidget> createState() => _DividerWidgetState();
}

/// The [DividerWidget] state.
class _DividerWidgetState extends State<DividerWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double?>? doubleAnimation;
  Animation<Color?>? backgroundColorAnimation;
  Animation<Color?>? foregroundColorAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.themeData.dividerPainter != null) {
      controller = AnimationController(
          duration: const Duration(milliseconds: 250), vsync: this);
      DividerPainter dividerPainter = widget.themeData.dividerPainter!;

      Tween<double>? doubleTween = dividerPainter.buildDoubleTween();
      if (doubleTween != null) {
        doubleAnimation = doubleTween.animate(controller!);
      }
      ColorTween? backgroundColorTween =
          dividerPainter.buildBackgroundColorTween();
      if (backgroundColorTween != null) {
        backgroundColorAnimation = backgroundColorTween.animate(controller!);
      }
      ColorTween? foregroundColorTween =
          dividerPainter.buildForegroundColorTween();
      if (foregroundColorTween != null) {
        foregroundColorAnimation = foregroundColorTween.animate(controller!);
      }

      controller?.addListener(() {
        setState(() {
          // rebuilds
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant DividerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dragging && widget.dragging == false) {
      controller?.reverse();
    } else if (oldWidget.highlighted == false && widget.highlighted) {
      controller?.forward();
    } else if (oldWidget.highlighted && widget.highlighted == false) {
      controller?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dividerWidget;
    if (widget.themeData.dividerPainter != null) {
      dividerWidget = ClipRect(
          child: CustomPaint(
              child: Container(),
              painter: _DividerPainterWrapper(
                  axis: widget.axis,
                  resizable: widget.resizable,
                  highlighted: widget.highlighted,
                  dividerPainter: widget.themeData.dividerPainter!,
                  animatedDoubleValue: doubleAnimation?.value,
                  animatedBackgroundColor: backgroundColorAnimation?.value,
                  animatedForegroundColor: foregroundColorAnimation?.value)));
    } else {
      dividerWidget = Container();
    }

    return dividerWidget;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/// Defines the custom painter for the divider using a [DividerPainter].
class _DividerPainterWrapper extends CustomPainter {
  _DividerPainterWrapper(
      {required this.axis,
      required this.resizable,
      required this.highlighted,
      required this.dividerPainter,
      required this.animatedDoubleValue,
      required this.animatedBackgroundColor,
      required this.animatedForegroundColor});

  /// The divider axis
  final Axis axis;
  final bool resizable;
  final bool highlighted;
  final DividerPainter dividerPainter;
  final double? animatedDoubleValue;
  final Color? animatedBackgroundColor;
  final Color? animatedForegroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    dividerPainter.paint(
        dividerAxis: axis,
        resizable: resizable,
        highlighted: highlighted,
        canvas: canvas,
        dividerSize: size,
        animatedDoubleValue: animatedDoubleValue,
        animatedBackgroundColor: animatedBackgroundColor,
        animatedForegroundColor: animatedForegroundColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

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
    with TickerProviderStateMixin {
  AnimationController? controller;
  Map<int, Animation> animations = Map<int, Animation>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations(null);
  }

  @override
  void didUpdateWidget(covariant DividerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeAnimations(oldWidget);
    if (oldWidget.dragging && widget.dragging == false) {
      controller?.reverse();
    } else if (oldWidget.highlighted == false && widget.highlighted) {
      controller?.forward();
    } else if (oldWidget.highlighted && widget.highlighted == false) {
      controller?.reverse();
    }
  }

  void _initializeAnimations(DividerWidget? oldWidget) {
    if (widget.themeData.dividerPainter !=
        oldWidget?.themeData.dividerPainter) {
      controller?.removeListener(_rebuild);
      controller?.dispose();
      animations.clear();
      controller = null;
      if (widget.themeData.dividerPainter != null &&
          widget.themeData.dividerPainter!.animationEnabled) {
        controller = AnimationController(
            duration: widget.themeData.dividerPainter!.animationDuration,
            vsync: this);
        DividerPainter dividerPainter = widget.themeData.dividerPainter!;

        Map<int, Tween> tweenMap = dividerPainter.buildTween();
        tweenMap.forEach((key, tween) {
          animations[key] = tween.animate(controller!);
        });

        controller?.addListener(_rebuild);
      }
    }
  }

  void _rebuild() {
    setState(() {
      // rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget dividerWidget;
    if (widget.themeData.dividerPainter != null) {
      Map<int, dynamic> animatedValues = Map<int, dynamic>();
      animations.forEach((key, animation) {
        animatedValues[key] = animation.value;
      });

      dividerWidget = CustomPaint(
          child: Container(),
          painter: _DividerPainterWrapper(
              axis: widget.axis,
              resizable: widget.resizable,
              highlighted: widget.highlighted,
              dividerPainter: widget.themeData.dividerPainter!,
              animatedValues: animatedValues));
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
      required this.animatedValues});

  /// The divider axis
  final Axis axis;
  final bool resizable;
  final bool highlighted;
  final DividerPainter dividerPainter;
  final Map<int, dynamic> animatedValues;

  @override
  void paint(Canvas canvas, Size size) {
    dividerPainter.paint(
        dividerAxis: axis,
        resizable: resizable,
        highlighted: highlighted,
        canvas: canvas,
        dividerSize: size,
        animatedValues: animatedValues);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

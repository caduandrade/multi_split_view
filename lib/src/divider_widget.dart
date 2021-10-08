import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:multi_split_view/src/divider_painter.dart';
import 'package:multi_split_view/src/theme_data.dart';

/// The divider widget.
@internal
class DividerWidget extends StatelessWidget {
  const DividerWidget(
      {required this.axis,
      required this.index,
      required this.themeData,
      required this.resizable,
      required this.highlighted});

  final Axis axis;
  final int index;
  final bool resizable;
  final bool highlighted;
  final MultiSplitViewThemeData themeData;

  @override
  Widget build(BuildContext context) {
    if (themeData.dividerPainter != null) {
      return ClipRect(
          child: CustomPaint(
              child: Container(color: themeData.dividerColor),
              painter: _DividerPainterWrapper(
                  axis: axis,
                  resizable: resizable,
                  highlighted: highlighted,
                  dividerPainter: themeData.dividerPainter!)));
    }
    return Container(color: themeData.dividerColor);
  }
}

/// Defines the custom painter for the divider using a [DividerPainter].
class _DividerPainterWrapper extends CustomPainter {
  _DividerPainterWrapper(
      {required this.axis,
      required this.resizable,
      required this.highlighted,
      required this.dividerPainter});

  /// The divider axis
  final Axis axis;
  final bool resizable;
  final bool highlighted;
  final DividerPainter dividerPainter;

  @override
  void paint(Canvas canvas, Size size) {
    dividerPainter.paint(axis, resizable, highlighted, canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

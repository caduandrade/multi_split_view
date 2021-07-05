import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:multi_split_view_demo/example_widget.dart';

class DividerPainterExample extends StatelessWidget with ContentBuilder {
  @override
  Widget build(BuildContext context) {
    var dividerPainter = (Axis axis, bool resizable, Canvas canvas, Size size) {
      var paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..isAntiAlias = true;
      if (axis == Axis.vertical) {
        double dashHeight = 9, dashSpace = 5, startY = 0;
        while (startY < size.height) {
          canvas.drawLine(Offset(size.width / 2, startY),
              Offset(size.width / 2, startY + dashHeight), paint);
          startY += dashHeight + dashSpace;
        }
      } else {
        double dashWidth = 9, dashSpace = 5, startX = 0;
        while (startX < size.width) {
          canvas.drawLine(Offset(startX, size.height / 2),
              Offset(startX + dashWidth, size.height / 2), paint);
          startX += dashWidth + dashSpace;
        }
      }
    };

    Widget child1 = buildContent(1);
    Widget child2 = buildContent(2);
    Widget child3 = buildContent(3);
    Widget child4 = buildContent(4);

    MultiSplitView multiSplitView = MultiSplitView(
        axis: Axis.vertical,
        children: [
          MultiSplitView(
              children: [child1, child2, child3],
              dividerThickness: 10,
              dividerPainter: dividerPainter),
          child4
        ],
        dividerThickness: 10,
        dividerPainter: dividerPainter);

    return multiSplitView;
  }
}

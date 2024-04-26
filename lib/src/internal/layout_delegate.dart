import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:multi_split_view/src/internal/layout_constraints.dart';

@internal
class LayoutDelegate extends MultiChildLayoutDelegate {
  LayoutDelegate(
      {required this.axis,
      required this.controller,
      required this.layoutConstraints,
      required this.antiAliasingWorkaround});

  final Axis axis;
  final MultiSplitViewController controller;
  final LayoutConstraints layoutConstraints;
  final bool antiAliasingWorkaround;

  @override
  void performLayout(Size size) {
    double start = 0;

    final double availableSizeForFlexAreas =
        layoutConstraints.calculateAvailableSizeForFlexAreas(controller);
    final double totalFlex = controller.totalFlex;
    final double pixelPerFlex = availableSizeForFlexAreas / totalFlex;

    for (int index = 0; index < controller.areasCount; index++) {
      Area area = controller.getArea(index);

      double pixels;
      if (area.flex != null) {
        pixels = area.flex! * pixelPerFlex;
      } else {
        pixels = area.size!;
      }

      if (antiAliasingWorkaround) {
        pixels = pixels.roundToDouble();
      }

      if (axis == Axis.horizontal) {
        Size currentSize = layoutChild(
            index, BoxConstraints.tightFor(width: pixels, height: size.height));
        positionChild(index, Offset(start, 0));
        start += currentSize.width;

        if (index < controller.areasCount - 1) {
          currentSize = layoutChild(
              'd$index',
              BoxConstraints.tightFor(
                  width: layoutConstraints.dividerThickness,
                  height: size.height));
          positionChild('d$index', Offset(start, 0));
          start += currentSize.width;
        }
      } else {
        Size currentSize = layoutChild(
            index, BoxConstraints.tightFor(width: size.width, height: pixels));
        positionChild(index, Offset(0, start));
        start += currentSize.height;

        if (index < controller.areasCount - 1) {
          currentSize = layoutChild(
              'd$index',
              BoxConstraints.tightFor(
                  width: size.width,
                  height: layoutConstraints.dividerThickness));
          positionChild('d$index', Offset(0, start));
          start += currentSize.height;
        }
      }
    }
  }

  @override
  bool shouldRelayout(covariant LayoutDelegate oldDelegate) {
    return true;
  }
}

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
    var onAreaLayout = (
        {required int index,
        required double start,
        required double thickness}) {
      if (axis == Axis.horizontal) {
        layoutChild(index,
            BoxConstraints.tightFor(width: thickness, height: size.height));
        positionChild(index, Offset(start, 0));
      } else {
        layoutChild(index,
            BoxConstraints.tightFor(width: size.width, height: thickness));
        positionChild(index, Offset(0, start));
      }
    };
    var onDividerLayout = (
        {required int index,
        required double start,
        required double thickness}) {
      if (axis == Axis.horizontal) {
        layoutChild('d$index',
            BoxConstraints.tightFor(width: thickness, height: size.height));
        positionChild('d$index', Offset(start, 0));
      } else {
        layoutChild('d$index',
            BoxConstraints.tightFor(width: size.width, height: thickness));
        positionChild('d$index', Offset(0, start));
      }
    };
    layoutConstraints.performLayout(
        controller: controller,
        antiAliasingWorkaround: antiAliasingWorkaround,
        onAreaLayout: onAreaLayout,
        onDividerLayout: onDividerLayout);
  }

  @override
  bool shouldRelayout(covariant LayoutDelegate oldDelegate) {
    return true;
  }
}

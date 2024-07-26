import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/divider_util.dart';
import 'package:multi_split_view/src/internal/layout_constraints.dart';
import 'package:multi_split_view/src/policies.dart';

class TestHelper {
  factory TestHelper(
      {required List<Area> areas,
      required double containerSize,
      required double dividerThickness,
      required double dividerHandleBuffer,
      SizeOverflowPolicy sizeOverflowPolicy = SizeOverflowPolicy.shrinkLast,
      SizeUnderflowPolicy sizeUnderflowPolicy = SizeUnderflowPolicy.stretchLast,
      MinSizeRecoveryPolicy minSizeRecoveryPolicy =
          MinSizeRecoveryPolicy.firstToLast}) {
    MultiSplitViewController controller =
        MultiSplitViewController(areas: areas);
    LayoutConstraints layout = LayoutConstraints(
        controller: controller,
        containerSize: containerSize,
        dividerThickness: dividerThickness,
        dividerHandleBuffer: dividerHandleBuffer);
    ControllerHelper controllerHelper = ControllerHelper(controller);
    layout.adjustAreas(
        controllerHelper: controllerHelper,
        sizeOverflowPolicy: sizeOverflowPolicy,
        sizeUnderflowPolicy: sizeUnderflowPolicy,
        minSizeRecoveryPolicy: minSizeRecoveryPolicy);

    expect(controller.areasCount, areas.length);

    TestHelper helper = TestHelper._(controller: controller, layout: layout);

    return helper;
  }

  TestHelper._(
      {required MultiSplitViewController controller,
      required LayoutConstraints layout})
      : this._controller = controller,
        this._layout = layout;

  final MultiSplitViewController _controller;
  final LayoutConstraints _layout;

  void moveAndTest(
      {required int dividerIndex,
      required double pixels,
      required bool pushDividers,
      required double rest}) {
    double rest = DividerUtil.move(
        controller: _controller,
        layoutConstraints: _layout,
        dividerIndex: dividerIndex,
        pixels: pixels,
        pushDividers: pushDividers);

    expect(rest, rest, reason: 'rest');
  }

  void testAreaIndex(int index,
      {required dynamic data,
      required double? flex,
      required double? size,
      required double? min,
      required double? max}) {
    Area area = _controller.getArea(index);
    testArea(area, data: data, min: min, max: max, flex: flex, size: size);
  }

  static void testArea(Area area,
      {required dynamic data,
      required double? flex,
      required double? size,
      required double? min,
      required double? max}) {
    expect(area.data, data, reason: 'data');
    expect(area.min, min, reason: 'min');
    expect(area.max, max, reason: 'max');
    expect(area.flex, flex, reason: 'flex');
    expect(area.size, size, reason: 'size');
  }
}

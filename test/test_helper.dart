import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/area_screen_constraints.dart';
import 'package:multi_split_view/src/internal/layout.dart';
import 'package:multi_split_view/src/policies.dart';

class TestHelper {
  factory TestHelper(
      {required List<Area> areas,
      required double containerSize,
      required double dividerThickness,
      SizeOverflowPolicy sizeOverflowPolicy = SizeOverflowPolicy.shrinkLast}) {
    MultiSplitViewController controller =
        MultiSplitViewController(areas: areas);
    Layout layout = Layout(
        childrenCount: areas.length,
        containerSize: containerSize,
        dividerThickness: dividerThickness);
    ControllerHelper controllerHelper = ControllerHelper(controller);
    layout.adjustAreas(
        controllerHelper: controllerHelper,
        sizeOverflowPolicy: sizeOverflowPolicy);
    layout.updateScreenConstraints(controllerHelper: controllerHelper);

    expect(controller.areasCount, areas.length);

    TestHelper helper = TestHelper._(controller: controller, layout: layout);
    helper._fetchConstraints();
    helper._fetchAreas();

    return helper;
  }

  TestHelper._(
      {required MultiSplitViewController controller, required Layout layout})
      : this._controller = controller,
        this._layout = layout,
        this._controllerHelper = ControllerHelper(controller);

  final List<AreaScreenConstraints> constrainsList = [];
  final List<Area> _areas = [];
  final MultiSplitViewController _controller;
  final ControllerHelper _controllerHelper;
  final Layout _layout;

  void _fetchConstraints() {
    constrainsList.clear();
    for (int index = 0; index < _controller.areasCount; index++) {
      AreaScreenConstraints constraints =
          AreaHelper.screenConstraintsOf(_controller.getArea(index));
      constrainsList.add(constraints);
    }
  }

  void _fetchAreas() {
    _areas.clear();
    for (int index = 0; index < _controller.areasCount; index++) {
      Area area = _controller.getArea(index);
      _areas.add(area.clone());
    }
  }

  void moveAndTest(
      {required int dividerIndex,
      required double pixels,
      required bool pushDividers,
      required double rest}) {
    double rest = _layout.moveDivider(
        controllerHelper: _controllerHelper,
        dividerIndex: dividerIndex,
        pixels: pixels,
        pushDividers: pushDividers);

    expect(rest, rest, reason: 'rest');

    _fetchConstraints();
    _fetchAreas();
  }

  void testConstraints(int index,
      {required double startPos,
      required double endPos,
      required double size,
      required double? minSize,
      required double? maxSize}) {
    AreaScreenConstraints constraints = constrainsList[index];
    AreaHelper.testScreenConstraints(constraints,
        startPos: startPos,
        endPos: endPos,
        size: size,
        minSize: minSize,
        maxSize: maxSize);
  }

  void testConstraintsSize(int index,
      {required double size,
      required double? minSize,
      required double? maxSize}) {
    AreaScreenConstraints constraints = constrainsList[index];
    AreaHelper.testScreenConstraintsSize(constraints,
        size: size, minSize: minSize, maxSize: maxSize);
  }

  void testArea(int index,
      {required dynamic data,
      required double? flex,
      required double? size,
      required double? min,
      required double? max}) {
    Area area = _controller.getArea(index);
    AreaHelper.testArea(area,
        data: data, min: min, max: max, flex: flex, size: size);
  }
}

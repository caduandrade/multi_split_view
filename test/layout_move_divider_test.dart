import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/layout.dart';

void main() {
  group('Layout - Move divider', () {
    test('1', () {
      MultiSplitViewController controller = MultiSplitViewController();
      Layout layout =
          Layout(childrenCount: 2, containerSize: 110, dividerThickness: 10);
      ControllerHelper controllerHelper = ControllerHelper(controller);
      layout.adjustAreas(controllerHelper: controllerHelper);
      layout.updateAreaIntervals(controllerHelper: controllerHelper);

      expect(controllerHelper.areas.length, 2);

      bool ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 0);
      expect(ret, false);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: -1);
      expect(ret, false);
      expect(controllerHelper.areas[0].flex, 0.98);
      expect(controllerHelper.areas[1].flex, 1.02);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 2);
      expect(ret, false);
      expect(controllerHelper.areas[0].flex, 1.02);
      expect(controllerHelper.areas[1].flex, 0.98);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 200);
      expect(ret, true);
      expect(controllerHelper.areas[0].flex, 2);
      expect(controllerHelper.areas[1].flex, 0);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: -200);
      expect(ret, true);
      expect(controllerHelper.areas[0].flex, 0);
      expect(controllerHelper.areas[1].flex, 2);
    });
    test('Pixel and Flex', () {
      MultiSplitViewController controller =
          MultiSplitViewController(areas: [Area(size: 200), Area(flex: 0)]);
      Layout layout =
          Layout(childrenCount: 3, containerSize: 320, dividerThickness: 10);
      ControllerHelper controllerHelper = ControllerHelper(controller);
      layout.adjustAreas(controllerHelper: controllerHelper);
      layout.updateAreaIntervals(controllerHelper: controllerHelper);

      expect(controllerHelper.areas.length, 3);

      bool ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: -100);
      expect(ret, false);

      expect(controllerHelper.areas[0].size, 100);
      expect(controllerHelper.areas[0].flex, null);
      expect(controllerHelper.areas[1].size, null);
      expect(controllerHelper.areas[1].flex, 1);
      expect(controllerHelper.areas[2].size, null);
      expect(controllerHelper.areas[2].flex, 1);
    });
    test('Pixel and Flex - 2', () {
      MultiSplitViewController controller =
          MultiSplitViewController(areas: [Area(size: 100)]);
      Layout layout =
          Layout(childrenCount: 3, containerSize: 320, dividerThickness: 10);
      ControllerHelper controllerHelper = ControllerHelper(controller);
      layout.adjustAreas(controllerHelper: controllerHelper);
      layout.updateAreaIntervals(controllerHelper: controllerHelper);

      expect(controllerHelper.areas.length, 3);

      bool ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 5);
      expect(ret, false);
      expect(controllerHelper.areas[0].size, 105);
      expect(controllerHelper.areas[0].flex, null);
      expect(controllerHelper.areas[1].size, null);
      expect(controllerHelper.areas[1].flex, 0.95);
      expect(controllerHelper.areas[2].size, null);
      expect(controllerHelper.areas[2].flex, 1);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 150);
      expect(ret, true);
      expect(controllerHelper.areas[0].size, 200);
      expect(controllerHelper.areas[0].flex, null);
      expect(controllerHelper.areas[1].size, null);
      expect(controllerHelper.areas[1].flex, 0);
      expect(controllerHelper.areas[2].size, null);
      expect(controllerHelper.areas[2].flex, 1);
    });
  });
}

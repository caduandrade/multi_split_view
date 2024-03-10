import 'package:flutter_test/flutter_test.dart';
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

      expect(controllerHelper.areas.length, 2);

      bool ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 0);
      expect(ret, false);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: -1);
      expect(ret, true);
      expect(controllerHelper.areas[0].flex, 0.98);
      expect(controllerHelper.areas[1].flex, 1.02);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 2);
      expect(ret, true);
      expect(controllerHelper.areas[0].flex, 1.02);
      expect(controllerHelper.areas[1].flex, 0.98);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: 200);
      expect(ret, false);
      expect(controllerHelper.areas[0].flex, 2);
      expect(controllerHelper.areas[1].flex, 0);

      ret = layout.moveDivider(
          controllerHelper: controllerHelper, dividerIndex: 0, pixels: -200);
      expect(ret, false);
      expect(controllerHelper.areas[0].flex, 0);
      expect(controllerHelper.areas[1].flex, 2);
    });
  });
}

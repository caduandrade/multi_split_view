import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/layout.dart';

void main() {
  group('Layout - Adjust areas', () {
    test('childrenCount vs areas length', () {
      MultiSplitViewController controller =
          MultiSplitViewController(areas: [Area()]);
      Layout(childrenCount: 0, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 0);

      controller = MultiSplitViewController(
          areas: [Area(data: 'a'), Area(data: 'b'), Area(data: 'c')]);
      Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 1);
      expect(controller.areas[0].data, 'a');

      controller = MultiSplitViewController(areas: [Area(data: 'a')]);
      Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 2);
      expect(controller.areas[0].data, 'a');
      expect(controller.areas[1].data, null);
    });

    test('all areas size valued', () {
      MultiSplitViewController controller =
          MultiSplitViewController(areas: [Area(data: 'a', size: 10, max: 20)]);
      Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 1);
      expect(controller.areas[0].data, 'a');
      expect(controller.areas[0].size, null);
      expect(controller.areas[0].min, null);
      expect(controller.areas[0].max, null);
      expect(controller.areas[0].flex, 1);

      controller = MultiSplitViewController(areas: [
        Area(data: 'a', size: 10, max: 20),
        Area(data: 'b', size: 2, min: 1)
      ]);
      Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 2);
      expect(controller.areas[0].data, 'a');
      expect(controller.areas[0].size, null);
      expect(controller.areas[0].min, null);
      expect(controller.areas[0].max, null);
      expect(controller.areas[0].flex, 5);
      expect(controller.areas[1].data, 'b');
      expect(controller.areas[1].size, null);
      expect(controller.areas[1].min, null);
      expect(controller.areas[1].max, null);
      expect(controller.areas[1].flex, 1);

      controller = MultiSplitViewController(areas: [
        Area(data: 'a', size: 0, max: 20),
        Area(data: 'b', size: 2, min: 1)
      ]);
      Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 2);
      expect(controller.areas[0].data, 'a');
      expect(controller.areas[0].size, null);
      expect(controller.areas[0].min, null);
      expect(controller.areas[0].max, null);
      expect(controller.areas[0].flex, 0);
      expect(controller.areas[1].data, 'b');
      expect(controller.areas[1].size, null);
      expect(controller.areas[1].min, null);
      expect(controller.areas[1].max, null);
      expect(controller.areas[1].flex, 2);
    });

    test('all flex 0', () {
      MultiSplitViewController controller =
          MultiSplitViewController(areas: [Area(data: 'a', flex: 0)]);
      Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 1);
      expect(controller.areas[0].data, 'a');
      expect(controller.areas[0].size, null);
      expect(controller.areas[0].min, null);
      expect(controller.areas[0].max, null);
      expect(controller.areas[0].flex, 1);

      controller = MultiSplitViewController(
          areas: [Area(data: 'a', flex: 0), Area(data: 'b', flex: 0)]);
      Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
          .adjustAreas(controllerHelper: ControllerHelper(controller));
      expect(controller.areas.length, 2);
      expect(controller.areas[0].data, 'a');
      expect(controller.areas[0].size, null);
      expect(controller.areas[0].min, null);
      expect(controller.areas[0].max, null);
      expect(controller.areas[0].flex, 1);
      expect(controller.areas[1].data, 'b');
      expect(controller.areas[1].size, null);
      expect(controller.areas[1].min, null);
      expect(controller.areas[1].max, null);
      expect(controller.areas[1].flex, 1);
    });
  });
}

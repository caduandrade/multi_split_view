import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/layout.dart';
import 'package:multi_split_view/src/policies.dart';

void main() {
  group('Layout', () {
    group('Adjust areas', () {
      test('removing unused areas', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 2)]);
        Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 1);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: 1, size: null);
      });
      test('creating new areas to accommodate all child widgets', () {
        MultiSplitViewController controller =
            MultiSplitViewController(areas: [Area(data: 'a', flex: 2)]);
        Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: 2, size: null);
        AreaHelper.testArea(controller.areas[1],
            data: null, min: null, max: null, flex: 1, size: null);
      });
      test('sizeOverflowPolicy - shrinkFirst', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 100), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 155, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkFirst,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 50);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 100);
      });
      test('sizeOverflowPolicy - shrinkLast', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 100), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 155, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 100);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 50);
      });
      test('sizeOverflowPolicy - shrinkLast - min', () {
        MultiSplitViewController controller = MultiSplitViewController(areas: [
          Area(data: 'a', size: 100),
          Area(data: 'b', size: 100, min: 90)
        ]);
        Layout(childrenCount: 2, containerSize: 155, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 100);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: 90, max: null, flex: null, size: 50);
      });
      test('sizeUnderflowPolicy - stretchFirst', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 100), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 255, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchFirst);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 150);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 100);
      });
      test('sizeUnderflowPolicy - stretchLast', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 100), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 255, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 100);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 150);
      });
      test('sizeUnderflowPolicy - stretchLast - max', () {
        MultiSplitViewController controller = MultiSplitViewController(areas: [
          Area(data: 'a', size: 100),
          Area(data: 'b', size: 100, max: 110)
        ]);
        Layout(childrenCount: 2, containerSize: 255, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 100);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: 110, flex: null, size: 150);
      });
      test('sizeUnderflowPolicy - stretchAll', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 50), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 205, dividerThickness: 5)
            .adjustAreas(
                controllerHelper: ControllerHelper(controller),
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchAll);
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 75);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 125);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/layout.dart';

void main() {
  group('Layout', () {
    group('Adjust areas', () {
      test('removing unused areas', () {
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 2)]);
        Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
            .adjustAreas(controllerHelper: ControllerHelper(controller));
        expect(controller.areas.length, 1);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: 1, size: null);
      });
      test('creating new areas to accommodate all child widgets', () {
        MultiSplitViewController controller =
            MultiSplitViewController(areas: [Area(data: 'a', flex: 2)]);
        Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
            .adjustAreas(controllerHelper: ControllerHelper(controller));
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: 2, size: null);
        AreaHelper.testArea(controller.areas[1],
            data: null, min: null, max: null, flex: 1, size: null);
      });
      test('shrinking size', () {
        /// Shrinks size when the total size of the areas is greater than
        /// the available space.
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 100), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 155, dividerThickness: 5)
            .adjustAreas(controllerHelper: ControllerHelper(controller));
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 100);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 50);
      });
      test('growing size', () {
        /// Grows size when the total size of the areas is smaller than the
        /// available space and there are no flex areas to fill the available space.
        MultiSplitViewController controller = MultiSplitViewController(
            areas: [Area(data: 'a', size: 100), Area(data: 'b', size: 100)]);
        Layout(childrenCount: 2, containerSize: 255, dividerThickness: 5)
            .adjustAreas(controllerHelper: ControllerHelper(controller));
        expect(controller.areas.length, 2);
        AreaHelper.testArea(controller.areas[0],
            data: 'a', min: null, max: null, flex: null, size: 100);
        AreaHelper.testArea(controller.areas[1],
            data: 'b', min: null, max: null, flex: null, size: 150);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/layout.dart';

void main() {
  group('Layout - Update area constraints', () {
    test('1', () {
      MultiSplitViewController controller = MultiSplitViewController();
      Layout layout =
          Layout(childrenCount: 2, containerSize: 100, dividerThickness: 10);
      ControllerHelper controllerHelper = ControllerHelper(controller);
      layout.adjustAreas(controllerHelper: controllerHelper);
      layout.updateAreaIntervals(controllerHelper: controllerHelper);

      expect(layout.areaIntervals.length, 2);
      expect(layout.areaIntervals[0].startPos, 0);
      expect(layout.areaIntervals[0].size, 45);
      expect(layout.areaIntervals[0].endPos, 45);
      expect(layout.areaIntervals[1].startPos, 55);
      expect(layout.areaIntervals[1].size, 45);
      expect(layout.areaIntervals[1].endPos, 100);
    });
    test('all flex 0 with 1 size', () {
      MultiSplitViewController controller = MultiSplitViewController(
          areas: [Area(data: 'a', flex: 0), Area(data: 'b', flex: 0), Area(data: 'c', size: 100)]);
      Layout layout = Layout(childrenCount: 3, containerSize: 100, dividerThickness: 5);
      ControllerHelper controllerHelper = ControllerHelper(controller);
          layout.adjustAreas(controllerHelper: controllerHelper);
      layout.updateAreaIntervals(controllerHelper: controllerHelper);
      expect(layout.areaIntervals.length, 3);
      expect(layout.areaIntervals[0].startPos, 0);
      expect(layout.areaIntervals[0].size, 0);
      expect(layout.areaIntervals[0].endPos, 0);
      expect(layout.areaIntervals[1].startPos, 5);
      expect(layout.areaIntervals[1].size, 0);
      expect(layout.areaIntervals[1].endPos, 5);
      expect(layout.areaIntervals[2].startPos, 10);
      expect(layout.areaIntervals[2].size, 100);
      expect(layout.areaIntervals[2].endPos, 110);
    });
  });
}

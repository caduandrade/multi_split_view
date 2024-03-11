import 'package:flutter_test/flutter_test.dart';
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
      expect(layout.areaIntervals[0].start, 0);
      expect(layout.areaIntervals[0].size, 45);
      expect(layout.areaIntervals[0].end, 45);
      expect(layout.areaIntervals[1].start, 55);
      expect(layout.areaIntervals[1].size, 45);
      expect(layout.areaIntervals[1].end, 100);
    });
  });
}

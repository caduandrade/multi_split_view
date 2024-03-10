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
      layout.updateAreaConstraints(controllerHelper: controllerHelper);

      expect(layout.areaConstraintsList.length, 2);
      expect(layout.areaConstraintsList[0].start, 0);
      expect(layout.areaConstraintsList[0].size, 45);
      expect(layout.areaConstraintsList[0].end, 45);
      expect(layout.dividers.length, 1);
      expect(layout.dividers[0].start, 45);
      expect(layout.dividers[0].size, 10);
      expect(layout.dividers[0].end, 55);
      expect(layout.areaConstraintsList[1].start, 55);
      expect(layout.areaConstraintsList[1].size, 45);
      expect(layout.areaConstraintsList[1].end, 100);
    });
  });
}

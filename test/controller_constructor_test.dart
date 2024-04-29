import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'test_helper.dart';

void main() {
  group('MultiSplitController', () {
    group('Constructor', () {
      test('total flex 0', () {
        MultiSplitViewController controller =
            MultiSplitViewController(areas: [Area(flex: 0, max: 2)]);
        expect(controller.areasCount, 1);
        TestHelper.testArea(controller.getArea(0),
            data: null, flex: 1, size: null, min: null, max: null);

        controller = MultiSplitViewController(
            areas: [Area(flex: 0, max: 2), Area(flex: 0)]);
        expect(controller.areasCount, 2);
        TestHelper.testArea(controller.getArea(0),
            data: null, flex: 1, size: null, min: null, max: null);
        TestHelper.testArea(controller.getArea(1),
            data: null, flex: 1, size: null, min: null, max: null);

        controller = MultiSplitViewController(areas: [
          Area(size: 100, min: 50),
          Area(flex: 0, min: 0),
          Area(flex: 0, max: 2)
        ]);
        expect(controller.areasCount, 3);
        TestHelper.testArea(controller.getArea(0),
            data: null, flex: null, size: 100, min: 50, max: null);
        TestHelper.testArea(controller.getArea(1),
            data: null, flex: 1, size: null, min: null, max: null);
        TestHelper.testArea(controller.getArea(2),
            data: null, flex: 1, size: null, min: null, max: null);
      });
    });
  });
}

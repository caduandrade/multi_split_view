import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() {
  group('Area', () {
    test('Index', () {
      List<Area> areas = [Area(data: 'a'), Area(data: 'b'), Area(data: 'c')];
      expect(areas[0].index, -1);
      expect(areas[1].index, -1);
      expect(areas[2].index, -1);
      MultiSplitViewController controller =
          MultiSplitViewController(areas: areas);
      expect(areas[0].index, 0);
      expect(areas[1].index, 1);
      expect(areas[2].index, 2);
      expect(controller.getArea(0).index, 0);
      expect(controller.getArea(1).index, 1);
      expect(controller.getArea(2).index, 2);
      controller.addArea(Area(data: 'd'));
      expect(controller.getArea(3).index, 3);
      controller.removeAreaAt(0);
      expect(areas[0].index, -1);
      expect(areas[1].index, 0);
      expect(areas[2].index, 1);
      expect(controller.getArea(0).index, 0);
      expect(controller.getArea(1).index, 1);
      expect(controller.getArea(2).index, 2);
    });
  });
}

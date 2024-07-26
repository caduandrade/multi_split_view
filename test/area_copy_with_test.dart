import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';

void main() {
  group('Area', () {
    group('copyWith', () {
      test('flex and size', () {
        Area area = Area(size: 2);
        expect(() {
          area.copyWith(size: 1, flex: 2);
        },
            throwsA(isA<ArgumentError>().having((e) => e.message, '',
                'Cannot provide both a size and a flex.')));
      });
      test('negative size', () {
        Area area = Area(size: 2);
        expect(() {
          area.copyWith(size: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'size')));
      });
      test('negative flex', () {
        Area area = Area(flex: 2);
        expect(() {
          area.copyWith(flex: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'flex')));
      });
      test('negative min', () {
        Area area = Area();
        expect(() {
          area.copyWith(min: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'min')));
      });
      test('negative max', () {
        Area area = Area();
        expect(() {
          area.copyWith(max: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'max')));
      });
      test('flex', () {
        Area area = Area();
        area = area.copyWith(flex: 2);
        expect(area.size, null);
        expect(area.flex, 2);
        expect(area.max, null);
        expect(area.min, null);
        expect(area.data, null);
      });
      test('size', () {
        Area area = Area(size: 2);
        area = area.copyWith(size: 3);
        expect(area.size, 3);
        expect(area.flex, null);
        expect(area.max, null);
        expect(area.min, null);
        expect(area.data, null);
      });
      test('flex - min', () {
        Area area = Area(flex: 3, min: 3);
        expect(area.flex, 3);
        expect(area.min, 3);

        area = area.copyWith(min: 1);
        expect(area.size, null);
        expect(area.flex, 3);
        expect(area.max, null);
        expect(area.min, 1);
        expect(area.data, null);
      });
      test('flex - max', () {
        Area area = Area(flex: 2, max: 2);
        expect(area.flex, 2);
        expect(area.max, 2);

        area = area.copyWith(max: 10);
        expect(area.size, null);
        expect(area.flex, 2);
        expect(area.max, 10);
        expect(area.min, null);
        expect(area.data, null);
      });
      test('size - min', () {
        Area area = Area(size: 3, min: 3);
        expect(area.size, 3);
        expect(area.min, 3);

        area = area.copyWith(min: 3);
        expect(area.size, 3);
        expect(area.flex, null);
        expect(area.max, null);
        expect(area.min, 3);
        expect(area.data, null);
      });
      test('size - max', () {
        Area area = Area(size: 2, max: 2);
        expect(area.size, 2);
        expect(area.max, 2);

        area = area.copyWith(max: 10);
        expect(area.size, 2);
        expect(area.flex, null);
        expect(area.max, 10);
        expect(area.min, null);
        expect(area.data, null);
      });
      test('flex to size', () {
        Area area = Area();

        area = area.copyWith(size: 1);

        expect(area.size, 1);
        expect(area.flex, null);
        expect(area.max, null);
        expect(area.min, null);
        expect(area.data, null);
      });
      test('size to flex', () {
        Area area = Area(size: 10);

        area = area.copyWith(flex: 2);

        expect(area.size, null);
        expect(area.flex, 2);
        expect(area.max, null);
        expect(area.min, null);
        expect(area.data, null);
      });
      test('same id', () {
        Area area1 = Area(id: 'id');
        Area area2 = area1.copyWith(flex: 2);

        expect(area1.id, isNotNull);
        expect(area2.id, isNotNull);
        expect(area1.id, 'id');
        expect(area2.id, 'id');
        expect(area1.id == area2.id, true);
      });
      test('change id', () {
        Area area1 = Area();
        Area area2 = area1.copyWith(id: 'id');

        expect(area1.id, isNotNull);
        expect(area2.id, isNotNull);
        expect(area2.id, 'id');
        expect(area1.id == area2.id, false);
      });
    });
  });
}

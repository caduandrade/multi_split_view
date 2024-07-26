import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';

void main() {
  group('Area', () {
    group('Constructor', () {
      test('negative size', () {
        expect(() {
          Area(size: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'size')));
      });
      test('negative flex', () {
        expect(() {
          Area(flex: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'flex')));
      });
      test('negative min', () {
        expect(() {
          Area(min: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'min')));
      });
      test('negative max', () {
        expect(() {
          Area(max: -1);
        }, throwsA(isA<ArgumentError>().having((e) => e.name, '', 'max')));
      });
      test('default flex', () {
        Area area = Area();
        expect(area.flex, 1);
      });
      test('size', () {
        Area area = Area(size: 2);
        expect(area.size, 2);
      });
      test('flex', () {
        Area area = Area(flex: 2);
        expect(area.flex, 2);
      });
      test('flex - min', () {
        Area area = Area(flex: 2, min: 3);
        expect(area.flex, 3);
        expect(area.min, 3);

        area = Area(flex: 5, min: 3);
        expect(area.flex, 5);
        expect(area.min, 3);
      });
      test('flex - max', () {
        Area area = Area(flex: 2, max: 1);
        expect(area.flex, 1);
        expect(area.max, 1);

        area = Area(flex: 5, max: 10);
        expect(area.flex, 5);
        expect(area.max, 10);
      });
      test('size - min', () {
        Area area = Area(size: 2, min: 3);
        expect(area.size, 3);
        expect(area.min, 3);

        area = Area(size: 5, min: 3);
        expect(area.size, 5);
        expect(area.min, 3);
      });
      test('size - max', () {
        Area area = Area(size: 2, max: 1);
        expect(area.size, 1);
        expect(area.max, 1);

        area = Area(size: 5, max: 10);
        expect(area.size, 5);
        expect(area.max, 10);
      });
    });
  });
}

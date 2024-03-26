import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/area.dart';

import 'test_helper.dart';

void main() {
  group('Layout', () {
    group('Update screen constraints', () {
      group('2 areas', () {
        test('SS', () {
          TestHelper helper = TestHelper(
              areas: [Area(size: 50), Area(size: 50)],
              containerSize: 110,
              dividerThickness: 10);
          helper.testConstraints(0,
              startPos: 0, endPos: 50, size: 50, minSize: null, maxSize: null);
          helper.testConstraints(1,
              startPos: 60,
              endPos: 110,
              size: 50,
              minSize: null,
              maxSize: null);

          // without screen space
          helper = TestHelper(
              areas: [Area(size: 100), Area(size: 100)],
              containerSize: 10,
              dividerThickness: 10);
          helper.testConstraints(0,
              startPos: 0, endPos: 0, size: 0, minSize: null, maxSize: null);
          helper.testConstraints(1,
              startPos: 10, endPos: 10, size: 0, minSize: null, maxSize: null);
        });

        test('FF', () {
          TestHelper helper = TestHelper(
              areas: [Area(flex: 1), Area(flex: 1)],
              containerSize: 100,
              dividerThickness: 10);
          helper.testConstraints(0,
              startPos: 0, endPos: 45, size: 45, minSize: null, maxSize: null);
          helper.testConstraints(1,
              startPos: 55,
              endPos: 100,
              size: 45,
              minSize: null,
              maxSize: null);

          // without screen space
          helper = TestHelper(
              areas: [Area(flex: 1), Area(flex: 1)],
              containerSize: 10,
              dividerThickness: 10);
          helper.testConstraints(0,
              startPos: 0, endPos: 0, size: 0, minSize: null, maxSize: null);
          helper.testConstraints(1,
              startPos: 10, endPos: 10, size: 0, minSize: null, maxSize: null);
        });
      });
      group('3 areas', () {
        test('FFS', () {
          TestHelper helper = TestHelper(
              areas: [Area(flex: 1), Area(flex: 1), Area(size: 100)],
              containerSize: 310,
              dividerThickness: 5);
          helper.testConstraints(0,
              startPos: 0,
              endPos: 100,
              size: 100,
              minSize: null,
              maxSize: null);
          helper.testConstraints(1,
              startPos: 105,
              endPos: 205,
              size: 100,
              minSize: null,
              maxSize: null);
          helper.testConstraints(2,
              startPos: 210,
              endPos: 310,
              size: 100,
              minSize: null,
              maxSize: null);
        });
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'test_helper.dart';

void main() {
  group('Layout', () {
    group('Move divider', () {
      group('2 areas', () {
        group('SS', () {
          test('-10 pixels - under overflow - max', () {
            TestHelper helper = TestHelper(
                areas: [
                  Area(data: 'a', size: 50),
                  Area(data: 'b', size: 10, max: 20)
                ],
                containerSize: 110,
                dividerThickness: 10,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 50, minSize: null, maxSize: 20);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -10, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 50, minSize: null, maxSize: 20);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 50);
            helper.testArea(1,
                data: 'b', min: null, max: 20, flex: null, size: 50);
          });
          test('10 pixels - under overflow - max', () {
            TestHelper helper = TestHelper(
                areas: [
                  Area(data: 'a', size: 50),
                  Area(data: 'b', size: 10, max: 20)
                ],
                containerSize: 110,
                dividerThickness: 10,
                sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 50, minSize: null, maxSize: 20);

            helper.moveAndTest(
                dividerIndex: 0, pixels: 10, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 60, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 40, minSize: null, maxSize: 20);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 60);
            helper.testArea(1,
                data: 'b', min: null, max: 20, flex: null, size: 40);
          });
          test('-10 pixels - shrink overflow - min', () {
            TestHelper helper = TestHelper(
                areas: [
                  Area(data: 'a', size: 50),
                  Area(data: 'b', size: 100, min: 90)
                ],
                containerSize: 110,
                dividerThickness: 10,
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 50, minSize: 90, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -10, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 40, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 60, minSize: 90, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 40);
            helper.testArea(1,
                data: 'b', min: 90, max: null, flex: null, size: 60);
          });
          test('10 pixels - shrink overflow - min', () {
            TestHelper helper = TestHelper(
                areas: [
                  Area(data: 'a', size: 50),
                  Area(data: 'b', size: 100, min: 90)
                ],
                containerSize: 110,
                dividerThickness: 10,
                sizeOverflowPolicy: SizeOverflowPolicy.shrinkLast);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 50, minSize: 90, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: 10, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1, size: 50, minSize: 90, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 50);
            helper.testArea(1,
                data: 'b', min: 90, max: null, flex: null, size: 50);
          });
        });
        group('SF', () {
          test('-100 pixels', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', size: 200), Area(data: 'b', flex: 1)],
                containerSize: 310,
                dividerThickness: 10);

            helper.testConstraintsSize(0,
                size: 200, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 100, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -100, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 200, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 100);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 1, size: null);
          });
          test('1o S +200 pixels over screen limit', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', size: 50), Area(data: 'b', flex: 1)],
                containerSize: 105,
                dividerThickness: 5);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: 200, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 0, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 100);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 1, size: null);
          });
        });
        group('FF', () {
          test('0 pixel', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 1)],
                containerSize: 110,
                dividerThickness: 10);
            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: 0, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: 1, size: null);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 1, size: null);
          });
          test('-1 pixel', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 1)],
                containerSize: 110,
                dividerThickness: 10);
            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -1, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 49, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 51, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: 0.98, size: null);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 1.02, size: null);
          });
          test('1 pixel', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 1)],
                containerSize: 110,
                dividerThickness: 10);
            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: 1, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 51, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 49, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: 1.02, size: null);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 0.98, size: null);
          });
          test('-200 pixels with rest', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 1)],
                containerSize: 110,
                dividerThickness: 10);
            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -200, pushDividers: false, rest: -150);

            helper.testConstraintsSize(0,
                size: 0, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 100, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: 0, size: null);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 2, size: null);
          });
          test('200 pixels with rest', () {
            TestHelper helper = TestHelper(
                areas: [Area(data: 'a', flex: 1), Area(data: 'b', flex: 1)],
                containerSize: 110,
                dividerThickness: 10);
            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: 200, pushDividers: false, rest: 150);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 0, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: 2, size: null);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 0, size: null);
          });
        });
      });
      group('3 areas', () {
        group('SFF', () {
          test('20 pixels - last F collapsed', () {
            TestHelper helper = TestHelper(areas: [
              Area(data: 'a', size: 100),
              Area(data: 'b', flex: 1),
              Area(data: 'c', flex: 1)
            ], containerSize: 110, dividerThickness: 5);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 0, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 0, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 1, pixels: 20, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 0, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 0, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 100);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 1, size: null);
            helper.testArea(2,
                data: 'c', min: null, max: null, flex: 1, size: null);
          });
          test('-20 pixels', () {
            TestHelper helper = TestHelper(areas: [
              Area(data: 'a', size: 100),
              Area(data: 'b', flex: 1),
              Area(data: 'c', flex: 3)
            ], containerSize: 510, dividerThickness: 5);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 300, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -20, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 80, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 105, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 315, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 80);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: 1, size: null);
            helper.testArea(2,
                data: 'c', min: null, max: null, flex: 3, size: null);
          });
        });
        group('FSF', () {
          test('-20 pixels', () {
            TestHelper helper = TestHelper(areas: [
              Area(data: 'a', flex: 1),
              Area(data: 'b', size: 100),
              Area(data: 'c', flex: 3)
            ], containerSize: 510, dividerThickness: 5);

            helper.testConstraintsSize(0,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 100, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 300, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -20, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 95, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 120, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 285, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: 1, size: null);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: null, size: 120);
            helper.testArea(2,
                data: 'c', min: null, max: null, flex: 3, size: null);
          });
        });
        group('SSF', () {
          test('1o S -20 pixels, F collapsed', () {
            TestHelper helper = TestHelper(areas: [
              Area(data: 'a', size: 50),
              Area(data: 'b', size: 50),
              Area(data: 'c', flex: 1)
            ], containerSize: 110, dividerThickness: 5);

            helper.testConstraintsSize(0,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 50, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 0, minSize: null, maxSize: null);

            helper.moveAndTest(
                dividerIndex: 0, pixels: -20, pushDividers: false, rest: 0);

            helper.testConstraintsSize(0,
                size: 30, minSize: null, maxSize: null);
            helper.testConstraintsSize(1,
                size: 70, minSize: null, maxSize: null);
            helper.testConstraintsSize(2,
                size: 0, minSize: null, maxSize: null);

            helper.testArea(0,
                data: 'a', min: null, max: null, flex: null, size: 30);
            helper.testArea(1,
                data: 'b', min: null, max: null, flex: null, size: 70);
            helper.testArea(2,
                data: 'c', min: null, max: null, flex: 1, size: null);
          });
        });
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/internal/layout_constraints.dart';

void main() {
  group('LayoutConstraints', () {
    group('Constructor', () {
      test('negative childrenCount', () {
        expect(() {
          LayoutConstraints(
              areasCount: -1, containerSize: 100, dividerThickness: 5);
        },
            throwsA(isA<ArgumentError>()
                .having((e) => e.name, '', 'childrenCount')));
      });
      test('negative dividerThickness', () {
        expect(() {
          LayoutConstraints(
              areasCount: 0, containerSize: 100, dividerThickness: -5);
        },
            throwsA(isA<ArgumentError>()
                .having((e) => e.name, '', 'dividerThickness')));
      });
      test('negative containerSize', () {
        expect(() {
          LayoutConstraints(
              areasCount: 1, containerSize: -10, dividerThickness: 5);
        },
            throwsA(isA<ArgumentError>()
                .having((e) => e.name, '', 'containerSize')));
      });
      test('totalDividerSize', () {
        expect(
            LayoutConstraints(
                    areasCount: 0, containerSize: 100, dividerThickness: 5)
                .totalDividerSize,
            0);
        expect(
            LayoutConstraints(
                    areasCount: 1, containerSize: 100, dividerThickness: 5)
                .totalDividerSize,
            0);
        expect(
            LayoutConstraints(
                    areasCount: 2, containerSize: 100, dividerThickness: 5)
                .totalDividerSize,
            5);
        expect(
            LayoutConstraints(
                    areasCount: 3, containerSize: 100, dividerThickness: 5)
                .totalDividerSize,
            10);
        expect(
            LayoutConstraints(
                    areasCount: 10, containerSize: 100, dividerThickness: 0)
                .totalDividerSize,
            0);
      });
      test('availableSpace', () {
        expect(
            LayoutConstraints(
                    areasCount: 0, containerSize: 100, dividerThickness: 5)
                .spaceForAreas,
            100);
        expect(
            LayoutConstraints(
                    areasCount: 1, containerSize: 100, dividerThickness: 5)
                .spaceForAreas,
            100);
        expect(
            LayoutConstraints(
                    areasCount: 2, containerSize: 100, dividerThickness: 5)
                .spaceForAreas,
            95);
        expect(
            LayoutConstraints(
                    areasCount: 3, containerSize: 100, dividerThickness: 5)
                .spaceForAreas,
            90);
        expect(
            LayoutConstraints(
                    areasCount: 10, containerSize: 100, dividerThickness: 0)
                .spaceForAreas,
            100);
        expect(
            LayoutConstraints(
                    areasCount: 2, containerSize: 100, dividerThickness: 100)
                .spaceForAreas,
            0);
        expect(
            LayoutConstraints(
                    areasCount: 2, containerSize: 100, dividerThickness: 200)
                .spaceForAreas,
            0);
      });
    });
  });
}

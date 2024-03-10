import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/src/internal/layout.dart';

void main() {
  group('Layout - Constructor', () {
    test('negative childrenCount', () {
      expect(() {
        Layout(childrenCount: -1, containerSize: 100, dividerThickness: 5);
      },
          throwsA(
              isA<ArgumentError>().having((e) => e.name, '', 'childrenCount')));
    });
    test('negative dividerThickness', () {
      expect(() {
        Layout(childrenCount: 0, containerSize: 100, dividerThickness: -5);
      },
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, '', 'dividerThickness')));
    });
    test('negative containerSize', () {
      expect(() {
        Layout(childrenCount: 1, containerSize: -10, dividerThickness: 5);
      },
          throwsA(
              isA<ArgumentError>().having((e) => e.name, '', 'containerSize')));
    });
    test('totalDividerSize', () {
      expect(
          Layout(childrenCount: 0, containerSize: 100, dividerThickness: 5)
              .totalDividerSize,
          0);
      expect(
          Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
              .totalDividerSize,
          0);
      expect(
          Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
              .totalDividerSize,
          5);
      expect(
          Layout(childrenCount: 3, containerSize: 100, dividerThickness: 5)
              .totalDividerSize,
          10);
      expect(
          Layout(childrenCount: 10, containerSize: 100, dividerThickness: 0)
              .totalDividerSize,
          0);
    });
    test('availableSize', () {
      expect(
          Layout(childrenCount: 0, containerSize: 100, dividerThickness: 5)
              .availableSize,
          100);
      expect(
          Layout(childrenCount: 1, containerSize: 100, dividerThickness: 5)
              .availableSize,
          100);
      expect(
          Layout(childrenCount: 2, containerSize: 100, dividerThickness: 5)
              .availableSize,
          95);
      expect(
          Layout(childrenCount: 3, containerSize: 100, dividerThickness: 5)
              .availableSize,
          90);
      expect(
          Layout(childrenCount: 10, containerSize: 100, dividerThickness: 0)
              .availableSize,
          100);
      expect(
          Layout(childrenCount: 2, containerSize: 100, dividerThickness: 100)
              .availableSize,
          0);
      expect(
          Layout(childrenCount: 2, containerSize: 100, dividerThickness: 200)
              .availableSize,
          0);
    });
  });
}

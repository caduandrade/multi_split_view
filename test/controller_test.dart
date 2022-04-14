import 'package:flutter_test/flutter_test.dart';
import 'package:multi_split_view/multi_split_view.dart';

const double delta = 0.00005;

void main() {
  group('Weight', () {
    test('0', () {
      MultiSplitViewController c = MultiSplitViewController();
      c.validateAndAdjust(0);
      expect(c.weights.length, 0);
    });
    test('0 -> 1', () {
      MultiSplitViewController c = MultiSplitViewController();
      c.validateAndAdjust(1);
      expect(c.weights.length, 1);
      expect(c.getWeight(0), 1);
    });
    test('1 -> 1 (a)', () {
      MultiSplitViewController c = MultiSplitViewController(weights: [1]);
      c.validateAndAdjust(1);
      expect(c.weights.length, 1);
      expect(c.getWeight(0), 1);
    });
    test('1 -> 1  (b)', () {
      MultiSplitViewController c = MultiSplitViewController(weights: [.4]);
      c.validateAndAdjust(1);
      expect(c.weights.length, 1);
      expect(c.getWeight(0), 1);
    });
    test('2 -> 2 (a)', () {
      MultiSplitViewController c = MultiSplitViewController(weights: [.4, .6]);
      c.validateAndAdjust(2);
      expect(c.weights.length, 2);
      expect(c.getWeight(0), .4);
      expect(c.getWeight(1), .6);
    });
    test('2 -> 2 (b)', () {
      MultiSplitViewController c = MultiSplitViewController(weights: [.1, .1]);
      c.validateAndAdjust(2);
      expect(c.weights.length, 2);
      expect(c.getWeight(0), .5);
      expect(c.getWeight(1), .5);
    });
    test('1 -> 2', () {
      MultiSplitViewController c = MultiSplitViewController(weights: [.4]);
      c.validateAndAdjust(2);
      expect(c.weights.length, 2);
      expect(c.getWeight(0), .4);
      expect(c.getWeight(1), .6);
    });
    test('3 -> 4', () {
      MultiSplitViewController c =
          MultiSplitViewController(weights: [.2, .2, .6]);
      c.validateAndAdjust(4);
      expect(c.weights.length, 4);

      expect(c.getWeight(0), closeTo(.15, delta));
      expect(c.getWeight(1), closeTo(.15, delta));
      expect(c.getWeight(2), closeTo(.45, delta));
      expect(c.getWeight(3), .25);
    });
  });
}



const double delta = 0.00005;

void main() {
  /*
  group('fixWeights', () {
    test('children: 2 / 1 area(minimalSize)', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(minimalSize: 100)]);
      c.fixWeights(childrenCount: 2, fullSize: 210, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, .5);
      expect(c.getArea(1).flex, .5);
    });
    test('children: 2 / 1 area(minimalSize)', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(minimalSize: 100)]);
      c.fixWeights(childrenCount: 2, fullSize: 110, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, 1);
      expect(c.getArea(1).flex, 0);
    });
    test('1', () {
      MultiSplitViewController c = MultiSplitViewController();
      c.fixWeights(childrenCount: 0, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 0);
    });
    test('2', () {
      MultiSplitViewController c = MultiSplitViewController();
      c.fixWeights(childrenCount: 1, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 1);
      expect(c.getArea(0).flex, 1);
    });
    test('3', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: 0)]);
      c.fixWeights(childrenCount: 1, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 1);
      expect(c.getArea(0).flex, 1);
    });
    test('4', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: .5)]);
      c.fixWeights(childrenCount: 1, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 1);
      expect(c.getArea(0).flex, 1);
    });
    test('5', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: 1)]);
      c.fixWeights(childrenCount: 1, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 1);
      expect(c.getArea(0).flex, 1);
    });
    test('6', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: 0), Area(weight: 1)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, 0);
      expect(c.getArea(1).flex, 1);
    });
    test('7', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: .4), Area(weight: .6)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, .4);
      expect(c.getArea(1).flex, .6);
    });
    test('8', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: .1), Area(weight: .1)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, .5);
      expect(c.getArea(1).flex, .5);
    });
    test('9', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: .4)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, .4);
      expect(c.getArea(1).flex, .6);
    });
    test('10', () {
      MultiSplitViewController c = MultiSplitViewController(
          areas: [Area(weight: .2), Area(weight: .2), Area(weight: .6)]);
      c.fixWeights(childrenCount: 4, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 4);
      expect(c.getArea(0).flex, moreOrLessEquals(.15, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.15, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.45, epsilon: delta));
      expect(c.getArea(3).flex, .25);
    });
    test('11', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: 0)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, 0);
      expect(c.getArea(1).flex, 1);
    });
    test('12', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(), Area(weight: 0)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, 1);
      expect(c.getArea(1).flex, 0);
    });
    test('13', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(), Area()]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, .5);
      expect(c.getArea(1).flex, .5);
    });
    test('14', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: 0), Area(weight: 0)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, .5);
      expect(c.getArea(1).flex, .5);
    });
    test('15', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: 1), Area(weight: 1)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, moreOrLessEquals(.5, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.5, epsilon: delta));
    });
    test('16', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: .2), Area(weight: 1)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, moreOrLessEquals(.16666, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.83333, epsilon: delta));
    });
    test('17', () {
      MultiSplitViewController c = MultiSplitViewController(areas: []);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, moreOrLessEquals(.5, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.5, epsilon: delta));
      c.fixWeights(childrenCount: 3, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 3);
      expect(c.getArea(0).flex, moreOrLessEquals(.33333, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.33333, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.33333, epsilon: delta));
    });
    test('18', () {
      MultiSplitViewController c =
          MultiSplitViewController(areas: [Area(weight: .5), Area(weight: .5)]);
      c.fixWeights(childrenCount: 2, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 2);
      expect(c.getArea(0).flex, moreOrLessEquals(.5, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.5, epsilon: delta));

      c.areas = [Area(weight: .5), Area(weight: .5), Area()];
      c.fixWeights(childrenCount: 3, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 3);
      expect(c.getArea(0).flex, moreOrLessEquals(.3333, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.3333, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.3333, epsilon: delta));
    });
    test('19', () {
      MultiSplitViewController c = MultiSplitViewController(
          areas: [Area(weight: .5), Area(weight: .5), Area()]);
      c.fixWeights(childrenCount: 3, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 3);
      expect(c.getArea(0).flex, moreOrLessEquals(.3333, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.3333, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.3333, epsilon: delta));
    });
    test('20', () {
      MultiSplitViewController c = MultiSplitViewController(
          areas: [Area(weight: .2), Area(weight: .8), Area()]);
      c.fixWeights(childrenCount: 3, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 3);
      expect(c.getArea(0).flex, moreOrLessEquals(.13333, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.53333, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.33333, epsilon: delta));
    });
    test('21', () {
      MultiSplitViewController c = MultiSplitViewController(
          areas: [Area(weight: .2), Area(weight: .8), Area(minimalWeight: .5)]);
      c.fixWeights(childrenCount: 3, fullSize: 1000, dividerThickness: 10);
      expect(c.areas.length, 3);
      expect(c.getArea(0).flex, moreOrLessEquals(.1, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.4, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.5, epsilon: delta));
    });
    test('22', () {
      MultiSplitViewController c = MultiSplitViewController(
          areas: [Area(weight: .2), Area(weight: .8), Area(minimalSize: 500)]);
      c.fixWeights(childrenCount: 3, fullSize: 1020, dividerThickness: 10);
      expect(c.areas.length, 3);
      expect(c.getArea(0).flex, moreOrLessEquals(.1, epsilon: delta));
      expect(c.getArea(1).flex, moreOrLessEquals(.4, epsilon: delta));
      expect(c.getArea(2).flex, moreOrLessEquals(.5, epsilon: delta));
    });
  });

   */
}

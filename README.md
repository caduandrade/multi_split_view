[![pub](https://img.shields.io/pub/v/multi_split_view.svg)](https://pub.dev/packages/multi_split_view) [![pub2](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/)

# Multi split view

A widget to provides horizontal or vertical multiple split view for Flutter.

![animated](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/animated.gif)

* Horizontal or vertical
* Configurable weight or size for each child
* Automatic calculation of weights when:
  * Child added without defined weight
  * Weight redistribution when a child is removed
* Listener to detect children size changes

## Usage

* [Horizontal](#horizontal)
* [Vertical](#vertical)
* [Horizontal and vertical](#horizontal-and-vertical)
* [Setting the weight](#setting-the-weight)
* Divider
  * [Color](#divider-color)
  * [Thickness](#divider-thickness)
  * [Custom painter](#divider-custom-painter)
  * [Resizable](#resizable)
* [Minimal child weight](#minimal-child-weight)
* [Listener](#listener)

## Horizontal

```dart
    MultiSplitView(children: [child1, child2, child3]);
```

![horizontal](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/horizontal.png)

## Vertical

```dart
    MultiSplitView(axis: Axis.vertical, children: [child1, child2]);
```

![vertical](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/vertical.png)

## Horizontal and vertical

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2, child3]),
      child4
    ]);
```

![horizontalvertical](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/horizontal_vertical.png)

## Setting the weight

```dart
    // setting 10% of weight for the first child
    MultiSplitView(
        children: [child1, child2, child3],
        controller: MultiSplitViewController(weights: [0.1]));
```

![horizontalweight](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/horizontal_weight.png)

## Divider color

The default color is `NULL`.

```dart
    MultiSplitView(
        children: [child1, child2], dividerColor: Colors.black);
```

![dividercolor](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/divider_color.png)

## Divider thickness

```dart
    MultiSplitView(
        children: [child1, child2, child3], dividerThickness: 30);
```

![dividerthickness](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/divider_thickness.png)

## Divider custom painter

```dart
    var dividerPainter = (Axis axis, bool resizable, Canvas canvas, Size size) {
      var paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..isAntiAlias = true;
      if (axis == Axis.vertical) {
        double dashHeight = 9, dashSpace = 5, startY = 0;
        while (startY < size.height) {
          canvas.drawLine(Offset(size.width / 2, startY),
              Offset(size.width / 2, startY + dashHeight), paint);
          startY += dashHeight + dashSpace;
        }
      } else {
        double dashWidth = 9, dashSpace = 5, startX = 0;
        while (startX < size.width) {
          canvas.drawLine(Offset(startX, size.height / 2),
              Offset(startX + dashWidth, size.height / 2), paint);
          startX += dashWidth + dashSpace;
        }
      }
    };

    MultiSplitView(
        axis: Axis.vertical,
        children: [
          MultiSplitView(
              children: [child1, child2, child3],
              dividerThickness: 10,
              dividerPainter: dividerPainter),
          child4
        ],
        dividerThickness: 10,
        dividerPainter: dividerPainter);
```

![](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/divider_painter_v1.png)

## Resizable

```dart
    MultiSplitView(children: [child1, child2, child3], resizable: false);
```

## Minimal child weight

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalWeight: .40),
      MultiSplitView(children: [child3, child4])
    ]);
```

![minimalweight](https://raw.githubusercontent.com/caduandrade/images/main/multi_split_view/minimal_weight.gif)

## Minimal child size in pixels

Used if `minimalWeight` has not been set.
The size will be converted into weight and will respect the limit defined by the `MultiSplitView.defaultMinimalWeight` constant, allowing all children to be visible.

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalSize: 100),
      MultiSplitView(children: [child3, child4])
    ]);
```

## Listener

```dart
    MultiSplitView(
        children: [child1, child2, child3, child4],
        onSizeChange: (childIndex1, childIndex2) => print(
            'Index of children whose size has changed: $childIndex1 and $childIndex2'));
```
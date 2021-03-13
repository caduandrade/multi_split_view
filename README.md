# multi_split_view

[![pub](https://img.shields.io/pub/v/multi_split_view.svg)](https://pub.dev/packages/multi_split_view)

A widget to provides horizontal or vertical multiple split view for Flutter.

![animated](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/animated.gif)

* Horizontal or vertical
* Configurable weights for children
* Automatic calculation of weights for:
  * Child added without defined weight
  * Weight redistribution when a child is removed
* Listener to detect children size changes

## Examples

**Horizontal**

```dart
    MultiSplitView(children: [child1, child2, child3]);
```

![horizontal](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/horizontal.png)

**Vertical**

```dart
    MultiSplitView(axis: Axis.vertical, children: [child1, child2]);
```

![vertical](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/vertical.png)

**Horizontal and vertical**

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2, child3]),
      child4
    ]);
```

![horizontalvertical](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/horizontal_vertical.png)

**Setting the weight**

```dart
    // setting 10% of weight for the first child
    MultiSplitView(
        children: [child1, child2, child3],
        controller: MultiSplitViewController(weights: [0.1]));
```

![horizontalweight](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/horizontal_weight.png)

**Divider color**

```dart
    MultiSplitView(
        children: [child1, child2], dividerColor: Colors.black);
```

![dividercolor](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/divider_color.png)

**Divider thickness**

```dart
    MultiSplitView(
        children: [child1, child2, child3], dividerThickness: 30);
```

![dividerthickness](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/divider_thickness.png)

**Minimal child weight**

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalWeight: .40),
      MultiSplitView(children: [child3, child4])
    ]);
```

![minimalweight](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/minimal_weight.gif)

**Listener**

```dart
    MultiSplitView(
        children: [child1, child2],
        onSizeChange: (childIndex1, childIndex2) => print(
            'Index of children who changed size: $childIndex1 and $childIndex2'));
```

## TODO

* Documentation
* Test
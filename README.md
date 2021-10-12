[![](https://img.shields.io/pub/v/multi_split_view.svg)](https://pub.dev/packages/multi_split_view) ![](https://github.com/caduandrade/multi_split_view/actions/workflows/test.yml/badge.svg) [![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/multi_split_view_demo/) [![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/)

# Multi split view

A widget to provides horizontal or vertical multiple split view for Flutter.

![](https://caduandrade.github.io/multi_split_view/get_started_v1.gif)

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
* Size
  * [Setting the weight](#setting-the-weight)
  * [Minimal child weight](#minimal-child-weight)
  * [Minimal child size in pixels](#minimal-child-size-in-pixels)
  * [Resizable](#resizable)
  * [Listener](#listener)
* Divider
  * [Thickness](#divider-thickness)
  * [Divider painters](#divider-painters)
    * [Background color](#divider---background-color)
    * [Custom painter](#divider---custom-painter)

## Horizontal

```dart
    MultiSplitView(children: [child1, child2, child3]);
```

![](https://caduandrade.github.io/multi_split_view/horizontal_v1.png)

## Vertical

```dart
    MultiSplitView(axis: Axis.vertical, children: [child1, child2]);
```

![](https://caduandrade.github.io/multi_split_view/vertical_v1.png)

## Horizontal and vertical

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2, child3]),
      child4
    ]);
```

![](https://caduandrade.github.io/multi_split_view/horizontal_vertical_v1.png)

## Setting the weight

```dart
    // setting 10% of weight for the first child
    MultiSplitView(
        children: [child1, child2, child3],
        controller: MultiSplitViewController(weights: [0.1]));
```

![](https://caduandrade.github.io/multi_split_view/horizontal_weight_v1.png)

## Minimal child weight

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalWeight: .40),
      MultiSplitView(children: [child3, child4])
    ]);
```

![](https://caduandrade.github.io/multi_split_view/minimal_weight_v1.gif)

## Minimal child size in pixels

Used if `minimalWeight` has not been set.
The size will be converted into weight and will respect the limit defined by the `MultiSplitView.defaultMinimalWeight` constant, allowing all children to be visible.

```dart
    MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalSize: 100),
      MultiSplitView(children: [child3, child4])
    ]);
```

## Resizable

```dart
    MultiSplitView(children: [child1, child2, child3], resizable: false);
```

## Listener

```dart
    MultiSplitView(
        children: [child1, child2, child3, child4],
        onSizeChange: (childIndex1, childIndex2) => print(
            'Index of children whose size has changed: $childIndex1 and $childIndex2'));
```

## Divider thickness

```dart
    MultiSplitView multiSplitView =
        MultiSplitView(children: [child1, child2, child3]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(dividerThickness: 30));
```

![](https://caduandrade.github.io/multi_split_view/divider_thickness_v1.png)

## Divider painters

Allows customizing the divider through the `DividerPainter` class.

The `DividerPainters` factory class offers default painters.

## Divider - background color

The `DividerPainters.background` allows setting the background color. The default color is `NULL`.

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.background(color: Colors.black)));
```

![](https://caduandrade.github.io/multi_split_view/divider_color_v1.png)

## Divider - Custom painter

It is possible to extend the `DividerPainter` class to create a painter from scratch.
[![](https://img.shields.io/pub/v/multi_split_view.svg)](https://pub.dev/packages/multi_split_view) ![](https://github.com/caduandrade/multi_split_view/actions/workflows/test.yml/badge.svg) [![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/multi_split_view_demo/) [![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/) [![](https://img.shields.io/badge/donate-crypto-green)](#support-this-project)

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
  * [Custom widget](#widget-as-a-custom-divider)
  * [Divider painters](#divider-painters)
    * [Background color](#divider---background-color)
    * [Custom painter](#divider---custom-painter)
    * [Divider - highlighted background color](#divider---highlighted-background-color)
    * [Dashed divider](#dashed-divider)
      * [Customizations](#dashed-divider---customizations)
    * [Grooved divider 1](#grooved-divider-1)
      * [Customizations](#grooved-divider-1---customizations)
    * [Grooved divider 2](#grooved-divider-2)
      * [Customizations](#grooved-divider-2---customizations)
* [Support this project](#support-this-project)

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

#### Using in a StatelessWidget

```dart
    // setting 10% of weight for the first child
    MultiSplitView multiSplitView = MultiSplitView(
        children: [child1, child2, child3], initialWeights: [0.1]);
```

#### Using in a StatefulWidget

```dart
  MultiSplitViewController _controller =
      MultiSplitViewController(weights: [0.1]);
```

```dart
    // setting 10% of weight for the first child
    MultiSplitView multiSplitView = MultiSplitView(
        children: [child1, child2, child3], controller: _controller);
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

## Widget as a custom divider

```dart
    MultiSplitView multiSplitView = MultiSplitView(
        children: [child1, child2, child3],
        dividerBuilder:
            (axis, index, resizable, dragging, highlighted, themeData) {
          return Container(
            color: dragging ? Colors.grey[300] : Colors.grey[100],
            child: Icon(
              Icons.drag_indicator,
              color: highlighted ? Colors.grey[600] : Colors.grey[400],
            ),
          );
        });

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(dividerThickness: 24));
```

![](https://caduandrade.github.io/multi_split_view/divider_custom_widget_v1.png)

## Divider painters

Allows customizing the divider through the `DividerPainter` class.

The `DividerPainters` factory class offers default painters.

### Divider - background color

The `DividerPainters.background` allows setting the background color. The default color is `NULL`.

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.background(color: Colors.black)));
```

![](https://caduandrade.github.io/multi_split_view/divider_color_v1.png)

### Divider - highlighted background color

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.background(
                color: Colors.grey[200], highlightedColor: Colors.grey[800])));
```

![](https://caduandrade.github.io/multi_split_view/highlighted_color_v1.gif)

### Dashed divider

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.dashed(
                color: Colors.deepOrange, highlightedColor: Colors.black)));
```

![](https://caduandrade.github.io/multi_split_view/dashed_divider_v1.gif)

#### Dashed divider - Customizations

```dart
    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.dashed(
                gap: 30, size: 20, thickness: 3, highlightedThickness: 6)));
```

![](https://caduandrade.github.io/multi_split_view/custom_dashed_divider_v1.png)

### Grooved divider 1

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved1(
                color: Colors.indigo[100]!,
                highlightedColor: Colors.indigo[900]!)));
```

![](https://caduandrade.github.io/multi_split_view/grooved_divider_1_v1.gif)

#### Grooved divider 1 - Customizations

```dart
    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved1(
                size: 5,
                highlightedSize: 30,
                thickness: 3,
                highlightedThickness: 6)));
```

![](https://caduandrade.github.io/multi_split_view/custom_grooved_divider_1_v1.png)

### Grooved divider 2

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved2(
                color: Colors.grey[400]!, highlightedColor: Colors.red)));
```

![](https://caduandrade.github.io/multi_split_view/grooved_divider_2_v1.gif)

#### Grooved divider 2 - Customizations

```dart
    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved2(
                gap: 15,
                thickness: 4,
                count: 3,
                highlightedCount: 9,
                strokeCap: StrokeCap.square)));
```

![](https://caduandrade.github.io/multi_split_view/custom_grooved_divider_2_v1.png)

### Divider - Custom painter

It is possible to extend the `DividerPainter` class to create a painter from scratch.

```dart
class MyDividerPainter extends DividerPainter {
  @override
  Map<int, Tween> buildTween() {
    Map<int, Tween> map = super.buildTween();
    // create your tween here, example:
    map[100] = Tween<double>(begin: 1, end: 5);
    return map;
  }

  @override
  void paint(
      {required Axis dividerAxis,
      required bool resizable,
      required bool highlighted,
      required Canvas canvas,
      required Size dividerSize,
      required Map<int, dynamic> animatedValues}) {
    super.paint(
        dividerAxis: dividerAxis,
        resizable: resizable,
        highlighted: highlighted,
        canvas: canvas,
        dividerSize: dividerSize,
        animatedValues: animatedValues);
    double myAnimatedValue = animatedValues[100];
    // ...
  }
}
```

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(dividerPainter: MyDividerPainter()));
```

## Support this project

### Bitcoin

[bc1qhqy84y45gya58gtfkvrvass38k4mcyqnav803h](https://www.blockchain.com/pt/btc/address/bc1qhqy84y45gya58gtfkvrvass38k4mcyqnav803h)

### Ethereum (ERC-20) or Binance Smart Chain (BEP-20)

[0x9eB815FD4c88A53322304143A9Aa8733D3369985](https://etherscan.io/address/0x9eb815fd4c88a53322304143a9aa8733d3369985)

### Helium

[13A2fDqoApT9VnoxFjHWcy8kPQgVFiVnzps32MRAdpTzvs3rq68](https://explorer.helium.com/accounts/13A2fDqoApT9VnoxFjHWcy8kPQgVFiVnzps32MRAdpTzvs3rq68)
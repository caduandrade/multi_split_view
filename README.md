[![](https://img.shields.io/pub/v/multi_split_view.svg)](https://pub.dev/packages/multi_split_view)
[![](https://img.shields.io/badge/demo-try%20it%20out-blue)](https://caduandrade.github.io/multi_split_view_demo/)
[![](https://img.shields.io/badge/Flutter-%E2%9D%A4-red)](https://flutter.dev/)
[![](https://img.shields.io/badge/%F0%9F%91%8D%20and%20%E2%AD%90-are%20free%20and%20motivate%20me-yellow)](#)

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
  * [Setting the initial weights](#setting-the-initial-weights)
  * [Changing the weights or sizes programmatically](#changing-the-weights-or-sizes-programmatically)
  * [Minimal child weight](#minimal-child-weight)
  * [Minimal child size in pixels](#minimal-child-size-in-pixels)
  * [Resizable](#resizable)
  * [Listener](#listener)
* Divider
  * [Thickness](#divider-thickness)
  * [Custom widget](#widget-as-a-custom-divider)
  * [Tap gestures](#divider-tap-gestures)
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

## Setting the initial weights

#### Using in a StatelessWidget

```dart
    // setting 10% of weight for the first child
    MultiSplitView multiSplitView = MultiSplitView(
        children: [child1, child2, child3], initialAreas: [Area(weight: 0.1)]);
```

#### Using in a StatefulWidget

```dart
  MultiSplitViewController _controller =
      MultiSplitViewController(areas: [Area(weight: 0.1)]);
```

or

```dart
  MultiSplitViewController _controller2 =
      MultiSplitViewController(areas: Area.weights([0.1]));
```

and

```dart
    // setting 10% of weight for the first child
    MultiSplitView multiSplitView = MultiSplitView(
        children: [child1, child2, child3], controller: _controller);
```

![](https://caduandrade.github.io/multi_split_view/horizontal_weight_v1.png)

## Changing the weights or sizes programmatically

```dart
    _controller.areas = [Area(size: 150)];
```

## Minimal child weight

```dart
  MultiSplitViewController _controller =
      MultiSplitViewController(areas: [Area(minimalWeight: .25), Area(minimalWeight: .25)]);
```

## Minimal child size in pixels

```dart
  final MultiSplitViewController _controller =
      MultiSplitViewController(areas: [Area(minimalSize: 150)]);
```

## Resizable

```dart
    MultiSplitView(children: [child1, child2, child3], resizable: false);
```

## Listener

```dart
    MultiSplitView(
        children: [child1, child2, child3, child4],
        onWeightChange: () =>
            DemoFlu.printOnConsole(context, 'Weight has changed'));
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

## Divider tap gestures

```dart
    MultiSplitView multiSplitView = MultiSplitView(
        children: [...],
        onDividerTap: (dividerIndex) => {},
        onDividerDoubleTap: (dividerIndex) => {});
```

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
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.dashed(
                color: Colors.deepOrange, highlightedColor: Colors.black)),
        child: multiSplitView);
```

![](https://caduandrade.github.io/multi_split_view/dashed_divider_v1.gif)

#### Dashed divider - Customizations

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.dashed(
                gap: 30, size: 20, thickness: 3, highlightedThickness: 6)),
        child: multiSplitView);
```

![](https://caduandrade.github.io/multi_split_view/custom_dashed_divider_v1.png)

### Grooved divider 1

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved1(
                color: Colors.indigo[100]!,
                highlightedColor: Colors.indigo[900]!)),
        child: multiSplitView);
```

![](https://caduandrade.github.io/multi_split_view/grooved_divider_1_v1.gif)

#### Grooved divider 1 - Customizations

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved1(
                size: 5,
                highlightedSize: 30,
                thickness: 3,
                highlightedThickness: 6)),
        child: multiSplitView);
```

![](https://caduandrade.github.io/multi_split_view/custom_grooved_divider_1_v1.png)

### Grooved divider 2

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved2(
                color: Colors.grey[400]!, highlightedColor: Colors.red)),
        child: multiSplitView);
```

![](https://caduandrade.github.io/multi_split_view/grooved_divider_2_v1.gif)

#### Grooved divider 2 - Customizations

```dart
    MultiSplitView multiSplitView = MultiSplitView(children: [child1, child2]);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved2(
                gap: 15,
                thickness: 4,
                count: 3,
                highlightedCount: 9,
                strokeCap: StrokeCap.square)),
        child: multiSplitView);
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

### Solana

[7vp45LoQXtLYFXXKx8wQGnzYmhcnKo1TmfqUgMX45Ad8](https://explorer.solana.com/address/7vp45LoQXtLYFXXKx8wQGnzYmhcnKo1TmfqUgMX45Ad8)

### Helium

[13A2fDqoApT9VnoxFjHWcy8kPQgVFiVnzps32MRAdpTzvs3rq68](https://explorer.helium.com/accounts/13A2fDqoApT9VnoxFjHWcy8kPQgVFiVnzps32MRAdpTzvs3rq68)
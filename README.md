# multi_split_view

A widget to provides horizontal or vertical multiple split view for Flutter.
![animated](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/animated.gif)
* Horizontal or vertical
* Configurable weights for children
* Automatic calculation of weights for:
  * Child added without defined weight
  * Weight redistribution when a child is removed.
* Listener to detect children size changes

## Examples

**Horizontal**

![horizontal](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/horizontal.png)

```
    MultiSplitView.horizontal(children: [child1, child2, child3]);
```

**Horizontal - setting the weight**

![horizontalweight](https://raw.githubusercontent.com/caduandrade/multi_split_view_images/main/horizontal_weight.png)

```
    // setting 10% of weight for the first child
    MultiSplitView.horizontal(
        children: [child1, child2, child3],
        controller: MultiSplitViewController(weights: [0.1]));
```

**Listener**

```
    MultiSplitView.horizontal(
        children: [child1, child2],
        onSizeChange: (childIndex1, childIndex2) => print(
            'Index of children who changed size: $childIndex1 and $childIndex2'));
```

## TODO

* More examples
* NullSafety
* Documentation
* Test
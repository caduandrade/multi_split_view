## 3.6.0

* `Area`
  * Allow changing size, flex, min and max values.

## 3.5.0

* Bugfix
  * The `Area.copyWith` method does not allow nulling values. The API has been changed to support this.

## 3.4.0

* `MultiSplitView`
  * Added `areaClipBehavior` to control area clipping.

## 3.3.0

* `Area`
  * Added `copyWith` method.
* `MultiSplitView`
  * Added `onDividerDragStart` and `onDividerDragEnd` callbacks.
* `MultiSplitViewThemeData`
  * Allows divider without thickness.
  * Allows increasing the handle area around the divider.

## 3.2.2

* Bugfix: The divider does not move when the widget's size includes a tiny fractional value.

## 3.2.1

* Bugfix: `MultiSplitViewController` throwing error when being built or modified to have no areas.

## 3.2.0

* `Area`
  * Adding `id` to be used as an internal Key and facilitating reconfiguration of the layout while maintaining the state of the widgets.
* Avoiding rebuilding areas when hovering over the divider.

## 3.1.0

* `Area`
  * The `widget` attribute has been removed. Developers may have encountered unintended behavior when using `widget` as it retained the last context, resulting in unexpected fixed states. Going forward, only the `builder` attribute will be available, ensuring dynamic updates based on the current context.
  * The `builder` function was replaced by `AreaWidgetBuilder`, thus receiving the area as an extra argument. 
  * New attribute: `index`
* `AreaWidgetBuilder`
  * The argument `index` has been removed.

## 3.0.2

Bugfix: Other Widgets visually behind are not receiving mouse events.

## 3.0.1

Bugfix: Stretching to recover the minimum size when space is available.

## 3.0.0

* `Area`
  * The algorithm has been changed to use `flex` factor instead of `weight`.
  * The `minimalWeight` and `minimalSize` attributes has been replaced by `min`.
  * The `hasMinimal` attribute has been removed.
  * New attribute: `max`.
* `Theme`
  * The `dividerThickness` now can be zero.
* `OnWeightChange` has been replaced by `OnDividerDragUpdate`
* `MultiSplitViewController`
  * The `areasLength` attribute has been renamed to `areasCount`
* `MultiSplitView`
  * Width and height configuration to be used in an unbounded situation.
* Setting the widget directly in the area or through builders.
* Bugfix
  * Area using the child widget key.

## 2.4.0

* `Area`
  * Replacing the factory constructor with a default constructor.
  * The `copyWithNewWeight` method has been removed.
* `MultiSplitViewController`
  * Keeping the reference to the areas received by the constructor parameter. A new instance of `Area` will no longer be built when resizing the layout. 
  * The `setAreaAt` method has been removed.

## 2.3.1

* Bugfix
  * The anti-aliasing bug workaround is clipping a pixel.

## 2.3.0

* The standard divider widget (`DividerWidget`) has been exported to the public API.
* Behavior change
  * Canceling the divider drag after using the `areas` setter in the `MultiSplitViewController`.
* Bugfix
  * Divider animation not starting when touching it on mobile.

## 2.2.0

* Divider
  * Tap gestures. 

## 2.1.0

* `OnSizeChange` renamed to `OnWeightChange`.
  * Removing `childIndex1` and `childIndex2` parameters. 
* Bugfix
  * Window resizing allowing area with a size smaller than the `minimalSize`.
  * `OnWeightChange` is not getting notified on window resizing.
* Fixing the README example.

## 2.0.1

* Bugfix
  * State is not being preserved when children are added/removed.

## 2.0.0

* `MultiSplitViewController`
  * `sizes`, `weights`, `minimalSizes` and `minimalWeights` has been replaced by `areas`.
  * `globalMinimalWeight` has been removed.
  * `globalMinimalSize` has been removed.
* `Area`
  * Defines each child area in the `MultiSplitView`.
  * Allow configure `size`, `weight`, `minimalWeight` and `minimalSize`.
  * Allow simultaneous use of `size` and `weight` (in different areas).
  * Allow empty `weight` or `size` (zero).
* Bugfix
  * Children without clip.

## 1.13.0

* `MultiSplitView`
  * `minimalWeight` renamed to `globalMinimalWeight`
  * `minimalSize` renamed to `globalMinimalSize`
  * `minimalWeights` has been added to set individual child minimal weights.
  * `minimalSizes` has been added to set individual child minimal sizes.

## 1.12.0

* `MultiSplitViewController`
  * Removing the internal `setWeight` method.
  * Adding Setter to the `weights`.

## 1.11.0+1

* Updating the README

## 1.11.0

* Widget as a custom divider
* Workaround for Flutter's anti-aliasing issue as https://github.com/flutter/flutter/issues/14288

## 1.10.0+1

* Updating the README

## 1.10.0

* The `initialWeights` parameter has been moved to `MultiSplitView`
* Added `weights` parameter in the `MultiSplitViewController`

## 1.9.1

* Bugfix
  * Rebuild the theme by changing the `animationEnabled` parameter has no effect
  
## 1.9.0

* Facilitate the use of `MultiSplitView` in `StatelessWidget` in order to maintain the state of weights
  * The `weights` parameter of `MultiSplitViewController` has been changed to `initialWeights`
* Removal of unused `highlightedSize` parameter from `DividerPainters.dashed`
* Enforcing the `count` and `highlightedCount` parameters of `DividerPainters.grooved2` to be odd
  
## 1.8.0

* Default divider thickness value has been changed to 10
* Customizable divider painters

## 1.7.2

* Bugfix
  * Divider flickering when dragging
  * Ignoring the initial weights when their sum is less than 1
  * Error when initializing weights with a constant

## 1.7.1

* Bugfix/Enhancement
  * Prevent `MultiSplitViewController` sharing between `MultiSplitView` instances to avoid unstable state

## 1.7.0

* API changes
  * `MultiSplitViewTheme` has been added following the same pattern used by Flutter's Theme
  * Divider configurations has been moved to `MultiSplitViewThemeData`

## 1.6.0

* Adding the `key` parameter to the constructor

## 1.5.0+1

* Removing a print (how embarrassing)
* Moving the Demo project to another repository

## 1.5.0

* Painter for the highlighted divider (under the cursor)
* Bugfix
  * Insufficient space for widgets

## 1.4.0+1

* Online demo

## 1.4.0

* Option to disable resizing

## 1.3.0

* The default divider color has been changed to null (transparent)
* Customizable painter for the divider

## 1.2.1

* Bugfix
  * Divider color also sets the background color

## 1.2.0

* Allow setting minimum child size in pixels

## 1.1.0+2

* Fixing the README

## 1.1.0+1

* Fixing the README

## 1.1.0

* Replacing bool primitive with the Axis class

## 1.0.0

* Null safety

## 0.0.3

* `WeightController` renamed to `MultiSplitViewController`
* Adding content to the README

## 0.0.2

* Adding example

## 0.0.1

* Initial release

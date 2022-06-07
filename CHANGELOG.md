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

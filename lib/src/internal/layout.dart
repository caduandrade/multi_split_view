import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/area_interval.dart';
import 'package:multi_split_view/src/internal/num_util.dart';

@internal
class Layout {
  factory Layout(
      {required final int childrenCount,
      required final double containerSize,
      required final double dividerThickness}) {
    NumUtil.validateInt('childrenCount', childrenCount);
    NumUtil.validateDouble('dividerThickness', dividerThickness);
    NumUtil.validateDouble('containerSize', containerSize);
    final double totalDividerSize =
        childrenCount > 1 ? (childrenCount - 1) * dividerThickness : 0;
    final double availableSize = math.max(0, containerSize - totalDividerSize);
    return Layout._(
        childrenCount: childrenCount,
        containerSize: containerSize,
        dividerThickness: dividerThickness,
        totalDividerSize: totalDividerSize,
        availableSize: availableSize);
  }

  Layout._(
      {required int childrenCount,
      required double containerSize,
      required double dividerThickness,
      required double totalDividerSize,
      required double availableSize})
      : childrenCount = childrenCount,
        containerSize = containerSize,
        dividerThickness = dividerThickness,
        totalDividerSize = totalDividerSize,
        availableSize = availableSize;

  final int childrenCount;
  final double containerSize;
  final double dividerThickness;
  final double totalDividerSize;
  final double availableSize;

  final List<AreaInterval> areaIntervals = [];

  /// Applies the following adjustments:
  ///
  /// * Creates new areas to accommodate all child widgets.
  /// * Removes unused areas.
  /// * Transforms all areas into flex if they are all size valued.
  /// Nullifies min and max.
  /// * Change flex value to 1 if all areas are flex 0.
  void adjustAreas({required ControllerHelper controllerHelper}) {
    // Removes unused areas.
    if (controllerHelper.areas.length > childrenCount) {
      controllerHelper.areas
          .removeRange(childrenCount, controllerHelper.areas.length);
    }

    // Creates new areas to accommodate all child widgets.
    while (controllerHelper.areas.length < childrenCount) {
      controllerHelper.areas.add(Area());
    }

    int sizedCount = 0;
    int flexCount = 0;
    double sumFlex = 0;
    double lowestSize = double.maxFinite;
    for (Area area in controllerHelper.areas) {
      if (area.size != null) {
        sizedCount++;
        lowestSize = math.min(lowestSize, area.size!);
      } else {
        flexCount++;
        sumFlex += area.flex!;
      }
    }
    if (sizedCount == controllerHelper.areas.length) {
      // Transforms all areas into flex if they are all size valued.
      // Nullifies min and max.
      for (Area area in controllerHelper.areas) {
        AreaHelper.setFlex(
            area: area,
            flex: lowestSize > 0 ? area.size! / lowestSize : area.size,
            initialFlex: true);
        AreaHelper.setSize(area: area, size: null);
        AreaHelper.setMin(area: area, min: null);
        AreaHelper.setMax(area: area, max: null);
      }
    } else if (flexCount == controllerHelper.areas.length && sumFlex == 0) {
      // Change flex value to 1 if all areas are flex 0.
      for (Area area in controllerHelper.areas) {
        AreaHelper.setFlex(area: area, flex: 1, initialFlex: true);
      }
    }
  }

  void updateAreaIntervals({required ControllerHelper controllerHelper}) {
    areaIntervals.clear();
    double start = 0;

    final double availableFlexSize =
        _calculateAvailableFlexSize(controllerHelper);

    final double flexSum = controllerHelper.flexSum();

    final double pixelPerFlex = flexSum == 0 ? 0 : availableFlexSize / flexSum;

    for (int index = 0; index < controllerHelper.areas.length; index++) {
      Area area = controllerHelper.areas[index];

      AreaInterval areaInterval = AreaInterval();
      areaIntervals.add(areaInterval);

      areaInterval.startPos = start;
      if (area.flex != null) {
        if (area.min != null) {
          areaInterval.minSize = area.min! * pixelPerFlex;
        }
        if (area.max != null) {
          areaInterval.maxSize = area.max! * pixelPerFlex;
        }
        areaInterval.size = area.flex! * pixelPerFlex;
      } else {
        areaInterval.minSize = area.min;
        areaInterval.maxSize = area.max;
        areaInterval.size = area.size!;
      }

      start += areaInterval.size + dividerThickness;
    }
  }

  void iterate(
      {required MultiSplitViewController controller,
      required IteratorBuilder child,
      required IteratorBuilder divider}) {
    double childStart = 0, childEnd = 0, dividerStart = 0, dividerEnd = 0;
    for (int childIndex = 0; childIndex < childrenCount; childIndex++) {
      final AreaInterval interval = areaIntervals[childIndex];
      childEnd = containerSize - interval.size - childStart;
      child(childIndex, childStart, childEnd);
      if (childIndex < childrenCount - 1) {
        dividerStart = childStart + interval.size;
        if (dividerThickness > 0) {
          dividerEnd = childEnd - dividerThickness;
          divider(childIndex, dividerStart, dividerEnd);
        }
        childStart = dividerStart + dividerThickness;
      }
    }
  }

  double _calculateAvailableFlexSize(ControllerHelper controllerHelper) {
    double size = availableSize;
    for (Area area in controllerHelper.areas) {
      if (area.size != null) {
        size -= area.size!;
      }
    }
    return math.max(size, 0);
  }

  double moveDivider(
      {required ControllerHelper controllerHelper,
      required int dividerIndex,
      required double pixels,
      required bool pushDividers}) {
    if (pixels == 0) {
      return 0;
    }

    double rest;
    if (pixels < 0) {
      rest = _resizeAreas(
              pixelsToMove: pixels.abs(),
              direction: -1,
              controllerHelper: controllerHelper,
              shrinkAreaIndex: dividerIndex,
              growAreaIndex: dividerIndex + 1,
              pushDividers: pushDividers) *
          -1;
    } else {
      rest = _resizeAreas(
          pixelsToMove: pixels,
          direction: 1,
          controllerHelper: controllerHelper,
          shrinkAreaIndex: dividerIndex + 1,
          growAreaIndex: dividerIndex,
          pushDividers: pushDividers);
    }
    _updateAreas(controllerHelper: controllerHelper);
    return rest;
  }

  double _resizeAreas(
      {required double pixelsToMove,
      required int direction,
      required ControllerHelper controllerHelper,
      required int shrinkAreaIndex,
      required int growAreaIndex,
      required bool pushDividers}) {
    AreaInterval shrinkAreaIntervals = areaIntervals[shrinkAreaIndex];
    AreaInterval growAreaIntervals = areaIntervals[growAreaIndex];

    double movedPixels = pixelsToMove;

    movedPixels =
        math.min(shrinkAreaIntervals.availableSizeToShrink, movedPixels);
    if (growAreaIntervals.maxSize != null) {
      movedPixels =
          math.min(growAreaIntervals.availableSizeToGrow, movedPixels);
    }
    movedPixels = NumUtil.fix('movedPixels', movedPixels);

    shrinkAreaIntervals.size = shrinkAreaIntervals.size - movedPixels;
    growAreaIntervals.size = growAreaIntervals.size + movedPixels;

    double rest = pixelsToMove - movedPixels;

    double start = 0;
    for (AreaInterval areaInterval in areaIntervals) {
      areaInterval.startPos = start;
      start += areaInterval.size + dividerThickness;
    }

    shrinkAreaIndex += direction;
    if (pushDividers &&
        shrinkAreaIndex >= 0 &&
        shrinkAreaIndex < areaIntervals.length) {
      return _resizeAreas(
          pixelsToMove: rest,
          direction: direction,
          controllerHelper: controllerHelper,
          shrinkAreaIndex: shrinkAreaIndex,
          growAreaIndex: growAreaIndex,
          pushDividers: pushDividers);
    }
    return rest;
  }

  void _updateAreas({required ControllerHelper controllerHelper}) {
    for (int index = 0; index < areaIntervals.length; index++) {
      AreaInterval areaInterval = areaIntervals[index];
      Area area = controllerHelper.areas[index];
      if (area.size != null) {
        AreaHelper.setSize(area: area, size: areaInterval.size);
      }
    }

    final double availableFlexSize =
        _calculateAvailableFlexSize(controllerHelper);

    // amount of flex for each pixel
    final double flexPerPixel = availableFlexSize == 0
        ? 0
        : controllerHelper.flexSum() / availableFlexSize;

    for (int index = 0; index < areaIntervals.length; index++) {
      AreaInterval areaInterval = areaIntervals[index];
      Area area = controllerHelper.areas[index];
      if (area.flex != null) {
        AreaHelper.setFlex(area: area, flex: areaInterval.size * flexPerPixel);
      }
    }
  }
}

typedef IteratorBuilder = void Function(int index, double start, double end);

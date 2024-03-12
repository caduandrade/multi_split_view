import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/area_interval.dart';
import 'package:multi_split_view/src/internal/argument_validator.dart';

@internal
class Layout {
  factory Layout(
      {required final int childrenCount,
      required final double containerSize,
      required final double dividerThickness}) {
    ArgumentValidator.validateInt('childrenCount', childrenCount);
    ArgumentValidator.validateDouble('dividerThickness', dividerThickness);
    ArgumentValidator.validateDouble('containerSize', containerSize);
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
            flex: lowestSize > 0 ? area.size! / lowestSize : area.size);
        AreaHelper.setSize(area: area, size: null);
        AreaHelper.setMin(area: area, min: null);
        AreaHelper.setMax(area: area, max: null);
      }
    } else if (flexCount == controllerHelper.areas.length && sumFlex == 0) {
      // Change flex value to 1 if all areas are flex 0.
      for (Area area in controllerHelper.areas) {
        AreaHelper.setFlex(area: area, flex: 1);
      }
    }
  }

  double sumFlex(ControllerHelper controllerHelper) {
    double sum = 0;
    for (Area area in controllerHelper.areas) {
      if (area.flex != null) {
        sum += area.flex!;
      }
    }
    return sum;
  }

  void updateAreaIntervals({required ControllerHelper controllerHelper}) {
    areaIntervals.clear();
    double start = 0;

    final double availableFlexSize =
        _calculateAvailableFlexSize(controllerHelper);

    final double pixelPerFlex = availableFlexSize / sumFlex(controllerHelper);

    for (int index = 0; index < controllerHelper.areas.length; index++) {
      Area area = controllerHelper.areas[index];

      AreaInterval areaInterval = AreaInterval();
      areaIntervals.add(areaInterval);

      areaInterval.start = start;
      if (area.flex != null) {
        if (area.min != null) {
          areaInterval.minSize = area.min! * pixelPerFlex;
        }
        if (area.max != null) {
          areaInterval.maxSize = area.max! * pixelPerFlex;
        }
        areaInterval.size = area.flex! * pixelPerFlex;
      } else {
        if (area.min != null) {
          areaInterval.minSize = area.min!;
        }
        if (area.max != null) {
          areaInterval.maxSize = area.max!;
        }
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

  bool moveDivider(
      {required ControllerHelper controllerHelper,
      required int dividerIndex,
      required double pixels}) {
    if (pixels == 0) {
      return false;
    }

    AreaInterval area1Intervals = areaIntervals[dividerIndex];
    AreaInterval area2Intervals = areaIntervals[dividerIndex + 1];

    double movedPixels = pixels;

    if (pixels < 0) {
      // negative: area1 shrinking
      final double candidateArea1Size = area1Intervals.size + movedPixels;
      if (candidateArea1Size < 0) {
        // shrinking over limit, removing excess
        movedPixels -= candidateArea1Size;
      }
    } else {
      // positive: area2 shrinking
      final double candidateArea2Size = area2Intervals.size - movedPixels;
      if (candidateArea2Size < 0) {
        // shrinking over limit, removing excess
        movedPixels += candidateArea2Size;
      }
    }

    area1Intervals.size = area1Intervals.size + movedPixels;
    area2Intervals.size = area2Intervals.size - movedPixels;

    double start = 0;
    for (AreaInterval areaInterval in areaIntervals) {
      areaInterval.start = start;
      start += areaInterval.size + dividerThickness;
    }

    final double availableFlexSize =
        _calculateAvailableFlexSize(controllerHelper);

    // amount of flex for each pixel
    final double flexPerPixel = availableFlexSize == 0
        ? 0
        : sumFlex(controllerHelper) / availableFlexSize;

    Area area1 = controllerHelper.areas[dividerIndex];
    if (area1.flex != null) {
      AreaHelper.setFlex(
          area: area1, flex: area1.flex! + movedPixels * flexPerPixel);
    } else {
      AreaHelper.setSize(area: area1, size: area1.size! + movedPixels);
    }
    Area area2 = controllerHelper.areas[dividerIndex + 1];
    if (area2.flex != null) {
      AreaHelper.setFlex(
          area: area2, flex: area2.flex! - movedPixels * flexPerPixel);
    } else {
      AreaHelper.setSize(area: area2, size: area2.size! - movedPixels);
    }

    if (area1Intervals.size == 0 || area2Intervals.size == 0) {
      return false;
    }
    return true;
  }
}

typedef IteratorBuilder = void Function(int index, double start, double end);

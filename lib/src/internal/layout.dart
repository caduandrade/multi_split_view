import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/area_constraints.dart';
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

  final List<AreaConstraints> areaConstraintsList = [];
  final List<DividerConstraints> dividers = [];

  /// Applies the following adjustments:
  ///
  /// * Creates new areas to accommodate all child widgets.
  /// * Removes unused areas.
  /// * Transforms all areas into flex if they are all size valued.
  /// Nullifies min and max.
  /// * Change flex value to 1 if all areas are flex 0.
  void adjustAreas({required MultiSplitViewController controller}) {
    ControllerHelper controllerHelper = ControllerHelper(controller);
    if (controllerHelper.areas.length > childrenCount) {
      controllerHelper.areas
          .removeRange(childrenCount, controllerHelper.areas.length);
    }
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
      for (Area area in controllerHelper.areas) {
        AreaHelper.setFlex(
            area: area,
            flex: lowestSize > 0 ? area.size! / lowestSize : area.size);
        AreaHelper.setSize(area: area, size: null);
        AreaHelper.setMin(area: area, min: null);
        AreaHelper.setMax(area: area, max: null);
      }
    } else if (flexCount == controllerHelper.areas.length && sumFlex == 0) {
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

  void updateAreaConstraints({required MultiSplitViewController controller}) {
    ControllerHelper controllerHelper = ControllerHelper(controller);
    dividers.clear();
    areaConstraintsList.clear();
    double start = 0;

    final double pixelPerFlex = availableSize / sumFlex(controllerHelper);

    for (int areaIndex = 0;
        areaIndex < controllerHelper.areas.length;
        areaIndex++) {
      Area area = controllerHelper.areas[areaIndex];

      AreaConstraints areaConstraints = AreaConstraints();
      areaConstraintsList.add(areaConstraints);

      areaConstraints.start = start;
      if (area.flex != null) {
        areaConstraints.size = area.flex! * pixelPerFlex;
      }

      start += areaConstraints.size;

      if (areaIndex < controllerHelper.areas.length - 1) {
        DividerConstraints dividerConstraints = DividerConstraints();
        dividerConstraints.start = start;
        dividerConstraints.size = dividerThickness;
        dividers.add(dividerConstraints);
      }

      start += dividerThickness;
    }
  }

  void iterate(
      {required MultiSplitViewController controller,
      required IteratorBuilder child,
      required IteratorBuilder divider}) {
    double childStart = 0, childEnd = 0, dividerStart = 0, dividerEnd = 0;
    for (int childIndex = 0; childIndex < childrenCount; childIndex++) {
      final AreaConstraints constraints = areaConstraintsList[childIndex];
      childEnd = containerSize - constraints.size - childStart;
      child(childIndex, childStart, childEnd);
      if (childIndex < childrenCount - 1) {
        dividerStart = childStart + constraints.size;
        dividerEnd = childEnd - dividerThickness;
        divider(childIndex, dividerStart, dividerEnd);
        childStart = dividerStart + dividerThickness;
      }
    }
  }

  bool moveDivider(
      {required MultiSplitViewController controller,
      required int dividerIndex,
      required double pixels}) {
    if (pixels == 0) {
      return false;
    }

    ControllerHelper controllerHelper = ControllerHelper(controller);

    Area area1 = controller.areas[dividerIndex];
    Area area2 = controller.areas[dividerIndex + 1];

    // amount of flex for each pixel
    final double flexPerPixel =
        availableSize == 0 ? 0 : sumFlex(controllerHelper) / availableSize;

    // amount of flex equivalent to the pixels covered by dragging the divider
    double movedFlex = pixels * flexPerPixel;

    if (pixels < 0) {
      // negative: area1 shrinking
      final double totalShrinkage = area1.flex! + movedFlex;
      if (totalShrinkage < 0) {
        // shrinking over limit, removing excess
        movedFlex -= totalShrinkage;
      }
    } else {
      // positive: area2 growing
      final double totalGrowth = area2.flex! - movedFlex;
      if (totalGrowth < 0) {
        // growth over limit, removing excess
        movedFlex += totalGrowth;
      }
    }

    AreaHelper.setFlex(area: area1, flex: area1.flex! + movedFlex);
    AreaHelper.setFlex(area: area2, flex: area2.flex! - movedFlex);

    if (area1.flex == 0 || area2.flex == 0) {
      return false;
    }
    return true;
  }
}

class DividerConstraints {
  double start = 0;
  double size = 0;

  double get end => start + size;
}

typedef IteratorBuilder = void Function(int index, double start, double end);

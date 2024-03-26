import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/area_screen_constraints.dart';
import 'package:multi_split_view/src/internal/num_util.dart';
import 'package:multi_split_view/src/policies.dart';

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
    final double availableSpace = math.max(0, containerSize - totalDividerSize);
    return Layout._(
        childrenCount: childrenCount,
        containerSize: containerSize,
        dividerThickness: dividerThickness,
        totalDividerSize: totalDividerSize,
        availableSpace: availableSpace);
  }

  Layout._(
      {required int childrenCount,
      required double containerSize,
      required double dividerThickness,
      required double totalDividerSize,
      required double availableSpace})
      : childrenCount = childrenCount,
        containerSize = containerSize,
        dividerThickness = dividerThickness,
        totalDividerSize = totalDividerSize,
        availableSpace = availableSpace;

  final int childrenCount;
  final double containerSize;
  final double dividerThickness;
  final double totalDividerSize;

  /// Container size without dividers.
  final double availableSpace;

  final ShrinkPolicy shrinkPolicy = ShrinkPolicy.right;
  final GrowPolicy growPolicy = GrowPolicy.last;

  /// Applies the following adjustments:
  ///
  /// * Removes unused areas.
  /// * Creates new areas to accommodate all child widgets.
  /// * Shrinks size when the total size of the areas is greater than
  /// the available space.
  /// * Grows size when the total size of the areas is smaller than the
  /// available space and there are no flex areas to fill the available space.
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

    int flexCount = 0;
    double sumFlex = 0;
    double sumSize = 0;
    double lowestSize = double.maxFinite;
    for (Area area in controllerHelper.areas) {
      if (area.size != null) {
        sumSize += area.size!;
        lowestSize = math.min(lowestSize, area.size!);
      } else {
        flexCount++;
        sumFlex += area.flex!;
      }
    }
    double availableSpace = this.availableSpace;

    if (sumSize > availableSpace) {
      //TODO min e max?
      // The total size of the areas is greater than the available space.
      // Need to shrink.
      Iterable<Area> it = shrinkPolicy == ShrinkPolicy.left
          ? controllerHelper.areas
          : controllerHelper.areas.reversed;
      for (Area area in it) {
        if (sumSize <= availableSpace) {
          break;
        } else if (area.size != null) {
          double excessToRemove =
              math.min(area.size!, sumSize - availableSpace);
          AreaHelper.setSize(area: area, size: area.size! - excessToRemove);
          sumSize -= excessToRemove;
        }
      }
    } else if (sumSize < availableSpace && flexCount == 0) {
      //TODO min e max?
      // The total size of the areas is smaller than the available space and
      // there are no flex areas to fill the available space.
      // Need to grow.
      if (growPolicy == GrowPolicy.first) {
        Area area = controllerHelper.areas.last;
        AreaHelper.setSize(
            area: area, size: area.size! + availableSpace - sumSize);
      } else if (growPolicy == GrowPolicy.last) {
        Area area = controllerHelper.areas.last;
        AreaHelper.setSize(
            area: area, size: area.size! + availableSpace - sumSize);
      } else if (growPolicy == GrowPolicy.all) {
        double extraSize =
            (availableSpace - sumSize) / controllerHelper.areas.length;
        for (Area area in controllerHelper.areas) {
          AreaHelper.setSize(area: area, size: extraSize);
        }
      } else {
        StateError('Unknown GrowPolicy: $growPolicy');
      }
    }
  }

  void updateScreenConstraints({required ControllerHelper controllerHelper}) {
    double start = 0;

    final double availableSizeForFlexAreas =
        _calculateAvailableSizeForFlexAreas(controllerHelper);
    final double totalFlex = controllerHelper.totalFlex();
    final double pixelPerFlex = availableSizeForFlexAreas / totalFlex;

    for (int index = 0; index < controllerHelper.areas.length; index++) {
      Area area = controllerHelper.areas[index];

      final AreaScreenConstraints screenConstraints =
          AreaHelper.screenConstraintsOf(area);
      screenConstraints.reset();

      screenConstraints.startPos = start;
      if (area.flex != null) {
        if (area.min != null) {
          screenConstraints.minSize = area.min! * pixelPerFlex;
        }
        if (area.max != null) {
          screenConstraints.maxSize = area.max! * pixelPerFlex;
        }
        screenConstraints.size = area.flex! * pixelPerFlex;
      } else {
        screenConstraints.minSize = area.min;
        screenConstraints.maxSize = area.max;
        screenConstraints.size = area.size!;
      }

      start += screenConstraints.size + dividerThickness;
    }
  }

  void iterate(
      {required MultiSplitViewController controller,
      required IteratorBuilder child,
      required IteratorBuilder divider}) {
    double childStart = 0, childEnd = 0, dividerStart = 0, dividerEnd = 0;
    for (int childIndex = 0; childIndex < childrenCount; childIndex++) {
      final Area area = controller.getArea(childIndex);
      final AreaScreenConstraints screenConstraints =
          AreaHelper.screenConstraintsOf(area);
      childEnd = containerSize - screenConstraints.size - childStart;
      child(childIndex, childStart, childEnd);
      if (childIndex < childrenCount - 1) {
        dividerStart = childStart + screenConstraints.size;
        if (dividerThickness > 0) {
          dividerEnd = childEnd - dividerThickness;
          divider(childIndex, dividerStart, dividerEnd);
        }
        childStart = dividerStart + dividerThickness;
      }
    }
  }

  double _calculateAvailableSizeForFlexAreas(
      ControllerHelper controllerHelper) {
    double size = availableSpace;
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
    //_updateAreas(controllerHelper: controllerHelper);
    return rest;
  }

  double _resizeAreas(
      {required double pixelsToMove,
      required int direction,
      required ControllerHelper controllerHelper,
      required int shrinkAreaIndex,
      required int growAreaIndex,
      required bool pushDividers}) {
    Area shrinkArea = controllerHelper.areas[shrinkAreaIndex];
    AreaScreenConstraints shrinkAreaConstraints =
        AreaHelper.screenConstraintsOf(shrinkArea);

    Area growArea = controllerHelper.areas[growAreaIndex];
    AreaScreenConstraints growAreaConstraints =
        AreaHelper.screenConstraintsOf(growArea);

    final double availableSizeForFlexAreas =
        _calculateAvailableSizeForFlexAreas(controllerHelper);
    final double totalFlex = controllerHelper.totalFlex();
    final double pixelPerFlex = availableSizeForFlexAreas / totalFlex;
    final double flexPerPixels = availableSizeForFlexAreas == 0
        ? 0
        : totalFlex / availableSizeForFlexAreas;

    double movedPixels = pixelsToMove;

    final bool bothFlex = shrinkArea.flex != null && growArea.flex != null;

    if (bothFlex) {
      // both flex
      movedPixels =
          math.min(shrinkAreaConstraints.availableSizeToShrink, movedPixels);
      final double? availablePixelsToMax =
          growAreaConstraints.availableSizeToMax;
      if (availablePixelsToMax != null) {
        movedPixels = math.min(availablePixelsToMax, movedPixels);
      }
    } else {
      if (shrinkArea.size != null) {
        movedPixels =
            math.min(shrinkAreaConstraints.availableSizeToShrink, movedPixels);
      }
      if (growArea.size != null) {
        final double? availablePixelsToMax =
            growAreaConstraints.availableSizeToMax;

        if (availablePixelsToMax != null) {
          movedPixels = math.min(availablePixelsToMax, movedPixels);
        }

        if (totalFlex > 0) {
          // avoid grow more then container
          movedPixels = math.min(shrinkAreaConstraints.size, movedPixels);
        }
      }
    }

    movedPixels = NumUtil.fix('movedPixels', movedPixels);

    if (shrinkArea.size != null) {
      AreaHelper.setSize(
          area: shrinkArea, size: shrinkArea.size! - movedPixels);
    }
    if (growArea.size != null) {
      AreaHelper.setSize(area: growArea, size: growArea.size! + movedPixels);
    }
    if (bothFlex && shrinkArea.flex != null) {
      //TODO max 0?
      AreaHelper.setFlex(
          area: shrinkArea,
          flex: shrinkArea.flex! - (movedPixels * flexPerPixels));
    }
    if (bothFlex && growArea.flex != null) {
      AreaHelper.setFlex(
          area: growArea, flex: growArea.flex! + (movedPixels * flexPerPixels));
    }

    double rest = pixelsToMove - movedPixels;

    updateScreenConstraints(controllerHelper: controllerHelper);

    shrinkAreaIndex += direction;
    if (pushDividers &&
        shrinkAreaIndex >= 0 &&
        shrinkAreaIndex < controllerHelper.areas.length) {
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
}

typedef IteratorBuilder = void Function(int index, double start, double end);

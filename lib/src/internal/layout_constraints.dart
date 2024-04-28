import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/num_util.dart';
import 'package:multi_split_view/src/policies.dart';

/// Represents the layout constraints used by the [MultiSplitView].
@internal
class LayoutConstraints {
  factory LayoutConstraints(
      {required final int areasCount,
      required final double containerSize,
      required final double dividerThickness}) {
    NumUtil.validateInt('childrenCount', areasCount);
    NumUtil.validateDouble('dividerThickness', dividerThickness);
    NumUtil.validateDouble('containerSize', containerSize);
    final double totalDividerSize =
        areasCount > 1 ? (areasCount - 1) * dividerThickness : 0;
    final double availableSpace = math.max(0, containerSize - totalDividerSize);
    return LayoutConstraints._(
        areasCount: areasCount,
        containerSize: containerSize,
        dividerThickness: dividerThickness,
        totalDividerSize: totalDividerSize,
        availableSpace: availableSpace);
  }

  LayoutConstraints._(
      {required int areasCount,
      required double containerSize,
      required double dividerThickness,
      required double totalDividerSize,
      required double availableSpace})
      : areasCount = areasCount,
        containerSize = containerSize,
        dividerThickness = dividerThickness,
        totalDividerSize = totalDividerSize,
        availableSpace = availableSpace;

  /// The count of visible areas on the screen.
  final int areasCount;

  /// The container size.
  final double containerSize;

  /// The divider thickness defined by the theme.
  final double dividerThickness;

  /// The total size of all dividers.
  final double totalDividerSize;

  /// The size of the container minus the size of the dividers.
  final double availableSpace;

  /// Applies the following adjustments:
  ///
  /// * Shrinks size when the total size of the areas is greater than
  /// the available space, even if a [min] limit exists.
  /// * Grows size when the total size of the areas is smaller than the
  /// available space and there are no flex areas to fill the available
  /// space, even if a [max] limit exists.
  void adjustAreas(
      {required ControllerHelper controllerHelper,
      required SizeOverflowPolicy sizeOverflowPolicy,
      required SizeUnderflowPolicy sizeUnderflowPolicy}) {
    bool changed = false;

    int flexCount = 0;
    double totalSize = 0;
    double lowestSize = double.maxFinite;
    for (Area area in controllerHelper.areas) {
      if (area.size != null) {
        totalSize += area.size!;
        lowestSize = math.min(lowestSize, area.size!);
      } else {
        flexCount++;
      }
    }
    double availableSpace = this.availableSpace;

    if (totalSize > availableSpace) {
      // The total size of the areas is greater than the available space.
      // Need to shrink.
      Iterable<Area> it = sizeOverflowPolicy == SizeOverflowPolicy.shrinkFirst
          ? controllerHelper.areas
          : controllerHelper.areas.reversed;
      for (Area area in it) {
        if (totalSize <= availableSpace) {
          break;
        } else if (area.size != null) {
          double excessToRemove =
              math.min(area.size!, totalSize - availableSpace);
          AreaHelper.setSize(area: area, size: area.size! - excessToRemove);
          totalSize -= excessToRemove;
        }
      }
      changed = true;
    } else if (totalSize < availableSpace && flexCount == 0) {
      // The total size of the areas is smaller than the available space and
      // there are no flex areas to fill the available space.
      // Need to stretch.
      if (sizeUnderflowPolicy == SizeUnderflowPolicy.stretchFirst) {
        Area area = controllerHelper.areas.first;
        AreaHelper.setSize(
            area: area, size: area.size! + availableSpace - totalSize);
      } else if (sizeUnderflowPolicy == SizeUnderflowPolicy.stretchLast) {
        Area area = controllerHelper.areas.last;
        AreaHelper.setSize(
            area: area, size: area.size! + availableSpace - totalSize);
      } else if (sizeUnderflowPolicy == SizeUnderflowPolicy.stretchAll) {
        double extraSize =
            (availableSpace - totalSize) / controllerHelper.areas.length;
        for (Area area in controllerHelper.areas) {
          AreaHelper.setSize(area: area, size: area.size! + extraSize);
        }
      }
      changed = true;
    }
    if (changed) {
      controllerHelper.updateAreas();
      Future.microtask(() => controllerHelper.notifyListeners());
    }
  }

  double calculateAvailableSizeForFlexAreas(
      MultiSplitViewController controller) {
    double size = availableSpace;
    for (int index = 0; index < controller.areasCount; index++) {
      Area area = controller.getArea(index);
      if (area.size != null) {
        size -= area.size!;
      }
    }
    return math.max(size, 0);
  }
}

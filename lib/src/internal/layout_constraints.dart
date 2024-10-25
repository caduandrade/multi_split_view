import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/num_util.dart';

/// Represents the layout constraints used by the [MultiSplitView].
@internal
class LayoutConstraints {
  factory LayoutConstraints(
      {required final MultiSplitViewController controller,
      required final double containerSize,
      required final double dividerThickness,
      required final double dividerHandleBuffer}) {
    NumUtil.validateDouble('dividerThickness', dividerThickness);
    NumUtil.validateDouble('dividerHandleBuffer', dividerHandleBuffer);
    NumUtil.validateDouble('containerSize', containerSize);
    final double totalDividerSize = controller.areasCount > 1
        ? (controller.areasCount - 1) * dividerThickness
        : 0;
    final double spaceForAreas = math.max(0, containerSize - totalDividerSize);
    return LayoutConstraints._(
        containerSize: containerSize,
        dividerThickness: dividerThickness,
        dividerHandleBuffer: dividerHandleBuffer,
        totalDividerSize: totalDividerSize,
        spaceForAreas: NumUtil.fix('spaceForAreas', spaceForAreas));
  }

  LayoutConstraints._(
      {required double containerSize,
      required double dividerThickness,
      required double dividerHandleBuffer,
      required double totalDividerSize,
      required double spaceForAreas})
      : containerSize = containerSize,
        dividerThickness = dividerThickness,
        dividerHandleBuffer = dividerHandleBuffer,
        totalDividerSize = totalDividerSize,
        spaceForAreas = spaceForAreas;

  /// The container size.
  final double containerSize;

  /// The divider thickness defined by the theme.
  final double dividerThickness;

  /// The additional clickable area around the divider defined by the theme.
  final double dividerHandleBuffer;

  /// The total size of all dividers.
  final double totalDividerSize;

  /// The size of the container minus the size of the dividers.
  final double spaceForAreas;

  /// The count of areas configured as flex.
  double _flexCount = 0;

  double get flexCount => _flexCount;

  /// Represents the total, cumulative value of all individual flex factors.
  double _flexSum = 0;

  double get flexSum => _flexSum;

  /// Applies the following adjustments:
  ///
  /// * Changes the flex to 1 if the total flex of the areas is 0.
  /// * Shrinks size when the total size of the areas is greater than
  /// the available space, even if a [min] limit exists.
  /// * Grows size to meet the minimum value when space is available.
  /// * Grows size when the total size of the areas is smaller than the
  /// available space and there are no flex areas to fill the available
  /// space, even if a [max] limit exists.
  void adjustAreas(
      {required ControllerHelper controllerHelper,
      required SizeOverflowPolicy sizeOverflowPolicy,
      required SizeUnderflowPolicy sizeUnderflowPolicy,
      required MinSizeRecoveryPolicy minSizeRecoveryPolicy}) {
    if (controllerHelper.areas.isEmpty) {
      return;
    }

    _flexSum = 0;
    _flexCount = 0;

    bool changed = false;
    double totalSize = 0;
    List<Area> minSizeToRecover = [];
    for (Area area in controllerHelper.areas) {
      if (area.size != null) {
        totalSize += area.size!;
        if (area.min != null && area.size! < area.min!) {
          minSizeToRecover.add(area);
        }
      } else {
        _flexSum += area.flex!;
        _flexCount++;
      }
    }
    if (_flexCount > 0 && _flexSum == 0) {
      for (Area area in controllerHelper.areas) {
        if (area.flex != null) {
          AreaHelper.setMinWithoutNotify(area: area, min: null);
          AreaHelper.setMaxWithoutNotify(area: area, max: null);
          AreaHelper.setFlex(area: area, flex: 1);
        }
      }
      _flexSum = _flexCount;
    }
    if (totalSize > spaceForAreas) {
      // The total size of the areas is greater than the available space.
      // Need to shrink.
      Iterable<Area> it = sizeOverflowPolicy == SizeOverflowPolicy.shrinkFirst
          ? controllerHelper.areas
          : controllerHelper.areas.reversed;
      for (Area area in it) {
        if (totalSize <= spaceForAreas) {
          break;
        } else if (area.size != null) {
          double excessToRemove =
              math.min(area.size!, totalSize - spaceForAreas);
          AreaHelper.setSize(area: area, size: area.size! - excessToRemove);
          totalSize -= excessToRemove;
        }
      }

      changed = true;
    }
    if (totalSize < spaceForAreas && minSizeToRecover.isNotEmpty) {
      // Grows size to meet the minimum value when space is available.
      for (Area area
          in minSizeRecoveryPolicy == MinSizeRecoveryPolicy.firstToLast
              ? minSizeToRecover
              : minSizeToRecover.reversed) {
        double available = math.max(spaceForAreas - totalSize, 0);
        if (available == 0) {
          break;
        }
        double sizeToRecover = math.min(area.min! - area.size!, available);

        totalSize += sizeToRecover;
        AreaHelper.setSize(
            area: area, size: math.min(area.size! + sizeToRecover, area.min!));
        changed = true;
      }
    }
    if (totalSize < spaceForAreas && flexCount == 0) {
      // The total size of the areas is smaller than the available space and
      // there are no flex areas to fill the available space.
      // Need to stretch.
      if (sizeUnderflowPolicy == SizeUnderflowPolicy.stretchFirst) {
        Area area = controllerHelper.areas.first;
        AreaHelper.setSize(
            area: area, size: area.size! + spaceForAreas - totalSize);
      } else if (sizeUnderflowPolicy == SizeUnderflowPolicy.stretchLast) {
        Area area = controllerHelper.areas.last;
        AreaHelper.setSize(
            area: area, size: area.size! + spaceForAreas - totalSize);
      } else if (sizeUnderflowPolicy == SizeUnderflowPolicy.stretchAll) {
        double extraSize =
            (spaceForAreas - totalSize) / controllerHelper.areas.length;
        for (Area area in controllerHelper.areas) {
          AreaHelper.setSize(area: area, size: area.size! + extraSize);
        }
      }
      changed = true;
    }
    if (changed) {
      Future.microtask(() => controllerHelper.notifyListeners());
    }
  }

  double calculateAvailableSpaceForFlexAreas(
      MultiSplitViewController controller) {
    double space = spaceForAreas;
    for (int index = 0; index < controller.areasCount; index++) {
      Area area = controller.getArea(index);
      if (area.size != null) {
        space -= area.size!;
      }
    }
    return math.max(space, 0);
  }

  double dividerStartOf(
      {required int index,
      required MultiSplitViewController controller,
      required bool antiAliasingWorkaround}) {
    double dividerStart = double.infinity;
    var onDividerLayout = (
        {required int index,
        required double start,
        required double thickness}) {
      dividerStart = start;
    };
    performLayout(
        controller: controller,
        antiAliasingWorkaround: antiAliasingWorkaround,
        onDividerLayout: onDividerLayout,
        onlyOnIndex: index);
    if (dividerStart == double.infinity) {
      throw ArgumentError.value(index, 'index', 'Invalid index');
    }
    return dividerStart;
  }

  void performLayout(
      {required MultiSplitViewController controller,
      required bool antiAliasingWorkaround,
      OnLayout? onAreaLayout,
      OnLayout? onDividerLayout,
      int? onlyOnIndex}) {
    double start = 0;

    final double availableSpaceForFlexAreas =
        calculateAvailableSpaceForFlexAreas(controller);

    final double pixelPerFlex = availableSpaceForFlexAreas / flexSum;

    for (int index = 0; index < controller.areasCount; index++) {
      Area area = controller.getArea(index);

      double thickness;
      if (area.flex != null) {
        thickness = area.flex! * pixelPerFlex;
      } else {
        thickness = area.size!;
      }
      if (antiAliasingWorkaround) {
        thickness = thickness.roundToDouble();
      }

      if (onAreaLayout != null &&
          (onlyOnIndex == null || onlyOnIndex == index)) {
        onAreaLayout(index: index, start: start, thickness: thickness);
      }
      start += thickness;
      if (index < controller.areasCount - 1) {
        if (onDividerLayout != null &&
            (onlyOnIndex == null || onlyOnIndex == index)) {
          onDividerLayout(
              index: index,
              start: start - dividerHandleBuffer,
              thickness: dividerThickness + (2 * dividerHandleBuffer));
        }
        start += dividerThickness;
      }
    }
  }
}

typedef OnLayout = void Function(
    {required int index, required double start, required double thickness});

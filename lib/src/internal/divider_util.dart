import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/internal/layout_constraints.dart';
import 'package:multi_split_view/src/internal/num_util.dart';

/// Represents divider util used by the [MultiSplitView].
@internal
class DividerUtil {
  static double move(
      {required MultiSplitViewController controller,
      required LayoutConstraints layoutConstraints,
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
              controller: controller,
              layoutConstraints: layoutConstraints,
              shrinkAreaIndex: dividerIndex,
              growAreaIndex: dividerIndex + 1,
              pushDividers: pushDividers) *
          -1;
    } else {
      rest = _resizeAreas(
          pixelsToMove: pixels,
          direction: 1,
          controller: controller,
          layoutConstraints: layoutConstraints,
          shrinkAreaIndex: dividerIndex + 1,
          growAreaIndex: dividerIndex,
          pushDividers: pushDividers);
    }
    return rest;
  }

  static double _resizeAreas(
      {required double pixelsToMove,
      required int direction,
      required MultiSplitViewController controller,
      required LayoutConstraints layoutConstraints,
      required int shrinkAreaIndex,
      required int growAreaIndex,
      required bool pushDividers}) {
    Area shrinkArea = controller.getArea(shrinkAreaIndex);

    Area growArea = controller.getArea(growAreaIndex);

    final double availableSizeForFlexAreas =
        layoutConstraints.calculateAvailableSpaceForFlexAreas(controller);
    final double pixelsPerFlex =
        availableSizeForFlexAreas / layoutConstraints.flexSum;

    final double flexPerPixels = availableSizeForFlexAreas == 0
        ? 0
        : layoutConstraints.flexSum / availableSizeForFlexAreas;

    double movedPixels = pixelsToMove;

    final bool bothFlex = shrinkArea.flex != null && growArea.flex != null;

    if (bothFlex) {
      // both flex
      movedPixels = math.min(
          flexToAvailablePixelsToShrink(
              area: shrinkArea, pixelsPerFlex: pixelsPerFlex),
          movedPixels);

      final double? availablePixelsToMax = flexToAvailablePixelsToMax(
          area: growArea, pixelsPerFlex: pixelsPerFlex);
      if (availablePixelsToMax != null) {
        movedPixels = math.min(availablePixelsToMax, movedPixels);
      }
    } else {
      if (shrinkArea.size != null) {
        final double availablePixelsToShrink =
            sizeToAvailablePixelsToShrink(area: shrinkArea);
        movedPixels = math.min(availablePixelsToShrink, movedPixels);
      }
      if (growArea.size != null) {
        final double? availablePixelsToMax =
            sizeToAvailablePixelsToMax(area: growArea);

        if (availablePixelsToMax != null) {
          movedPixels = math.min(availablePixelsToMax, movedPixels);
        }

        if (layoutConstraints.flexSum > 0) {
          // avoid grow more then container
          final double shrinkAreaPixels =
              toPixels(area: shrinkArea, pixelsPerFlex: pixelsPerFlex);
          movedPixels = math.min(shrinkAreaPixels, movedPixels);
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
      AreaHelper.setFlex(
          area: shrinkArea,
          flex: shrinkArea.flex! - (movedPixels * flexPerPixels));
    }
    if (bothFlex && growArea.flex != null) {
      AreaHelper.setFlex(
          area: growArea, flex: growArea.flex! + (movedPixels * flexPerPixels));
    }

    double rest = pixelsToMove - movedPixels;

    shrinkAreaIndex += direction;
    if (pushDividers &&
        shrinkAreaIndex >= 0 &&
        shrinkAreaIndex < controller.areasCount) {
      return _resizeAreas(
          pixelsToMove: rest,
          direction: direction,
          controller: controller,
          layoutConstraints: layoutConstraints,
          shrinkAreaIndex: shrinkAreaIndex,
          growAreaIndex: growAreaIndex,
          pushDividers: pushDividers);
    }
    return rest;
  }

  static double flexToAvailablePixelsToShrink(
      {required Area area, required double pixelsPerFlex}) {
    final double size = area.flex! * pixelsPerFlex;
    final double? minSize =
        area.min != null ? (area.min! * pixelsPerFlex) : null;
    return math.max(size - (minSize ?? 0), 0);
  }

  static double sizeToAvailablePixelsToShrink({required Area area}) {
    return math.max(area.size! - (area.min != null ? area.min! : 0), 0);
  }

  static double? flexToAvailablePixelsToMax(
      {required Area area, required double pixelsPerFlex}) {
    if (area.max == null) {
      return null;
    }
    final double maxSize = area.max! * pixelsPerFlex;
    final double size = area.flex! * pixelsPerFlex;
    return math.max(maxSize - size, 0);
  }

  static double? sizeToAvailablePixelsToMax({required Area area}) {
    if (area.max == null) {
      return null;
    }
    return math.max(area.max! - area.size!, 0);
  }

  static double toPixels({required Area area, required double pixelsPerFlex}) {
    if (area.size != null) {
      return area.size!;
    }
    return area.flex! * pixelsPerFlex;
  }
}

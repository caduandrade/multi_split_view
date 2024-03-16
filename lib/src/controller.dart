import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:multi_split_view/src/area.dart';

/// Controller for [MultiSplitView].
///
/// It is not allowed to share this controller between [MultiSplitView]
/// instances.
class MultiSplitViewController extends ChangeNotifier {
  /// Creates an [MultiSplitViewController].
  ///
  /// The sum of the [weights] cannot exceed 1.
  factory MultiSplitViewController({List<Area>? areas}) {
    return MultiSplitViewController._(areas != null ? List.from(areas) : []);
  }

  MultiSplitViewController._(this._areas);

  List<Area> _areas;

  UnmodifiableListView<Area> get areas => UnmodifiableListView(_areas);

  Object _areasUpdateHash = Object();

  set areas(List<Area> areas) {
    _areas = List.from(areas);
    _areasUpdateHash = Object();
    notifyListeners();
  }

  int get areasLength => _areas.length;

  /// Gets the area of a given widget index.
  Area getArea(int index) {
    return _areas[index];
  }

  /// Stores the hashCode of the state to identify if a controller instance
  /// is being shared by multiple [MultiSplitView].
  int? _stateHashCode;

  void _forceNotifyListeners() {
    notifyListeners();
  }
}

@internal
class ControllerHelper {
  const ControllerHelper(this.controller);

  final MultiSplitViewController controller;

  List<Area> get areas => controller._areas;

  Object get areasUpdateHash => controller._areasUpdateHash;

  /// The sum of all flex values.
  double flexSum() {
    double sum = 0;
    for (Area area in areas) {
      if (area.flex != null) {
        sum += AreaHelper.getInitialFlex(area: area)!;
      }
    }
    return sum;
  }

  void notifyListeners() => controller._forceNotifyListeners();

  static int? getStateHashCode(MultiSplitViewController controller) {
    return controller._stateHashCode;
  }

  static void setStateHashCode(
      MultiSplitViewController controller, int? value) {
    controller._stateHashCode = value;
  }
}

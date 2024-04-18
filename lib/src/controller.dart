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
  /// Changes the flex to 1 if the total flex of the areas is 0.
  MultiSplitViewController(
      {List<Area>? areas, AreaDataModifier? areaDataModifier})
      : _areaDataModifier = areaDataModifier {
    if (areas != null) {
      _updateAreas(areas);
    }
  }

  List<Area> _areas = [];

  UnmodifiableListView<Area> get areas => UnmodifiableListView(_areas);

  /// Allows to automatically set a new value for the data attribute of the [Area].
  AreaDataModifier? _areaDataModifier;
  AreaDataModifier? get areaDataModifier => _areaDataModifier;
  set areaDataModifier(AreaDataModifier? modifier) {
    if (_areaDataModifier != modifier) {
      _areaDataModifier = modifier;
      _applyDataModifier();
    }
  }

  Object _areasUpdateHash = Object();

  double _flexCount = 0;
  double get flexCount => _flexCount;

  double _totalFlex = 0;
  double get totalFlex => _totalFlex;

  /// Applies the current data modifier.
  void _applyDataModifier() {
    if (_areaDataModifier != null) {
      for (int index = 0; index < _areas.length; index++) {
        Area area = _areas[index];
        area.data = _areaDataModifier!(area, index);
      }
    }
  }

  /// Updates the areas.
  /// Changes the flex to 1 if the total flex of the areas is 0.
  void _updateAreas(List<Area> areas) {
    _areas = List.from(areas);
    _areasUpdateHash = Object();

    _totalFlex = 0;
    _flexCount = 0;
    for (Area area in _areas) {
      if (area.flex != null) {
        _totalFlex += area.flex!;
        _flexCount++;
      }
    }

    if (_flexCount > 0 && _totalFlex == 0) {
      for (Area area in _areas) {
        if (area.flex != null) {
          AreaHelper.setFlex(area: area, flex: 1);
          AreaHelper.setMax(area: area, max: null);
          AreaHelper.setMin(area: area, min: null);
        }
      }
      _totalFlex = _flexCount;
    }
    _applyDataModifier();
  }

  /// Set the areas.
  /// Changes the flex to 1 if the total flex of the areas is 0.
  set areas(List<Area> areas) {
    _updateAreas(areas);
    notifyListeners();
  }

  int get areasCount => _areas.length;

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

/// Allows to automatically set a new value for the data attribute of the [Area].
typedef AreaDataModifier = dynamic Function(Area area, int index);

@internal
class ControllerHelper {
  const ControllerHelper(this.controller);

  final MultiSplitViewController controller;

  List<Area> get areas => controller._areas;

  Object get areasUpdateHash => controller._areasUpdateHash;

  /// The sum of all flex values.
  double totalFlex() {
    double sum = 0;
    double count = 0;
    for (Area area in areas) {
      if (area.flex != null) {
        sum += area.flex!;
        count++;
      }
    }
    if (count > 0 && sum == 0) {
      // return count;
      throw StateError('Sum of flex must be positive.');
    }
    return sum;
  }

  void notifyListeners() => controller._forceNotifyListeners();

  void applyDataModifier() {
    controller._applyDataModifier();
  }

  static int? getStateHashCode(MultiSplitViewController controller) {
    return controller._stateHashCode;
  }

  static void setStateHashCode(
      MultiSplitViewController controller, int? value) {
    controller._stateHashCode = value;
  }
}

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
      _areas = List.from(areas);
      for (Area area in _areas) {
        AreaHelper.setHashChanger(area: area, function: _newAreasHash);
        area.addListener(notifyListeners);
      }
      _updateAreas();
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

  /// Object to indicate that some area has been changed programmatically.
  _AreasHash _areasHash = _AreasHash();

  void _newAreasHash() {
    _areasHash = _AreasHash();
  }

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
  void _updateAreas() {
    Set<dynamic> ids = {};

    int index = 0;
    for (Area area in _areas) {
      if (!ids.add(area.id)) {
        throw StateError('Duplicate area id.');
      }
      AreaHelper.setIndex(area: area, index: index);
      index++;
    }

    _applyDataModifier();

    _areasHash = _AreasHash();
  }

  /// Set the areas.
  /// Changes the flex to 1 if the total flex of the areas is 0.
  set areas(List<Area> areas) {
    for (Area area in _areas) {
      AreaHelper.setIndex(area: area, index: -1);
      AreaHelper.setHashChanger(area: area, function: null);
      area.removeListener(notifyListeners);
    }
    _areas = List.from(areas);
    for (Area area in _areas) {
      AreaHelper.setHashChanger(area: area, function: _newAreasHash);
      area.addListener(notifyListeners);
    }
    _updateAreas();
    notifyListeners();
  }

  void removeAreaAt(int index) {
    Area area = _areas.removeAt(index);
    AreaHelper.setIndex(area: area, index: -1);
    AreaHelper.setHashChanger(area: area, function: null);
    area.removeListener(notifyListeners);
    _updateAreas();
    notifyListeners();
  }

  void addArea(Area area) {
    _areas.add(area);
    AreaHelper.setHashChanger(area: area, function: _newAreasHash);
    area.addListener(notifyListeners);
    _updateAreas();
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

  _AreasHash get areasHash => controller._areasHash;

  void notifyListeners() => controller._forceNotifyListeners();

  static int? getStateHashCode(MultiSplitViewController controller) {
    return controller._stateHashCode;
  }

  static void setStateHashCode(
      MultiSplitViewController controller, int? value) {
    controller._stateHashCode = value;
  }
}

class _AreasHash {
  @override
  String toString() {
    return hashCode.toString();
  }
}

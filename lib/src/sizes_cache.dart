import 'package:multi_split_view/src/area.dart';

class SizesCache {
  factory SizesCache(
      {required List<Area> areas,
      required double fullSize,
      required double dividerThickness}) {
    final int childrenCount = areas.length;
    final double totalDividerSize = (childrenCount - 1) * dividerThickness;
    final double childrenSize = fullSize - totalDividerSize;
    List<double> sizes = [];
    List<double> minimalSizes = [];
    for (Area area in areas) {
      double size = area.weight! * childrenSize;
      sizes.add(size);
      double minimalSize = area.minimalSize ?? 0;
      if (area.minimalWeight != null) {
        minimalSize = area.minimalWeight! * childrenSize;
      }
      minimalSizes.add(minimalSize);
    }
    return SizesCache._(
        childrenCount: areas.length,
        fullSize: fullSize,
        childrenSize: childrenSize,
        sizes: sizes,
        minimalSizes: minimalSizes,
        dividerThickness: dividerThickness);
  }
  SizesCache._(
      {required this.childrenCount,
      required this.fullSize,
      required this.childrenSize,
      required this.sizes,
      required this.minimalSizes,
      required this.dividerThickness});

  final double dividerThickness;
  final int childrenCount;
  final double fullSize;
  final double childrenSize;
  List<double> sizes;
  List<double> minimalSizes;
}

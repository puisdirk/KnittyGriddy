// Represents the icondata for one stitch part on a single layer. Replaces use of iconData.
// The data is a single SVG path string that should fit within 40x40 boundaries
import 'package:flutter/painting.dart';
import 'package:knitty_griddy/model/knitting_symbol_path.dart';

class KnittingSymbol {
  final String name;
  final List<KnittingSymbolPath> paths;
  final Offset scale;
  final Offset translation;
  final double rotation;

  int get rows => paths.length;

  const KnittingSymbol({
    required this.name,
    required this.paths,
    Offset? scale,
    Offset? translation,
    double? rotation,
  }) : scale = scale?? const Offset(1,1), translation = translation?? Offset.zero, rotation = rotation?? 0;

  KnittingSymbol copyWith({
    String? name,
    List<KnittingSymbolPath>? paths,
    Offset? scale,
    Offset? translation,
    double? rotation,
  }) {
    return KnittingSymbol(
      name: name?? this.name, 
      paths: paths?? this.paths,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotation: rotation?? this.rotation,
    );
  }

  @override
  int get hashCode => name.hashCode ^ paths.hashCode ^ scale.hashCode ^ translation.hashCode ^ rotation.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is KnittingSymbol &&
    name == other.name &&
    paths == other.paths &&
    scale == other.scale &&
    translation == other.translation &&
    rotation == other.rotation;

}
// Represents the icondata for one stitch part on a single layer. Replaces use of iconData.
import 'package:flutter/painting.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';

class KnittingSymbol {
  final String name;
  final List<KnittingSymbolPart> parts;
  final Offset scale;
  final Offset translation;
  final double rotation;

  int get rows => parts.length;

  const KnittingSymbol({
    required this.name,
    required this.parts,
    Offset? scale,
    Offset? translation,
    double? rotation,
  }) : scale = scale?? const Offset(1,1), translation = translation?? Offset.zero, rotation = rotation?? 0;

  KnittingSymbol copyWith({
    String? name,
    List<KnittingSymbolPart>? parts,
    Offset? scale,
    Offset? translation,
    double? rotation,
  }) {
    return KnittingSymbol(
      name: name?? this.name, 
      parts: parts?? this.parts,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotation: rotation?? this.rotation,
    );
  }

  @override
  int get hashCode => name.hashCode ^ parts.hashCode ^ scale.hashCode ^ translation.hashCode ^ rotation.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is KnittingSymbol &&
    name == other.name &&
    parts == other.parts &&
    scale == other.scale &&
    translation == other.translation &&
    rotation == other.rotation;

  @override
  String toString() {
    String pathsString = '';
    for (KnittingSymbolPart path in parts) {
      pathsString += '$path, ';
    }
    return '''
KnittingSymbol(
  name: '$name',
  paths: [$pathsString],
  scale: Offset(${scale.dx}, ${scale.dy}),
  translation: Offset(${translation.dx}, ${translation.dy}),
  rotation: $rotation,
)''';
  }
}
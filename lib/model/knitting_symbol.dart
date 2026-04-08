import 'package:flutter/painting.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';

class KnittingSymbol {

  static const Offset _defaultScale = Offset(1, 1);
  static const Offset _defaultTranslation = Offset.zero;
  static const double _defaultRotation = 0;

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
  }) : 
    scale = scale?? _defaultScale, 
    translation = translation?? _defaultTranslation, 
    rotation = rotation?? _defaultRotation;

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
    String partsString = '';
    for (KnittingSymbolPart path in parts) {
      partsString += '$path, ';
    }
    String defString = '''
KnittingSymbol(
  name: '$name',
  parts: [$partsString],''';

    if (scale != _defaultScale) {
      defString += '''scale: Offset(${scale.dx}, ${scale.dy}),''';
    }
    
    if (translation != _defaultTranslation) {
      defString += '''translation: Offset(${translation.dx}, ${translation.dy}),''';
    }
    
    if (rotation != _defaultRotation) {
      defString += '''rotation: $rotation,''';
    }
    
    defString += ''')''';
    
    return defString;
  }
}
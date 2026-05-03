import 'package:flutter/painting.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_arc.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_curve.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_rectangle.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_text.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class KnittingSymbol {

  static const Offset _defaultScale = Offset(1, 1);
  static const Offset _defaultTranslation = Offset.zero;
  static const double _defaultRotationRad = 0;

  final String name;
  final List<KnittingSymbolPart> parts;
  final Offset scale;
  final Offset translation;
  final double rotationRad;

  int get rows => parts.length;

  const KnittingSymbol({
    required this.name,
    required this.parts,
    Offset? scale,
    Offset? translation,
    double? rotationRad,
  }) : 
    scale = scale?? _defaultScale, 
    translation = translation?? _defaultTranslation, 
    rotationRad = rotationRad?? _defaultRotationRad;

  KnittingSymbol copyWith({
    String? name,
    List<KnittingSymbolPart>? parts,
    Offset? scale,
    Offset? translation,
    double? rotationRad,
  }) {
    return KnittingSymbol(
      name: name?? this.name, 
      parts: parts?? this.parts,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotationRad: rotationRad?? this.rotationRad,
    );
  }

  Map<String, Object> toJson() {
    return {
      'name': name,
      'parts': parts.map((p) => p.toJson()).toList(),
      'scale': {'x': scale.dx, 'y': scale.dy},
      'translation': {'x': translation.dx, 'y': translation.dy},
      'rotationrad': rotationRad,
    };
  }

  static KnittingSymbol fromJson(Map<String, dynamic> json) {
    List<KnittingSymbolPart> parts = [];
    List<Map<String, dynamic>> partObjects = (json['parts'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> partObject in partObjects) {
      switch (partObject['type'] as String) {
        case knittingSymbolArcType:
          parts.add(KnittingSymbolArc.fromJson(partObject));
          break;
        case knittingSymbolCurveType:
          parts.add(KnittingSymbolCurve.fromJson(partObject));
          break;
        case knittingSymbolPathType:
          parts.add(KnittingSymbolPath.fromJson(partObject));
          break;
        case knittingSymbolRectangleType:
          parts.add(KnittingSymbolRectangle.fromJson(partObject));
          break;
        case knittingSymbolTextType:
          parts.add(KnittingSymbolText.fromJson(partObject));
          break;
        default:
          throw Exception('Unknown symbol part type ${partObject['type'] as String}');
      }
    }

    return KnittingSymbol(
      name: json['name'], 
      parts: parts,
      scale: Offset(json['scale']['x'] as double, json['scale']['y'] as double),
      translation: Offset(json['translation']['x'] as double, json['translation']['y'] as double),
      rotationRad: json['rotationrad'] as double,
    );
  }

  String toSvg(Color symbolColor) {
    String svg = '<g class="symbol" transform-origin="${stitchCellWidth / 2} ${stitchCellHeight / 2}" transform="translate(${translation.dx}, ${translation.dy}) scale(${scale.dx}, ${scale.dy}) rotate(${MathUtitilies.toDegrees(rotationRad)})">';
    for (KnittingSymbolPart part in parts) {
      svg += '<g class="symbolpart" transform-origin="${stitchCellWidth / 2} ${stitchCellHeight / 2}" transform="translate(${part.translation.dx}, ${part.translation.dy}) scale(${part.scale.dx}, ${part.scale.dy}) rotate(${MathUtitilies.toDegrees(part.rotationRad)})">';
      svg += part.toSvg(symbolColor);
      svg += '</g>';
    }
    svg += '</g>';

    return svg;
  }

  @override
  int get hashCode => name.hashCode ^ parts.hashCode ^ scale.hashCode ^ translation.hashCode ^ rotationRad.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is KnittingSymbol &&
    name == other.name &&
    parts == other.parts &&
    scale == other.scale &&
    translation == other.translation &&
    rotationRad == other.rotationRad;

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
    
    if (rotationRad != _defaultRotationRad) {
      defString += '''rotation: $rotationRad,''';
    }
    
    defString += ''')''';
    
    return defString;
  }
}
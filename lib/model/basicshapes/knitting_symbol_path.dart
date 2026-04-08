
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:path_drawing/path_drawing.dart';

class KnittingSymbolPath extends KnittingSymbolPart {

  final String path;

  const KnittingSymbolPath({
    required super.name,
    required this.path,
    super.scale,
    super.translation,
    super.rotation,
    super.filled,
    super.strokeWidth,
  }) : super();
  
  @override
  KnittingSymbolPath copyWith({
    String? name,
    String? path,
    Offset? scale,
    Offset? translation,
    double? rotation,
    bool? filled,
    double? strokeWidth,
  }) {
    return KnittingSymbolPath(
      name: name?? this.name, 
      path: path?? this.path,
      scale: scale?? this.scale,
      rotation: rotation?? this.rotation,
      translation: translation?? this.translation,
      filled: filled?? this.filled,
      strokeWidth: strokeWidth?? this.strokeWidth,
    );
  }

  @override
  void drawPart(Canvas canvas, Size size, Paint ink) {
    if (path.isNotEmpty) {
      Path p = parseSvgPathData(path);
      canvas.drawPath(p, ink);
    }
  }

  @override
  int get hashCode => name.hashCode ^ path.hashCode ^ scale.hashCode ^ translation.hashCode ^ rotation.hashCode;
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolPath &&
      name == other.name &&
      path == other.path &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation;

    @override
  String toString() {
    String defString = '''
KnittingSymbolPath(
  name: '$name',
  path: '$path',''';

    if (scale != KnittingSymbolPart.defaultScale) {
      defString += '''scale: Offset(${scale.dx}, ${scale.dy}),''';
    }
    
    if (translation != KnittingSymbolPart.defaultTranslation) {
      defString += '''translation: Offset(${translation.dx}, ${translation.dy}),''';
    }
    
    if (rotation != KnittingSymbolPart.defaultRotation) {
      defString += '''rotation: $rotation,''';
    }

    if (filled != KnittingSymbolPart.defaultFilled) {
      defString += '''filled: $filled,''';
    }
  
    if (strokeWidth != KnittingSymbolPart.defaultStrokeWidth) {
      defString += '''strokeWidth: $strokeWidth,''';
    }

    defString += ''')''';

    return defString;
  }

  @override
  Widget getPartControls(StitchDefinition stitchDefinition, int partColumn, int partRow, Function(StitchDefinition newDefinition) onChanged) {
    return const SizedBox.shrink();
  }
}
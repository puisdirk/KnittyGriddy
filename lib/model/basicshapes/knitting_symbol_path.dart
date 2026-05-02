
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/basicshapes/text_entry_control.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:path_drawing/path_drawing.dart';

class KnittingSymbolPath extends KnittingSymbolPart {

  static const bool _defaultFilled = false;

  final String path;

  const KnittingSymbolPath({
    required super.name,
    required this.path,
    super.scale,
    super.translation,
    super.rotationRad,
    bool? filled,
    super.strokeWidth,
  }) : super(filled: filled?? _defaultFilled);
  
  @override
  KnittingSymbolPath copyWith({
    String? name,
    String? path,
    Offset? scale,
    Offset? translation,
    double? rotationRad,
    bool? filled,
    double? strokeWidth,
  }) {
    return KnittingSymbolPath(
      name: name?? this.name, 
      path: path?? this.path,
      scale: scale?? this.scale,
      rotationRad: rotationRad?? this.rotationRad,
      translation: translation?? this.translation,
      filled: filled?? this.filled,
      strokeWidth: strokeWidth?? this.strokeWidth,
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'name': name,
      'path': path,
      'scale': {'x': scale.dx, 'y': scale.dy},
      'translation': {'x': translation.dx, 'y': translation.dy},
      'rotationrad': rotationRad,
      'filled': filled,
      'strokewidth': strokeWidth,
    };
  }

  static KnittingSymbolPath fromJson(Map<String, dynamic> json) {
    return KnittingSymbolPath(
      name: json['name'] as String,
      path: json['path'] as String,
      scale: Offset(json['x'] as double, json['y'] as double),
      translation: Offset(json['x'] as double, json['y'] as double),
      rotationRad: json['rotationrad'] as double,
      filled: json['filled'] as bool,
      strokeWidth: json['strokewidth'] as double,
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
  String toSvg(Color symbolColor) {
    String svg = '<path d="$path" ';
    if (filled) {
      svg += 'fill="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" fill-opacity="${symbolColor.alpha}" ';
    } else {
      svg += 'fill="none" stroke="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" stroke-width="$strokeWidth" stroke-opacity="${symbolColor.alpha}" ';
    }

    svg += '/>';
    return svg;
  }

  @override
  int get hashCode => name.hashCode ^ path.hashCode ^ scale.hashCode ^ translation.hashCode ^ rotationRad.hashCode;
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolPath &&
      name == other.name &&
      path == other.path &&
      scale == other.scale &&
      translation == other.translation &&
      rotationRad == other.rotationRad;

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
    
    if (rotationRad != KnittingSymbolPart.defaultRotationRad) {
      defString += '''rotation: $rotationRad,''';
    }

    if (filled != _defaultFilled) {
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
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Path text'),
              ),
            ),
            const SizedBox(width: 10,),
            TextEntryControl(
              initialText: path,
              width: 400,
              maxlines: 10,
              onChanged: (String newText) {
                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == partColumn) {
                    List<KnittingSymbolPart> newParts = [];
                    for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                      if (row == partRow) {
                        newParts.add(copyWith(path: newText));
                      } else {
                        newParts.add(stitchDefinition.symbolPartAt(col, row));
                      }
                    }
                    newSymbols.add(stitchDefinition.symbolAt(col).copyWith(parts: newParts));
                  } else {
                    newSymbols.add(stitchDefinition.symbolAt(col));
                  }
                }
            
                onChanged(stitchDefinition.copyWith(
                  symbols: newSymbols
                ));
              }
            ),
          ]
        )
      ]
    );
  }
}
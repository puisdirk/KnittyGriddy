import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/controls/stitcheditor/symbol_part_transform_controls.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

abstract class KnittingSymbolPart {

  static const Offset defaultScale = Offset(1, 1);
  static const Offset defaultTranslation = Offset.zero;
  static const double defaultRotation = 0;
  static const bool defaultFilled = true;
  static const double defaultStrokeWidth = 1;

  final String name;
  final Offset scale;
  final Offset translation;
  final double rotation;
  final bool filled;
  final double strokeWidth;
  final bool allowStroke;

  const KnittingSymbolPart({
    required this.name,
    bool? allowStroke,
    Offset? scale,
    Offset? translation,
    double? rotation,
    bool? filled,
    double? strokeWidth,
  }) : 
    allowStroke = allowStroke?? true,
    scale = scale?? defaultScale, 
    translation = translation?? defaultTranslation, 
    rotation = rotation?? defaultRotation,
    filled = filled?? defaultFilled,
    strokeWidth = strokeWidth?? defaultStrokeWidth;

  @override
  int get hashCode => 
    name.hashCode ^ 
    allowStroke.hashCode ^
    scale.hashCode ^ 
    translation.hashCode ^ 
    rotation.hashCode ^ 
    filled.hashCode ^ 
    strokeWidth.hashCode;
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolPart &&
      name == other.name &&
      allowStroke == other.allowStroke &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation &&
      filled == other.filled &&
      strokeWidth == other.strokeWidth;

  KnittingSymbolPart copyWith({
    String? name,
    Offset? scale,
    Offset? translation,
    double? rotation,
    bool? filled,
    double? strokeWidth,
  });

  void draw(Canvas canvas, Size size, Color color) {
    Paint ink = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    drawPart(canvas, size, ink);
  }

  void drawPart(Canvas canvas, Size size, Paint ink);

  Widget getPartControls(
    StitchDefinition stitchDefinition, 
    int partColumn, 
    int partRow,
    Function(StitchDefinition newDefinition) onChanged);

  Widget getEditControls(
    StitchDefinition stitchDefinition, 
    int partColumn, 
    int partRow,
    Function(StitchDefinition newDefinition) onChanged) {
      return Column(
        children: [
          SymbolPartTransformControls(
            stitchDefinition: stitchDefinition, 
            symbolPartColumn: partColumn, 
            symbolPartRow: partRow, 
            onChanged: onChanged
          ),
          const SizedBox(height: 10,),
          if (allowStroke)
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Filled'),
                ),
              ),
              const SizedBox(width: 10,),
              Checkbox(
                value: filled, 
                onChanged: (value) {
                  List<KnittingSymbol> newSymbols = [];
              
                  for (int col = 0; col < stitchDefinition.columns; col++) {
                    if (col == partColumn) {
                      List<KnittingSymbolPart> newParts = [];
                      for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                        if (row == partRow) {
                          newParts.add(copyWith(filled: value));
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
                },
              ),
              const SizedBox(width: 10,),
              if (filled == false)
                const SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Stroke width'),
                  ),
                ),
              const SizedBox(width: 10,),
              if (filled == false)
                SizedBox(
                  width: 160,
                  child: SpinBox(
                    onChanged: (value) {
                      List<KnittingSymbol> newSymbols = [];
                  
                      for (int col = 0; col < stitchDefinition.columns; col++) {
                        if (col == partColumn) {
                          List<KnittingSymbolPart> newParts = [];
                          for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                            if (row == partRow) {
                              newParts.add(copyWith(strokeWidth: value));
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
                    }, 
                    min: 0.1,
                    max: 100,
                    step: 0.1,
                    decimals: 1,
                    value: strokeWidth
                  ),
                ),           
            ],
          ),
          const SizedBox(height: 10,),
          getPartControls(stitchDefinition, partColumn, partRow, onChanged)
        ],
      );
    }
}
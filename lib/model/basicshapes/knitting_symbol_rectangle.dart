import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class KnittingSymbolRectangle extends KnittingSymbolPart {

  final double height;
  final double width;
  final bool rounded;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;

  const KnittingSymbolRectangle({
    required super.name,
    double? height,
    double? width,
    bool? rounded,
    double? topLeftRadius,
    double? topRightRadius,
    double? bottomLeftRadius,
    double? bottomRightRadius,
    super.filled,
    super.strokeWidth,
    super.scale,
    super.translation,
    super.rotation,
  }) : 
    height = height?? 10, 
    width = width?? 10, 
    rounded = rounded?? false,
    topLeftRadius = topLeftRadius?? 0,
    topRightRadius = topRightRadius?? 0,
    bottomLeftRadius = bottomLeftRadius?? 0,
    bottomRightRadius = bottomRightRadius?? 0,
    super();

  @override
  KnittingSymbolPart copyWith({
    String? name, 
    Offset? scale, 
    Offset? translation, 
    double? rotation,
    double? height,
    double? width,
    bool? rounded,
    double? topLeftRadius,
    double? topRightRadius,
    double? bottomLeftRadius,
    double? bottomRightRadius,
    bool? filled,
    double? strokeWidth,
  }) {
    return KnittingSymbolRectangle(
      name: name?? this.name,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotation: rotation?? this.rotation,
      height: height?? this.height,
      width: width?? this.width,
      filled: filled?? this.filled,
      strokeWidth: strokeWidth?? this.strokeWidth,
      rounded: rounded?? this.rounded,
      topLeftRadius: topLeftRadius?? this.topLeftRadius,
      topRightRadius: topRightRadius?? this.topRightRadius,
      bottomLeftRadius: bottomLeftRadius?? this.bottomLeftRadius,
      bottomRightRadius: bottomRightRadius?? this.bottomRightRadius,
    );
  }

  @override
  void drawPart(Canvas canvas, Size size, Paint ink) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2), 
          width: width, 
          height: height
        ),
        topLeft: Radius.circular(topLeftRadius),
        topRight: Radius.circular(topRightRadius),
        bottomLeft: Radius.circular(bottomLeftRadius),
        bottomRight: Radius.circular(bottomRightRadius)
      ),
      ink);
  }

  @override
  int get hashCode => super.hashCode ^ height.hashCode ^ width.hashCode ^ 
    rounded.hashCode ^ topLeftRadius.hashCode ^ topRightRadius.hashCode ^ bottomLeftRadius.hashCode ^ bottomRightRadius.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolRectangle &&
      name == other.name &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation &&
      width == other.width &&
      height == other.height &&
      filled == other.filled &&
      strokeWidth == other.strokeWidth &&
      rounded == other.rounded &&
      topLeftRadius == other.topLeftRadius &&
      topRightRadius == other.topRightRadius &&
      bottomLeftRadius == other.bottomLeftRadius &&
      bottomRightRadius == other.bottomRightRadius;
  
  @override
  Widget getPartControls(
    StitchDefinition stitchDefinition, 
    int partColumn, int partRow, 
    Function(StitchDefinition newDefinition) onChanged) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Width'),
              ),
            ),
            const SizedBox(width: 10,),
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
                          newParts.add(copyWith(width: value));
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
                max: 200,
                step: 0.1,
                decimals: 1,
                value: width
              ),
            ),
            const SizedBox(width: 10,),
            const SizedBox(
              width: 50,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Height'),
              ),
            ),
            const SizedBox(width: 10,),
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
                          newParts.add(copyWith(height: value));
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
                max: 200,
                step: 0.1,
                decimals: 1,
                value: height
              ),
            ),           
          ],
        ),
        const SizedBox(height: 10,),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Rounded'),
              ),
            ),
            const SizedBox(width: 10,),
            Checkbox(
              value: rounded, 
              onChanged: (value) {
                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == partColumn) {
                    List<KnittingSymbolPart> newParts = [];
                    for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                      if (row == partRow) {
                        newParts.add(copyWith(rounded: value));
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
          ],
        ),
        const SizedBox(height: 10,),
        if (rounded)
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Top left'),
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                value: topLeftRadius,
                min: 0,
                max: 25,
                onChanged: (value) {
                  List<KnittingSymbol> newSymbols = [];
              
                  for (int col = 0; col < stitchDefinition.columns; col++) {
                    if (col == partColumn) {
                      List<KnittingSymbolPart> newParts = [];
                      for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                        if (row == partRow) {
                          newParts.add(copyWith(topLeftRadius: value));
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
            ),
            const SizedBox(width: 10,),
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Top right'),
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                value: topRightRadius,
                min: 0,
                max: 25,
                onChanged: (value) {
                  List<KnittingSymbol> newSymbols = [];
              
                  for (int col = 0; col < stitchDefinition.columns; col++) {
                    if (col == partColumn) {
                      List<KnittingSymbolPart> newParts = [];
                      for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                        if (row == partRow) {
                          newParts.add(copyWith(topRightRadius: value));
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
            )
          ],
        ),
        const SizedBox(height: 10,),
        if (rounded)
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Bottom left'),
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                value: bottomLeftRadius,
                min: 0,
                max: 25,
                onChanged: (value) {
                  List<KnittingSymbol> newSymbols = [];
              
                  for (int col = 0; col < stitchDefinition.columns; col++) {
                    if (col == partColumn) {
                      List<KnittingSymbolPart> newParts = [];
                      for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                        if (row == partRow) {
                          newParts.add(copyWith(bottomLeftRadius: value));
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
            ),
            const SizedBox(width: 10,),
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Bottom right'),
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                value: bottomRightRadius,
                min: 0,
                max: 25,
                onChanged: (value) {
                  List<KnittingSymbol> newSymbols = [];
              
                  for (int col = 0; col < stitchDefinition.columns; col++) {
                    if (col == partColumn) {
                      List<KnittingSymbolPart> newParts = [];
                      for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                        if (row == partRow) {
                          newParts.add(copyWith(bottomRightRadius: value));
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
            )
          ]
        ),
      ],
    );
  }
}
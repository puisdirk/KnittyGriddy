
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/math_utitilies.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class KnittingSymbolArc extends KnittingSymbolPart {
  
  final double height;
  final double width;
  final double startAngle;
  final double sweepAngle;
  final bool closed;

  const KnittingSymbolArc({
    required super.name,
    double? height,
    double? width,
    double? startAngle,
    double? sweepAngle,
    bool? closed,
    super.filled,
    super.strokeWidth,
    super.scale,
    super.translation,
    super.rotation,
  }) : 
    height = height?? 10,
    width = width?? 10,
    startAngle = startAngle?? 0,
    sweepAngle = sweepAngle?? 360,
    closed = closed?? true,
    super();

  @override
  KnittingSymbolPart copyWith({
    String? name, 
    double? height,
    double? width,
    double? startAngle,
    double? sweepAngle,
    bool? closed,
    Offset? scale, 
    Offset? translation, 
    double? rotation, 
    bool? filled, 
    double? strokeWidth}) {
    return KnittingSymbolArc(
      name: name?? this.name,
      height: height?? this.height,
      width: width?? this.width,
      startAngle: startAngle?? this.startAngle,
      sweepAngle: sweepAngle?? this.sweepAngle,
      closed: closed?? this.closed,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotation: rotation?? this.rotation,
      filled: filled?? this.filled,
      strokeWidth: strokeWidth?? this.strokeWidth,
    );
  }

  @override
  void drawPart(Canvas canvas, Size size, Paint ink) {
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2), 
        width: width, 
        height: height), 
      MathUtitilies.toRadians(startAngle), 
      MathUtitilies.toRadians(sweepAngle), 
      closed, 
      ink
    );
  }

  @override
  int get hashCode => super.hashCode ^ height.hashCode ^ width.hashCode ^ startAngle.hashCode ^ sweepAngle.hashCode ^ closed.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolArc &&
      name == other.name &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation &&
      width == other.width &&
      height == other.height &&
      filled == other.filled &&
      strokeWidth == other.strokeWidth &&
      startAngle == other.startAngle &&
      sweepAngle == other.sweepAngle &&
      closed == other.closed;

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
                value: width
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
              child: Text('Start angle'),
            ),
          ),
          const SizedBox(width: 10,),
          SizedBox(
            width: 160,
            child: SpinBox(
              min: -360,
              max: 360,
              onChanged: (value) { 
                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == partColumn) {
                    List<KnittingSymbolPart> newParts = [];
                    for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                      if (row == partRow) {
                        newParts.add(copyWith(startAngle: value));
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
              value: startAngle, 
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 90,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Sweep angle'),
            ),
          ),
          const SizedBox(width: 10,),
          SizedBox(
            width: 160,
            child: SpinBox(
              min: -360,
              max: 360,
              onChanged: (value) { 
                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == partColumn) {
                    List<KnittingSymbolPart> newParts = [];
                    for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                      if (row == partRow) {
                        newParts.add(copyWith(sweepAngle: value));
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
              value: sweepAngle, 
            ),
          ),
        ]
      ),
      const SizedBox(height: 10,),
      Row(
        children: [
          const SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Closed'),
            ),
          ),
          Checkbox(
            value: closed, 
            onChanged: (value) {
              List<KnittingSymbol> newSymbols = [];
          
              for (int col = 0; col < stitchDefinition.columns; col++) {
                if (col == partColumn) {
                  List<KnittingSymbolPart> newParts = [];
                  for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                    if (row == partRow) {
                      newParts.add(copyWith(closed: value));
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
      ],
    );
  }

}
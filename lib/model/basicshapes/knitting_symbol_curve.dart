import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class KnittingSymbolCurve extends KnittingSymbolPart {

  final double length;
  final double amplitude;
  final double slant;
  final bool closed;

  const KnittingSymbolCurve({
    required super.name,
    bool? filled,
    double? strokeWidth,
    super.scale,
    super.translation,
    super.rotation,
    double? length,
    double? amplitude,
    double? slant,
    bool? closed,
  }) :
    length = length?? 20,
    amplitude = amplitude?? 0,
    slant = slant?? 0,
    closed = closed?? false,
    super(filled: filled?? false, strokeWidth: strokeWidth?? 3);

  @override
  KnittingSymbolPart copyWith({
    String? name, 
    Offset? scale, 
    Offset? translation, 
    double? rotation,
    bool? filled,
    double? strokeWidth,
    double? length,
    double? amplitude,
    double? slant,
    bool? closed,
  }) {
    return KnittingSymbolCurve(
      name: name?? this.name,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotation: rotation?? this.rotation,
      filled: filled?? this.filled,
      strokeWidth: strokeWidth?? this.strokeWidth,
      length: length?? this.length,
      amplitude: amplitude?? this.amplitude,
      slant: slant?? this.slant,
      closed: closed?? this.closed,
    );
  }

  @override
  int get hashCode => super.hashCode ^ length.hashCode ^ amplitude.hashCode ^ slant.hashCode ^ closed.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolCurve &&
      name == other.name &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation &&
      filled == other.filled &&
      strokeWidth == other.strokeWidth &&
      length == other.length &&
      amplitude == other.amplitude &&
      slant == other.slant &&
      closed == other.closed;


  @override
  void drawPart(Canvas canvas, Size size, Paint ink) {
    
    Offset middle = Offset(size.width / 2, size.height / 2); 
    if (amplitude == 0) {
      canvas.drawLine(Offset(middle.dx - (length / 2), middle.dy), Offset(middle.dx + (length / 2), middle.dy), ink);
    } else {
      Path path = Path()
        ..moveTo(middle.dx - (length / 2), middle.dy)
        ..quadraticBezierTo(middle.dx + slant, middle.dy + amplitude, middle.dx + (length / 2), middle.dy);
        if (closed) {
          path.close();
        }
      canvas.drawPath(path, ink);
    }
  }

  @override
  Widget getPartControls(
    StitchDefinition stitchDefinition, 
    int partColumn, 
    int partRow, 
    Function(StitchDefinition newDefinition) onChanged) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Length'),
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
                          newParts.add(copyWith(length: value));
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
                min: 1,
                max: 200,
                value: length
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
                child: Text('Amplitude'),
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
                          newParts.add(copyWith(amplitude: value));
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
                min: -200,
                max: 200,
                value: amplitude
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
                child: Text('Slant'),
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
                          newParts.add(copyWith(slant: value));
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
                min: -200,
                max: 200,
                value: slant
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
            const SizedBox(width: 10,),
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
        )
      ],
    );
  }

}
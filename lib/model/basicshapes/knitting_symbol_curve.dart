import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/utils/constants.dart';

class KnittingSymbolCurve extends KnittingSymbolPart {

  static const double _defaultLength = 20;
  static const double _defaultAmplitude = 0;
  static const double _defaultSlant = 0;
  static const bool _defaultClosed = false;
  static const bool _defaultFilled = false;
  static const double _defaultStrokeWidth = 3;

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
    super.rotationRad,
    double? length,
    double? amplitude,
    double? slant,
    bool? closed,
  }) :
    length = length?? _defaultLength,
    amplitude = amplitude?? _defaultAmplitude,
    slant = slant?? _defaultSlant,
    closed = closed?? _defaultClosed,
    super(filled: filled?? _defaultFilled, strokeWidth: strokeWidth?? _defaultStrokeWidth);

  @override
  KnittingSymbolPart copyWith({
    String? name, 
    Offset? scale, 
    Offset? translation, 
    double? rotationRad,
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
      rotationRad: rotationRad?? this.rotationRad,
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
      rotationRad == other.rotationRad &&
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
  String toSvg(Color symbolColor) {
    Offset middle = const Offset(stitchCellWidth / 2, stitchCellHeight / 2);
    String svg = '<path d="M${middle.dx - (length / 2)},${middle.dy}Q${middle.dx + slant},${middle.dy + amplitude}, ${middle.dx + (length / 2)}, ${middle.dy}${closed ? 'z' : ''}" ';

    if (filled) {
      svg += 'fill="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" fill-opacity="${symbolColor.alpha}" ';
    } else {
      svg += 'fill="none" stroke="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" stroke-width="$strokeWidth" stroke-opacity="${symbolColor.alpha}" ';
    }

    svg += '/>';
    return svg;
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

  @override
  String toString() {
    String defString = '''
KnittingSymbolCurve(
  name: '$name',''';

    if (length != _defaultLength) {
      defString += '''length: $length,''';
    }

    if (amplitude != _defaultAmplitude) {
      defString += '''amplitude: $amplitude,''';
    }

    if (slant != _defaultSlant) {
      defString += '''slant: $slant,''';
    }

    if (closed != _defaultClosed) {
      defString += '''closed: $closed,''';
    }

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
  
    if (strokeWidth != _defaultStrokeWidth) {
      defString += '''strokeWidth: $strokeWidth,''';
    }

    defString += ''')''';

    return defString;
  }

}
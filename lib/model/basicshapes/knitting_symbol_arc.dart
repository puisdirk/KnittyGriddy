
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

class KnittingSymbolArc extends KnittingSymbolPart {
  
  static const double _defaultHeight = 10;
  static const double _defaultWidth = 10;
  static const double _defaultStartAngle = 0;
  static const double _defaultSweepAngle = 360;
  static const bool _defaultClosed = true;

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
    super.rotationRad,
  }) : 
    height = height?? _defaultHeight,
    width = width?? _defaultWidth,
    startAngle = startAngle?? _defaultStartAngle,
    sweepAngle = sweepAngle?? _defaultSweepAngle,
    closed = closed?? _defaultClosed,
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
    double? rotationRad, 
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
      rotationRad: rotationRad?? this.rotationRad,
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
  String toSvg(Color symbolColor) {
    Offset middle = const Offset(stitchCellWidth / 2, stitchCellHeight / 2);
    double rw = width / 2;
    double rh = height / 2;

    Offset startPoint = Offset(
      middle.dx + (rw * cos(MathUtitilies.toRadians(startAngle))), 
      middle.dy + (rh * sin(MathUtitilies.toRadians(startAngle)))
    );
    Offset endPoint = Offset(
      middle.dx + (rw * cos(MathUtitilies.toRadians(startAngle + sweepAngle))), 
      middle.dy + (rh * sin(MathUtitilies.toRadians(startAngle + sweepAngle)))
    );

    int largeArcFlag = 1;
    int sweepArgFlag = 1;

    // The arc won't show up if start and end points are too close
    if (MathUtitilies.distance(startPoint, endPoint) < 0.000003) {
      endPoint = startPoint.translate(0, 0.000003);
      sweepArgFlag = 0;
    }

    const int xaxisrotation = 0;
    String svg = '<path d="M${startPoint.dx},${startPoint.dy} A$rw,$rh $xaxisrotation $largeArcFlag $sweepArgFlag ${endPoint.dx},${endPoint.dy} ';
    if (closed) {
      svg += 'L${middle.dx},${middle.dy} L${startPoint.dx}, ${startPoint.dy} z';
    }
    svg += '" ';

    if (filled) {
      svg += 'fill="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" fill-opacity="${symbolColor.alpha}" ';
    } else {
      svg += 'fill="none" stroke="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" stroke-width="$strokeWidth" stroke-opacity="${symbolColor.alpha}" ';
    }

    svg += '/>';

    return svg;
  }

  @override
  int get hashCode => 
    super.hashCode ^ 
    height.hashCode ^ width.hashCode ^ 
    startAngle.hashCode ^ sweepAngle.hashCode ^ 
    closed.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolArc &&
      name == other.name &&
      scale == other.scale &&
      translation == other.translation &&
      rotationRad == other.rotationRad &&
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

  @override
  String toString() {
    String defString = '''
KnittingSymbolArc(
  name: '$name',''';

    if (height != _defaultHeight) {
      defString += '''height: $height,''';
    }

    if (width != _defaultWidth) {
      defString += '''width: $width,''';
    }

    if (startAngle != _defaultStartAngle) {
      defString += '''startAngle: $startAngle,''';
    }

    if (sweepAngle != _defaultSweepAngle) {
      defString += '''sweepAngle: $sweepAngle,''';
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

    if (filled != KnittingSymbolPart.defaultFilled) {
      defString += '''filled: $filled,''';
    }
  
    if (strokeWidth != KnittingSymbolPart.defaultStrokeWidth) {
      defString += '''strokeWidth: $strokeWidth,''';
    }

    defString += ''')''';

    return defString;

  }

}
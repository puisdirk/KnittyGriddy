import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/utils/constants.dart';

const String knittingSymbolRectangleType ='rectangle';

class KnittingSymbolRectangle extends KnittingSymbolPart {

  static const double _defaultHeight = 20;
  static const double _defaultWidth = 20;
  static const bool _defaultRounded = false;
  static const double _defaultTopLeftRadius = 0;
  static const double _defaultTopRightRadius = 0;
  static const double _defaultBottomLeftRadius = 0;
  static const double _defaultBottomRightRadius = 0;

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
    super.rotationRad,
  }) : 
    height = height?? _defaultHeight, 
    width = width?? _defaultWidth, 
    rounded = rounded?? _defaultRounded,
    topLeftRadius = topLeftRadius?? _defaultTopLeftRadius,
    topRightRadius = topRightRadius?? _defaultTopRightRadius,
    bottomLeftRadius = bottomLeftRadius?? _defaultBottomLeftRadius,
    bottomRightRadius = bottomRightRadius?? _defaultBottomRightRadius,
    super();

  @override
  KnittingSymbolPart copyWith({
    String? name, 
    Offset? scale, 
    Offset? translation, 
    double? rotationRad,
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
      rotationRad: rotationRad?? this.rotationRad,
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
  Map<String, Object> toJson() {
    return {
      'type': knittingSymbolRectangleType,
      'name': name,
      'height': height,
      'width': width,
      'rounded': rounded,
      'topleftradius': topLeftRadius,
      'toprightradius': topRightRadius,
      'bottomleftradius': bottomLeftRadius,
      'bottomrightradius': bottomRightRadius,
      'scale': {'x': scale.dx, 'y': scale.dy},
      'translation': {'x': translation.dx, 'y': translation.dy},
      'rotationrad': rotationRad,
      'filled': filled,
      'strokewidth': strokeWidth,
    };
  }

  static KnittingSymbolRectangle fromJson(Map<String, dynamic> json) {
    return KnittingSymbolRectangle(
      name: json['name'] as String,
      height: json['height'] as double,
      width: json['width'] as double,
      rounded: json['rounded'] as bool,
      topLeftRadius: json['topleftradius'] as double,
      topRightRadius: json['toprightradius'] as double,
      bottomLeftRadius: json['bottomleftradius'] as double,
      bottomRightRadius: json['bottomrightradius'] as double,
      scale: Offset(json['scale']['x'] as double, json['scale']['y'] as double),
      translation: Offset(json['translation']['x'] as double, json['translation']['y'] as double),
      rotationRad: json['rotationrad'] as double,
      filled: json['filled'] as bool,
      strokeWidth: json['strokewidth'] as double,
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
        topLeft: rounded ? Radius.circular(topLeftRadius) : Radius.zero,
        topRight: rounded ? Radius.circular(topRightRadius) : Radius.zero,
        bottomLeft: rounded ? Radius.circular(bottomLeftRadius) : Radius.zero,
        bottomRight: rounded ? Radius.circular(bottomRightRadius) : Radius.zero,
      ),
      ink);
  }

  @override
  String toSvg(Color symbolColor) {
    String svg = '<rect x="${(stitchCellWidth / 2) - (width / 2)}" y="${(stitchCellHeight / 2) - (height / 2)}" width="$width" height="$height" ';
    if (filled) {
      svg += 'fill="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" fill-opacity="${symbolColor.alpha}" ';
    } else {
      svg += 'fill="none" stroke="rgb(${symbolColor.red}, ${symbolColor.green}, ${symbolColor.blue})" stroke-width="$strokeWidth" stroke-opacity="${symbolColor.alpha}" ';
    }
    if (rounded) {
      // TODO: if the roundings are different on each corner, we'll need a path instead of a rect
      svg += 'rx="$topLeftRadius" ';
    }
    svg += '/>';

    return svg;
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
      rotationRad == other.rotationRad &&
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

  @override
  String toString() {
    String defString =  '''
KnittingSymbolRectangle(
  name: '$name',''';

    if (height != _defaultHeight) {
      defString += '''height: $height,''';
    }

    if (width != _defaultWidth) {
      defString += '''width: $width,''';
    }

    if (rounded != _defaultRounded) {
      defString += '''rounded: $rounded,''';
    }

    if (topLeftRadius != _defaultTopLeftRadius) {
      defString += '''topLeftRadius: $topLeftRadius,''';
    }

    if (topRightRadius != _defaultTopRightRadius) {
      defString += '''topRightRadius: $topRightRadius,''';
    }

    if (bottomLeftRadius != _defaultBottomLeftRadius) {
      defString += '''bottomLeftRadius: $bottomLeftRadius,''';
    }

    if (bottomRightRadius != _defaultBottomRightRadius) {
      defString += '''bottomRightRadius: $bottomRightRadius,''';
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
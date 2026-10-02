import 'dart:ui';

import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';

class PatternDrawingField extends PatternField {
  final Drawing? drawing;

  const PatternDrawingField({
    required super.id,
    super.positionX,
    super.positionY,
    super.width,
    super.height,
    super.contentOffsetX,
    super.contentOffsetY,
    super.opacity,
    super.rotation,
    super.flipX,
    super.flipY,
    this.drawing,
  }) : super(fieldType: PatternFieldType.drawing);

  @override
  bool get hasContent => drawing != null;

  PatternDrawingField copyWith({
    String? id,
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
    double? rotation,
    bool? flipX,
    bool? flipY,
    Drawing? drawing,
  }) {
    return PatternDrawingField(
      id: id?? this.id,
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      contentOffsetX: contentOffsetX?? this.contentOffsetX,
      contentOffsetY: contentOffsetY?? this.contentOffsetY,
      opacity: opacity?? this.opacity,
      rotation: rotation?? this.rotation,
      flipX: flipX?? this.flipX,
      flipY: flipY?? this.flipY,
      drawing: drawing?? this.drawing,
    );
  }

  PatternDrawingField clearDrawing() {
    // Note: we can't use copyWith here as passing null will keep the current drawing
    return PatternDrawingField(
      id: id,
      positionX: positionX,
      positionY: positionY,
      width: width,
      height: height,
      contentOffsetX: contentOffsetX,
      contentOffsetY: contentOffsetY,
      opacity: opacity,
      rotation: rotation,
      flipX: flipX,
      flipY: flipY,
      drawing: null,
    );
  }

  @override
  PatternDrawingField abstractCopyWith({
    String? id,
    double? positionX, 
    double? positionY, 
    double? width, 
    double? height, 
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
    double? rotation,
    bool? flipX,
    bool? flipY,
  }) {
    return copyWith(
      id: id?? this.id,
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      contentOffsetX: contentOffsetX?? this.contentOffsetX,
      contentOffsetY: contentOffsetY?? this.contentOffsetY,
      opacity: opacity?? this.opacity,
      rotation: rotation?? this.rotation,
      flipX: flipX?? this.flipX,
      flipY: flipY?? this.flipY,
    );
  }

  DrawingInfo get drawingInfo => drawing == null ? DrawingInfo.emptyDrawingInfo : DrawingInfo(id: drawing!.id, name: drawing!.name, description: drawing!.description, contentHashCode: drawing!.contentHashCode);

  @override
  List<Color> get knownColours => drawing?.knownColours?? const[];

  @override
  bool get fixedAspectRatio => false;

  @override
  Map<String, Object> toJson() {
    if (drawing != null) {
      return {
        'type': fieldType.name,
        'id': id,
        'x': positionX,
        'y': positionY,
        'w': width,
        'h': height,
        'ox': contentOffsetX,
        'oy': contentOffsetY,
        'o': opacity,
        'r': rotation,
        'fx': flipX,
        'fy': flipY,
        'drawing': drawing!.toJson(),
      };
    }

    return {
      'type': fieldType.name,
      'id': id,
      'x': positionX,
      'y': positionY,
      'w': width,
      'h': height,
      'ox': contentOffsetX,
      'oy': contentOffsetY,
      'o': opacity,
      'r': rotation,
      'fx': flipX,
      'fy': flipY,
    };
  }

  static PatternDrawingField fromJson(Map<String, dynamic> json) {
    Drawing? drawing;
    if (json.containsKey('drawing')) {
      drawing = Drawing.fromJson(json['drawing']);//.validate();
    }

    return PatternDrawingField(
      id: json['id'] as String, 
      positionX: json['x'] as double,
      positionY: json['y'] as double,
      width: json['w'] as double,
      height: json['h'] as double,
      contentOffsetX: json['ox'] as double,
      contentOffsetY: json['oy'] as double,
      opacity: json['o'] as int,
      rotation: json.containsKey('r') ? json['r'] as double : 0,
      flipX: json.containsKey('fx') ? json['fx'] as bool : false,
      flipY: json.containsKey('fy') ? json['fy'] as bool : false,
      drawing: drawing,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PatternDrawingField &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    fieldType == other.fieldType &&
    positionX == other.positionX &&
    positionY == other.positionY &&
    width == other.width &&
    height == other.height &&
    contentOffsetX == other.contentOffsetX &&
    contentOffsetY == other.contentOffsetY &&
    opacity == other.opacity &&
    rotation == other.rotation &&
    flipX == other.flipX &&
    flipY == other.flipY &&
    drawing == other.drawing;
  
  @override
  int get hashCode => super.hashCode ^ drawing.hashCode;
}
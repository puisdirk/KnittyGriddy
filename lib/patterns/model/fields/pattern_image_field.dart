
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';

class PatternImageField extends PatternField {
  
  final Uint8List? imageData;
  
  const PatternImageField({
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
    this.imageData,
  }) : super(fieldType: PatternFieldType.image);

  @override
  bool get hasContent => imageData != null && imageData!.isNotEmpty;

  PatternImageField copyWith({
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
    Uint8List? imageData,
  }) {
    return PatternImageField(
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
      imageData: imageData?? this.imageData,
    );
  }

  bool get hasImage => imageData != null && imageData!.isNotEmpty;

  PatternImageField clearImage() {
    // Note: we can't use copyWith here as passing null will keep the current image
    return PatternImageField(
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
      imageData: null,
    );
  }

  @override
  PatternImageField abstractCopyWith({
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

  @override
  List<Color> get knownColours => const[];

  @override
  Map<String, Object> toJson() {
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
      'image': base64.encode(imageData?? Uint8List(0)),
    };
  }

  static PatternImageField fromJson(Map<String, dynamic> json) {
    return PatternImageField(
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
      imageData: base64.decode(json['image'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
    other is PatternImageField &&
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
    listEquals(imageData, other.imageData);
  
  @override
  int get hashCode => super.hashCode ^ imageData.hashCode;
}
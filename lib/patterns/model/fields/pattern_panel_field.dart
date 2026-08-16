
import 'dart:ui';

import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field_style.dart';

class PatternPanelField extends PatternField {

  final PatternPanelFieldStyle style;

  const PatternPanelField({
    required super.id,
    super.positionX,
    super.positionY,
    super.width,
    super.height,
    super.contentOffsetX,
    super.contentOffsetY,
    super.opacity,
    this.style = const PatternPanelFieldStyle(),
  }) : super(fieldType: PatternFieldType.panel);

  @override
  List<Color> get knownColours => style.knownColours;

  @override
  bool get fixedAspectRatio => false;

  @override
  double get padding => 1;
  
  @override
  double get bottompadding => 2;
  
  @override
  double get leftpadding => 0;

  PatternPanelField copyWith({
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
    PatternPanelFieldStyle? style,
  }) {
    return PatternPanelField(
      id: id,
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      contentOffsetX: contentOffsetX?? this.contentOffsetX,
      contentOffsetY: contentOffsetY?? this.contentOffsetY,
      opacity: opacity?? this.opacity,
      style: style?? this.style,
    );
  }

  @override
  PatternPanelField abstractCopyWith({
    double? positionX, 
    double? positionY, 
    double? width, 
    double? height, 
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
  }) {
    return copyWith(
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      contentOffsetX: contentOffsetX?? this.contentOffsetX,
      contentOffsetY: contentOffsetY?? this.contentOffsetY,
      opacity: opacity?? this.opacity,
    );
  }

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
      'style': style.toJson(),
    };
  }

  static PatternPanelField fromJson(Map<String, dynamic> json) {
    return PatternPanelField(
      id: json['id'] as String, 
      positionX: json['x'] as double,
      positionY: json['y'] as double,
      width: json['w'] as double,
      height: json['h'] as double,
      contentOffsetX: json['ox'] as double,
      contentOffsetY: json['oy'] as double,
      opacity: json['o'] as int,
      style: PatternPanelFieldStyle.fromJson(json['style']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PatternPanelField &&
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
    style == other.style;
  
  @override
  int get hashCode => super.hashCode ^ style.hashCode;
}
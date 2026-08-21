
import 'dart:ui';

import 'package:knitty_griddy/utils/constants.dart';

enum PatternFieldType {
  knittingchart(label: 'Chart'),
  texteditor(label: 'Text'),
  image(label: 'Image'),
  drawing(label: 'Drawing'),
  panel(label: 'Panel');

  final String label;

  const PatternFieldType({required this.label});
}

abstract class PatternField {
  
  final String id;
  final PatternFieldType fieldType;
  final double positionX;
  final double positionY;
  final double width;
  final double height;
  final double contentOffsetX;
  final double contentOffsetY;
  final int opacity;

  static const double minWidth = 600;
  static const double minHeight = 600;

  const PatternField({
    required this.id,
    required this.fieldType,
    this.positionX = 0,
    this.positionY = 0,
    this.width = minWidth,
    this.height = minHeight,
    this.contentOffsetX = 0,
    this.contentOffsetY = 0,
    this.opacity = 255,
  });

  PatternField abstractCopyWith({
    String? id,
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
  });

  List<Color> get knownColours;

  Map<String, Object> toJson();

  bool get fixedAspectRatio => true;
  double get minimumHeight => 100;
  double get minimumWidth => 100;
  double get padding => kResizerShortSide;
  double get leftpadding => kResizerShortSide;
  double get bottompadding => kResizerShortSide;

  @override
  int get hashCode => id.hashCode ^ fieldType.hashCode ^ positionX.hashCode ^ positionY.hashCode ^
    width.hashCode ^ height.hashCode ^ contentOffsetX.hashCode ^ contentOffsetY.hashCode ^ opacity.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PatternField &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    fieldType == other.fieldType &&
    positionX == other.positionX &&
    positionY == other.positionY &&
    width == other.width &&
    height == other.height &&
    contentOffsetX == other.contentOffsetX &&
    contentOffsetY == other.contentOffsetY &&
    opacity == other.opacity;
}
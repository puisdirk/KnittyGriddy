
enum PatternFieldType {
  knittingchart,
  texteditor,
  image,
  drawing,
  panel,
}

abstract class PatternField {
  
  final String id;
  final PatternFieldType fieldType;
  final double positionX;
  final double positionY;
  final double width;
  final double height;
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
    this.opacity = 255,
  });

  PatternField abstractCopyWith({
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    int? opacity,
  });

  Map<String, Object> toJson();

  bool get fixedAspectRatio => true;
  double get minimumHeight => 100;
  double get minimumWidth => 100;

  @override
  int get hashCode => id.hashCode ^ fieldType.hashCode ^ positionX.hashCode ^ positionY.hashCode ^
    width.hashCode ^ height.hashCode ^ opacity.hashCode;

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
    opacity == other.opacity;
}
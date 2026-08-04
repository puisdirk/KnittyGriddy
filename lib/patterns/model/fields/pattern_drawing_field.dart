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
    super.opacity,
    this.drawing,
  }) : super(fieldType: PatternFieldType.drawing);

  PatternDrawingField copyWith({
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    int? opacity,
    Drawing? drawing,
  }) {
    return PatternDrawingField(
      id: id,
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      opacity: opacity?? this.opacity,
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
      opacity: opacity,
      drawing: null,
    );
  }

  @override
  PatternDrawingField abstractCopyWith({
    double? positionX, 
    double? positionY, 
    double? width, 
    double? height, 
    int? opacity,
  }) {
    return copyWith(
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      opacity: opacity?? this.opacity,
    );
  }

  DrawingInfo get drawingInfo => drawing == null ? DrawingInfo.emptyDrawingInfo : DrawingInfo(id: drawing!.id, name: drawing!.name, description: drawing!.description);

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
        'o': opacity,
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
      'o': opacity,
    };
  }

  static PatternDrawingField fromJson(Map<String, dynamic> json) {
    Drawing? drawing;
    if (json.containsKey('drawing')) {
      drawing = Drawing.fromJson(json['drawing']).validate();
    }

    return PatternDrawingField(
      id: json['id'] as String, 
      positionX: json['x'] as double,
      positionY: json['y'] as double,
      width: json['w'] as double,
      height: json['h'] as double,
      opacity: json['o'] as int,
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
    opacity == other.opacity &&
    drawing == other.drawing;
  
  @override
  int get hashCode => super.hashCode ^ drawing.hashCode;
}

import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';

class PatternTextEditorField extends PatternField {

  final String docContents;

  static const String emptyDoc = '''[{"insert": "\\n"}]''';

  const PatternTextEditorField({
    required super.id,
    super.positionX,
    super.positionY,
    super.width,
    super.height,
    super.opacity,
    this.docContents = emptyDoc,
  }) : super(fieldType: PatternFieldType.texteditor);

  PatternTextEditorField copyWith({
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    int? opacity,
    String? docContents,
  }) {
    return PatternTextEditorField(
      id: id, 
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      opacity: opacity?? this.opacity,
      docContents: docContents?? this.docContents,
    );
  }

  @override
  PatternTextEditorField abstractCopyWith({
    double? positionX, 
    double? positionY, 
    double? width, 
    double? height, 
    int? opacity,
  }) {
    return copyWith(
      positionX: positionX,
      positionY: positionY,
      width: width,
      height: height,
      opacity: opacity,
    );
  }

  @override
  bool get fixedAspectRatio => false;

  @override
  Map<String, Object> toJson() {
    return {
      'type': fieldType.name,
      'id': id,
      'x': positionX,
      'y': positionY,
      'w': width,
      'h': height,
      'o': opacity,
      'doc': docContents,
    };
  }

  static PatternTextEditorField fromJson(Map<String, dynamic> json) {
    return PatternTextEditorField(
      id: json['id'] as String, 
      positionX: json['x'] as double,
      positionY: json['y'] as double,
      width: json['w'] as double,
      height: json['h'] as double,
      opacity: json['o'] as int,
      docContents: json['doc'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PatternTextEditorField &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    fieldType == other.fieldType &&
    positionX == other.positionX &&
    positionY == other.positionY &&
    width == other.width &&
    height == other.height &&
    opacity == other.opacity &&
    docContents == other.docContents;
  
  @override
  int get hashCode => super.hashCode ^ docContents.hashCode;
}
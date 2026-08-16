
import 'dart:convert';
import 'dart:ui';

import 'package:fleather/fleather.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/text_editor_field_settings.dart';

class PatternTextEditorField extends PatternField {

  final String docContents;
  final TextEditorFieldSettings settings;

  static const String emptyDoc = '''[{"insert": "\\n"}]''';

  const PatternTextEditorField({
    required super.id,
    super.positionX,
    super.positionY,
    super.width,
    super.height,
    super.contentOffsetX,
    super.contentOffsetY,
    super.opacity,
    this.settings = TextEditorFieldSettings.defaultSettings,
    this.docContents = emptyDoc,
  }) : super(fieldType: PatternFieldType.texteditor);

  PatternTextEditorField copyWith({
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
    TextEditorFieldSettings? settings,
    String? docContents,
  }) {
    return PatternTextEditorField(
      id: id, 
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      contentOffsetX: contentOffsetX?? this.contentOffsetX,
      contentOffsetY: contentOffsetY?? this.contentOffsetY,
      opacity: opacity?? this.opacity,
      settings: settings?? this.settings,
      docContents: docContents?? this.docContents,
    );
  }

  @override
  PatternTextEditorField abstractCopyWith({
    double? positionX, 
    double? positionY, 
    double? width, 
    double? height, 
    double? contentOffsetX,
    double? contentOffsetY,
    int? opacity,
  }) {
    return copyWith(
      positionX: positionX,
      positionY: positionY,
      width: width,
      height: height,
      contentOffsetX: contentOffsetX?? this.contentOffsetX,
      contentOffsetY: contentOffsetY?? this.contentOffsetY,
      opacity: opacity,
    );
  }

  @override
  List<Color> get knownColours {
    Set<Color> colors = {};

    ParchmentDocument doc = ParchmentDocument.fromJson(jsonDecode(docContents));
    DeltaIterator iter = DeltaIterator(doc.toDelta());
    while(iter.hasNext) {
      Operation op = iter.next();
      if (op.hasAttribute(ParchmentAttribute.backgroundColor.key)) {
        Color col = Color(op.attributes?[ParchmentAttribute.backgroundColor.key]);
        colors.add(col);
      }
      if (op.hasAttribute(ParchmentAttribute.foregroundColor.key)) {
        Color col = Color(op.attributes?[ParchmentAttribute.foregroundColor.key]);
        colors.add(col);
      }
    }

    return colors.toList();
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
      'ox': contentOffsetX,
      'oy': contentOffsetY,
      'fs': settings.toJson(),
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
      contentOffsetX: json['ox'] as double,
      contentOffsetY: json['oy'] as double,
      opacity: json['o'] as int,
      settings: TextEditorFieldSettings.fromJson(json['fs']),
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
    contentOffsetX == other.contentOffsetX &&
    contentOffsetY == other.contentOffsetY &&
    opacity == other.opacity &&
    settings == other.settings &&
    docContents == other.docContents;
  
  @override
  int get hashCode => super.hashCode ^ settings.hashCode ^ docContents.hashCode;
}
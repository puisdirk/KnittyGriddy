import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/utils/constants.dart';

const String placeholderPatternId = '_placeholder_pattern_id_';
const KnittingPattern placeholderPattern = KnittingPattern(
  id: placeholderPatternId,
  name: placeholderPatternId,
);

@immutable
class KnittingPattern {
  final String id;
  final String name;
  final String description;
  final List<PatternField> fields;
  final PatternPageLayout pageLayout;

  const KnittingPattern({
    required this.id,
    required this.name,
    this.description = '',
    this.fields = const[],
    this.pageLayout = PatternPageLayout.defaultLayout,
  });

  KnittingPattern copyWith({
    String? id,
    String? name,
    String? description,
    List<PatternField>? fields,
    PatternPageLayout? pageLayout,
  }) {
    return KnittingPattern(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      fields: fields?? this.fields,
      pageLayout: pageLayout?? this.pageLayout,
    );
  }

  List<Color> get knownColours {
    Set<Color> colors = {};

    for (PatternField field in fields) {
      colors.addAll(field.knownColours);
    }

    colors.remove(Colors.black);
    colors.remove(Colors.white);
    colors.remove(Colors.transparent);

    return colors.toList(growable: false);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ fields.hashCode ^ pageLayout.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingPattern &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(fields, other.fields) &&
      pageLayout == other.pageLayout;

    Map<String, Object> toJson() {
    return {
      'objectversion': objectversion,
      'id': id,
      'name': name,
      'description': description,
      'fields': fields.map((f) => f.toJson()).toList(),
      'layout': pageLayout.toJson(),
    };
  }

  static KnittingPattern fromJson(Map<String, dynamic> json) {
    
    Map<String, Drawing> validatedDrawings = {};

    List<PatternField> fields = [];
    List<Map<String, dynamic>> fieldObjects = (json['fields'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> fieldObject in fieldObjects) {
      PatternFieldType fieldType = PatternFieldType.values.byName(fieldObject['type'] as String);
      switch (fieldType) {
        case PatternFieldType.texteditor:
          fields.add(PatternTextEditorField.fromJson(fieldObject));
          break;
        case PatternFieldType.knittingchart:
          fields.add(PatternChartField.fromJson(fieldObject));
          break;
        case PatternFieldType.drawing:
          // Reuse validated drawings if they occur multiple times in the pattern
          PatternDrawingField f = PatternDrawingField.fromJson(fieldObject);
          if (f.drawing != null) {
            if (validatedDrawings.containsKey(f.drawing!.id)) {
              f = f.copyWith(drawing: validatedDrawings[f.drawing!.id]);
            } else {
              f = f.copyWith(drawing: f.drawing!.validate());
              validatedDrawings[f.drawing!.id] = f.drawing!;
            }
          }
          fields.add(f);
          break;
        case PatternFieldType.image:
          fields.add(PatternImageField.fromJson(fieldObject));
          break;
        case PatternFieldType.panel:
          fields.add(PatternPanelField.fromJson(fieldObject));
          break;
      }
    }
    
    return KnittingPattern(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      fields: fields,
      pageLayout: PatternPageLayout.fromJson(json['layout']),
    );
  }
}
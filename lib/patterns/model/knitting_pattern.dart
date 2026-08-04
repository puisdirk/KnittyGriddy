import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';

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
  final List<KnittingChart> usedKnittingCharts;

  const KnittingPattern({
    required this.id,
    required this.name,
    this.description = '',
    this.fields = const[],
    this.usedKnittingCharts = const[],
  });

  KnittingPattern copyWith({
    String? id,
    String? name,
    String? description,
    List<PatternField>? fields,
    List<KnittingChart>? usedKnittingCharts,
  }) {
    return KnittingPattern(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      fields: fields?? this.fields,
      usedKnittingCharts: usedKnittingCharts?? this.usedKnittingCharts,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ fields.hashCode ^ usedKnittingCharts.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingPattern &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(fields, other.fields) &&
      listEquals(usedKnittingCharts, other.usedKnittingCharts);

    Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fields': fields.map((f) => f.toJson()).toList(),
      'usedCharts': usedKnittingCharts.map((kc) => kc.toJson()).toList(),
    };
  }

  static KnittingPattern fromJson(Map<String, dynamic> json) {
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
          fields.add(PatternDrawingField.fromJson(fieldObject));
          break;
        case PatternFieldType.image:
          fields.add(PatternImageField.fromJson(fieldObject));
          break;
        case PatternFieldType.panel:
          fields.add(PatternPanelField.fromJson(fieldObject));
          break;
      }
    }
    
    List<KnittingChart> charts = [];
    List<Map<String, dynamic>> chartObjects = (json['usedCharts'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> chartObject in chartObjects) {
      charts.add(KnittingChart.fromJson(chartObject));
    }

    return KnittingPattern(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      fields: fields,
      usedKnittingCharts: charts,
    );
  }
}
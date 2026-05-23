
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/elements/curve.dart';
import 'package:knitty_griddy/drawings/model/elements/drawing_element.dart';
import 'package:knitty_griddy/drawings/model/elements/line.dart';
import 'package:knitty_griddy/drawings/model/elements/measurement_decoration.dart';
import 'package:knitty_griddy/drawings/model/measurement_requirement.dart';
import 'package:knitty_griddy/drawings/model/elements/point.dart';

const String placeholderDrawingId = '_placeholder_drawing_id_';
const Drawing placeholderDrawing = Drawing(
  id: placeholderDrawingId, 
  name: placeholderDrawingId
);

@immutable
class Drawing {
  final String id;
  final String name;
  final String description;
  final List<DrawingElement> elements;
  final List<MeasurementRequirement> measurementRequirements;

  const Drawing({
    required this.id,
    required this.name,
    this.description = '',
    this.elements = const[],
    this.measurementRequirements = const[],
  });

  Drawing copyWith({
    String? id,
    String? name,
    String? description,
    List<DrawingElement>? elements,
    List<MeasurementRequirement>? measurementRequirements,
  }) {
    return Drawing(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      elements: elements?? this.elements,
      measurementRequirements: measurementRequirements?? this.measurementRequirements,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'elements': elements.map((e) => e.toJson()).toList(),
      'mreqs': measurementRequirements.map((e) => e.toJson()).toList(),
    };
  }

  static Drawing fromJson(Map<String, dynamic> json) {
    List<DrawingElement> elements = [];
    List<Map<String, dynamic>> elementObjects = (json['elements'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> elementObject in elementObjects) {
      switch (elementObject['type'] as String) {
        case drawingTypePoint:
          elements.add(Point.fromJson(elementObject));
          break;
        case drawingTypeLine:
          elements.add(Line.fromJson(elementObject));
          break;
        case drawingTypeCurve:
          elements.add(Curve.fromJson(elementObject));
          break;
        case drawingTypeMeasurementDecoration:
          elements.add(MeasurementDecoration.fromJson(elementObject));
          break;
        default:
          throw Exception('Unknown drawing element type ${elementObject['type']}');
      }
    }

    List<MeasurementRequirement> measurementRequirements = [];
    List<Map<String, dynamic>> reqObjects = (json['mreqs'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> reqObject in reqObjects) {
      measurementRequirements.add(MeasurementRequirement.fromJson(reqObject));
    }

    return Drawing(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      elements: elements,
      measurementRequirements: measurementRequirements,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is Drawing &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description;
}
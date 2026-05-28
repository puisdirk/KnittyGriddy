
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_decoration_command.dart';
import 'package:knitty_griddy/drawings/model/measurement_requirement.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';

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
  final List<DrawingCommand> commands;
  final List<MeasurementRequirement> measurementRequirements;

  const Drawing({
    required this.id,
    required this.name,
    this.description = '',
    this.commands = const[],
    this.measurementRequirements = const[],
  });

  Drawing copyWith({
    String? id,
    String? name,
    String? description,
    List<DrawingCommand>? commands,
    List<MeasurementRequirement>? measurementRequirements,
  }) {
    return Drawing(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      commands: commands?? this.commands,
      measurementRequirements: measurementRequirements?? this.measurementRequirements,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'commands': commands.map((e) => e.toJson()).toList(),
      'mreqs': measurementRequirements.map((e) => e.toJson()).toList(),
    };
  }

  static Drawing fromJson(Map<String, dynamic> json) {
    List<DrawingCommand> commands = [];
    List<Map<String, dynamic>> commandObjects = (json['commands'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> commandObject in commandObjects) {
      switch (commandObject['type'] as String) {
        case drawingTypePoint:
          commands.add(PointCommand.fromJson(commandObject));
          break;
        case drawingTypeLine:
          commands.add(LineCommand.fromJson(commandObject));
          break;
        case drawingTypeCurve:
          commands.add(CurveCommand.fromJson(commandObject));
          break;
        case drawingTypeMeasurementDecoration:
          commands.add(MeasurementDecorationCommand.fromJson(commandObject));
          break;
        default:
          throw Exception('Unknown drawing element type ${commandObject['type']}');
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
      commands: commands,
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

    List<LineCommand> get lines => commands.whereType<LineCommand>().toList();
    List<PointCommand> get points => commands.whereType<PointCommand>().toList();
    LineCommand? lineById(String id) {
      try {
        return commands.firstWhere((c) => c.id == id && c is LineCommand) as LineCommand;
      } catch (e) {
        return null;
      }
    }
    PointCommand? pointById(String id) {
      if (id == originId) {
        return origin;
      }
      
      try {
        return commands.firstWhere((c) => c.id == id && c is PointCommand) as PointCommand;
      } catch (e) {
        return null;
      }
    }
}
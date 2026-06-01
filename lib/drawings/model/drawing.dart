
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

  List<LineCommand> get lines => commands.whereType<LineCommand>().toList();
  List<PointCommand> get points => commands.whereType<PointCommand>().toList();
  List<CurveCommand> get curves => commands.whereType<CurveCommand>().toList();

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

  CurveCommand? curveById(String id) {
    try {
      return commands.firstWhere((c) => c.id == id && c is CurveCommand) as CurveCommand;
    } catch (e) {
      return null;
    }
  }

  String get nextPointLabel {
    int nextNum = 1;
    while (true) {
      if (points.any((c) => c.label == 'p$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'p$nextNum';
  }

  String get nextLineLabel {
    int nextNum = 1;
    while (true) {
      if (lines.any((c) => c.label == 'l$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'l$nextNum';
  }

  String get nextCurveLabel {
    int nextNum = 1;
    while (true) {
      if (curves.any((c) => c.label == 'c$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'c$nextNum';
  }

  Drawing validate() {
    Drawing cleared = copyWith(commands: commands.map((c) => c.clearValidation()).toList());

    int passes = 1;
    int maxPasses = 10000;
    while (true) {
      if (cleared.commands.any((c) => !c.isValidated) && passes <= 10000) {
        // We pass through the whole list on each loop
        List<DrawingCommand> passedCommands = cleared.commands.map((c) => c.validate(cleared)).toList();
        cleared = cleared.copyWith(
          commands: passedCommands
        );
        passes++;
      } else {
        break;
      }
    }
    if (passes >= maxPasses) print('validation overflow!!!!');

    return cleared;
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
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ commands.hashCode ^ measurementRequirements.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is Drawing &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(commands, other.commands) &&
      listEquals(measurementRequirements, other.measurementRequirements);
}
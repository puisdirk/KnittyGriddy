
import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
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

  const Drawing({
    required this.id,
    required this.name,
    this.description = '',
    this.commands = const[],
  });

  Drawing copyWith({
    String? id,
    String? name,
    String? description,
    List<DrawingCommand>? commands,
  }) {
    return Drawing(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      commands: commands?? this.commands,
    );
  }

  List<MeasurementCommand> get measurements => commands.whereType<MeasurementCommand>().toList();
  List<PointCommand> get points => commands.whereType<PointCommand>().toList();
  List<LineCommand> get lines => commands.whereType<LineCommand>().toList();
  List<CurveCommand> get curves => commands.whereType<CurveCommand>().toList();
  List<VariableCommand> get variables => commands.whereType<VariableCommand>().toList();

  LineCommand? lineById(String id) {
    try {
      return commands.firstWhere((c) => c.id == id && c is LineCommand) as LineCommand;
    } catch (_) {
      return null;
    }
  }
  
  PointCommand? pointById(String id) {
    if (id == originId) {
      return origin;
    }
    
    try {
      return commands.firstWhere((c) => c.id == id && c is PointCommand) as PointCommand;
    } catch (_) {
      return null;
    }
  }

  CurveCommand? curveById(String id) {
    try {
      return commands.firstWhere((c) => c.id == id && c is CurveCommand) as CurveCommand;
    } catch (_) {
      return null;
    }
  }

  MeasurementCommand? measurementByName(String name) {
    try {
      return measurements.firstWhere((m) => m.label == name);
    } catch (_) {
      return null;
    }
  }

  VariableCommand? variableByName(String name) {
    try {
      return variables.firstWhere((v) => v.label == name);
    } catch (_) {
      return null;
    }
  }

  String get nextMeasurementLabel {
    int nextNum = 1;
    while (true) {
      if (measurements.any((c) => c.label == 'm$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'm$nextNum';
  }

  String get nextVariableLabel{
    int nextNum = 1;
    while (true) {
      if (variables.any((c) => c.label == 'v$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'v$nextNum';
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

    while (true) {
      Map<String, Set<String>> dependencies = {};
      for (DrawingCommand command in cleared.commands.where((c) => !c.validated)) {
        dependencies[command.id] = command.dependencies(this);
      }
      DirectedGraph<String> graph = DirectedGraph(dependencies);
      List<String> cycles = graph.cycle;

      if (cycles.isEmpty) break;
        String cycleDescription = cycles.map((cycle) => commands.firstWhere((c) => c.id == cycle).label).join(' -> ');
        cleared = cleared.copyWith(
          commands: cleared.commands.map((c) => cycles.contains(c.id) ? c.markAsCyclic(cycleDescription) : c).toList()
        );
    }

    int passes = 0;
    int maxPasses = 1000;
    while (true) {
      if (cleared.commands.any((c) => !c.validated) && passes <= maxPasses) {
        // We pass through the whole list on each loop as dependencies may not be solved yet
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
    };
  }

  static Drawing fromJson(Map<String, dynamic> json) {
    List<DrawingCommand> commands = [];
    List<Map<String, dynamic>> commandObjects = (json['commands'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> commandObject in commandObjects) {
      DrawingCommandTypes commandType = DrawingCommandTypes.values.byName(commandObject['type'] as String);
      switch (commandType) {
        case DrawingCommandTypes.pointCommand:
          commands.add(PointCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.lineCommand:
          commands.add(LineCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.curveCommand:
          commands.add(CurveCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.measurementCommand:
          commands.add(MeasurementCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.variableCommand:
          commands.add(VariableCommand.fromJson(commandObject));
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
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ commands.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is Drawing &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(commands, other.commands);
}
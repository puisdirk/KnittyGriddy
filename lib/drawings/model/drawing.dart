
import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';

const bool printDebugTiming = false;

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

  void _printTiming(String message) {
    if (printDebugTiming) {
      print(message);
    }
  }

  Rect getBoundingBox() {
    int lastTick = 0;
    Stopwatch stopwatch = Stopwatch()..start();

    _printTiming('------- start bounding box -------');

    Rect bbox = Rect.zero;
    for (DrawingCommand command in commands) {
      Rect cbbox = command.getBoundingBox(this);

      _printTiming('got bbox of ${command.label} in ${stopwatch.elapsedMilliseconds - lastTick})');
      lastTick = stopwatch.elapsedMilliseconds;

      bbox = bbox.expandToInclude(cbbox);
    }

    _printTiming('------- end bbox in ${stopwatch.elapsedMilliseconds} ------');
    stopwatch.stop();

    return bbox;
  }

  List<MeasurementCommand> get measurements => commands.whereType<MeasurementCommand>().toList();
  List<PointCommand> get points => commands.whereType<PointCommand>().toList();
  List<LineCommand> get lines => commands.whereType<LineCommand>().toList();
  List<CurveCommand> get curves => commands.whereType<CurveCommand>().toList();
  List<VariableCommand> get variables => commands.whereType<VariableCommand>().toList();
  List<PartCommand> get parts => commands.whereType<PartCommand>().toList();
  List<DrawingCommand> get linesAndCurves => [...lines, ...curves];
  List<PartInfo> get partInfos {
    Drawing validated = validate();
    List<PartInfo> infos = [];

    for (PartCommand part in validated.parts) {
      infos.add(part.getInfo(validated));
    }

    return infos;
  }

  DrawingCommand commandById(String id) {
    return commands.firstWhere((c) => c.id == id);
  }

  String commandLabel(String id) {
    return commandById(id).label;
  }

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

  PointCommand? pointByName(String name) {
    if (name == 'origin') return origin;

    try {
      return points.firstWhere((p) => p.label.replaceAll('_', ' ') == name.replaceAll('_', ' '));
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
      return measurements.firstWhere((m) => m.label.replaceAll('_', ' ') == name.replaceAll('_', ' '));
    } catch (_) {
      return null;
    }
  }

  VariableCommand? variableByName(String name) {
    try {
      return variables.firstWhere((v) => v.label.replaceAll('_', ' ') == name.replaceAll('_', ' '));
    } catch (_) {
      return null;
    }
  }

  LineCommand? lineByName(String name) {
    try {
      return lines.firstWhere((l) => l.label.replaceAll('_', ' ') == name.replaceAll('_', ' '));
    } catch (_) {
      return null;
    }
  }

  PartCommand? partById(String id) {
    try {
      return commands.firstWhere((c) => c.id == id && c is PartCommand) as PartCommand;
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

  String get nextPartLabel {
    int nextNum = 1;
    while (true) {
      if (curves.any((c) => c.label == 'part$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'part$nextNum';
  }

  String get nextIncludedPartLabel {
    int nextNum = 1;
    while (true) {
      if (curves.any((c) => c.label == 'subpart$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return 'subpart$nextNum';
  }

  Drawing validate() {
    int lastTick = 0;
    Stopwatch stopwatch = Stopwatch()..start();
    _printTiming('----------- validating ----------');
    Drawing cleared = copyWith(commands: commands.map((c) => c.clearValidation()).toList());

    _printTiming('cleared (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;
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
    _printTiming('dependencies checked (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;
    int valstartTick = lastTick;

    int passes = 0;
    int maxPasses = 1000;
    while (true) {
      if (cleared.commands.any((c) => !c.validated) && passes <= maxPasses) {
        _printTiming('pass $passes');
        // We pass through the whole list on each loop as dependencies may not be solved yet
        List<DrawingCommand> passedCommands = cleared.commands.map((c) {
          if (!c.validated) {
            DrawingCommand r = c.validate(cleared);
            _printTiming('validation of ${r.label}: ${stopwatch.elapsedMilliseconds - lastTick}msec. Validated: ${r.validated}');
            lastTick = stopwatch.elapsedMilliseconds;
            return r;
          }
          return c;
          
//          return c.validate(cleared);
        }).toList();
        cleared = cleared.copyWith(
          commands: passedCommands
        );
        passes++;
      } else {
        break;
      }
    }

    if (passes >= maxPasses) _printTiming('validation overflow!!!!');
    _printTiming('validated in $passes passes (${stopwatch.elapsedMilliseconds - valstartTick})');

    _printTiming('----------- end validation (${stopwatch.elapsedMilliseconds}) ----------');
    stopwatch.stop();
    
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
        case DrawingCommandTypes.partCommand:
          commands.add(PartCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.includedPartCommand:
          commands.add(IncludedPartCommand.fromJson(commandObject));
        default:
          throw Exception('Unknown drawing element type ${commandObject['type']}');
      }
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
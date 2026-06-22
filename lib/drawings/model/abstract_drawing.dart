
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';

const bool printDebugTiming = false;

abstract class AbstractDrawing {
  final String id;
  final String name;
  final String description;
  final List<DrawingCommand> commands;
  final Offset offset;

  const AbstractDrawing({
    required this.id,
    required this.name,
    this.description = '',
    this.commands = const[],
    this.offset = Offset.zero,
  });

  AbstractDrawing abstractCopyWith({
    String? name,
    String? description,
    List<DrawingCommand>? commands,
    Offset? offset,
  });

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ commands.hashCode ^ offset.hashCode;

    @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is AbstractDrawing &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(commands, other.commands) &&
      offset == other.offset;

  AbstractDrawing validate();

  void printTiming(String message) {
    if (printDebugTiming) {
      print(message);
    }
  }

  Rect getBoundingBox() {
    int lastTick = 0;
    Stopwatch stopwatch = Stopwatch()..start();

    printTiming('------- start bounding box -------');

    Rect bbox = Rect.zero;
    for (DrawingCommand command in commands) {
      Rect cbbox = command.getBoundingBox(this);

      printTiming('got bbox of ${command.label} in ${stopwatch.elapsedMilliseconds - lastTick})');
      lastTick = stopwatch.elapsedMilliseconds;

      bbox = bbox.expandToInclude(cbbox);
    }

    printTiming('------- end bbox in ${stopwatch.elapsedMilliseconds} ------');
    stopwatch.stop();

    return bbox;
  }

  static List<DrawingCommand> commandsFromJson(Map<String, dynamic> json) {
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
    return commands;
  }


  List<MeasurementCommand> get measurements => commands.whereType<MeasurementCommand>().toList();
  List<PointCommand> get points => commands.whereType<PointCommand>().toList();
  List<LineCommand> get lines => commands.whereType<LineCommand>().toList();
  List<CurveCommand> get curves => commands.whereType<CurveCommand>().toList();
  List<VariableCommand> get variables => commands.whereType<VariableCommand>().toList();
  List<PartCommand> get parts => commands.whereType<PartCommand>().toList();
  List<DrawingCommand> get linesAndCurves => [...lines, ...curves];

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
  
  String nextLabel(String prefix) {
    int nextNum = 1;
    while (true) {
      if (commands.any((c) => c.label == '$prefix$nextNum')) {
        nextNum++;
      } else {
        break;
      }
    }
    return '$prefix$nextNum';
  }

}
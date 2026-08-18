
import 'dart:ui';

import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/commands/comment_command.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/commands/tape_command.dart';
import 'package:knitty_griddy/drawings/model/commands/text_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';

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

  List<Color> get knownColours => const[];

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

  AbstractDrawing validate() {
    print('validate called for $name');
    int lastTick = 0;
    Stopwatch stopwatch = Stopwatch()..start();
    printTiming('----------- validating ----------');
    AbstractDrawing clearedDrawing = abstractCopyWith(
      commands: commands.map((c) => c.clearValidation()).toList(),
    );

    printTiming('cleared (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;
    while (true) {
      Map<String, Set<String>> dependencies = {};
      for (DrawingCommand command in clearedDrawing.commands.where((c) => !c.validated)) {
        dependencies[command.id] = command.dependencies(this);
      }
      DirectedGraph<String> graph = DirectedGraph(dependencies);
      List<String> cycles = graph.cycle;

      if (cycles.isEmpty) break;
        String cycleDescription = cycles.map((cycle) => commands.firstWhere((c) => c.id == cycle).label).join(' -> ');
        clearedDrawing = clearedDrawing.abstractCopyWith(
          commands: clearedDrawing.commands.map((c) => cycles.contains(c.id) ? c.markAsCyclic(cycleDescription) : c).toList()
        );
    }
    printTiming('dependencies checked (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;
    int valstartTick = lastTick;

    int passes = 0;
    int maxPasses = 1000;
    while (true) {
      if (clearedDrawing.commands.any((c) => !c.validated) && passes <= maxPasses) {
        printTiming('pass $passes');
        // We pass through the whole list on each loop as dependencies may not be solved yet
        List<DrawingCommand> passedCommands = clearedDrawing.commands.map((c) {
          if (!c.validated) {
            DrawingCommand r = c.validate(clearedDrawing);
            printTiming('validation of ${r.label}: ${stopwatch.elapsedMilliseconds - lastTick}msec. Validated: ${r.validated}');
            lastTick = stopwatch.elapsedMilliseconds;
            return r;
          }
          return c;
        }).toList();
        clearedDrawing = clearedDrawing.abstractCopyWith(
          commands: passedCommands
        );
        passes++;
      } else {
        break;
      }
    }
    //print('$passes validation passes for $name');
    if (passes >= maxPasses) printTiming('validation overflow!!!!');
    printTiming('validated in $passes passes (${stopwatch.elapsedMilliseconds - valstartTick})');

    printTiming('----------- end validation (${stopwatch.elapsedMilliseconds}) ----------');
    stopwatch.stop();
    
    return clearedDrawing;
  }

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
        case DrawingCommandTypes.commentCommand:
          commands.add(CommentCommand.fromJson(commandObject));
          break;
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
          break;
        case DrawingCommandTypes.stylingCommand:
          commands.add(StylingCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.textCommand:
          commands.add(TextCommand.fromJson(commandObject));
          break;
        case DrawingCommandTypes.tapeCommand:
          commands.add(TapeCommand.fromJson(commandObject));
          break;
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
  List<IncludedPartCommand> get includedParts => commands.whereType<IncludedPartCommand>().toList();
  List<DrawingCommand> get pointsLinesAndCurves => [...points, ...lines, ...curves];
  List<DrawingCommand> get linesAndCurvesIncluded => [...linesIncluded, ...curvesIncluded];
  List<DrawingCommand> get pointLinesAndCurvesIncluded => [...pointsIncluded, ...linesIncluded, ...curvesIncluded];
  List<DrawingCommand> get pointLinesCurvesAndTapesIncluded => [...pointsIncluded, ...linesIncluded, ...curvesIncluded, ...tapes];
  List<DrawingCommand> get linesCurvesAndTapesIncluded => [...linesIncluded, ...curvesIncluded, ...tapes];

  StylingCommand? styleFor(String id) {
    if (commands.whereType<StylingCommand>().any((s) => s.commandIds.contains(id))) {
      return commands.whereType<StylingCommand>().firstWhere((s) => s.commandIds.contains(id));
    }
    return null;
  }

  String commandLabelIncluded(String id) {
    if (id == originId) return origin.label;
    if (pointLinesCurvesAndTapesIncluded.any((c) => c.id == id)) {
      return pointLinesCurvesAndTapesIncluded.firstWhere((c) => c.id == id).label;
    }
    return '???';
  }

  List<TapeCommand> get tapes => commands.whereType<TapeCommand>().toList();

  List<LineCommand> get linesIncluded {
    List<LineCommand> lines = commands.whereType<LineCommand>().toList();
    for (IncludedPartCommand cmd in includedParts) {
      if (cmd.partDrawingId.isNotEmpty) {
        PartDrawing? pd = PartRepository.getPartDrawingById(cmd.partDrawingId);
        if (pd != null) {
          PartCommand? part = pd.partById(cmd.partId);
          if (part != null) {
            lines.addAll(part.lines(pd).map((l) => l.copyWith(id: '${pd.id}.${l.id}.${cmd.id}', label: '${cmd.label}.${l.label}')));
          }
        }
      }
    }
    return lines;
  }

  List<PointCommand> get pointsIncluded {
    List<PointCommand> points = commands.whereType<PointCommand>().toList();
    for (IncludedPartCommand cmd in includedParts) {
      if (cmd.partDrawingId.isNotEmpty) {
        PartDrawing? pd = PartRepository.getPartDrawingById(cmd.partDrawingId);
        if (pd != null) {
          PartCommand? part = pd.partById(cmd.partId);
          if (part != null) {
            points.addAll(part.points(pd).map((p) => p.copyWith(id: '${pd.id}.${p.id}.${cmd.id}', label: '${cmd.label}.${p.label}')));
          }
        }
      }
    }
    return points;
  }

  List<CurveCommand> get curvesIncluded {
    List<CurveCommand> curves = commands.whereType<CurveCommand>().toList();
    for (IncludedPartCommand cmd in includedParts) {
      if (cmd.partDrawingId.isNotEmpty) {
        PartDrawing? pd = PartRepository.getPartDrawingById(cmd.partDrawingId);
        if (pd != null) {
          PartCommand? part = pd.partById(cmd.partId);
          if (part != null) {
            curves.addAll(part.curves(pd).map((c) => c.copyWith(id: '${pd.id}.${c.id}.${cmd.id}', label: '${cmd.label}.${c.label}')));
          }
        }
      }
    }
    return curves;
  }

  DrawingCommand? commandById(String id) {
    if (id.contains('.')) {
      String includedPartCommandId = id.split('.')[2];
      IncludedPartCommand c = commands.firstWhere((c) => c is IncludedPartCommand && c.id == includedPartCommandId) as IncludedPartCommand;
      if (c.storedOffsetPartDrawing != null) {
        return c.storedOffsetPartDrawing!.commands.firstWhere((c) => c.id == id.split('.')[1]);
      }
    }

    try {
      return commands.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  String commandLabel(String id) {
    DrawingCommand? c = commandById(id);
    return c == null ? '' : c.label;
  }

  LineCommand? lineById(String id) {
    if (id.contains('.')) {
      String includedPartCommandId = id.split('.')[2];
      IncludedPartCommand c = commands.firstWhere((c) => c is IncludedPartCommand && c.id == includedPartCommandId) as IncludedPartCommand;
      if (c.storedOffsetPartDrawing != null) {
        return c.storedOffsetPartDrawing!.lineById(id.split('.')[1]);
      }
    }
    
    try {
      return linesIncluded.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
  
  PointCommand? pointById(String id) {
    if (id == originId) {
      return origin;
    }

    if (id.contains('.')) {
      String includedPartCommandId = id.split('.')[2];
      IncludedPartCommand c = commands.firstWhere((c) => c is IncludedPartCommand && c.id == includedPartCommandId) as IncludedPartCommand;
      if (c.storedOffsetPartDrawing != null) {
        return c.storedOffsetPartDrawing!.pointById(id.split('.')[1]);
      }
    }
    
    try {
      return pointsIncluded.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  PointCommand? pointByName(String name) {
    if (name == 'origin') return origin;

    if (name.contains('.')) {
      String includedPartCommandName = name.split('.').first;
      IncludedPartCommand c = commands.firstWhere((c) => c is IncludedPartCommand && c.label == includedPartCommandName.replaceAll('_', ' ')) as IncludedPartCommand;
      if (c.storedOffsetPartDrawing != null) {
        return c.storedOffsetPartDrawing!.pointByName(name.split('.')[1]);
      }
    }
    
    try {
      return pointsIncluded.firstWhere((p) => p.label.replaceAll('_', ' ') == name.replaceAll('_', ' '));
    } catch (_) {
      return null;
    }
  }

  CurveCommand? curveById(String id) {
    if (id.contains('.')) {
      String includedPartCommandId = id.split('.')[2];
      IncludedPartCommand c = commands.firstWhere((c) => c is IncludedPartCommand && c.id == includedPartCommandId) as IncludedPartCommand;
      if (c.storedOffsetPartDrawing != null) {
        return c.storedOffsetPartDrawing!.curveById(id.split('.')[1]);
      }
    }
    
    try {
      return curvesIncluded.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  MeasurementCommand? measurementById(String id) {
    try {
      return measurements.firstWhere((m) => m.id == id);
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
    if (name.contains('.')) {
      String partDrawingName = name.split('.').first;
      IncludedPartCommand c = commands.firstWhere((c) => c is IncludedPartCommand && c.label == partDrawingName.replaceAll('_', ' ')) as IncludedPartCommand;
      if (c.storedOffsetPartDrawing != null) {
        return c.storedOffsetPartDrawing!.lineByName(name.split('.')[1]);
      }
    }
    
    try {
      return linesIncluded.firstWhere((l) => l.label.replaceAll('_', ' ') == name.replaceAll('_', ' '));
    } catch (_) {
      return null;
    }
  }

  PartCommand? partById(String id) {
    try {
      return parts.firstWhere((c) => c.id == id);
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

  String nextLabelForType(DrawingCommand cmd) {
    if (cmd is MeasurementCommand) return nextLabel('m');
    if (cmd is VariableCommand) return nextLabel('v');
    if (cmd is PointCommand) return nextLabel('p');
    if (cmd is LineCommand) return nextLabel('l');
    if (cmd is CurveCommand) return nextLabel('c');
    if (cmd is PartCommand) return nextLabel('part');
    if (cmd is IncludedPartCommand) return nextLabel('subpart');
    if (cmd is StylingCommand) return nextLabel('style');
    if (cmd is TextCommand) return nextLabel('text');
    if (cmd is TapeCommand) return nextLabel('tape');
    return '';
  }

}
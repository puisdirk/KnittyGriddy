
import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';

@immutable
class PartDrawing extends AbstractDrawing {
  final String category;

  const PartDrawing({
    required super.id,
    required super.name,
    super.description,
    super.commands,
    super.offset,
    String? category,
  }) : category = category?? '';

  PartDrawing copyWith({
    String? id,
    String? name,
    String? description,
    List<DrawingCommand>? commands,
    String? category,
    Offset? offset,
  }) {
    return PartDrawing(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      commands: commands?? this.commands,
      category: category?? this.category,
      offset: offset?? this.offset,
    );
  }

  @override
  AbstractDrawing abstractCopyWith({
    String? name, 
    String? description, 
    List<DrawingCommand>? commands,
    Offset? offset,
  }) {
    return PartDrawing(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
      commands: commands?? this.commands,
      offset: offset?? this.offset,
      category: category,
    );
  }


  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'commands': commands.map((e) => e.toJson()).toList(),
      'category': category,
    };
  }

  static PartDrawing fromJson(Map<String, dynamic> json) {
    List<DrawingCommand> commands = AbstractDrawing.commandsFromJson(json);

    return PartDrawing(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      commands: commands,
      category: json['category'] as String,
    );
  }

  bool passesFilter(String filter) =>
    name.toLowerCase().contains(filter.toLowerCase()) || 
    category.toLowerCase().contains(filter.toLowerCase()) || 
    description.toLowerCase().contains(filter.toLowerCase()
  );

  bool sameContentAs(PartDrawing other) {
    return this == other ||
      name == other.name &&
      listEquals(commands, other.commands) &&
      category == other.category;
  }

  List<PartInfo> get validPartInfos {
    List<PartInfo> partInfos = [];
    for (PartCommand cmd in commands.whereType()) {
      if (cmd.validated && cmd.valid) {
        partInfos.add(PartInfo(partDrawingId: id, category: category, partId: cmd.id, partLabel: cmd.label));
      }
    }
    return partInfos;
  }

  @override
  PartDrawing validate() {
    int lastTick = 0;
    Stopwatch stopwatch = Stopwatch()..start();
    printTiming('----------- validating ----------');
    PartDrawing cleared = copyWith(commands: commands.map((c) => c.clearValidation()).toList());

    printTiming('cleared (${stopwatch.elapsedMilliseconds - lastTick})');
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
    printTiming('dependencies checked (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;
    int valstartTick = lastTick;

    int passes = 0;
    int maxPasses = 1000;
    while (true) {
      if (cleared.commands.any((c) => !c.validated) && passes <= maxPasses) {
        printTiming('pass $passes');
        // We pass through the whole list on each loop as dependencies may not be solved yet
        List<DrawingCommand> passedCommands = cleared.commands.map((c) {
          if (!c.validated) {
            DrawingCommand r = c.validate(cleared);
            printTiming('validation of ${r.label}: ${stopwatch.elapsedMilliseconds - lastTick}msec. Validated: ${r.validated}');
            lastTick = stopwatch.elapsedMilliseconds;
            return r;
          }
          return c;
        }).toList();
        cleared = cleared.copyWith(
          commands: passedCommands
        );
        passes++;
      } else {
        break;
      }
    }

    if (passes >= maxPasses) printTiming('validation overflow!!!!');
    printTiming('validated in $passes passes (${stopwatch.elapsedMilliseconds - valstartTick})');

    printTiming('----------- end validation (${stopwatch.elapsedMilliseconds}) ----------');
    stopwatch.stop();
    
    return cleared;
  }
}
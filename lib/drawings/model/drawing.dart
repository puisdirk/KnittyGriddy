import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/meaurement_override.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';

const String placeholderDrawingId = '_placeholder_drawing_id_';
const Drawing placeholderDrawing = Drawing(
  id: placeholderDrawingId, 
  name: placeholderDrawingId
);

@immutable
class Drawing extends AbstractDrawing {
  final List<PartDrawing> usedPartDrawings;

  const Drawing({
    required super.id,
    required super.name,
    super.description,
    super.commands,
    super.offset,
    this.usedPartDrawings = const[],
  });

  bool get validated => !commands.any((c) => !c.validated);

  Drawing copyWith({
    String? id,
    String? name,
    String? description,
    List<DrawingCommand>? commands,
    Offset? offset,
    List<PartDrawing>? usedPartDrawings,
  }) {
    return Drawing(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
      commands: commands?? this.commands,
      offset: offset?? this.offset,
      usedPartDrawings: usedPartDrawings?? this.usedPartDrawings,
    );
  }

  @override
  Drawing abstractCopyWith({
    String? name, 
    String? description, 
    List<DrawingCommand>? commands,
    Offset? offset,
  }) {
    return Drawing(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
      commands: commands?? this.commands,
      offset: offset?? this.offset,
      usedPartDrawings: usedPartDrawings,
    );
  }

  // We store the drawings of included parts inside the drawing. If the part gets
  // deleted, we will restore the drawing of the included part into the imported partset
  Drawing updateIncludedDrawings() {
    Set<PartDrawing> includedDrawings = {};
    for (IncludedPartCommand cmd in commands.whereType()) {
      if (cmd.validated && cmd.valid) {
        PartDrawing? partDrawing = PartRepository.getPartDrawingById(cmd.partDrawingId);
        if (partDrawing != null) {
          includedDrawings.add(partDrawing);
        }
      }
    }
    return copyWith(usedPartDrawings: includedDrawings.toList());
  }

  Drawing fixMeasurementOverrides() {
    return copyWith(
      commands: commands.map((cmd) {
        if (cmd is! IncludedPartCommand) return cmd;
        if (cmd.partDrawingId.isEmpty) return cmd;
        PartDrawing? partDrawing = PartRepository.getPartDrawingById(cmd.partDrawingId);
        if (partDrawing == null) return cmd;
        PartCommand? partCommand = partDrawing.partById(cmd.partId);
        if (partCommand == null) return cmd;

        // delete measurements that are no longer in the part
        Map<String, MeasurementOverride> newOverrides = {};
        for (MeasurementOverride oldOverride in cmd.measurementOverrides) {
          // does the partdrawing still have this measurement?
          MeasurementCommand? mcmd = partDrawing.measurementById(oldOverride.measurementId);
          if (mcmd != null) {
            // Unit or label may have changed
            newOverrides[oldOverride.measurementId] = oldOverride.copyWith(unit: mcmd.unit, measurementLabel: mcmd.label);
          }
        }

        // add measurement overrides for new measurements in the part if there are any
        for (MeasurementCommand mcmd in partDrawing.measurements) {
          if (!newOverrides.containsKey(mcmd.id)) {
            String formula = mcmd.value.toString();
            if (measurements.any((m) => m.label == mcmd.label)) {
              formula = '@${mcmd.label.replaceAll(' ', '_')}';
            }
            newOverrides[mcmd.id] = MeasurementOverride(
              measurementId: mcmd.id, 
              measurementLabel: mcmd.label, 
              formula: formula, 
              unit: mcmd.unit
            );
          }
        }

        return cmd.copyWith(
          measurementOverrides: newOverrides.values.toList()
        );
      }).toList()
    );
  }

  @override
  Drawing validate() => super.validate() as Drawing;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'commands': commands.map((e) => e.toJson()).toList(),
      'parts': usedPartDrawings.map((e) => e.toJson()).toList(),
    };
  }

  static Drawing fromJson(Map<String, dynamic> json) {
    List<DrawingCommand> commands = AbstractDrawing.commandsFromJson(json);

    List<PartDrawing> usedPartDrawings = [];
    List<Map<String, dynamic>> partObjects = (json['parts'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> partObject in partObjects) {
      usedPartDrawings.add(PartDrawing.fromJson(partObject));
    }

    return Drawing(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      commands: commands,
      usedPartDrawings: usedPartDrawings,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ commands.hashCode ^ usedPartDrawings.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is Drawing &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(commands, other.commands) &&
      listEquals(usedPartDrawings, other.usedPartDrawings);
}
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
  PartDrawing abstractCopyWith({
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
    bool commandsEqual = listEquals(commands, other.commands);
    return this == other ||
      name == other.name &&
      commandsEqual &&
//      listEquals(commands, other.commands) &&
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
  PartDrawing validate() => super.validate() as PartDrawing;
}
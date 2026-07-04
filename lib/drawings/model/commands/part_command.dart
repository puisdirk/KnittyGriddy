import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PartCommand extends DrawingCommand {

  final Set<String> commandIds;
  final String anchorPointId;

  const PartCommand({
    required super.id,
    required super.version,
    required super.label,
    this.commandIds = const{},
    this.anchorPointId = originId,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen
  });

  PartCommand copyWith({
    String? label,
    Set<String>? commandIds,
    String? anchorPointId,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return PartCommand(
      id: id, 
      version: version + 1,
      label: label?? this.label,
      commandIds: commandIds?? this.commandIds,
      anchorPointId: anchorPointId?? this.anchorPointId,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  List<LineCommand> lines(PartDrawing partDrawing) {
    return partDrawing.lines.where((l) => commandIds.contains(l.id)).toList();
  }

  List<PointCommand> points(PartDrawing partDrawing) {
    return partDrawing.points.where((p) => commandIds.contains(p.id)).toList();
  }

  List<CurveCommand> curves(PartDrawing partDrawing) {
    return partDrawing.curves.where((p) => commandIds.contains(p.id)).toList();
  }

  @override
  String previewPath(AbstractDrawing drawing) {
    if (validated && valid) {
      String p = '';
      for (String cmdId in commandIds) {
        DrawingCommand cmd = drawing.commandById(cmdId);
        p += cmd.previewPath(drawing);
      }
      return p;
    }

    return '';
  }

  @override
  double get editHeight => 310;

  Rect calculateBoundingBox(AbstractDrawing drawing) {
    if (valid) {
      Rect r = Rect.zero;
      for (String commandId in commandIds) {
        DrawingCommand command = drawing.commandById(commandId);
        r = r.expandToInclude(command.getBoundingBox(drawing));
      }
      return r;
    }

    return Rect.zero;
  }

  // We avoid expensive calculation as we don't require this in a PartDrawing
  // (existing lines and curves are already included)
  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    return Rect.zero;
  }

  @override
  PartCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  PartCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    return commandIds;
  }

  @override
  PartCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  PartCommand changePartDrawingReference({required String oldId, required String newId}) => this;

  @override
  PartCommand deleteReference({required String commandId}) {
    if (commandIds.contains(commandId) || anchorPointId == commandId) {
      return copyWith(
        commandIds: commandIds.where((c) => c != commandId).toSet(),
        anchorPointId: anchorPointId == commandId ? originId : anchorPointId,
      );
    } else {
      return this;
    }
  }

  @override
  PartCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return this;
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = ''}) {
    for (String commandId in commandIds) {
      DrawingCommand command = drawing.commandById(commandId);
      command.paint(canvas, size, drawing, selected, asPart: true, prefixLabel: prefixLabel);
    }

    // Draw anchor on the anchor point
    PointCommand? anchorPoint = drawing.pointById(anchorPointId);
    if (anchorPoint != null && anchorPoint.validated && anchorPoint.valid) {
      Offset? anchorCoordinate = anchorPoint.getCoordinate(drawing);
      if (anchorCoordinate != null) {
        anchorCoordinate = anchorCoordinate.scale(1, -1);
        anchorCoordinate = anchorCoordinate.translate(-10, 4);

        Offset middle = Offset(size.width / 2, size.height / 2);
        anchorCoordinate += middle;


        TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
        textPainter.text = TextSpan(
          text: String.fromCharCode(Icons.anchor.codePoint),
          style: TextStyle(fontSize: 10.0,fontFamily: Icons.anchor.fontFamily, color: selected ? selectedColor : partColor)
        );
        textPainter.layout();
        textPainter.paint(canvas, anchorCoordinate);
      }
    }
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.partCommand.name,
      'id': id,
      'label': label,
      'ids': commandIds.toList(),
      'anchor': anchorPointId,
    };
  }

  static PartCommand fromJson(Map<String, dynamic> json) {
    return PartCommand(
      id: json['id'] as String, 
      version: 0,
      label: json['label'] as String,
      commandIds: (json['ids'] as List).map((o) => o as String).toSet(),
      anchorPointId: json.containsKey('anchor') ? json['anchor'] as String : originId,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PartCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
//      version == other.version &&
      label == other.label &&
      setEquals(commandIds, other.commandIds) &&
      anchorPointId == other.anchorPointId &&
      validated == other.validated &&
      valid == other.valid &&
      listEquals(errors, other.errors);

  @override
  int get hashCode => super.hashCode ^ commandIds.hashCode ^ anchorPointId.hashCode;

  @override
  PartCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    for (String commandId in commandIds) {
      DrawingCommand command = drawing.commandById(commandId);
      if (!command.validated) {
        isvalid = false;
      } else if (!command.valid) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('${command.label} has errors');
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }

}
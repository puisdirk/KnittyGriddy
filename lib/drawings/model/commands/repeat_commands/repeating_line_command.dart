import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';

class RepeatingLineCommand extends RepeatingDrawingCommand {

  final LineCommand wrappedLine;

  const RepeatingLineCommand({
    required super.id,
    required super.version,
    required super.label,
    super.validated,
    super.valid,
    super.retryValidation,
    super.errors,
    super.initiallyOpen,
    required this.wrappedLine,
  });

  RepeatingLineCommand copyWith({
    String? id, 
    String? label, 
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    bool? retryValidation,
    LineCommand? wrappedLine,
  }) {
    return RepeatingLineCommand(
      id: id?? this.id, 
      version: version + 1, 
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      retryValidation: retryValidation?? this.retryValidation,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      wrappedLine: wrappedLine?? this.wrappedLine,
    );
  }

  @override
  RepeatingLineCommand abstractCopyWith({String? id, String? label, bool? initiallyOpen}) {
    return copyWith(
      id: id?? this.id,
      label: label?? this.label,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => wrappedLine.editHeight;

  @override
  String get wrappedId => wrappedLine.id;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    return wrappedLine.getBoundingBox(drawing);
  }

  @override
  RepeatingLineCommand setInitiallyClosed() => copyWith(initiallyOpen: false);

  @override
  RepeatingLineCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  RepeatingLineCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      wrappedLine: wrappedLine.changePartDrawingReference(oldId: oldId, newId: newId)
    );
  }

  @override
  RepeatingLineCommand deleteReference({required String commandId}) {
    return copyWith(
      wrappedLine: wrappedLine.deleteReference(commandId: commandId)
    );
  }

  @override
  RepeatingLineCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      wrappedLine: wrappedLine.dependentLabelChanged(oldLabel, newLabel)
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': RepeatingDrawingCommandTypes.repeatlineCommand.name,
      'id': id,
      'label': label,
      'line': wrappedLine.toJson(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': RepeatingDrawingCommandTypes.repeatlineCommand.name,
    'label': label,
    'line': wrappedLine.contentHashCode,
  });

  static RepeatingLineCommand fromJson(Map<String, dynamic> json) {
    return RepeatingLineCommand(
      id: json['id'] as String, 
      version: 0, 
      label: json['label'] as String, 
      wrappedLine: LineCommand.fromJson(json['line']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RepeatingLineCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    wrappedLine == other.wrappedLine &&
    validated == other.validated &&
    valid == other.valid &&
    retryValidation == other.retryValidation &&
    listEquals(errors, other.errors);
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
    other is RepeatingLineCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    wrappedLine.isSameAs(other.wrappedLine);

  @override
  int get hashCode => super.hashCode ^ wrappedLine.hashCode;

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    return wrappedLine.toSvg(drawingSize, drawing, stylings: stylings);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const [], bool drawDirectionArrow = false, bool forPreview = false}) {
    wrappedLine.paint(canvas, size, drawing, selected, asPart: asPart, prefixLabel: prefixLabel, stylings: stylings, drawDirectionArrow: drawDirectionArrow, forPreview: forPreview);
  }

  @override
  RepeatingLineCommand clearValidation() => copyWith(
    validated: false,
    valid: false,
    retryValidation: true,
    errors: const[],
    wrappedLine: wrappedLine.clearValidation(),
  );

  @override
  Set<String> dependencies(AbstractDrawing drawing) => wrappedLine.dependencies(drawing);

  @override
  RepeatingLineCommand validate(AbstractDrawing drawing, RepeatCommand repeatContext, int repeatValue) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label) || repeatContext.commands.any((c) => c.id != id && c.label == label)) { 
      isvalid = false; 
      retryValidation = false; 
      validationErrors.add('Label should be unique'); 
    }

    PointCommand? fromPoint;
    if (wrappedLine.fromPointId.isEmpty) {
      isvalid = false; 
      retryValidation = false;
      validationErrors.add('Requires a source point');
    } else if (wrappedLine.fromPointId == originId) {
      fromPoint = origin;
    } else {
      fromPoint = drawing.pointById(wrappedLine.fromPointId)?? repeatContext.pointById(wrappedLine.fromPointId);
      if (fromPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Source point does not exist');
      } else if (wrappedLine.fromPointId.contains('.')) {
        // need to wait on validation of the included part command
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedLine.fromPointId.split('.')[2]);
        if (!ipc.validated) {
          isvalid = false;
        }
      } else {
        if (!fromPoint.validated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!fromPoint.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Source point ${fromPoint.label} has errors');
        }
      }
    }

    PointCommand? toPoint;
    if (wrappedLine.toPointId.isEmpty) {
      isvalid = false; 
      retryValidation = false;
      validationErrors.add('Requires a target point');
    } else if (wrappedLine.toPointId == originId) {
      toPoint = origin;
    } else {
      toPoint = drawing.pointById(wrappedLine.toPointId)?? repeatContext.pointById(wrappedLine.toPointId);
      if (toPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Target point does not exist');
      } else if (wrappedLine.toPointId.contains('.')) {
        // need to wait on validation of the included part command
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedLine.toPointId.split('.')[2]);
        if (!ipc.validated) {
          isvalid = false;
        }
      } else {
        if (!toPoint.validated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!toPoint.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Target point ${toPoint.label} has errors');
        }
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      retryValidation: retryValidation,
      errors: validationErrors,
      wrappedLine: wrappedLine.copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
        storedStartCoordinate: isvalid ? fromPoint!.getCoordinate(drawing) : null,
        storedEndCoordinate: isvalid ? toPoint!.getCoordinate(drawing) : null,
      ),
    );
  }
}
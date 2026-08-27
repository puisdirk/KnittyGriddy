
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/commands/text_command.dart';

class RepeatingTextCommand extends RepeatingDrawingCommand {
  final TextCommand wrappedText;

  const RepeatingTextCommand({
    required super.id,
    required super.version,
    required super.label,
    super.validated,
    super.valid,
    super.retryValidation,
    super.errors,
    super.initiallyOpen,
    required this.wrappedText,
  });

  RepeatingTextCommand copyWith({
    String? id,
    String? label,
    bool? validated,
    bool? valid,
    bool? retryValidation,
    List<String>? errors,
    bool? initiallyOpen,
    TextCommand? wrappedText,
  }) {
    return RepeatingTextCommand(
      id: id?? this.id, 
      version: version + 1,
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      retryValidation: retryValidation?? this.retryValidation,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      wrappedText: wrappedText?? this.wrappedText,
    );
  }
  @override
  RepeatingTextCommand abstractCopyWith({String? id, String? label, bool? initiallyOpen}) {
    return copyWith(
      id: id?? this.id,
      label: label?? this.label,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => wrappedText.editHeight;

  @override
  String get wrappedId => wrappedText.id;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) => wrappedText.getBoundingBox(drawing);

  @override
  RepeatingTextCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  RepeatingTextCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  RepeatingTextCommand clearValidation() {
    return copyWith(
      validated: false, 
      valid: false, 
      retryValidation: true, 
      errors: const[], 
      wrappedText: wrappedText.clearValidation(),
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) => wrappedText.dependencies(drawing);

  @override
  RepeatingTextCommand changePartDrawingReference({required String oldId, required String newId}) =>
    copyWith(
      wrappedText: wrappedText.changePartDrawingReference(oldId: oldId, newId: newId)
    );

  @override
  RepeatingTextCommand deleteReference({required String commandId}) => 
    copyWith(
      wrappedText: wrappedText.deleteReference(commandId: commandId)
    );

  @override
  RepeatingTextCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      wrappedText: wrappedText.dependentLabelChanged(oldLabel, newLabel)
    );
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], bool drawDirectionArrow = false, bool forPreview = false}) {
    wrappedText.paint(canvas, size, drawing, selected, asPart: asPart, prefixLabel: prefixLabel, stylings: stylings, drawDirectionArrow: drawDirectionArrow, forPreview: forPreview);
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]}) => 
    wrappedText.toSvg(drawingSize, drawing, stylings: stylings);

  @override
  Map<String, Object> toJson() {
    return {
      'type': RepeatingDrawingCommandTypes.repeattextCommand.name,
      'id': id,
      'label': label,
      'txt': wrappedText.toJson(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': RepeatingDrawingCommandTypes.repeattextCommand.name,
    'label': label,
    'txt': wrappedText.contentHashCode,
  });

  static RepeatingTextCommand fromJson(Map<String, dynamic> json) {
    return RepeatingTextCommand(
      id: json['id'] as String, 
      version: 0,
      label: json['label'] as String,
      wrappedText: TextCommand.fromJson(json['txt']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is RepeatingTextCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      valid == other.valid &&
      validated == other.validated &&
      retryValidation == other.retryValidation &&
      listEquals(errors, other.errors) &&
      wrappedText == other.wrappedText;
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
      other is RepeatingTextCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      wrappedText.isSameAs(other.wrappedText);
  
  @override
  int get hashCode => super.hashCode ^ wrappedText.hashCode;

  @override
  RepeatingTextCommand validate(AbstractDrawing drawing, RepeatCommand repeatContext, int repeatValue) {
    bool isvalid = true;
    bool shouldRetryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; shouldRetryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label) || repeatContext.commands.any((c) => c.id != id && c.label == label)) { 
      isvalid = false; 
      shouldRetryValidation = false; 
      validationErrors.add('Label should be unique'); 
    }

    PointCommand? anchorPoint;
    if (wrappedText.anchorPointId.isEmpty) {
      isvalid = false;
      shouldRetryValidation = false;
      validationErrors.add('Requires an anchor point');
    } else if (wrappedText.anchorPointId == originId) {
      anchorPoint = origin;
    } else {
      anchorPoint = drawing.pointById(wrappedText.anchorPointId)?? repeatContext.pointById(wrappedText.anchorPointId);
      if (anchorPoint == null) {
        isvalid = false;
        shouldRetryValidation = false;
        validationErrors.add('Anchor point does not exist');
      } else if (wrappedText.anchorPointId.contains('.')) {
        // need to wait on validation of the included part command
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedText.anchorPointId.split('.')[2]);
        if (!ipc.validated) {
          isvalid = false;
        }
      } else {
        if (!anchorPoint.validated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!anchorPoint.valid) {
          isvalid = false;
          shouldRetryValidation = false;
          validationErrors.add('Anchor point ${anchorPoint.label} has errors');
        }
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !shouldRetryValidation),
      retryValidation: shouldRetryValidation,
      errors: validationErrors,
      wrappedText: wrappedText.copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
      )
    );
  }

}
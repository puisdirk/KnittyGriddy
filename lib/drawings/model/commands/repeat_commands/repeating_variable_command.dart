
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';

class RepeatingVariableCommand extends RepeatingDrawingCommand {
  final VariableCommand wrappedVariable;

  const RepeatingVariableCommand({
    required super.id,
    required super.version,
    required super.label,
    super.validated,
    super.valid,
    super.retryValidation,
    super.errors,
    super.initiallyOpen,
    required this.wrappedVariable,
  });

  RepeatingVariableCommand copyWith({
    String? id,
    String? label,
    bool? validated,
    bool? valid,
    bool? retryValidation,
    List<String>? errors,
    bool? initiallyOpen,
    VariableCommand? wrappedVariable,
  }) {
    return RepeatingVariableCommand(
      id: id?? this.id, 
      version: version + 1,
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      retryValidation: retryValidation?? this.retryValidation,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      wrappedVariable: wrappedVariable?? this.wrappedVariable,
    );
  }

  @override
  RepeatingVariableCommand abstractCopyWith({
    String? id, 
    String? label, 
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen
  }) {
    return copyWith(
      id: id?? this.id,
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => wrappedVariable.editHeight;

  @override
  String get wrappedId => wrappedVariable.id;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) => Rect.zero;

  @override
  RepeatingVariableCommand clearValidation() {
    return copyWith(
      validated: false, 
      valid: false, 
      retryValidation: true, 
      errors: const[], 
      wrappedVariable: wrappedVariable.clearValidation(),
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) => wrappedVariable.dependencies(drawing);

  @override
  RepeatingVariableCommand changePartDrawingReference({required String oldId, required String newId}) =>
    copyWith(
      wrappedVariable: wrappedVariable.changePartDrawingReference(oldId: oldId, newId: newId)
    );

  @override
  RepeatingVariableCommand deleteReference({required String commandId}) => 
    copyWith(
      wrappedVariable: wrappedVariable.deleteReference(commandId: commandId)
    );

  @override
  RepeatingVariableCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      wrappedVariable: wrappedVariable.dependentLabelChanged(oldLabel, newLabel)
    );
  }

  double? value(AbstractDrawing drawing) {
    return wrappedVariable.storedValue;
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], bool drawDirectionArrow = false, bool forPreview = false}) {
    // nothing to do
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]}) => '';

  @override
  Map<String, Object> toJson() {
    return {
      'type': RepeatingDrawingCommandTypes.repeatvariableCommand.name,
      'id': id,
      'label': label,
      'var': wrappedVariable.toJson(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': RepeatingDrawingCommandTypes.repeatvariableCommand.name,
    'label': label,
    'var': wrappedVariable.contentHashCode,
  });

  static RepeatingVariableCommand fromJson(Map<String, dynamic> json) {
    return RepeatingVariableCommand(
      id: json['id'] as String, 
      version: 0,
      label: json['label'] as String,
      wrappedVariable: VariableCommand.fromJson(json['var']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is RepeatingVariableCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      valid == other.valid &&
      validated == other.validated &&
      retryValidation == other.retryValidation &&
      listEquals(errors, other.errors) &&
      wrappedVariable == other.wrappedVariable;
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
      other is RepeatingVariableCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      wrappedVariable.isSameAs(other.wrappedVariable);
  
  @override
  int get hashCode => super.hashCode ^ wrappedVariable.hashCode;

  @override
  RepeatingVariableCommand validate(AbstractDrawing drawing, RepeatCommand repeatContext, int repeatValue) {
    bool isvalid = true;
    bool shouldRetryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; shouldRetryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label) || repeatContext.commands.any((c) => c.id != id && c.label == label)) { 
      isvalid = false; 
      shouldRetryValidation = false; 
      validationErrors.add('Label should be unique'); 
    }

    FormulaParseResult res = FormulaExpression.validate(
      formula: wrappedVariable.formula, drawing: drawing, repeatContext: repeatContext, repeatValue: repeatValue);
    if (res.isInvalid) {
      isvalid = false;
      if (!res.shouldRetry) shouldRetryValidation = false;
      validationErrors.add(res.errorMessage);
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !shouldRetryValidation),
      retryValidation: shouldRetryValidation,
      errors: validationErrors,
      wrappedVariable: wrappedVariable.copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
        storedValue: res.result
      ),
    );
  }

}
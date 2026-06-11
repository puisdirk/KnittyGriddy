
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

class VariableCommand extends DrawingCommand {
  final String formula;

  // Validated cache  
  final double? storedValue;

  const VariableCommand({
    required super.id,
    required super.label,
    this.formula = '',
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
    this.storedValue,
  });

  VariableCommand copyWith({
    String? label,
    String? formula,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    double? storedValue,
  }) {
    return VariableCommand(
      id: id, 
      label: label?? this.label,
      formula: formula?? this.formula,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      storedValue: storedValue?? this.storedValue,
    );
  }

  @override
  double get editHeight => 165;

  @override
  Rect getBoundingBox(Drawing drawing) {
    return Rect.zero;
  }

  @override
  VariableCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  VariableCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(Drawing drawing) {
    return FormulaExpression.dependencies(formula: formula, drawing: drawing);
  }

  @override
  VariableCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[], storedValue: null);
  }

  @override
  VariableCommand deleteReference({required String commandId}) {
    return this;
  }

  double? value(Drawing drawing) {
    return storedValue;
//    return FormulaExpression.validate(formula: formula, drawing: drawing).result;
  }

  @override
  void paint(Canvas canvas, Size size, Drawing drawing, bool selected) {
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.variableCommand.name,
      'id': id,
      'label': label,
      'formula': formula,
    };
  }

  static VariableCommand fromJson(Map<String, dynamic> json) {
    return VariableCommand(
      id: json['id'] as String, 
      label: json['label'] as String,
      formula: json['formula'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is VariableCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      formula == other.formula &&
      valid == other.valid &&
      validated == other.validated &&
      listEquals(errors, other.errors) &&
      storedValue == other.storedValue;
  
  @override
  int get hashCode => super.hashCode ^ formula.hashCode ^ storedValue.hashCode;

  @override
  DrawingCommand validate(Drawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    FormulaParseResult res = FormulaExpression.validate(formula: formula, drawing: drawing);
    if (res.isInvalid) {
      isvalid = false;
      if (!res.shouldRetry) retryValidation = false;
      validationErrors.add(res.errorMessage);
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
      storedValue: isvalid ? res.result : null,
    );
  }

}
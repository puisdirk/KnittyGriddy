
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:knitty_griddy/drawings/formulas/formula_grammar.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

class VariableCommand extends DrawingCommand {
  final String formula;
  final bool validated;
  final bool valid;

  const VariableCommand({
    required super.id,
    required super.label,
    this.formula = '',
    List<String>? errors,
    this.validated = false,
    this.valid = false,
  }) : super(errors: errors?? const[]);

  VariableCommand copyWith({
    String? label,
    String? formula,
    bool? validated,
    bool? valid,
    List<String>? errors,
  }) {
    return VariableCommand(
      id: id, 
      label: label?? this.label,
      formula: formula?? this.formula,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
    );
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
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  VariableCommand deleteReference({required String commandId}) {
    return this;
  }

  @override
  bool get isValidated => validated;

  @override
  VariableCommand offset(double x, double y) {
    return this;
  }

  double? value(Drawing drawing) {
    if (!valid) return null;

    if (formula.isEmpty) return null;

    final FormulaGrammar grammar = FormulaGrammar(drawing: drawing);

    return grammar.parse(formula).value;
  }

  @override
  void paint(Canvas canvas, Size size, TextStyle style, Drawing drawing) {
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.variableCommand,
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
      listEquals(errors, other.errors);
  
  @override
  int get hashCode => super.hashCode ^ formula.hashCode;

  @override
  DrawingCommand validate(Drawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    final FormulaGrammar grammar = FormulaGrammar(drawing: drawing);

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (formula.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires a value');
    } else {
      DoubleOrError res = grammar.parse(formula);
      if (!res.isSuccess) {
        isvalid = false;
        retryValidation = res.error is DependantNotValidated;
        validationErrors.add(res.error.toString());
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }

}

import 'package:knitty_griddy/drawings/formulas/formula_grammar.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:petitparser/petitparser.dart';

class FormulaParseResult {
  final double? result;
  final bool shouldRetry;
  final String errorMessage;

  const FormulaParseResult({
    this.result,
    this.shouldRetry = false,
    this.errorMessage = '',
  });

  factory FormulaParseResult.valid({required double val}) {
    return FormulaParseResult(result: val);
  }

  factory FormulaParseResult.error({required String errorMessage, bool shouldRetry = false}) {
    return FormulaParseResult(errorMessage: errorMessage, shouldRetry: shouldRetry);
  }

  bool get isValid => result != null;
  bool get isInvalid => result == null;
}

class FormulaExpression {
  static final RegExp _variablergx = RegExp(r'!\w*');
  static final RegExp _measurementrgx = RegExp(r'@\w*');

  static Set<String> dependencies({required String formula, required AbstractDrawing drawing}) {
    Set<String> deps = {};

    if (formula.isNotEmpty) {
      List<String> variableLabels = _variablergx.allMatches(formula).map((match) => match[0]!).toList();
      List<String> measurementLabels = _measurementrgx.allMatches(formula).map((match) => match[0]!).toList();

      for (String variableLabel in variableLabels) {
        VariableCommand? variableCommand = drawing.variableByName(variableLabel.substring(1));
        if (variableCommand != null) {
          deps.add(variableCommand.id);
        }
      }
      for (String measurementLabel in measurementLabels) {
        MeasurementCommand? measurementCommand = drawing.measurementByName(measurementLabel.substring(1));
        if (measurementCommand != null) {
          deps.add(measurementCommand.id);
        }
      }
    }    

    return deps;
  }

  static FormulaParseResult validate({required String formula, required AbstractDrawing drawing, String? label}) {
    if (formula.isEmpty) {
      return FormulaParseResult.error(errorMessage: 'Requires ${label?? 'a value'}');
    }

    try {
      final Result d = FormulaGrammar(drawing: drawing).parse(formula);
      if (d is Success) {
        return FormulaParseResult.valid(val: d.value as double);
      } else {
        return FormulaParseResult.error(errorMessage: 'Invalid formula (${d.message})');
      }
    } on FormulaException catch(e) {
      return FormulaParseResult.error(errorMessage: e.errorMessage, shouldRetry: e.shouldRetry);
    } catch (e) {
      return FormulaParseResult.error(errorMessage: 'Invalid formula (${e.toString()})');
    }
  }
}

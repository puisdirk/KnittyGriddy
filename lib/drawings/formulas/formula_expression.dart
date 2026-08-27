
import 'package:knitty_griddy/drawings/formulas/formula_grammar.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
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
//  static final RegExp _variablergx = RegExp(r'!\w*([\s)\*\/\-\+])');
//  static final RegExp _measurementrgx = RegExp(r'(@\w*)([\s)\*\/\-\+])');
  static final RegExp _variablergx = RegExp(r'!\w*');
  static final RegExp _measurementrgx = RegExp(r'@\w*');
  static final RegExp _linelengthrgx = RegExp(r'#linelength\(\s*\w*(\.\w*)?\s*\)');
  static final RegExp _distancergx = RegExp(r'#distance\(\s*\w*(\.\w*)?\s*,\s*\w*(\.\w*)?\s*\)');

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

      List<String> lineLengthLabels = _linelengthrgx.allMatches(formula).map((match) => match[0]!).toList();
      if (lineLengthLabels.isNotEmpty) {
        // Will get e.g. #linelength( adjwest )
        for (String lineLengthLabel in lineLengthLabels) {
          lineLengthLabel = lineLengthLabel.substring('#linelength('.length);
          lineLengthLabel = lineLengthLabel.substring(0, lineLengthLabel.length - 1);
          String lineLabel = lineLengthLabel.trim().replaceAll('_', ' ');
          if (lineLabel.contains('.')) {
            List<IncludedPartCommand> ipcs = drawing.includedParts.where((c) => c.label == lineLabel.split('.').first).toList();
            if (ipcs.isNotEmpty) {
              deps.add(ipcs.first.id);
            }
          } else {
            LineCommand? l = drawing.lineByName(lineLabel);
            if (l != null) {
              deps.add(l.id);
            }
          }
        }
      }

      List<String> pointDistanceLabels = _distancergx.allMatches(formula).map((match) => match[0]!).toList();
      if (pointDistanceLabels.isNotEmpty) {
        // Will get e.g. #distance(sl.gauntlet, p1)
        for (String pointDistanceLabel in pointDistanceLabels) {
          pointDistanceLabel = pointDistanceLabel.substring('#distance('.length);
          pointDistanceLabel = pointDistanceLabel.substring(0, pointDistanceLabel.length - 1);
          List<String> pointLabels = pointDistanceLabel.split(',');
          for (String pointLabel in pointLabels) {
            pointLabel = pointLabel.trim().replaceAll('_', ' ');

            if (pointLabel.contains('.')) {
              List<IncludedPartCommand> ipcs = drawing.includedParts.where((c) => c.label == pointLabel.split('.').first).toList();
              if (ipcs.isNotEmpty) {
                deps.add(ipcs.first.id);
              }
            } else {
              PointCommand? p = drawing.pointByName(pointLabel);
              if (p != null) {
                deps.add(p.id);
              }
            }
          }
        }
      }
    }    

    return deps;
  }

  static String replaceDependentLabel({required String formula, required String oldLabel, required String newLabel}) {

    // Greedy expression to skip e.g. #linelength(l14) when old label is l1
    final RegExp regExp = RegExp(oldLabel + r'[\.\s\+\-\*\/\)]');

    List<Match> matches = regExp.allMatches(formula).toList();
    if (matches.isNotEmpty) {
      String newFormula = formula;
      for (Match match in matches) {
        newFormula = newFormula.replaceRange(match.start, match.end - 1, newLabel);
      }
      return newFormula;
    }
    return formula;
  }

  static FormulaParseResult validate({required String formula, required AbstractDrawing drawing, String? label, RepeatCommand? repeatContext, int? repeatValue}) {
    if (formula.isEmpty) {
      return FormulaParseResult.error(errorMessage: 'Requires ${label?? 'a value'}');
    }

    try {
      final Result d = FormulaGrammar(drawing: drawing, repeatContext: repeatContext, repeatValue: repeatValue).parse(formula);
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

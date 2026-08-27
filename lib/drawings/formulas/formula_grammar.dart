
import 'dart:math';

import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:petitparser/petitparser.dart';

class FormulaException {
  final String? buffer;
  final int? pos;
  final String errorMessage;
  final bool shouldRetry;

  const FormulaException({
    this.buffer,
    this.pos,
    this.errorMessage = '',
    this.shouldRetry = false,
  });
}

class FormulaGrammar extends GrammarDefinition {

  final AbstractDrawing drawing;
  final RepeatCommand? repeatContext;
  final int? repeatValue;

  const FormulaGrammar({
    required this.drawing,
    this.repeatContext,
    this.repeatValue,
  }) : super();

  Result parse(String formula) {
    return buildFrom(start().end()).parse(formula);
  }

  @override
  Parser start() {
    return ref0(formula).map((p) {
      return p;
    });
  }

  Parser formula() => ref0(term).map((p) {
    return p;
  });

  Parser term() => (ref0(add) | ref0(prod)).map((p) {
    return p;
  });

  Parser add() => (ref0(prod) & (char('+') | char('-')).trim() & ref0(term)).map((p) {
    if (p[0] is FailureParser) {
      return failure(p[0].message);
    }
    if (p[2] is FailureParser) {
      return failure(p[2].message);
    }

    return p[1] == '+' ? p[0] + p[2] : p[0] - p[2];
  });

  Parser prod() => ref0(mul) | ref0(prim).map((p) {
    return p;
  });

  Parser mul() => (ref0(prim) & (char('*') | char('/')).trim() & ref0(prod)).map((p) {
    if (p[0] is FailureParser) {
      return failure(p[0].message);
    }
    if (p[2] is FailureParser) {
      return failure(p[2].message);
    }

    return p[1] == '*' ? p[0] * p[2] : p[0] / p[2];
  });

  Parser prim() => ref0(parens) | ref0(mathsfunction) | ref0(number).map((p) {
    return p;
  });

  Parser parens() => (string('(').trim() & ref0(term) & string(')')).map((p) {
    if (p[1] is FailureParser) {
      return failure(p[1].message);
    }
    return p[1];
  });

  Parser number() => ref0(measurement) | ref0(variable) | ref0(unitDouble) | ref0(pDouble).map((p) {
    return p;
  });

  Parser measurement() => (char('@') & seq2(letter(), word().star()).flatten('measurement name expected').trim()).map((p) {
    if (p[1] is FailureParser) {
      return failure(p[1].message);
    }

    String measurementName = ((p[1]) as String).replaceAll('_', ' ');
    MeasurementCommand? m = drawing.measurementByName(measurementName);
    if (m == null) {
      throw FormulaException(errorMessage: 'Measurement $measurementName does not exist', shouldRetry: false);
    }

    if (!m.validated) {
      throw FormulaException(errorMessage: 'Measurement $measurementName is not validated', shouldRetry: true);
    }

    if (!m.valid) {
      throw FormulaException(errorMessage: 'Measurement $measurementName has errors', shouldRetry: false);
    }

    return m.valueInMM;
  });

  Parser variable() => (char('!') & seq2(letter(), word().star()).flatten('variable name expected').trim()).map((p) {
    if (p[1] is FailureParser) {
      return failure(p[1].message);
    }

    String varName = ((p[1]) as String).replaceAll('_', ' ');
    if (varName == 'RepeatValue') {
      if (repeatValue != null) {
        return repeatValue;
      }
      throw const FormulaException(errorMessage: '!RepeatValue is reserved for formula\'s inside Repeat commands', shouldRetry: false);
    }

    VariableCommand? v = drawing.variableByName(varName)?? repeatContext?.variableByName(varName);
    if (v == null) {
      throw FormulaException(errorMessage: 'Variable $varName does not exist', shouldRetry: false);
    }

    if (!v.validated) {
      throw FormulaException(errorMessage: 'Variable $varName is not validated', shouldRetry: true);
    }

    if (!v.valid) {
      throw FormulaException(errorMessage: 'Variable $varName has errors', shouldRetry: false);
    }

    return v.value(drawing);
  });

  Parser unitDouble() => (pDouble() & (string('mm') | string('cm') | string('m') | string('"') | string('ft') | string('deg')).trim()).map((p) {
    Unit unit = Unit.mm;
    switch (p[1]) {
      case 'mm':
        unit = Unit.mm;
        break;
      case 'cm':
        unit = Unit.cm;
        break;
      case 'm':
        unit = Unit.meter;
        break;
      case '"':
        unit = Unit.inches;
        break;
      case 'ft':
        unit = Unit.feet;
        break;
      case 'deg':
        unit = Unit.angle;
        break;
    }
    return MathUtitilies.valueInMM(p[0], unit);
  });

  Parser pDouble() => ((char('-')).optional() & digit().star() & (string('.') & digit().star()).optional()).flatten().map((d) {
    try {
      return double.parse(d);
    } catch (err) {
      return failure('Not a valid number');
    }
  });

  Parser distance() =>
    seq2(
      string('#distance'),
      seq5(
        char('(').trim(),
        ((word() | char('.')).star()).flatten().trim(),
        char(',').trim(),
        ((word() | char('.')).star()).flatten().trim(),
        char(')').trim()  
      ).map5((_, p1label, __, p2label, ___) {

            PointCommand? p1 = drawing.pointByName(p1label)?? repeatContext?.pointByName(p1label);
            if (p1 == null) throw FormulaException(errorMessage: 'Point $p1label does not exist', shouldRetry: false);
            if (!p1.validated) throw FormulaException(errorMessage: 'Point $p1label is not validated', shouldRetry: true);
            if (!p1.valid) throw FormulaException(errorMessage: 'Point $p1label has errors', shouldRetry: false);

            PointCommand? p2 = drawing.pointByName(p2label)?? repeatContext?.pointByName(p2label);
            if (p2 == null) throw FormulaException(errorMessage: 'Point $p2label does not exist', shouldRetry: false);
            if (!p2.validated) throw FormulaException(errorMessage: 'Point $p2label is not validated', shouldRetry: true);
            if (!p2.valid) throw FormulaException(errorMessage: 'Point $p2label has errors', shouldRetry: false);

            return MathUtitilies.distance(p1.getCoordinate(drawing)!, p2.getCoordinate(drawing)!);
      })
    ).map2((_, dist) => dist);

  Parser linelength() => 
    seq2(
      string('#linelength'),
      seq3(
        char('(').trim(),
        ((word() | char('.')).star()).flatten().trim(),
        char(')').trim()).map3((_, label, __) => label)
    ).map2((_, lineLabel) {
      LineCommand? line = drawing.lineByName(lineLabel)?? repeatContext?.lineByName(lineLabel);
      if (line == null) {
        throw FormulaException(errorMessage: 'Line $lineLabel does not exist', shouldRetry: false);
      }
      if (!line.validated) {
        throw FormulaException(errorMessage: 'Line $lineLabel is not validated', shouldRetry: true);
      }
      if (!line.valid) {
        throw FormulaException(errorMessage: 'Line $lineLabel has errors', shouldRetry: false);
      }
      return line.lengthInMM(drawing);
    });

  Parser mathsExpression() =>
    seq2(
      seq3(char('#'),letter(), word().star()).flatten('function name expected').trim(),
      seq3(
        char('(').trim(),
        ref0(term).starSeparated(string(',').trim()).map((list) {
          return list.elements;
        }),
        char(')').trim()
      ).map3((_, list, __) => list)
    ).map2((name, args) {
    // Here we get a function name and the args list. E.g. cos(5) will give name cos and args [5]
    // Original would create an 'Application' here, but I'll just perform the maths right here and return
    // a double
    
    switch (args.length) {
      case 1:
        switch (name) {
          case '#cos': return cos(args[0]);
          case '#acos': return acos(args[0]);
          case '#sin': return sin(args[0]);
          case '#asin': return asin(args[0]);
          case '#tan': return tan(args[0]);
          case '#atan': return atan(args[0]);
          case '#exp': return exp(args[0]);
          case '#log': return log(args[0]);
          case '#sqrt': {
            return sqrt(args[0]);
          }
          case '#pow': return pow(args[0], 2);
          case '#abs': return (args[0] as double).abs();
          case '#ceil': return (args[0] as double).ceil();
          case '#floor': return (args[0] as double).floor();
          case '#round': return (args[0] as double).round();
          case '#toRadians': return (MathUtitilies.toRadians(args[0] as double));
          case '#toDegrees': return (MathUtitilies.toDegrees(args[0] as double));

          case '#toMM': return (MathUtitilies.valueInUnit(args[0] as double, Unit.mm));
          case '#toCM': return (MathUtitilies.valueInUnit(args[0] as double, Unit.cm));
          case '#toMeter': return (MathUtitilies.valueInUnit(args[0] as double, Unit.meter));
          case '#toInches': return (MathUtitilies.valueInUnit(args[0] as double, Unit.inches));
          case '#toFeet': return (MathUtitilies.valueInUnit(args[0] as double, Unit.feet));

          default:
            throw FormulaException(errorMessage: 'Unknown function $name', shouldRetry: false);
        }
      case 2:
        switch (name) {
          case '#adjacent': return sqrt(pow(args[0], 2) - pow(args[1], 2));
          case '#hypotenuse': return sqrt(pow(args[0], 2) + pow(args[1], 2));
          case '#opposite': return sqrt(pow(args[1], 2) - pow(args[0], 2));
          case '#atan2': return atan2(args[0], args[1]);
          case '#max': return max(args[0] as double, args[1] as double);
          case '#min': return min(args[0] as double, args[1] as double);
          case '#power': return pow(args[0] as double, args[1] as double);

          default:
            throw FormulaException(errorMessage: 'Unknown function $name', shouldRetry: false);
        }
      default:
        throw FormulaException(errorMessage: 'Unknown function $name', shouldRetry: false);
    }
  });

  // Maths functions like cos(x), max(x, y), etc or linelength(linelabel)
  Parser mathsfunction() => (ref0(linelength) | ref0(distance) | ref0(mathsExpression));
    
}

import 'dart:math';

import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:petitparser/petitparser.dart';

class DoubleOrError {
  final double? value;
  final FormulaException? error;

  const DoubleOrError({
    this.value,
    this.error,
  });

  factory DoubleOrError.valid(double val) {
    return DoubleOrError(value: val);
  }

  factory DoubleOrError.error(FormulaException err) {
    return DoubleOrError(error: err);
  }

  bool get isSuccess => error == null && value != null;
}

class FormulaException {
  final String? buffer;
  final int? pos;

  const FormulaException({
    this.buffer,
    this.pos,
  });
}

class GenericFormulaException extends FormulaException {
  final String message;

  const GenericFormulaException({
    super.buffer,
    super.pos,
    required this.message,
  });

  @override
  String toString() {
    String str = message;
    str += pos == null ? '' : ' at position $pos';
    str += (buffer == null || buffer!.isEmpty) ? '' : ' of buffer $buffer';
    return str;
  }
}

class MeasurementNotValidatedException extends FormulaException {
  final MeasurementCommand measurementCommand;

  const MeasurementNotValidatedException({
    super.buffer,
    super.pos,  
    required this.measurementCommand,
  });

  @override
  String toString() {
    return 'Measurement ${measurementCommand.label} is not valid';
  }
}

class MeasurementDoesNotExistException extends FormulaException {
  final String measurementName;

  const MeasurementDoesNotExistException({
    super.buffer,
    super.pos,  
    required this.measurementName,
  });

  @override
  String toString() {
    return 'Measurement $measurementName does not exist';
  }
}

class FormulaGrammar extends GrammarDefinition {

  final Drawing drawing;

  const FormulaGrammar({
    required this.drawing
  }) : super();

  DoubleOrError parse(String formula) {
    try {
      Result d = buildFrom(start().end()).parse(formula);
      if (d is Success) {
        return DoubleOrError.valid(d.value);
      } else {
        return DoubleOrError.error(GenericFormulaException(message: d.message, buffer: d.buffer, pos: d.position));
      }
    } on MeasurementDoesNotExistException catch (err) {
      return DoubleOrError.error(err);
    } on MeasurementNotValidatedException catch (err) {
      return DoubleOrError.error(err);
    } on GenericFormulaException catch(err) {
      return DoubleOrError.error(err);
    } catch (e) {
      return DoubleOrError.error(GenericFormulaException(message: e.toString()));
    }
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

  Parser number() => ref0(measurement) | ref0(pDouble).map((p) {
    return p;
  });

  Parser measurement() => (char('@') & seq2(letter(), word().star()).flatten('measurement name expected').trim()).map((p) {
    if (p[1] is FailureParser) {
      return failure(p[1].message);
    }

    MeasurementCommand? m = drawing.measurementByName(p[1]);
    if (m == null) {
      throw MeasurementDoesNotExistException(measurementName: p[1]);
    }

    if (!m.validated) {
      throw MeasurementNotValidatedException(measurementCommand: m);
    }

    return m.value;
  });

  Parser pDouble() => (digit().star() & (string('.') & digit().star()).optional()).flatten().map((d) {
    try {
      return double.parse(d);
    } catch (err) {
      return failure('Not a valid number');
    }
  });

  // Maths functions like cos(x), max(x, y), etc
  Parser mathsfunction() => seq2(
    seq3(char('#'),letter(), word().star()).flatten('function name expected').trim(),
    seq3(
      char('(').trim(),
      ref0(term).starSeparated(char(',')).map((list) {
        return list.elements;
      }),
      char(')').trim(),
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
          case '#sqrt': return sqrt(args[0]);
          case '#pow': return pow(args[0], 2);
          case '#abs': return (args[0] as double).abs();
          case '#ceil': return (args[0] as double).ceil();
          case '#floor': return (args[0] as double).floor();
          case '#round': return (args[0] as double).round();
          case '#toRadians': return (MathUtitilies.toRadians(args[0] as double));
          case '#toDegrees': return (MathUtitilies.toDegrees(args[0] as double));
          default:
            throw ArgumentError.value(name, 'Unknown function', 'Unknown function $name');
        }
      case 2:
        switch (name) {
          case '#atan2': return atan2(args[0], args[1]);
          case '#max': return max(args[0] as double, args[1] as double);
          case '#min': return min(args[0] as double, args[1] as double);
          case '#power': return pow(args[0] as double, args[1] as double);

          default:
            throw ArgumentError.value(name, 'Unknown function', 'Unknown function $name');
        }
      default:
        throw ArgumentError.value(name, 'Unknown function', 'Unknown function $name');
    }
  });

}

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_grammar.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

@immutable
class CurveCommand extends DrawingCommand {

  final String startPointId;
  final String endPointId;
  final String amplitudeFormula;
  final String slantFormula;

  final bool validated;
  final bool valid;

  const CurveCommand({
    required super.id,
    required super.label,
    List<String>? errors,
    this.startPointId = '',
    this.endPointId = '',
    this.amplitudeFormula = '1',
    this.slantFormula = '0',
    this.validated = false,
    this.valid = false,
  }) : super(errors: errors?? const[]);

  CurveCommand copyWith({
    String? label,
    String? startPointId,
    String? endPointId,
    String? amplitudeFormula,
    String? slantFormula,
    bool? validated,
    bool? valid,
    List<String>? errors,
  }) {
    return CurveCommand(
      id: id,
      label: label?? this.label, 
      startPointId: startPointId?? this.startPointId, 
      endPointId: endPointId?? this.endPointId, 
      amplitudeFormula: amplitudeFormula?? this.amplitudeFormula,
      slantFormula: slantFormula?? this.slantFormula,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
    );
  }

  @override
  DrawingCommand deleteReference({required String commandId}) {
    return copyWith(
      startPointId: startPointId == commandId ? '' : startPointId,
      endPointId: endPointId == commandId ? '' : endPointId,
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.curveCommand.name,
      'id': id,
      'label': label,
      'from': startPointId,
      'to': endPointId,
      'amp': amplitudeFormula,
      'slant': slantFormula,
    };
  }

  static CurveCommand fromJson(Map<String, dynamic> json) {
    return CurveCommand(
      id: json['id'] as String,
      label: json['label'] as String, 
      startPointId: json['start'] as String,
      endPointId: json['end'] as String, 
      amplitudeFormula: json['amp'] as String,
      slantFormula: json['slant'] as String,
    );
  }

  @override
  CurveCommand offset(double x, double y) {
    return this;/*copyWith(
      startPoint: startPoint.offset(x, y),
      endPoint: endPoint.offset(x, y),
      controlPoint: controlPoint.offset(x, y),
    );*/
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is CurveCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    startPointId == other.startPointId &&
    endPointId == other.endPointId &&
    amplitudeFormula == other.amplitudeFormula &&
    slantFormula == other.slantFormula &&
    validated == other.validated &&
    valid == other.valid &&
    listEquals(errors, other.errors);
  
  @override
  int get hashCode => super.hashCode ^ startPointId.hashCode ^ endPointId.hashCode ^ 
    amplitudeFormula.hashCode ^ slantFormula.hashCode ^
    validated.hashCode ^ valid.hashCode ^ errors.hashCode;

  @override
  void paint(Canvas canvas, Size size, TextStyle style, Drawing drawing) {
    if (!valid) return;

    Offset middle = Offset(size.width / 2, size.height / 2);

    Offset? startCoordinate = getStartCoordinate(drawing);
    if (startCoordinate == null) return;
    startCoordinate = startCoordinate.scale(1, -1);
    startCoordinate += middle;

    Offset? endCoordinate = getEndCoordinate(drawing);
    if (endCoordinate == null) return;
    endCoordinate = endCoordinate.scale(1, -1);
    endCoordinate += middle;

    double? amplitude = getAmplitude(drawing);
    if (amplitude == null) return;

    double? slant = getSlant(drawing);
    if (slant == null) return;

    Offset controlCoordinate = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude, slant);

    Path p = Path()
      ..moveTo(startCoordinate.dx, startCoordinate.dy)
      ..quadraticBezierTo(
        controlCoordinate.dx, controlCoordinate.dy, 
        endCoordinate.dx, endCoordinate.dy);
    
    canvas.drawPath(p, Paint()..color = Colors.grey.shade700..style = PaintingStyle.stroke);
  }

  double? getAmplitude(Drawing drawing) {
    if (amplitudeFormula.isEmpty) return null;

    final FormulaGrammar grammar = FormulaGrammar(drawing: drawing);
    DoubleOrError res = grammar.parse(amplitudeFormula);
    if (res.isSuccess) {
      return res.value;
    } else {
      return null;
    }
  }

  double? getSlant(Drawing drawing) {
    if (slantFormula.isEmpty) return null;

    final FormulaGrammar grammar = FormulaGrammar(drawing: drawing);
    DoubleOrError res = grammar.parse(slantFormula);
    if (res.isSuccess) {
      return res.value;
    } else {
      return null;
    }
  }

  @override
  bool get isValidated => validated;

  Offset? getStartCoordinate(Drawing drawing) {
    PointCommand? startPoint = drawing.pointById(startPointId);
    if (startPoint == null) return null;
    return startPoint.getCoordinate(drawing);
  }

  Offset? getEndCoordinate(Drawing drawing) {
    PointCommand? endPoint = drawing.pointById(endPointId);
    if (endPoint == null) return null;
    return endPoint.getCoordinate(drawing);
  }

  // TODO: move to MathUtilities?
  Offset getControlPointCoordinate(Offset startCoordinate, Offset endCoordinate, double amplitude, double slant) {
    double lineLength = MathUtitilies.distance(startCoordinate, endCoordinate);
    double ampLength = lineLength * amplitude;

    Offset ampStartPoint = MathUtitilies.fractionOfLine(startCoordinate, endCoordinate, 0.5 + (slant / 2));

    // control point is perpendicular to the line with the given ampLenght
    final double angleOfLine = MathUtitilies.angleOfLine(startCoordinate, endCoordinate);
    double perpendicularAngle = angleOfLine + (pi / 2.0);
    // Take quadrant into account
    if (endCoordinate.dx > startCoordinate.dx) {
      perpendicularAngle = angleOfLine - (pi / 2.0);
    }
    
    return MathUtitilies.relativepointatangle(ampStartPoint, ampLength, perpendicularAngle);
  }

  @override
  DrawingCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }
  
  @override
  DrawingCommand validate(Drawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    final FormulaGrammar grammar = FormulaGrammar(drawing: drawing);

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (startPointId.isEmpty) {
      isvalid = false; 
      retryValidation = false;
      validationErrors.add('Requires a source point');
    } else if (startPointId != originId) {
      PointCommand? fromPoint = drawing.pointById(startPointId);
      if (fromPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Source point does not exist');
      } else {
        if (!fromPoint.isValidated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!fromPoint.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Source point ${fromPoint.label} has errors');
        }
      }
    }

    if (endPointId.isEmpty) {
      isvalid = false; 
      retryValidation = false;
      validationErrors.add('Requires a target point');
    } else if (endPointId != originId) {
      PointCommand? toPoint = drawing.pointById(endPointId);
      if (toPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Target point does not exist');
      } else {
        if (!toPoint.isValidated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!toPoint.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Target point ${toPoint.label} has errors');
        }
      }
    }

    if (amplitudeFormula.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires an amplitude');
    } else {
      DoubleOrError res = grammar.parse(amplitudeFormula);
      if (!res.isSuccess) {
        isvalid = false;
        retryValidation = res.error is DependantNotValidated;
        validationErrors.add(res.error.toString());
      }
    }

    if (slantFormula.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires a slant');
    } else {
      DoubleOrError res = grammar.parse(slantFormula);
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
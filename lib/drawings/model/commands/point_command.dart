
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

const String originId = '063f22af-bc7f-4e77-bc8b-60e48c821259';
const PointCommand origin = PointCommand(id: originId, label: 'origin', valid: true, );

enum PointDefinitionType {
  relativeToPoint(label: 'Relative to a point'),
  onLine(label: 'On a line'),
  onCurve(label: 'On a curve'),
  onIntersection(label: 'On intersection');
  // TODO: as adjacent?

  final String label;

  const PointDefinitionType({required this.label});
}

enum RelativePointDirection {
  north(label: 'North', angleInDegrees: 90),
  south(label: 'South', angleInDegrees: 270),
  east(label: 'East', angleInDegrees: 0),
  west(label: 'West', angleInDegrees: 180),
  northEast(label: 'North-East', angleInDegrees: 45),
  northWest(label: 'North-West', angleInDegrees: 135),
  southEast(label: 'South-East', angleInDegrees: 315),
  southWest(label: 'South-West', angleInDegrees: 225),
  angle(label: 'At angle', angleInDegrees: 0);

  final String label;
  final double angleInDegrees;

  const RelativePointDirection({required this.label, required this.angleInDegrees});
}

@immutable
class PointCommand extends DrawingCommand {
  final PointDefinitionType pointDefinitionType;
  final String fromPointId;
  final String distanceFormula;
  final RelativePointDirection direction;
  final String directionAngleFormula;

  final String onLineId;
  final String onLineFractionFormula;
  
  final String onCurveId;
  final String onCurveFractionFormula;

  final String intersectionLine1Id;
  final String intersectionLine2Id;

  const PointCommand({
    required super.id,
    required super.label,
    PointDefinitionType? pointDefinitionType,
    this.fromPointId = '',
    this.distanceFormula = '',
    RelativePointDirection? direction,
    this.directionAngleFormula = '',
    this.onLineId = '',
    this.onLineFractionFormula = '',
    this.onCurveId = '',
    this.onCurveFractionFormula = '',
    this.intersectionLine1Id = '',
    this.intersectionLine2Id = '',
    super.validated,
    super.valid,
    super.errors,
  }) : 
    pointDefinitionType = pointDefinitionType?? PointDefinitionType.relativeToPoint,
    direction = direction?? RelativePointDirection.north;

  PointCommand copyWith({
    String? label,
    PointDefinitionType? pointDefinitionType,
    String? fromPointId,
    String? distanceFormula,
    RelativePointDirection? direction,
    String? directionAngleFormula,
    String? onLineId,
    String? onLineFractionFormula,
    String? onCurveId,
    String? onCurveFractionFormula,
    String? intersectionLine1Id,
    String? intersectionLine2Id,
    bool? validated,
    bool? valid,
    List<String>? errors,
  }) {
    return PointCommand(
      id: id,
      label: label?? this.label,
      pointDefinitionType: pointDefinitionType?? this.pointDefinitionType,
      fromPointId: fromPointId?? this.fromPointId,
      distanceFormula: distanceFormula?? this.distanceFormula,
      direction: direction?? this.direction,
      directionAngleFormula: directionAngleFormula?? this.directionAngleFormula,
      onLineId: onLineId?? this.onLineId,
      onLineFractionFormula: onLineFractionFormula?? this.onLineFractionFormula,
      onCurveId: onCurveId?? this.onCurveId,
      onCurveFractionFormula: onCurveFractionFormula?? this.onCurveFractionFormula,
      intersectionLine1Id: intersectionLine1Id?? this.intersectionLine1Id,
      intersectionLine2Id: intersectionLine2Id?? this.intersectionLine2Id,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
    );
  }

  @override
  double get editHeight {
    switch (pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        if (direction == RelativePointDirection.angle) {
          return 230;
        } else {
          return 220;
        }
      case PointDefinitionType.onLine:
        return 190;
      case PointDefinitionType.onCurve:
        return 190;
      case PointDefinitionType.onIntersection:
        return 190;
    }
  }

  @override
  PointCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  PointCommand deleteReference({required String commandId}) {
    return copyWith(
      fromPointId: fromPointId == commandId ? '' : fromPointId,
      onLineId: onLineId == commandId ? '' : onLineId,
      onCurveId: onCurveId == commandId ? '' : onCurveId,
      intersectionLine1Id: intersectionLine1Id == commandId ? '' : intersectionLine1Id,
      intersectionLine2Id: intersectionLine2Id == commandId ? '' : intersectionLine2Id,
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.pointCommand,
      'id': id,
      'label': label,
      'pdt': pointDefinitionType.name,
      'frompointid': fromPointId,
      'distance': distanceFormula,
      'direction': direction.name,
      'angle': directionAngleFormula,
      'onlineid': onLineId,
      'onlinefraction': onLineFractionFormula,
      'oncurveid': onCurveId,
      'oncurvefraction': onCurveFractionFormula,
      'isl1id': intersectionLine1Id,
      'isl2id': intersectionLine2Id,
    };
  }

  static PointCommand fromJson(Map<String, dynamic> json) {
    return PointCommand(
      id: json['id'] as String,
      label: json['label'] as String, 
      pointDefinitionType: PointDefinitionType.values.byName(json['pdt'] as String),
      fromPointId: json['frompointid'] as String,
      distanceFormula: json['distance'] as String,
      direction: RelativePointDirection.values.byName(json['direction'] as String),
      directionAngleFormula: json['angle'] as String,
      onLineId: json['onlineid'] as String,
      onLineFractionFormula: json['fraction'] as String,
      onCurveId: json['oncurveid'] as String,
      onCurveFractionFormula: json['oncurvefraction'] as String,
      intersectionLine1Id: json['isl1id'] as String,
      intersectionLine2Id: json['isl2id'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PointCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    pointDefinitionType == other.pointDefinitionType &&
    fromPointId == other.fromPointId &&
    distanceFormula == other.distanceFormula &&
    direction == other.direction &&
    directionAngleFormula == other.directionAngleFormula &&
    onLineId == other.onLineId &&
    onLineFractionFormula == other.onLineFractionFormula &&
    onCurveId == other.onCurveId &&
    onCurveFractionFormula == other.onCurveFractionFormula &&
    intersectionLine1Id == other.intersectionLine1Id &&
    intersectionLine2Id == other.intersectionLine2Id &&
    validated == other.validated &&
    valid == other.valid &&
    listEquals(errors, other.errors);

  @override
  int get hashCode => super.hashCode ^ pointDefinitionType.hashCode ^ 
    fromPointId.hashCode ^ distanceFormula.hashCode ^ direction.hashCode ^ directionAngleFormula.hashCode ^
    onLineId.hashCode ^ onLineFractionFormula.hashCode ^
    onCurveId.hashCode ^ onCurveFractionFormula.hashCode ^
    intersectionLine1Id.hashCode ^ intersectionLine2Id.hashCode;

  Offset? getCoordinate(Drawing drawing) {
    if (id == originId) return Offset.zero;

    if (!valid) return null;

    switch (pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        PointCommand? fromPoint = drawing.pointById(fromPointId);
        if (fromPoint == null || !fromPoint.valid) return null;

        Offset? coordinate =  fromPoint.getCoordinate(drawing);
        if (coordinate == null) return null;
        
        double distance = 0;
        FormulaParseResult res = FormulaExpression.validate(formula: distanceFormula, drawing: drawing, label: 'a distance');
        if (res.isValid) {
          distance = res.result!;
        } else {
          return null;
        }

        double offsetAngle = 0;
        if (direction == RelativePointDirection.angle) {
          FormulaParseResult res = FormulaExpression.validate(formula: directionAngleFormula, drawing: drawing, label: 'an angle');
          if (res.isValid) {
            offsetAngle = res.result!;
          } else {
            return null;
          }
        } else {
          offsetAngle = direction.angleInDegrees;
        }
        coordinate += Offset.fromDirection(MathUtitilies.toRadians(offsetAngle), distance);
        return coordinate;
      case PointDefinitionType.onLine:
        LineCommand? line = drawing.lineById(onLineId);
        if (line == null || !line.valid) return null;
        
        double fraction = 0;
        FormulaParseResult res = FormulaExpression.validate(formula: onLineFractionFormula, drawing: drawing, label: 'a fraction');
        if (res.isValid) {
          fraction = res.result!;
        } else {
          return null;
        }

        return line.pointOnLine(fraction, drawing);
      case PointDefinitionType.onCurve:
        CurveCommand? curve = drawing.curveById(onCurveId);
        if (curve == null || !curve.valid) return null;

        double fraction = 0;
        FormulaParseResult res = FormulaExpression.validate(formula: onCurveFractionFormula, drawing: drawing, label: 'a fraction');
        if (res.isValid) {
          fraction = res.result!;
        } else {
          return null;
        }

        Path? p = curve.getPath(drawing, Offset.zero);
        if (p == null) return null;
        return curve.pointOnPath(p, fraction);
      case PointDefinitionType.onIntersection:
        LineCommand? line1 = drawing.lineById(intersectionLine1Id);
        if (line1 == null) return null;
        LineCommand? line2 = drawing.lineById(intersectionLine2Id);
        if (line2 == null) return null;
        List<Offset> intersections = line1.intersections(line2, drawing);
        if (intersections.isEmpty) {
          return line1.getStartCoordinate(drawing);
        } else {
          return intersections.first;
        }
      default:
        // TODO: other def types
        return null;
    }
  }

  @override
  void paint(Canvas canvas, Size size, Drawing drawing, bool selected) {
    if (!valid) {
      return;
    }

    Offset? coordinate = getCoordinate(drawing);
    if (coordinate == null) {
      return;
    }
    coordinate = coordinate.scale(1, -1);

    Offset middle = Offset(size.width / 2, size.height / 2);
    coordinate += middle;

    canvas.drawCircle(coordinate, 2, Paint()..color = selected ? Colors.purple : Colors.grey.shade700..style = PaintingStyle.stroke);

    // draw point label
    TextStyle style = TextStyle(color: selected ? Colors.purple : Colors.grey[400]);
    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        fontSize: 10,
        fontFamily: style.fontFamily,
        fontStyle: style.fontStyle,
        fontWeight: style.fontWeight,
        textAlign: TextAlign.justify,
      ),
    )
    ..pushStyle(style.getTextStyle())
    ..addText(label);

    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph,  coordinate.translate(2, 0));

  }

  @override
  DrawingCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }
  
  @override
  Set<String> dependencies(Drawing drawing) {
    Set<String> deps = {};

    switch (pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        if (fromPointId.isNotEmpty) deps.add(fromPointId);
        deps.addAll(FormulaExpression.dependencies(formula: distanceFormula, drawing: drawing));
        if (direction == RelativePointDirection.angle) deps.addAll(FormulaExpression.dependencies(formula: directionAngleFormula, drawing: drawing));
        break;
      case PointDefinitionType.onLine:
        if (onLineId.isNotEmpty) deps.add(onLineId);
        deps.addAll(FormulaExpression.dependencies(formula: onLineFractionFormula, drawing: drawing));
        break;
      case PointDefinitionType.onCurve:
        if (onCurveId.isNotEmpty) deps.add(onCurveId);
        deps.addAll(FormulaExpression.dependencies(formula: onCurveFractionFormula, drawing: drawing));
        break;
      case PointDefinitionType.onIntersection:
        if (intersectionLine1Id.isNotEmpty) deps.add(intersectionLine1Id);
        if (intersectionLine2Id.isNotEmpty) deps.add(intersectionLine2Id);
        break;
    }

    return deps;
  }

  @override
  DrawingCommand validate(Drawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    switch (pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        if (direction == RelativePointDirection.angle) {
          FormulaParseResult res = FormulaExpression.validate(formula: directionAngleFormula, drawing: drawing, label: 'an angle');
          if (res.isInvalid) {
            isvalid = false;
            if (!res.shouldRetry) retryValidation = false;
            validationErrors.add(res.errorMessage);
          }
        }

        FormulaParseResult res = FormulaExpression.validate(formula: distanceFormula, drawing: drawing, label: 'a distance');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        if (fromPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a reference point');
        } else if (fromPointId != originId) {
          PointCommand? fromPoint = drawing.pointById(fromPointId);
          if (fromPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference point does not exist');
          } else {
            if (!fromPoint.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!fromPoint.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('Reference point ${fromPoint.label} has errors');
            }
          }
        }

        break;
      case PointDefinitionType.onLine:
        if (onLineId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a reference line');
        } else {
          LineCommand? line = drawing.lineById(onLineId);
          if (line == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference line does not exist');
          } else if (!line.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference line ${line.label} has errors');
          }
        }

        FormulaParseResult res = FormulaExpression.validate(formula: onLineFractionFormula, drawing: drawing, label: 'a fraction');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }
        break;
      case PointDefinitionType.onCurve:
        if (onCurveId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a curve');
        } else {
          CurveCommand? curve = drawing.curveById(onCurveId);
          if (curve == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Referece curve does not exist');
          } else if (!curve.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!curve.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference curve ${curve.label} has errors');
          }
        }

        FormulaParseResult res = FormulaExpression.validate(formula: onCurveFractionFormula, drawing: drawing, label: 'a fraction');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }
      case PointDefinitionType.onIntersection:
        if (intersectionLine1Id.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires Line 1');
        } else {
          LineCommand? line = drawing.lineById(intersectionLine1Id);
          if (line == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line 1 does not exist');
          } else if (!line.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line ${line.label} has errors');
          }
        }
        if (intersectionLine2Id.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires Line 2');
        } else {
          LineCommand? line = drawing.lineById(intersectionLine2Id);
          if (line == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line 2 does not exist');
          } else if (!line.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line ${line.label} has errors');
          }
        }
        break;
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }
}
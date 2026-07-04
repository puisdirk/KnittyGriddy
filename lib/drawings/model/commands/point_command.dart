
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

const String originId = '063f22af-bc7f-4e77-bc8b-60e48c821259';
const PointCommand origin = PointCommand(id: originId, label: 'origin', validated: true, valid: true, );

enum PointDefinitionType {
  relativeToPoint(label: 'Relative to a point'),
  onLine(label: 'On a line'),
  onCurve(label: 'On a curve'),
  onIntersection(label: 'On intersection');

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

  // Validated cache
  final Offset? storedCoordinate;

  const PointCommand({
    required super.id,
    super.version = 0,
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
    super.initiallyOpen,
    this.storedCoordinate,
  }) : 
    pointDefinitionType = pointDefinitionType?? PointDefinitionType.relativeToPoint,
    direction = direction?? RelativePointDirection.north;

  PointCommand copyWith({
    String? id,
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
    bool? initiallyOpen,
    Offset? storedCoordinate,
  }) {
    return PointCommand(
      id: id?? this.id,
      version: version + 1,
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
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      storedCoordinate: storedCoordinate?? this.storedCoordinate,
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
  Rect getBoundingBox(AbstractDrawing drawing) {
    if (valid) {
      Offset? coord = getCoordinate(drawing);
      if (coord != null) {
        return Rect.fromPoints(coord - const Offset(1, 1), coord + const Offset(1, 1));
      }
    }
    return Rect.zero;
  }

  @override
  PointCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
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
  PointCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      fromPointId: fromPointId.replaceAll(oldId, newId),
      onLineId: onLineId.replaceAll(oldId, newId),
      onCurveId: onCurveId.replaceAll(oldId, newId),
      intersectionLine1Id: intersectionLine1Id.replaceAll(oldId, newId),
      intersectionLine2Id: intersectionLine2Id.replaceAll(oldId, newId),
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
  PointCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      directionAngleFormula: FormulaExpression.replaceDependentLabel(formula: directionAngleFormula, oldLabel: oldLabel, newLabel: newLabel),
      distanceFormula: FormulaExpression.replaceDependentLabel(formula: distanceFormula, oldLabel: oldLabel, newLabel: newLabel),
      onCurveFractionFormula: FormulaExpression.replaceDependentLabel(formula: onCurveFractionFormula, oldLabel: oldLabel, newLabel: newLabel),
      onLineFractionFormula: FormulaExpression.replaceDependentLabel(formula: onLineFractionFormula, oldLabel: oldLabel, newLabel: newLabel),
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.pointCommand.name,
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
      version: 0,
      label: json['label'] as String, 
      pointDefinitionType: PointDefinitionType.values.byName(json['pdt'] as String),
      fromPointId: json['frompointid'] as String,
      distanceFormula: json['distance'] as String,
      direction: RelativePointDirection.values.byName(json['direction'] as String),
      directionAngleFormula: json['angle'] as String,
      onLineId: json['onlineid'] as String,
      onLineFractionFormula: json['onlinefraction'] as String,
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
//    version == other.version &&
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
    listEquals(errors, other.errors) &&
    storedCoordinate == other.storedCoordinate;

  @override
  int get hashCode => super.hashCode ^ pointDefinitionType.hashCode ^ 
    fromPointId.hashCode ^ distanceFormula.hashCode ^ direction.hashCode ^ directionAngleFormula.hashCode ^
    onLineId.hashCode ^ onLineFractionFormula.hashCode ^
    onCurveId.hashCode ^ onCurveFractionFormula.hashCode ^
    intersectionLine1Id.hashCode ^ intersectionLine2Id.hashCode ^
    storedCoordinate.hashCode;

  Offset? getCoordinate(AbstractDrawing drawing) {
    if (id == originId) return Offset.zero + drawing.offset;

    if (!valid) return null;

    return storedCoordinate;
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = ''}) {
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

    canvas.drawCircle(
      coordinate, 
      2, 
      Paint()
        ..color = selected ? selectedColor : asPart ? partColor : Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2 : 1);

    // draw point label
    TextStyle style = TextStyle(color: selected ? selectedColor : Colors.grey[400]);
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
    ..addText(prefixLabel.isEmpty ? label : '$prefixLabel.$label');

    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph,  coordinate.translate(2, 0));
  }

  @override
  PointCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[], storedCoordinate: null);
  }
  
  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};

    switch (pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        if (fromPointId.isNotEmpty) {
          if (fromPointId.contains('.')) {
            deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == fromPointId.split('.').first).id);
          }
          
          deps.add(fromPointId);
        }
        deps.addAll(FormulaExpression.dependencies(formula: distanceFormula, drawing: drawing));
        if (direction == RelativePointDirection.angle) deps.addAll(FormulaExpression.dependencies(formula: directionAngleFormula, drawing: drawing));
        break;
      case PointDefinitionType.onLine:
        if (onLineId.isNotEmpty) {
          if (onLineId.contains('.')) {
            deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == onLineId.split('.').first).id);
          }
          
          deps.add(onLineId);
        }
        deps.addAll(FormulaExpression.dependencies(formula: onLineFractionFormula, drawing: drawing));
        break;
      case PointDefinitionType.onCurve:
        if (onCurveId.isNotEmpty) {
          if (onCurveId.contains('.')) {
            deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == onCurveId.split('.').first).id);
          }
          
          deps.add(onCurveId);
        }
        deps.addAll(FormulaExpression.dependencies(formula: onCurveFractionFormula, drawing: drawing));
        break;
      case PointDefinitionType.onIntersection:
        if (intersectionLine1Id.isNotEmpty) {
          if (intersectionLine1Id.contains('.')) {
            deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == intersectionLine1Id.split('.').first).id);
          }
          
          deps.add(intersectionLine1Id);
        }
        if (intersectionLine2Id.isNotEmpty) {
          if (intersectionLine2Id.contains('.')) {
            deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == intersectionLine2Id.split('.').first).id);
          }
          
          deps.add(intersectionLine2Id);
        }
        break;
    }

    return deps;
  }

  @override
  PointCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    Offset? newStoredCoordinate;

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    switch (pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        double distance = 0;
        FormulaParseResult res = FormulaExpression.validate(formula: distanceFormula, drawing: drawing, label: 'a distance');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        } else {
          distance = res.result!;
        }

        double offsetAngle = 0;
        if (direction == RelativePointDirection.angle) {
          FormulaParseResult res = FormulaExpression.validate(formula: directionAngleFormula, drawing: drawing, label: 'an angle');
          if (res.isInvalid) {
            isvalid = false;
            if (!res.shouldRetry) retryValidation = false;
            validationErrors.add(res.errorMessage);
          } else {
            offsetAngle = res.result!;
          }
        } else {
          offsetAngle = direction.angleInDegrees;
        }

        PointCommand? fromPoint;
        if (fromPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a reference point');
        } else if (fromPointId == originId) {
          fromPoint = origin;
        } else {
          fromPoint = drawing.pointById(fromPointId);
          if (fromPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference point does not exist');
          } else if (fromPointId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == fromPointId.split('.').first);
            if (!ipc.validated) {
              isvalid = false;
            }
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

        if (isvalid) {
          Offset offset = fromPoint!.getCoordinate(drawing)!;
          offset += Offset.fromDirection(MathUtitilies.toRadians(offsetAngle), distance);
          newStoredCoordinate = offset;
        }

        break;
      case PointDefinitionType.onLine:
        LineCommand? line;
        if (onLineId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a reference line');
        } else {
          line = drawing.lineById(onLineId);
          if (line == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference line does not exist');
          } else if (onLineId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == onLineId.split('.').first);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else if (!line.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference line ${line.label} has errors');
          }
        }

        double fraction = 0;
        FormulaParseResult res = FormulaExpression.validate(formula: onLineFractionFormula, drawing: drawing, label: 'a fraction');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        } else {
          fraction = res.result!;
        }

        if (isvalid) {
          newStoredCoordinate = line!.pointOnLine(fraction, drawing);
        }

        break;
      case PointDefinitionType.onCurve:
        CurveCommand? curve;
        if (onCurveId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a curve');
        } else {
          curve = drawing.curveById(onCurveId);
          if (curve == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Referece curve does not exist');
          } else if (onCurveId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == onCurveId.split('.').first);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else if (!curve.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!curve.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference curve ${curve.label} has errors');
          }
        }

        double fraction = 0;
        FormulaParseResult res = FormulaExpression.validate(formula: onCurveFractionFormula, drawing: drawing, label: 'a fraction');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        } else {
          fraction = res.result!;
        }

        if (isvalid) {
          if (onCurveId.contains('.')) {
            String partDrawingId = onCurveId.split('.').first;
            IncludedPartCommand c = drawing.commands.firstWhere((c) => c is IncludedPartCommand && c.partInfo?.partDrawingId == partDrawingId) as IncludedPartCommand;
            PartDrawing? pd = c.partInfo?.storedOffsetPartDrawing;
            if (pd != null) {
              Path p = curve!.getPath(pd, Offset.zero)!;
              newStoredCoordinate = curve.pointOnPath(p, fraction).scale(1, -1);
            }
          } else {
            Path p = curve!.getPath(drawing, Offset.zero)!;
            newStoredCoordinate = curve.pointOnPath(p, fraction).scale(1, -1);
          }
        }

      case PointDefinitionType.onIntersection:
        LineCommand? line1;
        LineCommand? line2;
        
        if (intersectionLine1Id.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires Line 1');
        } else {
          line1 = drawing.lineById(intersectionLine1Id);
          if (line1 == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line 1 does not exist');
          } else if (intersectionLine1Id.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == intersectionLine1Id.split('.').first);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else if (!line1.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line1.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line ${line1.label} has errors');
          }
        }
        if (intersectionLine2Id.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires Line 2');
        } else {
          line2 = drawing.lineById(intersectionLine2Id);
          if (line2 == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line 2 does not exist');
          } else if (intersectionLine2Id.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == intersectionLine2Id.split('.').first);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else if (!line2.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line2.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line ${line2.label} has errors');
          }
        }

        if (isvalid) {
          List<Offset> intersections = line1!.intersections(line2!, drawing);
          if (intersections.isEmpty) {
            newStoredCoordinate = line1.getStartCoordinate(drawing);
          } else {
            newStoredCoordinate = intersections.first;
          }
        }

        break;
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
      storedCoordinate: newStoredCoordinate,
    );
  }
}
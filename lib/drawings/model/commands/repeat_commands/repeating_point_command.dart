import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class RepeatingPointCommand extends RepeatingDrawingCommand {
  final PointCommand wrappedPoint;

  const RepeatingPointCommand({
    required super.id,
    required super.version,
    required super.label,
    super.validated,
    super.valid,
    super.retryValidation,
    super.errors,
    super.initiallyOpen,
    required this.wrappedPoint,
  });

  RepeatingPointCommand copyWith({
    String? id, 
    String? label, 
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    bool? retryValidation,
    PointCommand? wrappedPoint,
  }) {
    return RepeatingPointCommand(
      id: id?? this.id, 
      version: version + 1, 
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      retryValidation: retryValidation?? this.retryValidation,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      wrappedPoint: wrappedPoint?? this.wrappedPoint,
    );
  }

  @override
  RepeatingPointCommand abstractCopyWith({
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
  double get editHeight => wrappedPoint.editHeight;

  @override
  String get wrappedId => wrappedPoint.id;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    return wrappedPoint.getBoundingBox(drawing);
  }

  @override
  RepeatingPointCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      wrappedPoint: wrappedPoint.changePartDrawingReference(oldId: oldId, newId: newId)
    );
  }

  @override
  RepeatingPointCommand deleteReference({required String commandId}) {
    return copyWith(
      wrappedPoint: wrappedPoint.deleteReference(commandId: commandId)
    );
  }

  @override
  RepeatingPointCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      wrappedPoint: wrappedPoint.dependentLabelChanged(oldLabel, newLabel)
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': RepeatingDrawingCommandTypes.repeatpointCommand.name,
      'id': id,
      'label': label,
      'point': wrappedPoint.toJson(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': RepeatingDrawingCommandTypes.repeatpointCommand.name,
    'label': label,
    'point': wrappedPoint.contentHashCode,
  });

  static RepeatingPointCommand fromJson(Map<String, dynamic> json) {
    return RepeatingPointCommand(
      id: json['id'] as String, 
      version: 0, 
      label: json['label'] as String, 
      wrappedPoint: PointCommand.fromJson(json['point']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RepeatingPointCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    wrappedPoint == other.wrappedPoint &&
    validated == other.validated &&
    valid == other.valid &&
    retryValidation == other.retryValidation &&
    listEquals(errors, other.errors);
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
    other is RepeatingPointCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    wrappedPoint.isSameAs(other.wrappedPoint);

  @override
  int get hashCode => super.hashCode ^ wrappedPoint.hashCode;

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    return wrappedPoint.toSvg(drawingSize, drawing, stylings: stylings);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const [], bool drawDirectionArrow = false, bool forPreview = false}) {
    wrappedPoint.paint(canvas, size, drawing, selected, asPart: asPart, prefixLabel: prefixLabel, stylings: stylings, drawDirectionArrow: drawDirectionArrow, forPreview: forPreview);
  }

  @override
  RepeatingPointCommand clearValidation() => copyWith(
    validated: false,
    valid: false,
    retryValidation: true,
    errors: const[],
    wrappedPoint: wrappedPoint.clearValidation(),
  );

  @override
  Set<String> dependencies(AbstractDrawing drawing) => wrappedPoint.dependencies(drawing);

  @override
  RepeatingPointCommand validate(AbstractDrawing drawing, RepeatCommand repeatContext, int repeatValue) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    Offset? newStoredCoordinate;

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label) || repeatContext.commands.any((c) => c.id != id && c.label == label)) {
      isvalid = false; 
      retryValidation = false; 
      validationErrors.add('Label should be unique'); 
    }

    switch (wrappedPoint.pointDefinitionType) {
      case PointDefinitionType.relativeToPoint:
        double distance = 0;
        FormulaParseResult res = FormulaExpression.validate(
          formula: wrappedPoint.distanceFormula, 
          drawing: drawing, 
          label: 'a distance', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        } else {
          distance = res.result!;
        }

        double offsetAngle = 0;
        if (wrappedPoint.direction == RelativePointDirection.angle) {
          FormulaParseResult res = FormulaExpression.validate(
            formula: wrappedPoint.directionAngleFormula, 
            drawing: drawing, 
            label: 'an angle', 
            repeatContext: repeatContext,
            repeatValue: repeatValue
          );
          if (res.isInvalid) {
            isvalid = false;
            if (!res.shouldRetry) retryValidation = false;
            validationErrors.add(res.errorMessage);
          } else {
            offsetAngle = res.result!;
          }
        } else {
          offsetAngle = wrappedPoint.direction.angleInDegrees;
        }

        PointCommand? fromPoint;
        if (wrappedPoint.fromPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a reference point');
        } else if (wrappedPoint.fromPointId == originId) {
          fromPoint = origin;
        } else {
          fromPoint = drawing.pointById(wrappedPoint.fromPointId)?? repeatContext.pointById(wrappedPoint.fromPointId);
          if (fromPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference point does not exist');
          } else if (wrappedPoint.fromPointId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedPoint.fromPointId.split('.')[2]);
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
        if (wrappedPoint.onLineId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a reference line');
        } else {
          line = drawing.lineById(wrappedPoint.onLineId)?? repeatContext.lineById(wrappedPoint.onLineId);
          if (line == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference line does not exist');
          } else if (wrappedPoint.onLineId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedPoint.onLineId.split('.')[2]);
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
        FormulaParseResult res = FormulaExpression.validate(
          formula: wrappedPoint.onLineFractionFormula, 
          drawing: drawing, 
          label: 'a fraction', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
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
        if (wrappedPoint.onCurveId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a curve');
        } else {
          curve = drawing.curveById(wrappedPoint.onCurveId)?? repeatContext.curveById(wrappedPoint.onCurveId);
          if (curve == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Reference curve does not exist');
          } else if (wrappedPoint.onCurveId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedPoint.onCurveId.split('.')[2]);
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
        FormulaParseResult res = FormulaExpression.validate(
          formula: wrappedPoint.onCurveFractionFormula, 
          drawing: drawing, 
          label: 'a fraction', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        } else {
          fraction = res.result!;
        }

        if (isvalid) {
          if (wrappedPoint.onCurveId.contains('.')) {
            String includedPartCommandId = wrappedPoint.onCurveId.split('.')[2];
            IncludedPartCommand c = drawing.commands.firstWhere((c) => c is IncludedPartCommand && c.id == includedPartCommandId) as IncludedPartCommand;
            PartDrawing? pd = c.storedOffsetPartDrawing;
            if (pd != null) {
              Path p = curve!.getPath(pd, Offset.zero)!;
              newStoredCoordinate = MathUtitilies.pointOnPathAtFraction(p, fraction).scale(1, -1);
            }
          } else {
            Path p = curve!.getPath(drawing, Offset.zero)!;
            newStoredCoordinate = MathUtitilies.pointOnPathAtFraction(p, fraction).scale(1, -1);
          }
        }

      case PointDefinitionType.onIntersection:
        LineCommand? line1;
        LineCommand? line2;
        
        if (wrappedPoint.intersectionLine1Id.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires Line 1');
        } else {
          line1 = drawing.lineById(wrappedPoint.intersectionLine1Id)?? repeatContext.lineById(wrappedPoint.intersectionLine1Id);
          if (line1 == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line 1 does not exist');
          } else if (wrappedPoint.intersectionLine1Id.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedPoint.intersectionLine1Id.split('.')[2]);
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
        if (wrappedPoint.intersectionLine2Id.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires Line 2');
        } else {
          line2 = drawing.lineById(wrappedPoint.intersectionLine2Id)?? repeatContext.lineById(wrappedPoint.intersectionLine2Id);
          if (line2 == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line 2 does not exist');
          } else if (wrappedPoint.intersectionLine2Id.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedPoint.intersectionLine2Id.split('.')[2]);
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
      retryValidation: retryValidation,
      errors: validationErrors,
      wrappedPoint: wrappedPoint.copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
        errors: validationErrors,
        storedCoordinate: newStoredCoordinate,
      ),
    );
  }    

}
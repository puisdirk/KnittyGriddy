import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';

class RepeatingCurveCommand extends RepeatingDrawingCommand {

  final CurveCommand wrappedCurve;

  const RepeatingCurveCommand({
    required super.id,
    required super.version,
    required super.label,
    super.validated,
    super.valid,
    super.retryValidation,
    super.errors,
    super.initiallyOpen,
    required this.wrappedCurve,
  });

  RepeatingCurveCommand copyWith({
    String? id, 
    String? label, 
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    bool? retryValidation,
    CurveCommand? wrappedCurve,
  }) {
    return RepeatingCurveCommand(
      id: id?? this.id, 
      version: version + 1, 
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      retryValidation: retryValidation?? this.retryValidation,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      wrappedCurve: wrappedCurve?? this.wrappedCurve,
    );
  }

  @override
  RepeatingCurveCommand abstractCopyWith({
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
  double get editHeight => wrappedCurve.editHeight;

  @override
  String get wrappedId => wrappedCurve.id;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    return wrappedCurve.getBoundingBox(drawing);
  }

  @override
  RepeatingCurveCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      wrappedCurve: wrappedCurve.changePartDrawingReference(oldId: oldId, newId: newId)
    );
  }

  @override
  RepeatingCurveCommand deleteReference({required String commandId}) {
    return copyWith(
      wrappedCurve: wrappedCurve.deleteReference(commandId: commandId)
    );
  }

  @override
  RepeatingCurveCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      wrappedCurve: wrappedCurve.dependentLabelChanged(oldLabel, newLabel)
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': RepeatingDrawingCommandTypes.repeatcurveCommand.name,
      'id': id,
      'label': label,
      'curve': wrappedCurve.toJson(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': RepeatingDrawingCommandTypes.repeatcurveCommand.name,
    'label': label,
    'curve': wrappedCurve.contentHashCode,
  });

  static RepeatingCurveCommand fromJson(Map<String, dynamic> json) {
    return RepeatingCurveCommand(
      id: json['id'] as String, 
      version: 0, 
      label: json['label'] as String, 
      wrappedCurve: CurveCommand.fromJson(json['curve']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RepeatingCurveCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    wrappedCurve == other.wrappedCurve &&
    validated == other.validated &&
    valid == other.valid &&
    retryValidation == other.retryValidation &&
    listEquals(errors, other.errors);
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
    other is RepeatingCurveCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    wrappedCurve.isSameAs(other.wrappedCurve);

  @override
  int get hashCode => super.hashCode ^ wrappedCurve.hashCode;

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    return wrappedCurve.toSvg(drawingSize, drawing, stylings: stylings);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const [], bool drawDirectionArrow = false, bool forPreview = false}) {
    wrappedCurve.paint(canvas, size, drawing, selected, asPart: asPart, prefixLabel: prefixLabel, stylings: stylings, drawDirectionArrow: drawDirectionArrow, forPreview: forPreview);
  }

  @override
  RepeatingDrawingCommand clearValidation() => copyWith(
    validated: false,
    valid: false,
    retryValidation: true,
    errors: const[],
    wrappedCurve: wrappedCurve.clearValidation(),
  );

  @override
  Set<String> dependencies(AbstractDrawing drawing) => wrappedCurve.dependencies(drawing);

  @override
  RepeatingCurveCommand validate(AbstractDrawing drawing, RepeatCommand repeatContext, int repeatValue) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label) || repeatContext.commands.any((c) => c.id != id && c.label == label)) { 
      isvalid = false; 
      retryValidation = false; 
      validationErrors.add('Label should be unique'); 
    }

    PointCommand? fromPoint;
    if (wrappedCurve.startPointId.isEmpty) {
      isvalid = false; 
      retryValidation = false;
      validationErrors.add('Requires a source point');
    } else if (wrappedCurve.startPointId == originId) {
      fromPoint = origin;
    } else {
      fromPoint = drawing.pointById(wrappedCurve.startPointId)?? repeatContext.pointById(wrappedCurve.startPointId);
      if (fromPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Source point does not exist');
      } else if (wrappedCurve.startPointId.contains('.')) {
        // need to wait on validation of the included part command
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedCurve.startPointId.split('.')[2]);
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
          validationErrors.add('Source point ${fromPoint.label} has errors');
        }
      }
    }

    PointCommand? toPoint;
    if (wrappedCurve.endPointId.isEmpty) {
      isvalid = false; 
      retryValidation = false;
      validationErrors.add('Requires a target point');
    } else if (wrappedCurve.endPointId == originId) {
      toPoint = origin;
    } else {
      toPoint = drawing.pointById(wrappedCurve.endPointId)?? repeatContext.pointById(wrappedCurve.endPointId);
      if (toPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Target point does not exist');
      } else if (wrappedCurve.endPointId.contains('.')) {
        // need to wait on validation of the included part command
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedCurve.endPointId.split('.')[2]);
        if (!ipc.validated) {
          isvalid = false;
        }
      } else {
        if (!toPoint.validated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!toPoint.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Target point ${toPoint.label} has errors');
        }
      }
    }

    PointCommand? quadCtrlPoint;
    PointCommand? cubic1CtrlPoint;
    PointCommand? cubic2CtrlPoint;

    switch (wrappedCurve.curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        FormulaParseResult res = FormulaExpression.validate(
          formula: wrappedCurve.quadAmplitudeFormula, 
          drawing: drawing, 
          label: 'an amplitude', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(
          formula: wrappedCurve.quadSlantFormula, 
          drawing: drawing, 
          label: 'a slant', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }
        break;
      case CurveDefinitionType.quadraticFromPoints:
        if (wrappedCurve.quadCtrlPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a control point');
        } else if (wrappedCurve.quadCtrlPointId != originId) {
          quadCtrlPoint = drawing.pointById(wrappedCurve.quadCtrlPointId)?? repeatContext.pointById(wrappedCurve.quadCtrlPointId);
          if (quadCtrlPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Control point does not exist');
          } else if (wrappedCurve.quadCtrlPointId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedCurve.quadCtrlPointId.split('.')[2]);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else {
            if (!quadCtrlPoint.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!quadCtrlPoint.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('Control point ${quadCtrlPoint.label} has errors');
            }
          }
        }
        break;
      case CurveDefinitionType.cubic:
        FormulaParseResult res = FormulaExpression.validate(
          formula: wrappedCurve.cubicAmplitudeFormula1, 
          drawing: drawing, 
          label: 'first amplitude', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(
          formula: wrappedCurve.cubicSlantFormula1, 
          drawing: drawing, 
          label: 'first slant', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(
          formula: wrappedCurve.cubicAmplitudeFormula2, 
          drawing: drawing, 
          label: 'second amplitude', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(
          formula: wrappedCurve.cubicSlantFormula2, 
          drawing: drawing, 
          label: 'second slant', 
          repeatContext: repeatContext,
          repeatValue: repeatValue
        );
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }
        break;
      case CurveDefinitionType.cubicFromPoints:
        if (wrappedCurve.cubicCtrlPointId1.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires first control point');
        } else if (wrappedCurve.cubicCtrlPointId1 != originId) {
          cubic1CtrlPoint = drawing.pointById(wrappedCurve.cubicCtrlPointId1)?? repeatContext.pointById(wrappedCurve.cubicCtrlPointId1);
          if (cubic1CtrlPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('First control point does not exist');
          } else if (wrappedCurve.cubicCtrlPointId1.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedCurve.cubicCtrlPointId1.split('.')[2]);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else {
            if (!cubic1CtrlPoint.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!cubic1CtrlPoint.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('First control point ${cubic1CtrlPoint.label} has errors');
            }
          }
        }
        if (wrappedCurve.cubicCtrlPointId2.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires second control point');
        } else if (wrappedCurve.cubicCtrlPointId2 != originId) {
          cubic2CtrlPoint = drawing.pointById(wrappedCurve.cubicCtrlPointId2)?? repeatContext.pointById(wrappedCurve.cubicCtrlPointId2);
          if (cubic2CtrlPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Second control point does not exist');
          } else if (wrappedCurve.cubicCtrlPointId2.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == wrappedCurve.cubicCtrlPointId2.split('.')[2]);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else {
            if (!cubic2CtrlPoint.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!cubic2CtrlPoint.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('Second Control point ${cubic2CtrlPoint.label} has errors');
            }
          }
        }
        break;
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      retryValidation: retryValidation,
      errors: validationErrors,
      wrappedCurve: wrappedCurve.copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
        storedStartCoordinate: isvalid ? fromPoint!.getCoordinate(drawing) : null,
        storedEndCoordinate: isvalid ? toPoint!.getCoordinate(drawing) : null,
        storedQuadCtrlPointCoordinate: isvalid ? quadCtrlPoint?.getCoordinate(drawing) : null,
        storedCubicCtrlPoint1Coordinate: isvalid ? cubic1CtrlPoint?.getCoordinate(drawing) : null,
        storedCubicCtrlPoint2Coordinate: isvalid ? cubic2CtrlPoint?.getCoordinate(drawing) : null,
      ),
    );
  }
}
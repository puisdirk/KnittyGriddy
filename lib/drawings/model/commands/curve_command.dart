
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

enum CurveDefinitionType {
  quadratic(label: 'Quadratic'),                        // one ctrl point with amp and slant
  quadraticFromPoints(label: 'Quadratic from points'),  // one ctrl point from point id
  cubic(label: 'Cubic'),                                // two ctrl points with amp and slant
  cubicFromPoints(label: 'Cubic from points');          // two ctrl points from point ids

  final String label;

  const CurveDefinitionType({required this.label});
}

@immutable
class CurveCommand extends DrawingCommand {

  final String startPointId;
  final String endPointId;

  final CurveDefinitionType curveDefinitionType;

  final String quadAmplitudeFormula;
  final String quadSlantFormula;
  final String quadCtrlPointId;
  final String cubicAmplitudeFormula1;
  final String cubicSlantFormula1;
  final String cubicAmplitudeFormula2;
  final String cubicSlantFormula2;
  final String cubicCtrlPointId1;
  final String cubicCtrlPointId2;

  const CurveCommand({
    required super.id,
    required super.label,
    required super.version,
    CurveDefinitionType? curveDefinitionType,
    this.startPointId = '',
    this.endPointId = '',
    this.quadAmplitudeFormula = '1',
    this.quadSlantFormula = '0',
    this.quadCtrlPointId = '',
    this.cubicAmplitudeFormula1 = '1',
    this.cubicSlantFormula1 = '0',
    this.cubicAmplitudeFormula2 = '-1',
    this.cubicSlantFormula2 = '0',
    this.cubicCtrlPointId1 = '',
    this.cubicCtrlPointId2 = '',
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  }) : curveDefinitionType = curveDefinitionType?? CurveDefinitionType.quadratic;

  CurveCommand copyWith({
    String? label,
    CurveDefinitionType? curveDefinitionType,
    String? startPointId,
    String? endPointId,
    String? quadAmplitudeFormula,
    String? quadSlantFormula,
    String? quadCtrlPointId,
    String? cubicAmplitudeFormula1,
    String? cubicSlantFormula1,
    String? cubicAmplitudeFormula2,
    String? cubicSlantFormula2,
    String? cubicCtrlPointId1,
    String? cubicCtrlPointId2,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return CurveCommand(
      id: id,
      version: version + 1,
      label: label?? this.label, 
      curveDefinitionType: curveDefinitionType?? this.curveDefinitionType,
      startPointId: startPointId?? this.startPointId, 
      endPointId: endPointId?? this.endPointId, 
      quadAmplitudeFormula: quadAmplitudeFormula?? this.quadAmplitudeFormula,
      quadSlantFormula: quadSlantFormula?? this.quadSlantFormula,
      quadCtrlPointId: quadCtrlPointId?? this.quadCtrlPointId,
      cubicAmplitudeFormula1: cubicAmplitudeFormula1?? this.cubicAmplitudeFormula1,
      cubicAmplitudeFormula2: cubicAmplitudeFormula2?? this.cubicAmplitudeFormula2,
      cubicSlantFormula1: cubicSlantFormula1?? this.cubicSlantFormula1,
      cubicSlantFormula2: cubicSlantFormula2?? this.cubicSlantFormula2,
      cubicCtrlPointId1: cubicCtrlPointId1?? this.cubicCtrlPointId1,
      cubicCtrlPointId2: cubicCtrlPointId2?? this.cubicCtrlPointId2,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight {
    if (curveDefinitionType == CurveDefinitionType.cubic) return 360;
    if (curveDefinitionType == CurveDefinitionType.cubicFromPoints) return 240;
    if (curveDefinitionType == CurveDefinitionType.quadraticFromPoints) return 200;
    return 270;
  }

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    if (valid) {
      Path? p = getPath(drawing, Offset.zero);
      if (p != null) return p.getBounds();
    }
    return Rect.zero;
  }

  @override
  CurveCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  CurveCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};
    
    if (startPointId.isNotEmpty) deps.add(startPointId);
    if (endPointId.isNotEmpty) deps.add(endPointId);

    switch (curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        deps.addAll(FormulaExpression.dependencies(formula: quadAmplitudeFormula, drawing: drawing));
        deps.addAll(FormulaExpression.dependencies(formula: quadSlantFormula, drawing: drawing));
        break;
      case CurveDefinitionType.quadraticFromPoints:
        if (quadCtrlPointId.isNotEmpty) deps.add(quadCtrlPointId);
        break;
      case CurveDefinitionType.cubic:
        deps.addAll(FormulaExpression.dependencies(formula: cubicAmplitudeFormula1, drawing: drawing));
        deps.addAll(FormulaExpression.dependencies(formula: cubicSlantFormula1, drawing: drawing));
        deps.addAll(FormulaExpression.dependencies(formula: cubicAmplitudeFormula2, drawing: drawing));
        deps.addAll(FormulaExpression.dependencies(formula: cubicSlantFormula2, drawing: drawing));
        break;
      case CurveDefinitionType.cubicFromPoints:
        if (cubicCtrlPointId1.isNotEmpty) deps.add(cubicCtrlPointId1);
        if (cubicCtrlPointId2.isNotEmpty) deps.add(cubicCtrlPointId2);
        break;
    }

    return deps;
  }

  @override
  CurveCommand deleteReference({required String commandId}) {
    return copyWith(
      startPointId: startPointId == commandId ? '' : startPointId,
      endPointId: endPointId == commandId ? '' : endPointId,
      quadCtrlPointId: quadCtrlPointId == commandId ? '' : quadCtrlPointId,
      cubicCtrlPointId1: cubicCtrlPointId1 == commandId ? '' : cubicCtrlPointId1,
      cubicCtrlPointId2: cubicCtrlPointId2 == commandId ? '' : cubicCtrlPointId2,
    );
  }

  @override
  CurveCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      cubicAmplitudeFormula1: cubicAmplitudeFormula1.replaceAll(oldLabel, newLabel),
      cubicAmplitudeFormula2: cubicAmplitudeFormula2.replaceAll(oldLabel, newLabel),
      cubicSlantFormula1: cubicSlantFormula1.replaceAll(oldLabel, newLabel),
      cubicSlantFormula2: cubicSlantFormula2.replaceAll(oldLabel, newLabel),
      quadAmplitudeFormula: quadAmplitudeFormula.replaceAll(oldLabel, newLabel),
      quadSlantFormula: quadSlantFormula.replaceAll(oldLabel, newLabel),
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
      'cdt': curveDefinitionType.name,
      'qamp': quadAmplitudeFormula,
      'qslant': quadSlantFormula,
      'qctrl': quadCtrlPointId,
      'camp1': cubicAmplitudeFormula1,
      'cslant1': cubicSlantFormula1,
      'camp2': cubicAmplitudeFormula2,
      'cslant2': cubicSlantFormula2,
      'cctrl1': cubicCtrlPointId1,
      'cctrl2': cubicCtrlPointId2,
    };
  }

  static CurveCommand fromJson(Map<String, dynamic> json) {
    return CurveCommand(
      id: json['id'] as String,
      version: 0,
      label: json['label'] as String, 
      startPointId: json['from'] as String,
      endPointId: json['to'] as String, 
      curveDefinitionType: CurveDefinitionType.values.byName(json['cdt'] as String),
      quadAmplitudeFormula: json['qamp'] as String,
      quadSlantFormula: json['qslant'] as String,
      quadCtrlPointId: json['qctrl'] as String,
      cubicAmplitudeFormula1: json['camp1'] as String,
      cubicSlantFormula1: json['cslant1'] as String,
      cubicAmplitudeFormula2: json['camp2'] as String,
      cubicSlantFormula2: json['cslant2'] as String,
      cubicCtrlPointId1: json['cctrl1'] as String,
      cubicCtrlPointId2: json['cctrl2'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is CurveCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    version == other.version &&
    label == other.label &&
    startPointId == other.startPointId &&
    endPointId == other.endPointId &&
    curveDefinitionType == other.curveDefinitionType &&
    quadAmplitudeFormula == other.quadAmplitudeFormula &&
    quadSlantFormula == other.quadSlantFormula &&
    quadCtrlPointId == other.quadCtrlPointId &&
    cubicAmplitudeFormula1 == other.cubicAmplitudeFormula1 &&
    cubicSlantFormula1 == other.cubicSlantFormula1 &&
    cubicAmplitudeFormula2 == other.cubicAmplitudeFormula2 &&
    cubicSlantFormula2 == other.cubicSlantFormula2 &&
    cubicCtrlPointId1 == other.cubicCtrlPointId1 &&
    cubicCtrlPointId2 == other.cubicCtrlPointId2 &&
    validated == other.validated &&
    valid == other.valid &&
    listEquals(errors, other.errors);
  
  @override
  int get hashCode => super.hashCode ^ startPointId.hashCode ^ endPointId.hashCode ^ 
    curveDefinitionType.hashCode ^
    quadAmplitudeFormula.hashCode ^ quadSlantFormula.hashCode ^ quadCtrlPointId.hashCode ^
    cubicAmplitudeFormula1.hashCode ^ cubicSlantFormula1.hashCode ^ cubicAmplitudeFormula2.hashCode ^ cubicSlantFormula2.hashCode ^ 
    cubicCtrlPointId1.hashCode ^ cubicCtrlPointId2.hashCode;

  Path? getPath(AbstractDrawing drawing, Offset offset) {
    if (!valid) return null;

    Offset? startCoordinate = getStartCoordinate(drawing);
    if (startCoordinate == null) return null;
    startCoordinate = startCoordinate.scale(1, -1);
    startCoordinate += offset;

    Offset? endCoordinate = getEndCoordinate(drawing);
    if (endCoordinate == null) return null;
    endCoordinate = endCoordinate.scale(1, -1);
    endCoordinate += offset;

    switch (curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        double? amplitude = getQuadAmplitude(drawing);
        if (amplitude == null) return null;

        double? slant = getQuadSlant(drawing);
        if (slant == null) return null;

        Offset controlCoordinate = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude, slant);

        return Path()
        ..moveTo(startCoordinate.dx, startCoordinate.dy)
        ..quadraticBezierTo(
          controlCoordinate.dx, controlCoordinate.dy, 
          endCoordinate.dx, endCoordinate.dy);
      case CurveDefinitionType.quadraticFromPoints:
        if (quadCtrlPointId.isEmpty) return null;
        PointCommand? ctrlPointCmd = drawing.pointById(quadCtrlPointId);
        if (ctrlPointCmd == null) return null;
        Offset? ctrlPoint = ctrlPointCmd.getCoordinate(drawing);
        if (ctrlPoint == null) return null;
        ctrlPoint = ctrlPoint.scale(1, -1);
        ctrlPoint += offset;
        return Path()
        ..moveTo(startCoordinate.dx, startCoordinate.dy)
        ..quadraticBezierTo(
          ctrlPoint.dx, ctrlPoint.dy, 
          endCoordinate.dx, endCoordinate.dy);
      case CurveDefinitionType.cubic:
        double? amplitude1 = getCubicAmplitude1(drawing);
        if (amplitude1 == null) return null;

        double? slant1 = getCubicSlant1(drawing);
        if (slant1 == null) return null;

        double? amplitude2 = getCubicAmplitude2(drawing);
        if (amplitude2 == null) return null;

        double? slant2 = getCubicSlant2(drawing);
        if (slant2 == null) return null;

        Offset controlCoordinate1 = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude1, slant1);
        Offset controlCoordinate2 = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude2, slant2);

        return Path()
        ..moveTo(startCoordinate.dx, startCoordinate.dy)
        ..cubicTo(
          controlCoordinate1.dx, controlCoordinate1.dy, 
          controlCoordinate2.dx, controlCoordinate2.dy, 
          endCoordinate.dx, endCoordinate.dy);
      case CurveDefinitionType.cubicFromPoints:
        if (cubicCtrlPointId1.isEmpty) return null;
        PointCommand? ctrlPoint1Cmd = drawing.pointById(cubicCtrlPointId1);
        if (ctrlPoint1Cmd == null) return null;
        Offset? ctrlPoint1 = ctrlPoint1Cmd.getCoordinate(drawing);
        if (ctrlPoint1 == null) return null;
        ctrlPoint1 = ctrlPoint1.scale(1, -1);
        ctrlPoint1 += offset;

        if (cubicCtrlPointId2.isEmpty) return null;
        PointCommand? ctrlPoint2Cmd = drawing.pointById(cubicCtrlPointId2);
        if (ctrlPoint2Cmd == null) return null;
        Offset? ctrlPoint2 = ctrlPoint2Cmd.getCoordinate(drawing);
        if (ctrlPoint2 == null) return null;
        ctrlPoint2 = ctrlPoint2.scale(1, -1);
        ctrlPoint2 += offset;

        return Path()
        ..moveTo(startCoordinate.dx, startCoordinate.dy)
        ..cubicTo(
          ctrlPoint1.dx, ctrlPoint1.dy, 
          ctrlPoint2.dx, ctrlPoint2.dy, 
          endCoordinate.dx, endCoordinate.dy);
    }
  }

  Offset pointOnPath(Path p, double fraction) {
    final PathMetrics m = p.computeMetrics();
    final PathMetric pm = m.first;
    return pm.getTangentForOffset(pm.length * fraction)!.position;
  }

  @override
  String previewPath(AbstractDrawing drawing) {
    if (!valid) return '';

    Offset? startCoordinate = getStartCoordinate(drawing);
    if (startCoordinate == null) return '';
    startCoordinate = startCoordinate.scale(1, -1);

    Offset? endCoordinate = getEndCoordinate(drawing);
    if (endCoordinate == null) return '';
    endCoordinate = endCoordinate.scale(1, -1);

    switch (curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        double? amplitude = getQuadAmplitude(drawing);
        if (amplitude == null) return '';

        double? slant = getQuadSlant(drawing);
        if (slant == null) return '';

        Offset controlCoordinate = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude, slant);

        return ' M${startCoordinate.dx},${startCoordinate.dy} Q${controlCoordinate.dx},${controlCoordinate.dy} ${endCoordinate.dx},${endCoordinate.dy}';
      case CurveDefinitionType.quadraticFromPoints:
        if (quadCtrlPointId.isEmpty) return '';
        PointCommand? ctrlPointCmd = drawing.pointById(quadCtrlPointId);
        if (ctrlPointCmd == null) return '';
        Offset? ctrlPoint = ctrlPointCmd.getCoordinate(drawing);
        if (ctrlPoint == null) return '';
        ctrlPoint = ctrlPoint.scale(1, -1);

        return ' M${startCoordinate.dx},${startCoordinate.dy} Q${ctrlPoint.dx},${ctrlPoint.dy} ${endCoordinate.dx},${endCoordinate.dy}';
      case CurveDefinitionType.cubic:
        double? amplitude1 = getCubicAmplitude1(drawing);
        if (amplitude1 == null) return '';

        double? slant1 = getCubicSlant1(drawing);
        if (slant1 == null) return '';

        double? amplitude2 = getCubicAmplitude2(drawing);
        if (amplitude2 == null) return '';

        double? slant2 = getCubicSlant2(drawing);
        if (slant2 == null) return '';

        Offset controlCoordinate1 = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude1, slant1);
        Offset controlCoordinate2 = getControlPointCoordinate(startCoordinate, endCoordinate, amplitude2, slant2);

        return ' M${startCoordinate.dx},${startCoordinate.dy} C${controlCoordinate1.dx},${controlCoordinate1.dy} ${controlCoordinate2.dx},${controlCoordinate2.dy} ${endCoordinate.dx},${endCoordinate.dy}';
      case CurveDefinitionType.cubicFromPoints:
        if (cubicCtrlPointId1.isEmpty) return '';
        PointCommand? ctrlPoint1Cmd = drawing.pointById(cubicCtrlPointId1);
        if (ctrlPoint1Cmd == null) return '';
        Offset? ctrlPoint1 = ctrlPoint1Cmd.getCoordinate(drawing);
        if (ctrlPoint1 == null) return '';
        ctrlPoint1 = ctrlPoint1.scale(1, -1);

        if (cubicCtrlPointId2.isEmpty) return '';
        PointCommand? ctrlPoint2Cmd = drawing.pointById(cubicCtrlPointId2);
        if (ctrlPoint2Cmd == null) return '';
        Offset? ctrlPoint2 = ctrlPoint2Cmd.getCoordinate(drawing);
        if (ctrlPoint2 == null) return '';
        ctrlPoint2 = ctrlPoint2.scale(1, -1);

        return ' M${startCoordinate.dx},${startCoordinate.dy} C${ctrlPoint1.dx},${ctrlPoint1.dy} ${ctrlPoint2.dx},${ctrlPoint2.dy} ${endCoordinate.dx},${endCoordinate.dy}';
    }

  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false}) {
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

    Path? p = getPath(drawing, middle);
    if (p == null) return;

    canvas.drawPath(
      p, 
      Paint()
        ..color = selected ? selectedColor : asPart ? partColor : Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = asPart || selected ? 2 : 1);

    // draw curve label
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
    ..addText(label);

    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width));

    Offset labelPosition = pointOnPath(p, 0.3);
    canvas.drawParagraph(paragraph, labelPosition);

    // Draw control points and lines
    Paint controlsPaint = Paint()
      ..color = selected ? selectedColorLight : Colors.grey.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 1 : .5;
      
    if (curveDefinitionType == CurveDefinitionType.quadratic) {
      Offset controlCoordinate = getControlPointCoordinate(startCoordinate, endCoordinate, getQuadAmplitude(drawing)!, getQuadSlant(drawing)!);
      canvas.drawRect(Rect.fromCenter(center: controlCoordinate, width: 3, height: 3), controlsPaint);
      canvas.drawLine(controlCoordinate, startCoordinate, controlsPaint);
      canvas.drawLine(controlCoordinate, endCoordinate, controlsPaint);
    }
    if (curveDefinitionType == CurveDefinitionType.quadraticFromPoints) {
      if (quadCtrlPointId.isEmpty) return;
      PointCommand? ctrlPointCmd = drawing.pointById(quadCtrlPointId);
      if (ctrlPointCmd == null) return;
      Offset? ctrlPoint = ctrlPointCmd.getCoordinate(drawing);
      if (ctrlPoint == null) return;
      ctrlPoint = ctrlPoint.scale(1, -1);
      ctrlPoint += middle;
      
      canvas.drawRect(Rect.fromCenter(center: ctrlPoint, width: 3, height: 3), controlsPaint);
      canvas.drawLine(ctrlPoint, startCoordinate, controlsPaint);
      canvas.drawLine(ctrlPoint, endCoordinate, controlsPaint);
    }
    if (curveDefinitionType == CurveDefinitionType.cubic) {
      Offset controlCoordinate1 = getControlPointCoordinate(startCoordinate, endCoordinate, getCubicAmplitude1(drawing)!, getCubicSlant1(drawing)!);
      Offset controlCoordinate2 = getControlPointCoordinate(startCoordinate, endCoordinate, getCubicAmplitude2(drawing)!, getCubicSlant2(drawing)!);
    
      canvas.drawRect(Rect.fromCenter(center: controlCoordinate1, width: 3, height: 3), controlsPaint);
      canvas.drawRect(Rect.fromCenter(center: controlCoordinate2, width: 3, height: 3), controlsPaint);
      canvas.drawLine(controlCoordinate1, startCoordinate, controlsPaint);
      canvas.drawLine(controlCoordinate2, endCoordinate, controlsPaint);
    }
    if (curveDefinitionType == CurveDefinitionType.cubicFromPoints) {
      if (cubicCtrlPointId1.isEmpty) return;
      PointCommand? ctrlPointCmd1 = drawing.pointById(cubicCtrlPointId1);
      if (ctrlPointCmd1 == null) return;
      Offset? ctrlPoint1 = ctrlPointCmd1.getCoordinate(drawing);
      if (ctrlPoint1 == null) return;
      ctrlPoint1 = ctrlPoint1.scale(1, -1);
      ctrlPoint1 += middle;
      
      if (cubicCtrlPointId2.isEmpty) return;
      PointCommand? ctrlPointCmd2 = drawing.pointById(cubicCtrlPointId2);
      if (ctrlPointCmd2 == null) return;
      Offset? ctrlPoint2 = ctrlPointCmd2.getCoordinate(drawing);
      if (ctrlPoint2 == null) return;
      ctrlPoint2 = ctrlPoint2.scale(1, -1);
      ctrlPoint2 += middle;
      
      canvas.drawRect(Rect.fromCenter(center: ctrlPoint1, width: 3, height: 3), controlsPaint);
      canvas.drawRect(Rect.fromCenter(center: ctrlPoint2, width: 3, height: 3), controlsPaint);
      canvas.drawLine(ctrlPoint1, startCoordinate, controlsPaint);
      canvas.drawLine(ctrlPoint2, endCoordinate, controlsPaint);
    }
  }

  double? getQuadAmplitude(AbstractDrawing drawing) {
    return FormulaExpression.validate(formula: quadAmplitudeFormula, drawing: drawing).result;
  }

  double? getQuadSlant(AbstractDrawing drawing) {
    return FormulaExpression.validate(formula: quadSlantFormula, drawing: drawing).result;
  }

  double? getCubicAmplitude1(AbstractDrawing drawing) {
    return FormulaExpression.validate(formula: cubicAmplitudeFormula1, drawing: drawing).result;
  }

  double? getCubicSlant1(AbstractDrawing drawing) {
    return FormulaExpression.validate(formula: cubicSlantFormula1, drawing: drawing).result;
  }

  double? getCubicAmplitude2(AbstractDrawing drawing) {
    return FormulaExpression.validate(formula: cubicAmplitudeFormula2, drawing: drawing).result;
  }

  double? getCubicSlant2(AbstractDrawing drawing) {
    return FormulaExpression.validate(formula: cubicSlantFormula2, drawing: drawing).result;
  }

  Offset? getStartCoordinate(AbstractDrawing drawing) {
    PointCommand? startPoint = drawing.pointById(startPointId);
    if (startPoint == null) return null;
    return startPoint.getCoordinate(drawing);
  }

  Offset? getEndCoordinate(AbstractDrawing drawing) {
    PointCommand? endPoint = drawing.pointById(endPointId);
    if (endPoint == null) return null;
    return endPoint.getCoordinate(drawing);
  }

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
  CurveCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }
  
  @override
  CurveCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

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

    switch (curveDefinitionType) {
      case CurveDefinitionType.quadratic:
        FormulaParseResult res = FormulaExpression.validate(formula: quadAmplitudeFormula, drawing: drawing, label: 'an amplitude');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(formula: quadSlantFormula, drawing: drawing, label: 'a slant');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }
        break;
      case CurveDefinitionType.quadraticFromPoints:
        if (quadCtrlPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a control point');
        } else if (quadCtrlPointId != originId) {
          PointCommand? ctrlPoint = drawing.pointById(quadCtrlPointId);
          if (ctrlPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Control point does not exist');
          } else {
            if (!ctrlPoint.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!ctrlPoint.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('Control point ${ctrlPoint.label} has errors');
            }
          }
        }
        break;
      case CurveDefinitionType.cubic:
        FormulaParseResult res = FormulaExpression.validate(formula: cubicAmplitudeFormula1, drawing: drawing, label: 'first amplitude');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(formula: cubicSlantFormula1, drawing: drawing, label: 'first slant');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(formula: cubicAmplitudeFormula2, drawing: drawing, label: 'second amplitude');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }

        res = FormulaExpression.validate(formula: cubicSlantFormula2, drawing: drawing, label: 'second slant');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add(res.errorMessage);
        }
        break;
      case CurveDefinitionType.cubicFromPoints:
        if (cubicCtrlPointId1.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires first control point');
        } else if (cubicCtrlPointId1 != originId) {
          PointCommand? ctrlPoint1 = drawing.pointById(cubicCtrlPointId1);
          if (ctrlPoint1 == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('First control point does not exist');
          } else {
            if (!ctrlPoint1.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!ctrlPoint1.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('First control point ${ctrlPoint1.label} has errors');
            }
          }
        }
        if (cubicCtrlPointId2.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires second control point');
        } else if (cubicCtrlPointId2 != originId) {
          PointCommand? ctrlPoint2 = drawing.pointById(cubicCtrlPointId2);
          if (ctrlPoint2 == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Second control point does not exist');
          } else {
            if (!ctrlPoint2.validated) {
              // We are not valid, but we should retry
              isvalid = false;
            } else if (!ctrlPoint2.valid) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('Second Control point ${ctrlPoint2.label} has errors');
            }
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
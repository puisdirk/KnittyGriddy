import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/arrow_painter.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:path_drawing/path_drawing.dart';

enum TapeUnit {
  mm(label: 'Millimeter', abbr: 'mm', shortLabel: 'mm'),
  cm(label: 'Centimeter', abbr: 'cm', shortLabel: 'cm'),
  m(label: 'Meter', abbr: 'm', shortLabel: 'meters'),
  inch(label: 'Inches', abbr: '"', shortLabel: 'inches'),
  feet(label: 'Feet', abbr: 'ft', shortLabel: 'feet'),
  rows(label: 'Rows', abbr: 'rows', shortLabel: 'rows'),
  sts(label: 'Stitches', abbr: 'sts', shortLabel: 'sts');

  final String label;
  final String shortLabel;
  final String abbr;

  const TapeUnit({required this.label, required this.shortLabel, required this.abbr});
}

enum TapeDirectionType {
  free(label: 'Free'),
  horizontal(label: 'Horizontal'),
  vertical(label: 'Vertical');

  final String label;

  const TapeDirectionType({required this.label});
}

enum TapeType {
  betweenPoints(label: 'Between points'),
  line(label: 'Line'),
  linesAndcurves(label: 'Lines and Curves');

  final String label;

  const TapeType({required this.label});
}

class TapeCommand extends DrawingCommand {
  final String fromPointId;
  final String toPointId;
  final String lineId;
  final Set<String> lineAndCurveIds;
  final bool isCircular;
  final TapeDirectionType directionType;
  final TapeType tapeType;
  final TapeUnit unit;
  final double rowsGauge;
  final double stitchesGauge;

  const TapeCommand({
    required super.id,
    required super.version,
    required super.label,
    this.fromPointId = '',
    this.toPointId = '',
    this.lineId = '',
    this.lineAndCurveIds = const{},
    this.isCircular = false,
    this.directionType = TapeDirectionType.free,
    this.tapeType = TapeType.betweenPoints,
    this.unit = TapeUnit.mm,
    this.rowsGauge = 10,
    this.stitchesGauge = 10,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  TapeCommand copyWith({
    String? id,
    String? label,
    String? fromPointId,
    String? toPointId,
    String? lineId,
    Set<String>? lineAndCurveIds,
    bool? isCircular,
    TapeDirectionType? directionType,
    TapeType? tapeType,
    TapeUnit? unit,
    double? rowsGauge,
    double? stitchesGauge,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return TapeCommand(
      id: id?? this.id, 
      version: version + 1, 
      label: label?? this.label,
      fromPointId: fromPointId?? this.fromPointId,
      toPointId: toPointId?? this.toPointId,
      lineId: lineId?? this.lineId,
      lineAndCurveIds: lineAndCurveIds?? this.lineAndCurveIds,
      isCircular: isCircular?? this.isCircular,
      directionType: directionType?? this.directionType,
      tapeType: tapeType?? this.tapeType,
      unit: unit?? this.unit,
      rowsGauge: rowsGauge?? this.rowsGauge,
      stitchesGauge: stitchesGauge?? this.stitchesGauge,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  TapeCommand abstractCopyWith({
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
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is TapeCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      fromPointId == other.fromPointId &&
      lineId == other.lineId &&
      setEquals(lineAndCurveIds, other.lineAndCurveIds) &&
      isCircular == other.isCircular &&
      directionType == other.directionType &&
      tapeType == other.tapeType &&
      toPointId == other.toPointId &&
      unit == other.unit &&
      rowsGauge == other.rowsGauge &&
      stitchesGauge == other.stitchesGauge &&
      validated == other.validated &&
      valid == other.valid &&
      listEquals(errors, other.errors);

  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
      other is TapeCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      fromPointId == other.fromPointId &&
      lineId == other.lineId &&
      setEquals(lineAndCurveIds, other.lineAndCurveIds) &&
      isCircular == other.isCircular &&
      directionType == other.directionType &&
      tapeType == other.tapeType &&
      toPointId == other.toPointId &&
      unit == other.unit &&
      rowsGauge == other.rowsGauge &&
      stitchesGauge == other.stitchesGauge;

  @override
  int get hashCode => super.hashCode ^ fromPointId.hashCode ^ toPointId.hashCode ^ lineId.hashCode ^ lineAndCurveIds.hashCode ^
    isCircular.hashCode ^ directionType.hashCode ^ tapeType.hashCode ^ unit.hashCode ^ rowsGauge.hashCode ^ stitchesGauge.hashCode;

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.tapeCommand.name,
      'id': id,
      'label': label,
      'from': fromPointId,
      'lineid': lineId,
      'lineandcurveids': lineAndCurveIds.toList(),
      'directiontype': directionType.name,
      'tapetype': tapeType.name,
      'to': toPointId,
      'unit': unit.name,
      'rg': rowsGauge,
      'stsg': stitchesGauge,
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': DrawingCommandTypes.tapeCommand.name,
    'label': label,
    'from': fromPointId,
    'lineid': lineId,
    'lineandcurveids': lineAndCurveIds.toList(),
    'directiontype': directionType.name,
    'tapetype': tapeType.name,
    'to': toPointId,
    'unit': unit.name,
    'rg': rowsGauge,
    'stsg': stitchesGauge,
  });

  static TapeCommand fromJson(Map<String, dynamic> json) {
    return TapeCommand(
      id: json['id'] as String, 
      version: 0, 
      label: json['label'] as String,
      fromPointId: json['from'] as String,
      toPointId: json['to'] as String,
      lineId: json['lineid'] as String,
      lineAndCurveIds: (json['lineandcurveids'] as List).map((o) => o as String).toSet(),
      directionType: TapeDirectionType.values.byName(json['directiontype'] as String),
      tapeType: TapeType.values.byName(json['tapetype'] as String),
      unit: TapeUnit.values.byName(json['unit'] as String),
      rowsGauge: json['rg'] as double,
      stitchesGauge: json['stsg'] as double,
    );
  }

  @override
  double get editHeight {
    double h = tapeType == TapeType.linesAndcurves ? 380 : 200;
    h += (unit == TapeUnit.rows || unit == TapeUnit.sts) ? 30 : 0;
    return h;
  }

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    if (valid) {
      switch (tapeType) {
        case TapeType.betweenPoints: {
          Offset? start = drawing.pointById(fromPointId)!.getCoordinate(drawing);
          Offset? end = drawing.pointById(toPointId)!.getCoordinate(drawing);
          if (start != null && end != null) {
            return Rect.fromPoints(start, end);
          } else {
            return Rect.zero;
          }
        }

        case TapeType.line: {
          return drawing.lineById(lineId)!.getBoundingBox(drawing);
        }

        case TapeType.linesAndcurves: {
          Rect res = Rect.zero;
          for (String lineOrCurveId in lineAndCurveIds) {
            res = res.expandToInclude(drawing.commandById(lineOrCurveId)!.getBoundingBox(drawing));
          }
          return res;
        }
      }
    }

    return Rect.zero;
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};

    if (fromPointId.isNotEmpty) {
      if (fromPointId.contains('.')) {
        deps.add(fromPointId.split('.')[2]);
      }
      
      deps.add(fromPointId);
    }

    if (toPointId.isNotEmpty) {
      if (toPointId.contains('.')) {
        deps.add(toPointId.split('.')[2]);
      }
      
      deps.add(toPointId);
    }

    if (lineId.isNotEmpty) {
      if (lineId.contains('.')) {
        deps.add(lineId.split('.')[2]);
      }
      
      deps.add(toPointId);
    }

    for (String lineOrCurveId in lineAndCurveIds) {
      if (lineOrCurveId.contains('.')) {
        deps.add(lineOrCurveId.split('.')[2]);
      }

      deps.add(lineOrCurveId);
    }

    return deps;
  }

  @override
  TapeCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return this;
  }

  @override
  TapeCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      fromPointId: fromPointId.replaceAll(oldId, newId),
      toPointId: toPointId.replaceAll(oldId, newId),
      lineId: lineId.replaceAll(oldId, newId),
      lineAndCurveIds: lineAndCurveIds.map((c) => c.replaceAll(oldId, newId)).toSet(),
    );
  }

  @override
  TapeCommand deleteReference({required String commandId}) {
    return copyWith(
      fromPointId: (fromPointId == commandId || fromPointId.startsWith('$commandId.')) ? '' : fromPointId,
      toPointId: (toPointId == commandId || toPointId.startsWith('$commandId.')) ? '' : toPointId,
      lineId: (lineId == commandId || lineId.startsWith('$commandId.')) ? '' : lineId,
      lineAndCurveIds: lineAndCurveIds.where((c) => c != commandId && !c.startsWith('$commandId.')).toSet(),
    );
  }

  @override
  TapeCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[], isCircular: false);
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    if (!valid) return '';

    Offset middle = Offset(drawingSize.width / 2, drawingSize.height / 2);
    StylingCommand? styling = drawing.styleFor(id)?? stylings.where((s) => s.commandIds.any((c) => c == id)).firstOrNull;

    String svg = '<g id="$label">';

    switch (tapeType) {
      case TapeType.betweenPoints: {

        Offset? start = drawing.pointById(fromPointId)!.getCoordinate(drawing);
        if (start == null) {
          return '';
        }
        start = start.scale(1, -1);

        Offset? end = drawing.pointById(toPointId)!.getCoordinate(drawing);
        if (end == null) {
          return '';
        }
        end = end.scale(1, -1);
        start += middle;
        end += middle;

        switch (directionType) {
          case TapeDirectionType.free: {
            svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${end.dx}" y2="${end.dy}" fill="none" ';

            if (styling == null) {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
            } else {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
              if (styling.dashStyle == DashStyle.full) {
                svg += '/>';
              } else {
                svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
              }
            }

            if (styling != null) {
              svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: start, end: end);
              svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: start, end: end);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, end, 0.5);

            svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

          } break;
          case TapeDirectionType.horizontal: {
            Offset tapeEndPoint = Offset(end.dx, start.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dy - end.dy).abs() > 5) {
              svg += '<line x1="${end.dx}" y1="#{end.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            }

            svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" ';

            if (styling == null) {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
            } else {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
              if (styling.dashStyle == DashStyle.full) {
                svg += '/>';
              } else {
                svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
              }
            }

            if (styling != null) {
              svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
              svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, end, 0.5);

            svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

          } break;
          case TapeDirectionType.vertical: {
            Offset tapeEndPoint = Offset(start.dx, end.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dx - end.dx).abs() > 5) {
              svg += '<line x1="${end.dx}" y1="${end.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            }

            svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" ';

            if (styling == null) {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
            } else {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
              if (styling.dashStyle == DashStyle.full) {
                svg += '/>';
              } else {
                svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
              }
            }

            if (styling != null) {
              svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
              svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, end, 0.5);

            svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

          } break;
        }
      } break; // end of TapeType.betweenPoints

      case TapeType.line: {

        LineCommand? line = drawing.lineById(lineId);
        if (line == null) return '';

        Offset? start = line.getStartCoordinate(drawing);
        if (start == null) return '';
        start = start.scale(1, -1);

        Offset? end = line.getEndCoordinate(drawing);
        if (end == null) return '';
        end = end.scale(1, -1);

        start += middle;
        end += middle;

        switch (directionType) {
          case TapeDirectionType.free: {
            // Calculate perpendicular points to start and end
            double perpendicularAngle = MathUtitilies.angleOfLine(start, end) + (pi / 2.0);

            double helperLineHeight = 20;
            Offset tapeStartPoint = MathUtitilies.relativepointatangle(start, -helperLineHeight, perpendicularAngle);
            Offset tapeEndPoint= MathUtitilies.relativepointatangle(end, -helperLineHeight, perpendicularAngle);

            svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${tapeStartPoint.dx}" y2="${tapeStartPoint.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            svg += '<line x1="${end.dx}" y1="${end.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';

            svg += '<line x1="${tapeStartPoint.dx}" y1="${tapeStartPoint.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" ';

            if (styling == null) {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
            } else {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
              if (styling.dashStyle == DashStyle.full) {
                svg += '/>';
              } else {
                svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
              }
            }

            if (styling != null) {
              svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: tapeStartPoint, end: tapeEndPoint);
              svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: tapeStartPoint, end: tapeEndPoint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(tapeStartPoint, tapeEndPoint, 0.5);

            svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

          } break;
          case TapeDirectionType.horizontal: {
            Offset tapeEndPoint = Offset(end.dx, start.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dy - end.dy).abs() > 5) {
              svg += '<line x1="${end.dx}" y1="${end.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            }

            svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" ';

            if (styling == null) {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
            } else {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
              if (styling.dashStyle == DashStyle.full) {
                svg += '/>';
              } else {
                svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
              }
            }

            if (styling != null) {
              svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
              svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, tapeEndPoint, 0.5);

            svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

          } break;
          case TapeDirectionType.vertical: {
            Offset tapeEndPoint = Offset(start.dx, end.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dx - end.dx).abs() > 5) {
              svg += '<line x1="${end.dx}" y1="${end.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            }

            svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${tapeEndPoint.dx}" y2="${tapeEndPoint.dy}" fill="none" ';

            if (styling == null) {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
            } else {
              svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
              if (styling.dashStyle == DashStyle.full) {
                svg += '/>';
              } else {
                svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
              }
            }

            if (styling != null) {
              svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
              svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: start, end: tapeEndPoint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, tapeEndPoint, 0.5);

            svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

          } break;
        }
      } break; // end of TapeType.line

      case TapeType.linesAndcurves: {
        double helperLineHeight = 20;

        List<DrawingCommand> linesAndCurves = [];
        for (String lineOrCurveId in lineAndCurveIds) {
          DrawingCommand? lineOrcurve = drawing.commandById(lineOrCurveId);
          if (lineOrcurve == null) return '';
          linesAndCurves.add(lineOrcurve);
        }

        DrawingCommand startLineOrCurve;
        DrawingCommand endLineOrCurve;

        if (isCircular) {
          // Use the first one as start
          startLineOrCurve = linesAndCurves.first;

          // Find the command that ends on the first's head
          endLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) =>
            _getLineOrCurveEndPointId(lineOrCurve) == _getLineOrCurveStartPointId(startLineOrCurve)
          );
        } else {
          // Find the command that doesn't have a command at the head
          startLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) =>
            !linesAndCurves.any((other) => lineOrCurve != other &&
            _getLineOrCurveStartCoordinate(lineOrCurve, drawing) == _getLineOrCurveEndCoordinate(other, drawing))
          );

          // Find the command that doesn't have a command at the tail
          endLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) =>
            !linesAndCurves.any((other) => lineOrCurve != other &&
            _getLineOrCurveEndCoordinate(lineOrCurve, drawing) == _getLineOrCurveStartCoordinate(other, drawing))
          );
        }

        Offset? start = _getLineOrCurveStartCoordinate(startLineOrCurve, drawing);
        start = start.scale(1, -1);

        Offset? end = _getLineOrCurveEndCoordinate(endLineOrCurve, drawing);
        end = end.scale(1, -1);

        start += middle;
        end += middle;

        double fractionIncrease = 0.02;

        // We build the tape path to draw it at the end
        String tapeCurvePath = '';
        // We'll remember the start and end of the tape to draw arrows on them at the end
        Offset tapeCurveStartLocation = Offset.zero;
        Offset tapeCurveEndLocation = Offset.zero;
        // We add the length of each segment
        double distanceInMM = 0;

        DrawingCommand lineOrCurve = startLineOrCurve;
        while (true) {
          if (lineOrCurve is CurveCommand) {
            Path curvePath = lineOrCurve.getPath(drawing, middle)!;
            distanceInMM += MathUtitilies.lengthOfPath(curvePath);

            // Calculate perpendicular points, every fractionIncrease step of the curve
            for (double perplocation = 0; perplocation <= 1 + fractionIncrease; perplocation += fractionIncrease) {
              bool atEndOfCurve = perplocation >= 1;

              // Find that next point on the curve
              Offset perpOffset = MathUtitilies.pointOnPathAtFraction(curvePath, perplocation);
              
              // Find a point that is a bit further or back on the curve to get the angle between those two points
              Offset perpoffsetincreased = MathUtitilies.pointOnPathAtFraction(curvePath, atEndOfCurve ? perplocation - 0.05 : perplocation + 0.05);
              
              // Get the perpendicular angle of that piece of the curve
              double perpendicularAngle = atEndOfCurve ?
                MathUtitilies.angleOfLine(perpoffsetincreased, perpOffset) + (pi / 2.0)
              : MathUtitilies.angleOfLine(perpOffset, perpoffsetincreased) + (pi / 2.0);

              // Get a point at that angle, somewhat removed from the curve
              Offset shadowPointOffset = MathUtitilies.relativepointatangle(perpOffset, -helperLineHeight, perpendicularAngle);

              // If we are at the first point of the start curve, we draw a helper line
              if (lineOrCurve == startLineOrCurve && perplocation == 0) {
                svg += '<line x1="${start.dx}" y1="${start.dy}" x2="${shadowPointOffset.dx}" y2="${shadowPointOffset.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
                tapeCurveStartLocation = shadowPointOffset;
              }
              // and same on the last point of the last curve
              if (lineOrCurve == endLineOrCurve && atEndOfCurve) {
                svg += '<line x1="${end.dx}" y1="${end.dy}" x2="${shadowPointOffset.dx}" y2="${shadowPointOffset.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
                tapeCurveEndLocation = shadowPointOffset;
              }

              // Construct on the tapeCurvePath
              if (lineOrCurve == startLineOrCurve && perplocation == 0) {
                tapeCurvePath += 'M${shadowPointOffset.dx},${shadowPointOffset.dy} ';
              } else {
                tapeCurvePath += 'L${shadowPointOffset.dx},${shadowPointOffset.dy} ';
              }
            }
          } else {
            LineCommand line = lineOrCurve as LineCommand;

            Offset lineStart = line.getStartCoordinate(drawing)!;
            lineStart = lineStart.scale(1, -1); lineStart += middle;
            Offset lineEnd = line.getEndCoordinate(drawing)!;
            lineEnd = lineEnd.scale(1, -1); lineEnd += middle;

            distanceInMM += MathUtitilies.distance(lineStart, lineEnd);

            double perpendicularAngle = MathUtitilies.angleOfLine(lineStart, lineEnd) + (pi / 2.0);

            Offset startShadowPointOffset = MathUtitilies.relativepointatangle(lineStart, -helperLineHeight, perpendicularAngle);

            if (line == startLineOrCurve) {
              tapeCurveStartLocation = startShadowPointOffset;
              tapeCurvePath += 'M${startShadowPointOffset.dx},${startShadowPointOffset.dy} ';
              svg += '<line x1="${lineStart.dx}" y1="${lineStart.dy}" x2="${startShadowPointOffset.dx}" y2="${startShadowPointOffset.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            } else {
              tapeCurvePath += 'L${startShadowPointOffset.dx},${startShadowPointOffset.dy} ';
            }

            Offset endShadowPointOffset = MathUtitilies.relativepointatangle(lineEnd, -helperLineHeight, perpendicularAngle);
            tapeCurvePath += 'L${endShadowPointOffset.dx},${endShadowPointOffset.dy} ';

            if (line == endLineOrCurve) {
              tapeCurveEndLocation = endShadowPointOffset;
              svg += '<line x1="${lineEnd.dx}" y1="${lineEnd.dy}" x2="${endShadowPointOffset.dx}" y2="${endShadowPointOffset.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}" stroke-width="0.7" stroke-dasharray="${DashStyle.shortStripes.svgString}"/>';
            }
          }

          // Find the next line or curve or stop the forever loop
          if (lineOrCurve == endLineOrCurve) {
            break;
          }
          lineOrCurve = linesAndCurves.firstWhere((c) => _getLineOrCurveStartPointId(c) == _getLineOrCurveEndPointId(lineOrCurve));
        } // end of while(true)

        // Draw the tape path
        svg += '<path d="$tapeCurvePath" fill="none" ';

        if (styling == null) {
          svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/>';
        } else {
          svg += 'stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
          if (styling.dashStyle == DashStyle.full) {
            svg += '/>';
          } else {
            svg += 'stroke-dasharray="${styling.dashStyle.svgString}"/>';
          }
        }

        Path curvePath = parseSvgPathData(tapeCurvePath);

        if (styling != null) {
          svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: tapeCurveStartLocation, end: tapeCurveEndLocation, curvePath: curvePath);
          svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: tapeCurveStartLocation, end: tapeCurveEndLocation, curvePath: curvePath);
        }

        // Draw value in correct units
        String distanceInUnit = _distanceInUnit(distanceInMM, unit);

        // We put the label in the middle of the tape curve
        Offset midline = MathUtitilies.pointOnPathAtFraction(curvePath, 0.5);

        svg += '<text font-family="Roboto" font-size="12" x="${midline.dx}" y="${midline.dy}">$distanceInUnit</text>';

      } // end of case linesAndCurves
    }

    svg += '</g>';

    return svg;
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const [], bool drawDirectionArrow = false, bool forPreview = false}) {
    if (!valid) return;

    Offset middle = Offset(size.width / 2, size.height / 2);
    Paint paint = Paint()..style = PaintingStyle.stroke;
    StylingCommand? styling = drawing.styleFor(id)?? stylings.where((s) => s.commandIds.any((c) => c == id)).firstOrNull;
    if (styling == null) {
      paint.color = (!forPreview && selected) ? selectedColor : (!forPreview && asPart && drawing is PartDrawing) ? partColor : Colors.grey.shade700;
      paint.strokeWidth = selected ? 2 : 1;
    } else {
      paint.color = (!forPreview && selected) ? selectedColor : styling.color;
      paint.strokeWidth = styling.thickness;
    }

    Paint helperLinePaint = Paint()..color = Colors.grey.shade700..style = PaintingStyle.stroke..strokeWidth = 0.7;

    switch (tapeType) {
      case TapeType.betweenPoints: {

        Offset? start = drawing.pointById(fromPointId)!.getCoordinate(drawing);
        if (start == null) {
          return;
        }
        start = start.scale(1, -1);

        Offset? end = drawing.pointById(toPointId)!.getCoordinate(drawing);
        if (end == null) {
          return;
        }
        end = end.scale(1, -1);
        start += middle;
        end += middle;

        switch (directionType) {
          case TapeDirectionType.free: {
            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(
                canvas: canvas,
                styleCommand: styling,
                start: start,
                end: end,
                paint: paint
              );
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, end, 0.5);

            TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
            ..addText(distanceInUnit);

            final Paragraph paragraph = paragraphBuilder.build()
            ..layout(ParagraphConstraints(width: size.width));

            canvas.drawParagraph(paragraph,  midline.translate(2, 0));
          } break;
          case TapeDirectionType.horizontal: {
            Offset tapeEndPoint = Offset(end.dx, start.dy);

            Paint helperPaint = Paint()..color = Colors.grey.shade700..style = PaintingStyle.stroke..strokeWidth = 0.7;

            // Helper line from endpoint
            if ((tapeEndPoint.dy - end.dy).abs() > 5) {
              Path helperLine = Path()..moveTo(end.dx, end.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, helperLine, helperPaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(
                canvas: canvas,
                styleCommand: styling,
                start: start,
                end: tapeEndPoint,
                paint: paint
              );
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
            ..addText(distanceInUnit);

            final Paragraph paragraph = paragraphBuilder.build()
            ..layout(ParagraphConstraints(width: size.width));

            canvas.drawParagraph(paragraph,  midline.translate(2, 0));
          } break;
          case TapeDirectionType.vertical: {
            Offset tapeEndPoint = Offset(start.dx, end.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dx - end.dx).abs() > 5) {
              Path helperLine = Path()..moveTo(end.dx, end.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, helperLine, helperLinePaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(
                canvas: canvas,
                styleCommand: styling,
                start: start,
                end: tapeEndPoint,
                paint: paint
              );
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
            ..addText(distanceInUnit);

            final Paragraph paragraph = paragraphBuilder.build()
            ..layout(ParagraphConstraints(width: size.width));

            canvas.drawParagraph(paragraph,  midline.translate(2, 0));
          } break;
        }

      } break; // end of TapeType.betweenPoints

      case TapeType.line: {

        LineCommand? line = drawing.lineById(lineId);
        if (line == null) return;

        Offset? start = line.getStartCoordinate(drawing);
        if (start == null) return;
        start = start.scale(1, -1);

        Offset? end = line.getEndCoordinate(drawing);
        if (end == null) return;
        end = end.scale(1, -1);

        start += middle;
        end += middle;

        switch (directionType) {
          case TapeDirectionType.free: {
            // Calculate perpendicular points to start and end
            double perpendicularAngle = MathUtitilies.angleOfLine(start, end) + (pi / 2.0);

            double helperLineHeight = 20;
            Offset tapeStartPoint = MathUtitilies.relativepointatangle(start, -helperLineHeight, perpendicularAngle);
            Offset tapeEndPoint= MathUtitilies.relativepointatangle(end, -helperLineHeight, perpendicularAngle);

            Path startHelperPath = Path()..moveTo(start.dx, start.dy)..lineTo(tapeStartPoint.dx, tapeStartPoint.dy);
            DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, startHelperPath, helperLinePaint);
            Path endHelperPath = Path()..moveTo(end.dx, end.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);
            DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, endHelperPath, helperLinePaint);

            Path path = Path()..moveTo(tapeStartPoint.dx, tapeStartPoint.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(
                canvas: canvas,
                styleCommand: styling,
                start: tapeStartPoint,
                end: tapeEndPoint,
                paint: paint
              );
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(tapeStartPoint, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
            ..addText(distanceInUnit);

            final Paragraph paragraph = paragraphBuilder.build()
            ..layout(ParagraphConstraints(width: size.width));

            canvas.drawParagraph(paragraph,  midline.translate(2, 0));
          } break;
          case TapeDirectionType.horizontal: {
            Offset tapeEndPoint = Offset(end.dx, start.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dy - end.dy).abs() > 5) {
              Path helperLine = Path()..moveTo(end.dx, end.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, helperLine, helperLinePaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(
                canvas: canvas,
                styleCommand: styling,
                start: start,
                end: tapeEndPoint,
                paint: paint
              );
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
            ..addText(distanceInUnit);

            final Paragraph paragraph = paragraphBuilder.build()
            ..layout(ParagraphConstraints(width: size.width));

            canvas.drawParagraph(paragraph,  midline.translate(2, 0));
          } break;
          case TapeDirectionType.vertical: {
            Offset tapeEndPoint = Offset(start.dx, end.dy);

            // Helper line from endpoint
            if ((tapeEndPoint.dx - end.dx).abs() > 5) {
              Path helperLine = Path()..moveTo(end.dx, end.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, helperLine, helperLinePaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(
                canvas: canvas,
                styleCommand: styling,
                start: start,
                end: tapeEndPoint,
                paint: paint
              );
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.pointOnLineAtFraction(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
            ..addText(distanceInUnit);

            final Paragraph paragraph = paragraphBuilder.build()
            ..layout(ParagraphConstraints(width: size.width));

            canvas.drawParagraph(paragraph,  midline.translate(2, 0));
          } break;
        }
      } break; // end of TapeType.line

      case TapeType.linesAndcurves: {
        double helperLineHeight = 20;

        List<DrawingCommand> linesAndCurves = [];
        for (String lineOrCurveId in lineAndCurveIds) {
          DrawingCommand? lineOrcurve = drawing.commandById(lineOrCurveId);
          if (lineOrcurve == null) return;
          linesAndCurves.add(lineOrcurve);
        }

        DrawingCommand startLineOrCurve;
        DrawingCommand endLineOrCurve;

        if (isCircular) {
          // Use the first one as start
          startLineOrCurve = linesAndCurves.first;

          // Find the command that ends on the first's head
          endLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) =>
            _getLineOrCurveEndPointId(lineOrCurve) == _getLineOrCurveStartPointId(startLineOrCurve)
          );
        } else {
          // Find the command that doesn't have a command at the head
          startLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) =>
            !linesAndCurves.any((other) => lineOrCurve != other &&
            _getLineOrCurveStartCoordinate(lineOrCurve, drawing) == _getLineOrCurveEndCoordinate(other, drawing))
          );

          // Find the command that doesn't have a command at the tail
          endLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) =>
            !linesAndCurves.any((other) => lineOrCurve != other &&
            _getLineOrCurveEndCoordinate(lineOrCurve, drawing) == _getLineOrCurveStartCoordinate(other, drawing))
          );
        }

        Offset? start = _getLineOrCurveStartCoordinate(startLineOrCurve, drawing);
        start = start.scale(1, -1);

        Offset? end = _getLineOrCurveEndCoordinate(endLineOrCurve, drawing);
        end = end.scale(1, -1);

        start += middle;
        end += middle;

        double fractionIncrease = 0.02;

        // We build the tape path to draw it at the end
        Path tapeCurvePath = Path();
        // We'll remember the start and end of the tape to draw arrows on them at the end
        Offset tapeCurveStartLocation = Offset.zero;
        Offset tapeCurveEndLocation = Offset.zero;
        // We add the length of each segment
        double distanceInMM = 0;

        DrawingCommand lineOrCurve = startLineOrCurve;
        while (true) {
          if (lineOrCurve is CurveCommand) {
            Path curvePath = lineOrCurve.getPath(drawing, middle)!;
            distanceInMM += MathUtitilies.lengthOfPath(curvePath);

            // Calculate perpendicular points, every fractionIncrease step of the curve
            for (double perplocation = 0; perplocation <= 1 + fractionIncrease; perplocation += fractionIncrease) {
              bool atEndOfCurve = perplocation >= 1;

              // Find that next point on the curve
              Offset perpOffset = MathUtitilies.pointOnPathAtFraction(curvePath, perplocation);
              
              // Find a point that is a bit further or back on the curve to get the angle between those two points
              Offset perpoffsetincreased = MathUtitilies.pointOnPathAtFraction(curvePath, atEndOfCurve ? perplocation - 0.05 : perplocation + 0.05);
              
              // Get the perpendicular angle of that piece of the curve
              double perpendicularAngle = atEndOfCurve ?
                MathUtitilies.angleOfLine(perpoffsetincreased, perpOffset) + (pi / 2.0)
              : MathUtitilies.angleOfLine(perpOffset, perpoffsetincreased) + (pi / 2.0);

              // Get a point at that angle, somewhat removed from the curve
              Offset shadowPointOffset = MathUtitilies.relativepointatangle(perpOffset, -helperLineHeight, perpendicularAngle);

              // If we are at the first point of the start curve, we draw a helper line
              if (lineOrCurve == startLineOrCurve && perplocation == 0) {
                canvas.drawLine(start, shadowPointOffset, helperLinePaint);
                tapeCurveStartLocation = shadowPointOffset;
              }
              // and same on the last point of the last curve
              if (lineOrCurve == endLineOrCurve && atEndOfCurve) {
                canvas.drawLine(end, shadowPointOffset, helperLinePaint);
                tapeCurveEndLocation = shadowPointOffset;
              }

              // Construct on the tapeCurvePath
              if (lineOrCurve == startLineOrCurve && perplocation == 0) {
                tapeCurvePath.moveTo(shadowPointOffset.dx, shadowPointOffset.dy);
              } else {
                tapeCurvePath.lineTo(shadowPointOffset.dx, shadowPointOffset.dy);
              }
            }
          } else {
            LineCommand line = lineOrCurve as LineCommand;

            Offset lineStart = line.getStartCoordinate(drawing)!;
            lineStart = lineStart.scale(1, -1); lineStart += middle;
            Offset lineEnd = line.getEndCoordinate(drawing)!;
            lineEnd = lineEnd.scale(1, -1); lineEnd += middle;

            distanceInMM += MathUtitilies.distance(lineStart, lineEnd);

            double perpendicularAngle = MathUtitilies.angleOfLine(lineStart, lineEnd) + (pi / 2.0);

            Offset startShadowPointOffset = MathUtitilies.relativepointatangle(lineStart, -helperLineHeight, perpendicularAngle);

            if (line == startLineOrCurve) {
              tapeCurveStartLocation = startShadowPointOffset;
              tapeCurvePath.moveTo(startShadowPointOffset.dx, startShadowPointOffset.dy);
              canvas.drawLine(lineStart, startShadowPointOffset, helperLinePaint);
            } else {
              tapeCurvePath.lineTo(startShadowPointOffset.dx, startShadowPointOffset.dy);
            }

            Offset endShadowPointOffset = MathUtitilies.relativepointatangle(lineEnd, -helperLineHeight, perpendicularAngle);
            tapeCurvePath.lineTo(endShadowPointOffset.dx, endShadowPointOffset.dy);

            if (line == endLineOrCurve) {
              tapeCurveEndLocation = endShadowPointOffset;
              canvas.drawLine(lineEnd, endShadowPointOffset, helperLinePaint);
            }
          }

          // Find the next line or curve or stop the forever loop
          if (lineOrCurve == endLineOrCurve) {
            break;
          }
          lineOrCurve = linesAndCurves.firstWhere((c) => _getLineOrCurveStartPointId(c) == _getLineOrCurveEndPointId(lineOrCurve));
        } // end of while(true)

        if (styling == null || styling.dashStyle == DashStyle.full) {
          canvas.drawPath(tapeCurvePath, paint);
        } else {
          DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, tapeCurvePath, paint);
        }

        // Draw arrows
        if (styling != null) {
          ArrowPainter.paint(
            canvas: canvas,
            styleCommand: styling,
            start: tapeCurveStartLocation,
            end: tapeCurveEndLocation,
            paint: paint,
            curvePath: tapeCurvePath,
          );
        }

        // Draw value in correct units
        String distanceInUnit = _distanceInUnit(distanceInMM, unit);

        // We put the label in the middle of the tape curve
        Offset midline = MathUtitilies.pointOnPathAtFraction(tapeCurvePath, 0.5);

        TextStyle style = TextStyle(color: (!forPreview && selected) ? selectedColor : Colors.black);
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
        ..addText(distanceInUnit);

        final Paragraph paragraph = paragraphBuilder.build()
        ..layout(ParagraphConstraints(width: size.width));

        canvas.drawParagraph(paragraph,  midline.translate(2, 0));

      } // end of case linesAndCurves
    }
  }

  Offset _getLineOrCurveStartCoordinate(DrawingCommand lineOrCurve, AbstractDrawing drawing) {
    if (lineOrCurve is LineCommand) {
      return lineOrCurve.getStartCoordinate(drawing)!;
    } else {
      return (lineOrCurve as CurveCommand).getStartCoordinate(drawing)!;
    }
  }

  Offset _getLineOrCurveEndCoordinate(DrawingCommand lineOrCurve, AbstractDrawing drawing) {
    if (lineOrCurve is LineCommand) {
      return lineOrCurve.getEndCoordinate(drawing)!;
    } else {
      return (lineOrCurve as CurveCommand).getEndCoordinate(drawing)!;
    }
  }

  String _getLineOrCurveStartPointId(DrawingCommand lineOrCurve) {
    if (lineOrCurve is LineCommand) return lineOrCurve.fromPointId;
    return (lineOrCurve as CurveCommand).startPointId;
  }

  String _getLineOrCurveEndPointId(DrawingCommand lineOrCurve) {
    if (lineOrCurve is LineCommand) return lineOrCurve.toPointId;
    return (lineOrCurve as CurveCommand).endPointId;
  }

  String _distanceInUnit(double distanceInMM, TapeUnit toUnit) {
    switch (toUnit) {
      case TapeUnit.mm:
        return '${distanceInMM.toStringAsFixed(2)} ${toUnit.abbr}';
      case TapeUnit.cm:
        return '${(distanceInMM / 10).toStringAsFixed(2)} ${toUnit.abbr}';
      case TapeUnit.m:
        return '${(distanceInMM / 1000).toStringAsFixed(2)} ${toUnit.abbr}';
      case TapeUnit.inch:
        // TODO: use the code from sewML to get e.g. 1 1/4"
        return '${(distanceInMM / 24.4).toStringAsFixed(2)} ${toUnit.abbr}';
      case TapeUnit.feet:
        return '${(distanceInMM / 304.8).toStringAsFixed(2)} ${toUnit.abbr}';
      case TapeUnit.rows:
        return '${((distanceInMM / 100) * rowsGauge).toStringAsFixed(2)} ${toUnit.abbr}';
      case TapeUnit.sts:
        return '${((distanceInMM / 100) * stitchesGauge).toStringAsFixed(2)} ${toUnit.abbr}';
    }
  }

  @override
  DrawingCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];
    bool circular = false;

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    switch (tapeType) {
      case TapeType.betweenPoints: {
        PointCommand? fromPoint;
        if (fromPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a source point');
        } else if (fromPointId == originId) {
          fromPoint = origin;
        } else {
          fromPoint = drawing.pointById(fromPointId);
          if (fromPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Source point does not exist');
          } else if (fromPointId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == fromPointId.split('.')[2]);
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
        if (toPointId.isEmpty) {
          isvalid = false; 
          retryValidation = false;
          validationErrors.add('Requires a target point');
        } else if (toPointId == originId) {
          toPoint = origin;
        } else {
          toPoint = drawing.pointById(toPointId);
          if (toPoint == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Target point does not exist');
          } else if (toPointId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == toPointId.split('.')[2]);
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
      } break;

      case TapeType.line: {
        LineCommand? line;
        if (lineId.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires a line to measure');
        } else {
          line = drawing.lineById(lineId);
          if (line == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line does not exist');
          } else if (lineId.contains('.')) {
            // need to wait on validation of the included part command
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == lineId.split('.')[2]);
            if (!ipc.validated) {
              isvalid = false;
            }
          } else if (!line.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!line.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Line ${line.label} has errors');
          }
        }

      } break;
      
      case TapeType.linesAndcurves: {
        List<DrawingCommand> linesAndCurves = [];
        if (lineAndCurveIds.isEmpty) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Requires lines and curves to measure');
        } else {
          for (String lineOrCurveId in lineAndCurveIds) {
            if (lineOrCurveId.contains('.')) {
              // need to wait on validation of the included part command
              IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == lineOrCurveId.split('.')[2]);
              if (!ipc.validated) {
                isvalid = false;
              }
            } else {
              DrawingCommand? lineOrCurve = drawing.commandById(lineOrCurveId);
              if (lineOrCurve != null) linesAndCurves.add(lineOrCurve);

              if (lineOrCurve == null) {
                isvalid = false;
                retryValidation = false;
                validationErrors.add('Line or curve $lineOrCurveId does not exist');
              } else if (!lineOrCurve.validated) {
                // We are not valid, but we should retry
                isvalid = false;
              } else if (!lineOrCurve.valid) {
                isvalid = false;
                retryValidation = false;
                validationErrors.add('${lineOrCurve is LineCommand ? 'Line' : 'Curve'} ${lineOrCurve.label} has errors');
              }
            }
          }
        }

        // Check if the elements are consecutive
        if (isvalid) {
          if (linesAndCurves.length > 1) {
            bool foundStart = false;
            bool foundEnd = false;
            // Border case: 2 curves, but they are separate
            if (linesAndCurves.length == 2) {
              String firstStartPointId = _getLineOrCurveStartPointId(linesAndCurves.first);
              String firstEndPointId = _getLineOrCurveEndPointId(linesAndCurves.first);
              String lastStartPointId = _getLineOrCurveStartPointId(linesAndCurves.last);
              String lastEndPointId = _getLineOrCurveEndPointId(linesAndCurves.last);
              if (!((firstStartPointId == lastEndPointId) || (firstEndPointId == lastStartPointId))) {
                isvalid = false;
                retryValidation = false;
                validationErrors.add('The lines and curves to measure must be consecutive');
              } else if ((firstStartPointId == lastEndPointId) && (firstEndPointId == lastStartPointId)) {
                circular = true;
              }

            } else {
              for (DrawingCommand lineOrCurve in linesAndCurves) {
                // No previous line or curve?
                if (!linesAndCurves.any((c) => lineOrCurve != c && _getLineOrCurveEndPointId(c) == _getLineOrCurveStartPointId(lineOrCurve))) {
                  if (foundStart) {
                    // we already had a startcurve
                    isvalid = false;
                    retryValidation = false;
                    validationErrors.add('The lines and curves to measure must be consecutive');
                    break;
                  } else {
                    foundStart = true;
                  }
                }
                // No next line or curve?
                if (!linesAndCurves.any((c) => lineOrCurve != c && _getLineOrCurveStartPointId(c) == _getLineOrCurveEndPointId(lineOrCurve))) {
                  if (foundEnd) {
                    // We already had an endcurve
                    isvalid = false;
                    retryValidation = false;
                    validationErrors.add('The lines and curves to measure must be consecutive');
                    break;
                  } else {
                    foundEnd = true;
                  }
                }
              }
              if (!foundStart && !foundEnd) circular = true;
            }
          }
        }

      } break;
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
      isCircular: circular,
    );
  }

}
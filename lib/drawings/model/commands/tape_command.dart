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
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

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
    String? label,
    String? fromPointId,
    String? toPointId,
    String? lineId,
    Set<String>? lineAndCurveIds,
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
      id: id, 
      version: version + 1, 
      label: label?? this.label,
      fromPointId: fromPointId?? this.fromPointId,
      toPointId: toPointId?? this.toPointId,
      lineId: lineId?? this.lineId,
      lineAndCurveIds: lineAndCurveIds?? this.lineAndCurveIds,
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
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is TapeCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      fromPointId == other.fromPointId &&
      lineId == other.lineId &&
      setEquals(lineAndCurveIds, other.lineAndCurveIds) &&
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
  int get hashCode => super.hashCode ^ fromPointId.hashCode ^ toPointId.hashCode ^ lineId.hashCode ^ lineAndCurveIds.hashCode ^
    directionType.hashCode ^ tapeType.hashCode ^ unit.hashCode ^ rowsGauge.hashCode ^ stitchesGauge.hashCode;

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
  TapeCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  TapeCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription']
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};

    if (fromPointId.isNotEmpty) {
      if (fromPointId.contains('.')) {
        deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == fromPointId.split('.').first).id);
      }
      
      deps.add(fromPointId);
    }

    if (toPointId.isNotEmpty) {
      if (toPointId.contains('.')) {
        deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == toPointId.split('.').first).id);
      }
      
      deps.add(toPointId);
    }

    if (lineId.isNotEmpty) {
      if (lineId.contains('.')) {
        deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == lineId.split('.').first).id);
      }
      
      deps.add(toPointId);
    }

    for (String lineOrCurveId in lineAndCurveIds) {
      if (lineOrCurveId.contains('.')) {
        deps.add(drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == lineOrCurveId.split('.').first).id);
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
      fromPointId: fromPointId == commandId ? '' : fromPointId,
      toPointId: toPointId == commandId ? '' : toPointId,
      lineId: lineId == commandId ? '' : lineId,
      lineAndCurveIds: lineAndCurveIds.where((c) => c != commandId).toSet(),
    );
  }

  @override
  TapeCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[],);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const []}) {
    if (!valid) {
      return;
    }

    Offset middle = Offset(size.width / 2, size.height / 2);
    Paint paint = Paint()..style = PaintingStyle.stroke;
    StylingCommand? styling = drawing.styleFor(id);
    if (styling == null) {
      paint.color = selected ? selectedColor : (asPart && drawing is PartDrawing) ? partColor : Colors.grey.shade700;
      paint.strokeWidth = asPart || selected ? 2 : 1;
    } else {
      paint.color = selected ? selectedColor : styling.color;
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
              ArrowPainter.paint(canvas, styling, start, end, paint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.fractionOfLine(start, end, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.stripes.dashPattern).paint(canvas, helperLine, helperPaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(canvas, styling, start, tapeEndPoint, paint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.fractionOfLine(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.stripes.dashPattern).paint(canvas, helperLine, helperLinePaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(canvas, styling, start, tapeEndPoint, paint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.fractionOfLine(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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
            final double angleOfLine = MathUtitilies.angleOfLine(start, end);
            double perpendicularAngle = angleOfLine + (pi / 2.0);
            // Take quadrant into account
            if (start.dx > end.dx) {
              perpendicularAngle = angleOfLine + pi;
            }

            double helperLineHeight = 20;
            Offset tapeStartPoint = MathUtitilies.relativepointatangle(start, -helperLineHeight, perpendicularAngle);
            Offset tapeEndPoint= MathUtitilies.relativepointatangle(end, -helperLineHeight, perpendicularAngle);

            Path startHelperPath = Path()..moveTo(start.dx, start.dy)..lineTo(tapeStartPoint.dx, tapeStartPoint.dy);
            DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.stripes.dashPattern).paint(canvas, startHelperPath, helperLinePaint);
            Path endHelperPath = Path()..moveTo(end.dx, end.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);
            DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.stripes.dashPattern).paint(canvas, endHelperPath, helperLinePaint);

            Path path = Path()..moveTo(tapeStartPoint.dx, tapeStartPoint.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(canvas, styling, tapeStartPoint, tapeEndPoint, paint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.fractionOfLine(tapeStartPoint, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.stripes.dashPattern).paint(canvas, helperLine, helperLinePaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(canvas, styling, start, tapeEndPoint, paint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.fractionOfLine(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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
              DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.stripes.dashPattern).paint(canvas, helperLine, helperLinePaint);
            }

            Path path = Path()..moveTo(start.dx, start.dy)..lineTo(tapeEndPoint.dx, tapeEndPoint.dy);

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(path, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, path, paint);
            }

            if (styling != null) {
              ArrowPainter.paint(canvas, styling, start, tapeEndPoint, paint);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, tapeEndPoint);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            Offset midline = MathUtitilies.fractionOfLine(start, tapeEndPoint, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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

        // Get the start and end curve
        DrawingCommand startLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) {
          return !linesAndCurves.any((other) {
            if (lineOrCurve == other) return false;
            Offset startOffset;
            if (lineOrCurve is LineCommand) {
              startOffset = lineOrCurve.getStartCoordinate(drawing)!;
            } else {
              startOffset = (lineOrCurve as CurveCommand).getStartCoordinate(drawing)!;
            }
            Offset endOffset;
            if (other is LineCommand) {
              endOffset = other.getEndCoordinate(drawing)!;
            } else {
              endOffset = (other as CurveCommand).getEndCoordinate(drawing)!;
            }
            return startOffset == endOffset;
          });
        });
        DrawingCommand endLineOrCurve = linesAndCurves.firstWhere((lineOrCurve) {
          return !linesAndCurves.any((other) {
            if (lineOrCurve == other) return false;
            
            Offset endOffset;
            if (lineOrCurve is LineCommand) {
              endOffset = lineOrCurve.getEndCoordinate(drawing)!;
            } else {
              endOffset = (lineOrCurve as CurveCommand).getEndCoordinate(drawing)!;
            }

            Offset startOffset;
            if (other is LineCommand) {
              startOffset = other.getStartCoordinate(drawing)!;
            } else {
              startOffset = (other as CurveCommand).getStartCoordinate(drawing)!;
            }

            return endOffset == startOffset;
          });
        });

        Offset? start = (startLineOrCurve is LineCommand) ? startLineOrCurve.getStartCoordinate(drawing) : (startLineOrCurve as CurveCommand).getStartCoordinate(drawing);
        if (start == null) return;
        start = start.scale(1, -1);

        Offset? end = (endLineOrCurve is LineCommand) ? endLineOrCurve.getEndCoordinate(drawing) : (endLineOrCurve as CurveCommand).getEndCoordinate(drawing);
        if (end == null) return;
        end = end.scale(1, -1);

        start += middle;
        end += middle;

        switch (directionType) {
          case TapeDirectionType.free: {

            double fractionIncrease = 0.01;
  
            Path tapeCurvePath = Path();
            Offset tapeCurveStartLocation = Offset.zero;
            Offset tapeCurveEndLocation = Offset.zero;

            for (DrawingCommand lineOrCurve in linesAndCurves) {
              if (lineOrCurve is CurveCommand) {
                Path curvePath = lineOrCurve.getPath(drawing, middle)!;
    
                // Calculate perpendicular points, every fractionIncrease step of the curve
                for (double perplocation = 0; perplocation <= 1 + fractionIncrease; perplocation += fractionIncrease) {
                  bool atEndOfCurve = perplocation >= 1;

                  // Find that next point on the curve
                  Offset perpOffset = MathUtitilies.pointOnPath(curvePath, perplocation);
                  
                  // Find a point that is a bit further or back on the curve to get the angle between those two points
                  Offset perpoffsetincreased = MathUtitilies.pointOnPath(curvePath, atEndOfCurve ? perplocation - 0.05 : perplocation + 0.05);
                  
                  // Get the angle of that piece of the curve
                  final double angleOfCurveAtPerplocation = MathUtitilies.angleOfLine(perpOffset, perpoffsetincreased);

                  // Add 90 degrees
                  double perpendicularAngle = angleOfCurveAtPerplocation + (pi / 2.0);

                  // Take quadrant into account
                  // TODO: the dx compare is not a good criterium, but not sure what would be
                  if (perpoffsetincreased.dx > perpOffset.dx) {
                    perpendicularAngle += pi;
                  } else {
                    perpendicularAngle -= pi;
                  }

                  // Get a point at that angle, somewhat removed from the curve
                  Offset shadowPointOffset = MathUtitilies.relativepointatangle(perpOffset, helperLineHeight, perpendicularAngle);

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

                final double angleOfLine = MathUtitilies.angleOfLine(lineStart, lineEnd);
                double perpendicularAngle = angleOfLine + (pi / 2.0);
                if (lineEnd.dx > lineStart.dx) perpendicularAngle += pi;

                Offset startShadowPointOffset = MathUtitilies.relativepointatangle(lineStart, helperLineHeight, perpendicularAngle);

                if (line == startLineOrCurve) {
                  tapeCurveStartLocation = startShadowPointOffset;
                  tapeCurvePath.moveTo(startShadowPointOffset.dx, startShadowPointOffset.dy);
                  canvas.drawLine(lineStart, startShadowPointOffset, helperLinePaint);
                } else {
                  tapeCurvePath.lineTo(startShadowPointOffset.dx, startShadowPointOffset.dy);
                }

                Offset endShadowPointOffset = MathUtitilies.relativepointatangle(lineEnd, helperLineHeight, perpendicularAngle);
                tapeCurvePath.lineTo(endShadowPointOffset.dx, endShadowPointOffset.dy);

                if (line == endLineOrCurve) {
                  tapeCurveEndLocation = endShadowPointOffset;
                  canvas.drawLine(lineEnd, endShadowPointOffset, helperLinePaint);
                }
              }
            }

            if (styling == null || styling.dashStyle == DashStyle.full) {
              canvas.drawPath(tapeCurvePath, paint);
            } else {
              DashedPainter.pattern(enableCaching: false, dashPattern: styling.dashStyle.dashPattern).paint(canvas, tapeCurvePath, paint);
            }

            // Draw arrows
            if (styling != null) {
              ArrowPainter.paint(canvas, styling, tapeCurveStartLocation, tapeCurveEndLocation, paint, curvePath: tapeCurvePath);
            }

            // Draw value in correct units
            double distanceInMM = MathUtitilies.distance(start, end);
            String distanceInUnit = _distanceInUnit(distanceInMM, unit);

            // We put the label in the middle of the tape curve
            Offset midline = MathUtitilies.pointOnPath(tapeCurvePath, 0.5);

            TextStyle style = TextStyle(color: selected ? selectedColor : Colors.black);
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

          } break;
          case TapeDirectionType.vertical: {

          } break;
//======================================
        } break; // end of TapeType.curve

      }
    }
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
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == toPointId.split('.').first);
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
            IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == lineId.split('.').first);
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
            DrawingCommand? lineOrCurve = drawing.commandById(lineOrCurveId);
            if (lineOrCurve != null) linesAndCurves.add(lineOrCurve);

            if (lineOrCurve == null) {
              isvalid = false;
              retryValidation = false;
              validationErrors.add('Line or curve $lineOrCurveId does not exist');
            } else if (lineOrCurveId.contains('.')) {
              // need to wait on validation of the included part command
              IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == lineOrCurveId.split('.').first);
              if (!ipc.validated) {
                isvalid = false;
              }
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

        // Check if the elements are consecutive
        if (isvalid) {
          if (linesAndCurves.length > 1) {
            bool foundStart = false;
            bool foundEnd = false;
            // Border case: 2 curves, but they are separate
            if (linesAndCurves.length == 2) {
              DrawingCommand first = linesAndCurves.first;
              DrawingCommand last = linesAndCurves.last;
              String firstStartPointId = (first is LineCommand) ? first.fromPointId : (first as CurveCommand).startPointId;
              String firstEndPointId = (first is LineCommand) ? first.toPointId : (first as CurveCommand).endPointId;
              String lastStartPointId = (last is LineCommand) ? last.fromPointId : (last as CurveCommand).startPointId;
              String lastEndPointId = (last is LineCommand) ? last.toPointId : (last as CurveCommand).endPointId;
              if (!((firstStartPointId == lastEndPointId) || (firstEndPointId == lastStartPointId))) {
                isvalid = false;
                retryValidation = false;
                validationErrors.add('The lines and curves to measure must be consecutive');
              }
            } else {
              for (DrawingCommand lineOrCurve in linesAndCurves) {
                // No previous curve?
                if (!linesAndCurves.any((c) {
                  if (c == lineOrCurve) return false;
                  String cEndPointId = (c is LineCommand) ? c.toPointId : (c as CurveCommand).endPointId;
                  String lineOrCurveStartPointId = (lineOrCurve is LineCommand) ? lineOrCurve.fromPointId : (lineOrCurve as CurveCommand).startPointId;
                  return cEndPointId == lineOrCurveStartPointId;
                })) {
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
                // No next curve?
                if (!linesAndCurves.any((c) {
                  if (c == lineOrCurve) return false;
                  String cstartPointId = (c is LineCommand) ? c.fromPointId : (c as CurveCommand).startPointId;
                  String lineOrCurveEndPointId = (lineOrCurve is LineCommand) ? lineOrCurve.toPointId : (lineOrCurve as CurveCommand).endPointId;
                  return cstartPointId == lineOrCurveEndPointId;
                })) {
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
            }
          }
        }

      } break;
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }

}
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/arrow_painter.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';

import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:knitty_griddy/utils/infinite_line.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

@immutable
class LineCommand extends DrawingCommand {
  final String fromPointId;
  final String toPointId;

  // Validated cache  
  final Offset? storedStartCoordinate;
  final Offset? storedEndCoordinate;

  const LineCommand({
    required super.id,
    required super.version,
    required super.label,
    this.fromPointId = '',
    this.toPointId = '',
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
    this.storedStartCoordinate,
    this.storedEndCoordinate,
  });

  LineCommand copyWith({
    String? id,
    String? label,
    String? fromPointId,
    String? toPointId,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    Offset? storedStartCoordinate,
    Offset? storedEndCoordinate,
  }) {
    return LineCommand(
      id: id?? this.id,
      version: version + 1,
      label: label?? this.label,
      fromPointId: fromPointId?? this.fromPointId,
      toPointId: toPointId?? this.toPointId,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
      storedStartCoordinate: storedStartCoordinate?? this.storedStartCoordinate,
      storedEndCoordinate: storedEndCoordinate?? this.storedEndCoordinate,
    );
  }

  @override
  double get editHeight => 170;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    if (valid) {
      Offset? start = getStartCoordinate(drawing);
      Offset? end = getEndCoordinate(drawing);
      if (start != null && end != null) {
        return Rect.fromPoints(start, end);
      }
    }

    return Rect.zero;
  }

  @override
  LineCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  LineCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};

    if (fromPointId.isNotEmpty) {
      if (fromPointId.contains('.')) {
        deps.add(drawing.includedParts.firstWhere((c) => c.id == fromPointId.split('.')[2]).id);
      }
      
      deps.add(fromPointId);
    }

    if (toPointId.isNotEmpty) {
      if (toPointId.contains('.')) {
        deps.add(drawing.includedParts.firstWhere((c) => c.id == toPointId.split('.')[2]).id);
      }
      
      deps.add(toPointId);
    }

    return deps;
  }

  @override
  LineCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return this;
  }

  @override
  LineCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(
      fromPointId: fromPointId.replaceAll(oldId, newId),
      toPointId: toPointId.replaceAll(oldId, newId),
    );
  }


  @override
  LineCommand deleteReference({required String commandId}) {
    return copyWith(
      fromPointId: (fromPointId == commandId || fromPointId.startsWith('$commandId.')) ? '' : fromPointId,
      toPointId: (toPointId == commandId || toPointId.startsWith('$commandId.')) ? '' : toPointId,
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.lineCommand.name,
      'id': id,
      'label': label,
      'from': fromPointId,
      'to': toPointId,
    };
  }

  @override
  String get contentHashCode => jsonEncode({
      'type': DrawingCommandTypes.lineCommand.name,
      'label': label,
      'from': fromPointId,
      'to': toPointId,
    });

  static LineCommand fromJson(Map<String, dynamic> json) {
    return LineCommand(
      id: json['id'] as String,
      version: 0,
      label: json['label'] as String, 
      fromPointId: json['from'] as String, 
      toPointId: json['to'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LineCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    fromPointId == other.fromPointId &&
    toPointId == other.toPointId &&
    validated == other.validated &&
    valid == other.valid &&
    listEquals(errors, other.errors) &&
    storedStartCoordinate == other.storedStartCoordinate &&
    storedEndCoordinate == other.storedEndCoordinate;

  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
    other is LineCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    fromPointId == other.fromPointId &&
    toPointId == other.toPointId;
    
  @override
  int get hashCode => super.hashCode ^ fromPointId.hashCode ^ toPointId.hashCode ^
    storedStartCoordinate.hashCode ^ storedEndCoordinate.hashCode;

  double? lengthInMM(AbstractDrawing drawing) {
    Offset? startOffset = getStartCoordinate(drawing);
    if (startOffset == null) return null;
    Offset? endOffset = getEndCoordinate(drawing);
    if (endOffset == null) return null;
    return MathUtitilies.distance(startOffset, endOffset);
  }

  Offset? middle(AbstractDrawing drawing) => pointOnLine(0.5, drawing);

  Offset? pointOnLine(double fraction, AbstractDrawing drawing) {
    Offset? startOffset = getStartCoordinate(drawing);
    if (startOffset == null) return null;
    Offset? endOffset = getEndCoordinate(drawing);
    if (endOffset == null) return null;

    return Offset(
      startOffset.dx + ((endOffset.dx - startOffset.dx) * fraction), 
      startOffset.dy + (endOffset.dy - startOffset.dy) * fraction
    );
  }

  List<Offset> intersections(LineCommand otherSegment, AbstractDrawing drawing) {
    if (!valid || !otherSegment.valid) return const[];
    return _intersections(otherSegment, drawing).map((v) => Offset(v.x, v.y)).toList();
  } 

  List<vec.Vector2> _intersections(LineCommand otherSegment, AbstractDrawing drawing) {
    Offset? startPoint = getStartCoordinate(drawing);
    if (startPoint == null) return const[];
    Offset? endPoint = getEndCoordinate(drawing);
    if (endPoint == null) return const[];

    Offset? otherStartPoint = otherSegment.getStartCoordinate(drawing);
    if (otherStartPoint == null) return const[];
    Offset? otherEndPoint = otherSegment.getEndCoordinate(drawing);
    if (otherEndPoint == null) return const[];

    final from = vec.Vector2(startPoint.dx, startPoint.dy);
    final to = vec.Vector2(endPoint.dx, endPoint.dy);
    final otherFrom = vec.Vector2(otherStartPoint.dx, otherStartPoint.dy);
    final otherTo = vec.Vector2(otherEndPoint.dx, otherEndPoint.dy);

    final result = InfiniteLine.fromPoints(startPoint, endPoint).intersections(InfiniteLine.fromPoints(otherStartPoint, otherEndPoint));
    if (result.isNotEmpty) {
      // The lines are not parallel
      final intersection = result.first;
      if (containsPoint(from, to, intersection) &&
          containsPoint(otherFrom, otherTo, intersection)) {
        // The intersection point is on both line segments
        return result;
      }
    } else {
      // In here we know that the lines are parallel
      final overlaps = {
        if (containsPoint(otherFrom, otherTo, from)) from,
        if (containsPoint(otherFrom, otherTo, to)) to,
        if (containsPoint(from, to, otherFrom)) otherFrom,
        if (containsPoint(from, to, otherTo)) otherTo,
      };
      if (overlaps.isNotEmpty) {
        final sum = vec.Vector2.zero();
        overlaps.forEach(sum.add);
        return [sum..scale(1 / overlaps.length)];
      }
    }

    return [];
  }

  bool containsPoint(vec.Vector2 from, vec.Vector2 to, vec.Vector2 point, {double epsilon = 0.000001}) {
    final delta = to - from;
    final crossProduct =
        (point.y - from.y) * delta.x - (point.x - from.x) * delta.y;

    // compare versus epsilon for floating point values
    if (crossProduct.abs() > epsilon) {
      return false;
    }

    final dotProduct =
        (point.x - from.x) * delta.x + (point.y - from.y) * delta.y;
    if (dotProduct < 0) {
      return false;
    }

    final squaredLength = from.distanceToSquared(to);
    if (dotProduct > squaredLength) {
      return false;
    }

    return true;
  }

  Offset? getStartCoordinate(AbstractDrawing drawing) {
    return storedStartCoordinate;
  }

  Offset? getEndCoordinate(AbstractDrawing drawing) {
    return storedEndCoordinate;
  }

  @override
  String previewPath(AbstractDrawing drawing) {
    if (!valid) return '';

    Offset? start = getStartCoordinate(drawing);
    if (start == null) {
      return '';
    }
    start = start.scale(1, -1);

    Offset? end = getEndCoordinate(drawing);
    if (end == null) {
      return '';
    }
    end = end.scale(1, -1);

    return ' M ${start.dx},${start.dy} L${end.dx},${end.dy}';
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]}) {
    if (!valid) return '';    

    Offset? start = getStartCoordinate(drawing);
    if (start == null) {
      return '';
    }
    start = start.scale(1, -1);

    Offset? end = getEndCoordinate(drawing);
    if (end == null) {
      return '';
    }
    end = end.scale(1, -1);

    Offset middle = Offset(drawingSize.width / 2, drawingSize.height / 2);
    start += middle;
    end += middle;

    StylingCommand? styling = drawing.styleFor(id);
    if (styling == null) {
      // Look for id in format drawingid.id
      if (stylings.any((s) => s.commandIds.any((sid) => sid.startsWith('${drawing.id}.$id')))) {
        styling = stylings.firstWhere((s) => s.commandIds.any((sid) => sid.startsWith('${drawing.id}.$id')));
      }
    }

    if (styling == null) {
      return '<g id="$label"><line x1="${start.dx}" y1="${start.dy}" x2="${end.dx}" y2="${end.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade700)}"/></g>';
    } else {
      String svg = '<g id="$label"><line x1="${start.dx}" y1="${start.dy}" x2="${end.dx}" y2="${end.dy}" fill="none" stroke="${ColorUtilities.colorToSvhHex(styling.color)}" ${ColorUtilities.strokeOpacity(styling.color)} stroke-width="${styling.thickness}" ';
      if (styling.dashStyle == DashStyle.full) {
        svg += '/>';
      } else {
        svg += 'stroke-dasharray="${styling.dashStyle.svgString}" />';
      }

      svg += ArrowPainter.startArrowSvg(styleCommand: styling, start: start, end: end);
      svg += ArrowPainter.endArrowSvg(styleCommand: styling, start: start, end: end);

      svg += '</g>';
      return svg;
    }
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], bool drawDirectionArrow = false, bool forPreview = false}) {
    if (!valid) return;

    Offset? start = getStartCoordinate(drawing);
    if (start == null) {
      return;
    }
    start = start.scale(1, -1);

    Offset? end = getEndCoordinate(drawing);
    if (end == null) {
      return;
    }
    end = end.scale(1, -1);

    Offset middle = Offset(size.width / 2, size.height / 2);
    start += middle;
    end += middle;

    Paint paint = Paint()..style = PaintingStyle.stroke;
    StylingCommand? styling = drawing.styleFor(id);
    if (styling == null) {
      // Look for id in format drawingid.id
      if (stylings.any((s) => s.commandIds.any((sid) => sid.startsWith('${drawing.id}.$id')))) {
        styling = stylings.firstWhere((s) => s.commandIds.any((sid) => sid.startsWith('${drawing.id}.$id')));
      }
    }

    if (styling == null) {
      paint.color = (!forPreview && selected) ? selectedColor : (!forPreview && asPart && drawing is PartDrawing) ? partColor : const Color(0xFF616161);
      paint.strokeWidth = selected ? 2 : 1;
    } else {
      paint.color = (!forPreview && selected) ? selectedColor : styling.color;
      paint.strokeWidth = styling.thickness;
    }

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

    if (!forPreview && (selected || drawDirectionArrow)) {
      ArrowPainter.paintDirectionArrow(canvas: canvas, path: path, paint: paint, thickness: styling == null ? 1 : styling.thickness);
    }

    // draw line label
    if (!forPreview) {
      Offset? midline = pointOnLine(0.3, drawing);
      if (midline == null) return;
      midline = midline.scale(1, -1);
      midline += middle;

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

      canvas.drawParagraph(paragraph,  midline.translate(2, 0));
    }
  }

  @override
  LineCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[], 
      storedStartCoordinate: null, storedEndCoordinate: null);
  }
  
  @override
  LineCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

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

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
      storedStartCoordinate: isvalid ? fromPoint!.getCoordinate(drawing) : null,
      storedEndCoordinate: isvalid ? toPoint!.getCoordinate(drawing) : null,
    );
  }
}
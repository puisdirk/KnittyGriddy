
import 'dart:math';
import 'dart:ui';

import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

enum ArrowType {
  none,
  open,
  hollow,
  full,
  sharpHollow,
  sharpFull,
  circle,
  hollowCircle,
}

class ArrowPainter {

  static void paint({
    required Canvas canvas, 
    required StylingCommand styleCommand, 
    required Offset start, 
    required Offset end, 
    required Paint paint,
    Path? curvePath,
    double? arrowSizeOverride,
  }) {
    if (styleCommand.startArrow == ArrowType.none && styleCommand.endArrow == ArrowType.none) return;

    double arrowHeight = arrowSizeOverride?? styleCommand.arrowSize.size + styleCommand.thickness;

    if (styleCommand.startArrow == ArrowType.circle) {
      Paint filledPaint = Paint.from(paint)..style = PaintingStyle.fill;
      canvas.drawCircle(
        curvePath == null ? start : MathUtitilies.pointOnPathAtFraction(curvePath, 0),
        arrowHeight / 2, filledPaint);
    } else if (styleCommand.startArrow == ArrowType.hollowCircle) {
      canvas.drawCircle(
        curvePath == null ? start : MathUtitilies.pointOnPathAtFraction(curvePath, 0),
        arrowHeight / 2, paint);
    } else if (styleCommand.startArrow != ArrowType.none) {
      Offset arrowPoint = curvePath == null ? start : 
        MathUtitilies.pointOnPathAtFraction(curvePath, 0);
      Offset arrowBase = curvePath == null ? 
        MathUtitilies.pointOnLineAtDistance(start, end, arrowHeight) : 
        MathUtitilies.pointOnPathAtDistance(curvePath, arrowHeight);
      Offset sharpArrowPoint = curvePath == null ?
        MathUtitilies.pointOnLineAtDistance(start, end, arrowHeight / 2.0) :
        MathUtitilies.pointOnPathAtDistance(curvePath, arrowHeight / 2.0);

      double arrowAngle = MathUtitilies.angleOfLine(arrowBase, arrowPoint);
      Offset arrowHeadEnd1 = MathUtitilies.relativepointatangle(arrowBase, arrowHeight / 2, arrowAngle + (pi / 2.0));
      Offset arrowHeadEnd2 = MathUtitilies.relativepointatangle(arrowBase, arrowHeight / 2, arrowAngle - (pi / 2.0));

      Path startArrow = Path()
        ..moveTo(arrowHeadEnd1.dx, arrowHeadEnd1.dy)
        ..lineTo(arrowPoint.dx, arrowPoint.dy)
        ..lineTo(arrowHeadEnd2.dx, arrowHeadEnd2.dy);
      if (styleCommand.startArrow == ArrowType.sharpFull || styleCommand.startArrow == ArrowType.sharpHollow) {
        startArrow.lineTo(sharpArrowPoint.dx, sharpArrowPoint.dy);
      }
      
      if (styleCommand.startArrow != ArrowType.open) {
        startArrow.lineTo(arrowHeadEnd1.dx, arrowHeadEnd1.dy);
        startArrow.close();
      }

      Paint arrowPaint = Paint.from(paint);
      if (styleCommand.startArrow == ArrowType.full || styleCommand.startArrow == ArrowType.sharpFull) {
        arrowPaint.style = PaintingStyle.fill;
      }

      canvas.drawPath(startArrow, arrowPaint);
    }

    if (styleCommand.endArrow == ArrowType.circle) {
      Paint filledPaint = Paint.from(paint)..style = PaintingStyle.fill;
      canvas.drawCircle(
        curvePath == null ? end : MathUtitilies.pointOnPathAtFraction(curvePath, 1),
        arrowHeight / 2, filledPaint);
    } else if (styleCommand.endArrow == ArrowType.hollowCircle) {
      canvas.drawCircle(
        curvePath == null ? end : MathUtitilies.pointOnPathAtFraction(curvePath, 1),
        arrowHeight / 2, paint);
    } else if (styleCommand.endArrow != ArrowType.none) {
      Offset arrowPoint = curvePath == null ? end : 
        MathUtitilies.pointOnPathAtFraction(curvePath, 1);
      Offset arrowBase = curvePath == null ? 
        MathUtitilies.pointOnLineAtDistance(start, end, MathUtitilies.distance(start, end) - arrowHeight) : 
        MathUtitilies.pointOnPathAtDistance(curvePath, MathUtitilies.lengthOfPath(curvePath) - arrowHeight);
      Offset sharpArrowPoint = curvePath == null ?
        MathUtitilies.pointOnLineAtDistance(start, end, MathUtitilies.distance(start, end) -(arrowHeight / 2.0)) :
        MathUtitilies.pointOnPathAtDistance(curvePath, MathUtitilies.lengthOfPath(curvePath) -(arrowHeight / 2.0));
      
      double arrowAngle = MathUtitilies.angleOfLine(arrowBase, arrowPoint);
      Offset arrowHeadEnd1 = MathUtitilies.relativepointatangle(arrowBase, arrowHeight / 2, arrowAngle + (pi / 2.0));
      Offset arrowHeadEnd2 = MathUtitilies.relativepointatangle(arrowBase, arrowHeight / 2, arrowAngle - (pi / 2.0));

      Path endArrow = Path()
        ..moveTo(arrowHeadEnd1.dx, arrowHeadEnd1.dy)
        ..lineTo(arrowPoint.dx, arrowPoint.dy)
        ..lineTo(arrowHeadEnd2.dx, arrowHeadEnd2.dy);
      if (styleCommand.endArrow == ArrowType.sharpFull || styleCommand.endArrow == ArrowType.sharpHollow) {
        endArrow.lineTo(sharpArrowPoint.dx, sharpArrowPoint.dy);
      }
      
      if (styleCommand.endArrow != ArrowType.open) {
        endArrow.lineTo(arrowHeadEnd1.dx, arrowHeadEnd1.dy);
        endArrow.close();
      }

      Paint arrowPaint = Paint.from(paint);
      if (styleCommand.endArrow == ArrowType.full || styleCommand.endArrow == ArrowType.sharpFull) {
        arrowPaint.style = PaintingStyle.fill;
      }

      canvas.drawPath(endArrow, arrowPaint);
    }
  }

/*
  static void paint(Canvas canvas, StylingCommand styleCommand, 
    Offset start, Offset end, Paint paint, 
    {
      double heightFraction = 0.03,     // how high the arrows should be relative to the line length
      double arrowFraction = 0.05,      // how deep into the line the arrows should go relative to the line length
      double sharpArrowFraction = 0.02, // how deep into the line sharp arrows should go relative to the line length
      Path? curvePath,                  // needed to correctly rotate the arrows on curves
    }) {
    
    if (styleCommand.startArrow == ArrowType.none && styleCommand.endArrow == ArrowType.none) return;

    double lineLength = curvePath == null ? MathUtitilies.distance(start, end) : MathUtitilies.lengthOfPath(curvePath);

    // position of the arrow's top points
    Offset ampStartPoint = curvePath == null ? MathUtitilies.pointOnLineAtFraction(start, end, arrowFraction) : MathUtitilies.pointOnPathAtFraction(curvePath, arrowFraction);
    Offset ampEndPoint = curvePath == null ? MathUtitilies.pointOnLineAtFraction(start, end, 1 - arrowFraction) : MathUtitilies.pointOnPathAtFraction(curvePath, 1 - arrowFraction);

    double sharpPointStartFraction = sharpArrowFraction;
    double sharpPointEndFraction = 1 - sharpPointStartFraction;
    Offset sharpPointStartOffset = curvePath == null ? MathUtitilies.pointOnLineAtFraction(start, end, sharpPointStartFraction) : MathUtitilies.pointOnPathAtFraction(curvePath, sharpPointStartFraction);
    Offset sharpPointEndOffset = curvePath == null ? MathUtitilies.pointOnLineAtFraction(start, end, sharpPointEndFraction) : MathUtitilies.pointOnPathAtFraction(curvePath, sharpPointEndFraction);

    // height of the arrows as fraction of the line
    double arrowHeight = (lineLength * heightFraction) + styleCommand.thickness;

    // arrow top and bottom are perpendicular to the line with the given ampLength
    // we use the points where the arrows end to so that curves point in the right direction

    double perpendicularAngleAtStart = MathUtitilies.angleOfLine(start, ampStartPoint) + (pi / 2.0);
    double perpendicularAngleAtEnd = MathUtitilies.angleOfLine(ampEndPoint, end) + (pi / 2.0);

    // determine the arrow points
    Offset startArrowTop = MathUtitilies.relativepointatangle(ampStartPoint, arrowHeight, perpendicularAngleAtStart);
    Offset startArrowBottom = MathUtitilies.relativepointatangle(ampStartPoint, -arrowHeight, perpendicularAngleAtStart);
    Offset endArrowTop = MathUtitilies.relativepointatangle(ampEndPoint, arrowHeight, perpendicularAngleAtEnd);
    Offset endArrowBottom = MathUtitilies.relativepointatangle(ampEndPoint, -arrowHeight, perpendicularAngleAtEnd);

    if (styleCommand.startArrow != ArrowType.none) {
      Paint startArrowPaint = Paint.from(paint);
      startArrowPaint.strokeWidth = 1;
      if (styleCommand.startArrow == ArrowType.full || styleCommand.startArrow == ArrowType.sharpFull) {
        startArrowPaint.style = PaintingStyle.fill;
      }

      Path startArrowPath = Path()
        ..moveTo(startArrowTop.dx, startArrowTop.dy)
        ..lineTo(start.dx, start.dy)
        ..lineTo(startArrowBottom.dx, startArrowBottom.dy);
      
      if (styleCommand.startArrow == ArrowType.full || styleCommand.startArrow == ArrowType.hollow) {
        startArrowPath.lineTo(startArrowTop.dx, startArrowTop.dy);
      } else if (styleCommand.startArrow == ArrowType.sharpFull || styleCommand.startArrow == ArrowType.sharpHollow) {
        startArrowPath.lineTo(sharpPointStartOffset.dx, sharpPointStartOffset.dy);
        startArrowPath.lineTo(startArrowTop.dx, startArrowTop.dy);
      }

      if (styleCommand.startArrow == ArrowType.full || styleCommand.startArrow == ArrowType.sharpFull) {
        startArrowPath.close();
      }

      canvas.drawPath(startArrowPath, startArrowPaint);
    }

    if (styleCommand.endArrow != ArrowType.none) {
      Paint endArrowPaint = Paint.from(paint);
      endArrowPaint.strokeWidth = 1;
      if (styleCommand.endArrow == ArrowType.full || styleCommand.endArrow == ArrowType.sharpFull) {
        endArrowPaint.style = PaintingStyle.fill;
      }

      Path endArrowPath = Path()
        ..moveTo(endArrowTop.dx, endArrowTop.dy)
        ..lineTo(end.dx, end.dy)
        ..lineTo(endArrowBottom.dx, endArrowBottom.dy);
      
      if (styleCommand.endArrow == ArrowType.full || styleCommand.endArrow == ArrowType.hollow) {
        endArrowPath.lineTo(endArrowTop.dx, endArrowTop.dy);
      } else if (styleCommand.endArrow == ArrowType.sharpFull || styleCommand.endArrow == ArrowType.sharpHollow) {
        endArrowPath.lineTo(sharpPointEndOffset.dx, sharpPointEndOffset.dy);
        endArrowPath.lineTo(endArrowTop.dx, endArrowTop.dy);
      }

      if (styleCommand.endArrow == ArrowType.full || styleCommand.endArrow == ArrowType.sharpFull) {
        endArrowPath.close();
      }

      canvas.drawPath(endArrowPath, endArrowPaint);
    }
  }
*/

  static void paintDirectionArrow({
    required Canvas canvas, 
    required Path path, 
    required Paint paint, 
    required double thickness
    }) {
      Offset midPoint = MathUtitilies.pointOnPathAtFraction(path, .5);
      double arrowHeight = 10 + thickness;
      Offset arrowPoint = MathUtitilies.pointOnPathAtDistance(path, (MathUtitilies.lengthOfPath(path) / 2) + arrowHeight);
      double arrowAngle = MathUtitilies.angleOfLine(midPoint, arrowPoint);
      Offset arrowHeadEnd1 = MathUtitilies.relativepointatangle(midPoint, arrowHeight / 2, arrowAngle + (pi / 2.0));
      Offset arrowHeadEnd2 = MathUtitilies.relativepointatangle(midPoint, arrowHeight / 2, arrowAngle - (pi / 2.0));
      Path arrow = Path()
        ..moveTo(arrowHeadEnd1.dx, arrowHeadEnd1.dy)
        ..lineTo(arrowPoint.dx, arrowPoint.dy)
        ..lineTo(arrowHeadEnd2.dx, arrowHeadEnd2.dy)
        ..lineTo(arrowHeadEnd1.dx, arrowHeadEnd1.dy)
        ..close();
      canvas.drawPath(arrow, paint..style = PaintingStyle.fill);
  }

}
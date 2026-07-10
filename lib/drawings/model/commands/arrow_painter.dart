
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
}

class ArrowPainter {

  static void paint(Canvas canvas, StylingCommand styleCommand, 
    Offset start, Offset end, Paint paint, 
    {
      double heightFraction = 0.03,     // how high the arrows should be relative to the line length
      double arrowFraction = 0.05,      // how deep into the line the arrows should go relative to the line length
      double sharpArrowFraction = 0.02, // how deep into the line sharp arrows should go relative to the line length
      Path? curvePath,                  // needed to correctly rotate the arrows on curves
    }) {
    
    if (styleCommand.startArrow == ArrowType.none && styleCommand.endArrow == ArrowType.none) return;

    double lineLength = MathUtitilies.distance(start, end);

    // position of the arrow's top points
    Offset ampStartPoint = curvePath == null ? MathUtitilies.fractionOfLine(start, end, arrowFraction) : MathUtitilies.pointOnPath(curvePath, arrowFraction);
    Offset ampEndPoint = curvePath == null ? MathUtitilies.fractionOfLine(start, end, 1 - arrowFraction) : MathUtitilies.pointOnPath(curvePath, 1 - arrowFraction);

    double sharpPointStartFraction = sharpArrowFraction;
    double sharpPointEndFraction = 1 - sharpPointStartFraction;
    Offset sharpPointStartOffset = curvePath == null ? MathUtitilies.fractionOfLine(start, end, sharpPointStartFraction) : MathUtitilies.pointOnPath(curvePath, sharpPointStartFraction);
    Offset sharpPointEndOffset = curvePath == null ? MathUtitilies.fractionOfLine(start, end, sharpPointEndFraction) : MathUtitilies.pointOnPath(curvePath, sharpPointEndFraction);

    // height of the arrows as fraction of the line
    double arrowHeight = (lineLength * heightFraction) + styleCommand.thickness;

    // arrow top and bottom are perpendicular to the line with the given ampLength
    // we use the points where the arrows end to so that curves point in the right direction

    final double angleOfLineAtStart = MathUtitilies.angleOfLine(start, ampStartPoint);
    double perpendicularAngleAtStart = angleOfLineAtStart + (pi / 2.0);
    // Take quadrant into account
    if (end.dx > start.dx) {
      perpendicularAngleAtStart = angleOfLineAtStart - (pi / 2.0);
    }

    final double angleOfLineAtEnd = MathUtitilies.angleOfLine(ampEndPoint, end);
    double perpendicularAngleAtEnd = angleOfLineAtEnd + (pi / 2.0);
    // Take quadrant into account
    if (end.dx > start.dx) {
      perpendicularAngleAtEnd = angleOfLineAtEnd - (pi / 2.0);
    }

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

}
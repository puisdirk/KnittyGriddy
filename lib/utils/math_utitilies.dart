
import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';

class MathUtitilies {
  static double toDegrees(double radians) {
    return (180/pi) * radians;
  }

  static toRadians(double degrees) {
    return (pi / 180) * degrees;
  }

  static Size textSize(String text, TextStyle style, {int maxLines = 1, double minWidth = 0, double maxWidth = double.infinity,}) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: maxLines, textDirection: TextDirection.ltr
    )
    ..layout(minWidth: minWidth, maxWidth: maxWidth,);
    return textPainter.size;
  }

  static double distance(Offset p1, Offset p2) =>
   sqrt(pow(((p2.dx - p1.dx).abs()), 2.0) + pow(((p2.dy - p1.dy).abs()), 2.0));
  
  // Given a start coordinate, calculate a new coordinate at distance away in a given direction
  static Offset relativepointatangle(Offset p0, double distance, double angleInRadians) => 
    Offset(p0.dx + (distance * cos(angleInRadians)), p0.dy + (distance * sin(angleInRadians)));

  // Given two coordinates, get the coordinate in the middle of those two
  static Offset middleOfLine(Offset p0, Offset p1) => 
    Offset((p0.dx + p1.dx) / 2.0, (p0.dy + p1.dy) / 2.0);

  // Given two coordinates, get a coordinate at a fraction of the line between these coordinates
  static Offset pointOnLineAtFraction(Offset p0, Offset p1, double fraction) =>
    Offset(
      p0.dx + ((p1.dx - p0.dx) * fraction), 
      p0.dy + (p1.dy - p0.dy) * fraction
    );

  static Offset pointOnLineAtDistance(Offset p0, Offset p1, double distance) =>
    pointOnPathAtDistance(Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy), distance);

  // Get the angle between two coordinates. (see https://www.mathsisfun.com/algebra/trig-finding-angle-right-triangle.html)
  static double angleOfLine(Offset p0, Offset p1) {
    final double opposite = p1.dy - p0.dy;
    final double adjacent = p1.dx - p0.dx;
    if (adjacent == 0) {
      return p0.dx >= p1.dx ? pi / 2.0 : (pi * 3.0) / 2.0; // 90 or 270
    }

    // Take quadrant into account
    if (p0.dx > p1.dx) {
      return atan(opposite / adjacent) + pi;
    }
    return atan(opposite / adjacent);
  }

  static double adjacentFromHypotenuseAndOpposite(double hypotenuse, double opposite) {
    // a2 + b2 = c2, so opp2 + adj2 = hyp2 => adj2 = hyp2 - opp2
    // could also do cos(asin(opposite/hypotenuse)) * hypotenuse?
    return sqrt(pow(hypotenuse, 2) - pow(opposite, 2));
  }

  static double valueInMM(double value, Unit unit) {
    switch (unit) {
      case Unit.cm:
        return value * 10;
      case Unit.mm:
        return value;
      case Unit.meter:
        return value * 1000;
      case Unit.inches:
        return value * 25.4;
      case Unit.feet:
        return value * 304.8;
      case Unit.angle:
        return value;
    }
  }

  static double valueInUnit(double valueInMM, Unit unit) {
    switch (unit) {
      case Unit.mm:
        return valueInMM;
      case Unit.cm:
        return valueInMM / 10;
      case Unit.meter:
        return valueInMM / 1000;
      case Unit.inches:
        return valueInMM / 25.4;
      case Unit.feet:
        return valueInMM / 304.8;
      case Unit.angle:
        return valueInMM;
    }
  }

  static Offset pointOnPathAtFraction(Path p, double fraction) {
    final PathMetrics m = p.computeMetrics();
    final PathMetric pm = m.first;
    return pm.getTangentForOffset(pm.length * fraction)!.position;
  }

  static Offset pointOnPathAtDistance(Path p, double distance) {
    final PathMetrics m = p.computeMetrics();
    final PathMetric pm = m.first;
    return pm.getTangentForOffset(distance)!.position;
  }

  static double lengthOfPath(Path p) {
    final PathMetrics m = p.computeMetrics();
    return m.first.length;
  }
}
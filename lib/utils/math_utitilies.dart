
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';

class MathUtitilies {
  static double toDegrees(double radians) {
    return (180/pi) * radians;
  }

  static toRadians(double degrees) {
    return (pi / 180) * degrees;
  }

  static Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr
    )
    ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static double offsetDistance(Offset p1, Offset p2) =>
   sqrt(pow(((p2.dx - p1.dx).abs()), 2.0) + pow(((p2.dy - p1.dy).abs()), 2.0));

  static double distance(Coordinate p0, Coordinate p1) => 
   sqrt(pow(((p1.x - p0.x).abs()), 2.0) + pow(((p1.y - p0.y).abs()), 2.0));
  
  // Given a start coordinate, calculate a new coordinate at distance away in a given direction
  static Coordinate relativepointatangle(Coordinate p0, double distance, double angleInRadians) => 
    Coordinate(x: p0.x + (distance * cos(angleInRadians)), y: p0.y + (distance * sin(angleInRadians)));

  // Given two coordinates, get the coordinate in the middle of those two
  static Coordinate middleOfLine(Coordinate p0, Coordinate p1) => 
    Coordinate(x: (p0.x + p1.x) / 2.0, y: (p0.y + p1.y) / 2.0);

  // Get the angle between two coordinates. (see https://www.mathsisfun.com/algebra/trig-finding-angle-right-triangle.html)
  static double angleOfLine(Coordinate p0, Coordinate p1) {
    final double opposite = p1.y - p0.y;
    final double adjacent = p1.x - p0.x;
    if (adjacent == 0) {
      return p0.x >= p1.x ? pi / 2.0 : (pi * 3.0) / 2.0; // 90 or 270
    }
    return atan(opposite / adjacent);
  }

  static double adjacentFromHypotenuseAndOpposite(double hypotenuse, double opposite) {
    // a2 + b2 = c2, so opp2 + adj2 = hyp2 => adj2 = hyp2 - opp2
    // could also do cos(asin(opposite/hypotenuse)) * hypotenuse?
    return sqrt(pow(hypotenuse, 2) - pow(opposite, 2));
  }

}
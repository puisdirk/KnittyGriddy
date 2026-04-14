
import 'dart:math';

import 'package:flutter/painting.dart';

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

}
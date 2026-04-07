
import 'dart:math';

class MathUtitilies {
  static double toDegrees(double radians) {
    return (180/pi) * radians;
  }

  static toRadians(double degrees) {
    return (pi / 180) * degrees;
  }
}

import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';

/// An infinite line on the 2D Cartesian space, represented in the form
/// of ax + by = c.
class InfiniteLine {
  final double a;
  final double b;
  final double c;

  const InfiniteLine(this.a, this.b, this.c);

  InfiniteLine.fromPoints(Offset p1, Offset p2) : this(
    p2.dy - p1.dy,
    p1.dx - p2.dx,
    p2.dy * p1.dx - p1.dy * p2.dx,
  );

  List<Vector2> intersections(InfiniteLine other) {
    final determinant = a * other.b - other.a * b;
    if (determinant == 0) {
      // the lines are parallel. no intersections
      return [];
    }

    return [
      Vector2(
        (other.b * c - b * other.c) / determinant, 
        (a * other.c - other.a * c) / determinant,
      )
    ];
  }
}
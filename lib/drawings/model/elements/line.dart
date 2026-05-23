
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';
import 'package:knitty_griddy/drawings/model/elements/drawing_element.dart';
import 'package:knitty_griddy/drawings/model/infinite_line.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:vector_math/vector_math_64.dart';

const String drawingTypeLine = 'line';

@immutable
class Line extends DrawingElement {
  final Coordinate startPoint;
  final Coordinate endPoint;

  const Line({
    required super.label,
    required this.startPoint,
    required this.endPoint,
  });

  Line copyWith({
    String? label,
    Coordinate? startPoint,
    Coordinate? endPoint,
  }) {
    return Line(
      label: label?? this.label, 
      startPoint: startPoint?? this.startPoint, 
      endPoint: endPoint?? this.endPoint,
    );
  }

  @override
  Line offset(double x, double y) {
    return copyWith(
      startPoint: startPoint.offset(x, y),
      endPoint: endPoint.offset(x, y)
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': drawingTypeLine,
      'label': label,
      'start': startPoint.toJson(),
      'end': endPoint.toJson(),
    };
  }

  static Line fromJson(Map<String, dynamic> json) {
    return Line(
      label: json['label'] as String, 
      startPoint: Coordinate.fromJson(json['start']), 
      endPoint: Coordinate.fromJson(json['end']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Line &&
    label == other.label &&
    runtimeType == other.runtimeType &&
    startPoint == other.startPoint &&
    endPoint == other.endPoint;

  @override
  int get hashCode => super.hashCode ^ startPoint.hashCode ^ endPoint.hashCode;

  double lengthInMM() => MathUtitilies.distance(startPoint, endPoint);

  Coordinate middle() => coordAt(0.5);

  Coordinate coordAt(double fraction) => Coordinate(
    x: startPoint.x + ((endPoint.x - startPoint.x) * fraction), 
    y: startPoint.y + (endPoint.y - startPoint.y) * fraction
  );

  List<Coordinate> intersections(Line otherSegment) {
    return _intersections(otherSegment).map((v) => Coordinate(x: v.x, y: v.y)).toList();
  } 

  List<Vector2> _intersections(Line otherSegment) {
    final from = Vector2(startPoint.x, startPoint.y);
    final to = Vector2(endPoint.x, endPoint.y);
    final otherFrom = Vector2(otherSegment.startPoint.x, otherSegment.startPoint.y);
    final otherTo = Vector2(otherSegment.endPoint.x, otherSegment.endPoint.y);

    final result = toInfiniteLine().intersections(otherSegment.toInfiniteLine());
    if (result.isNotEmpty) {
      // The lines are not parallel
      final intersection = result.first;
      if (containsPoint(intersection) &&
          otherSegment.containsPoint(intersection)) {
        // The intersection point is on both line segments
        return result;
      }
    } else {
      // In here we know that the lines are parallel
      final overlaps = {
        if (otherSegment.containsPoint(from)) from,
        if (otherSegment.containsPoint(to)) to,
        if (containsPoint(otherFrom)) otherFrom,
        if (containsPoint(otherTo)) otherTo,
      };
      if (overlaps.isNotEmpty) {
        final sum = Vector2.zero();
        overlaps.forEach(sum.add);
        return [sum..scale(1 / overlaps.length)];
      }
    }

    return [];
  }

  InfiniteLine toInfiniteLine() => InfiniteLine.fromCoordinates(startPoint, endPoint);

  bool containsPoint(Vector2 point, {double epsilon = 0.000001}) {
    final from = Vector2(startPoint.x, startPoint.y);
    final to = Vector2(endPoint.x, endPoint.y);

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
}
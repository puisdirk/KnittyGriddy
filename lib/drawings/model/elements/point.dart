
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';
import 'package:knitty_griddy/drawings/model/elements/drawing_element.dart';

const String drawingTypePoint = 'point';

@immutable
class Point extends DrawingElement {
  final Coordinate coordinate;

  const Point({
    required super.label,
    required this.coordinate,
  });

  Point copyWith({
    String? label,
    Coordinate? coordinate,
  }) {
    return Point(
      label: label?? this.label,
      coordinate: coordinate?? this.coordinate,
    );
  }

  @override
  Point offset(double x, double y) {
    return copyWith(coordinate: coordinate.offset(x, y));
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': drawingTypePoint,
      'label': label,
      'coordinate': coordinate.toJson(),
    };
  }

  static Point fromJson(Map<String, dynamic> json) {
    return Point(
      label: json['label'] as String, 
      coordinate: Coordinate.fromJson(json['coordinate']),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Point &&
    runtimeType == other.runtimeType &&
    label == other.label &&
    coordinate == other.coordinate;

  @override
  int get hashCode => super.hashCode ^ label.hashCode ^ coordinate.hashCode;

}
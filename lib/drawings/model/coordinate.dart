
import 'package:flutter/foundation.dart';

@immutable
class Coordinate {
  final double _x;
  final double _y;

  const Coordinate({
    double x = 0, 
    double y = 0,
  }) : _x = x, _y = y;

  double get x => double.parse(_x.toStringAsFixed(2));
  double get y => double.parse(_y.toStringAsFixed(2));

  Coordinate copyWith({
    double? x,
    double? y,
  }) {
    return Coordinate(
      x: x?? this.x,
      y: y?? this.y,
    );
  }

  Coordinate offset(double x, double y) {
    return copyWith(x: _x + x, y: _y + y);
  }

  Map<String, Object> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  static Coordinate fromJson(Map<String, dynamic> json) {
    return Coordinate(
      x: json['x'] as double,
      y: json['y'] as double,
    );
  }

  @override
  int get hashCode => super.hashCode ^ _x.hashCode ^ _y.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Coordinate &&
      runtimeType == other.runtimeType &&
      double.parse(_x.toStringAsFixed(3)) == double.parse(other._x.toStringAsFixed(3)) &&
      double.parse(_y.toStringAsFixed(3)) == double.parse(other._y.toStringAsFixed(3));
}
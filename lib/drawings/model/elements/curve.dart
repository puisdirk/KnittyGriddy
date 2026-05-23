
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';
import 'package:knitty_griddy/drawings/model/elements/drawing_element.dart';

const String drawingTypeCurve = 'curve';

@immutable
class Curve extends DrawingElement {

  final Coordinate startPoint;
  final Coordinate endPoint;
  final Coordinate controlPoint;

  const Curve({
    required super.label,
    required this.startPoint,
    required this.endPoint,
    required this.controlPoint,
  });

  Curve copyWith({
    String? label,
    Coordinate? startPoint,
    Coordinate? endPoint,
    Coordinate? controlPoint,
  }) {
    return Curve(
      label: label?? this.label, 
      startPoint: startPoint?? this.startPoint, 
      endPoint: endPoint?? this.endPoint, 
      controlPoint: controlPoint?? this.controlPoint,
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': drawingTypeCurve,
      'label': label,
      'start': startPoint.toJson(),
      'end': endPoint.toJson(),
      'control': controlPoint.toJson(),
    };
  }

  static Curve fromJson(Map<String, dynamic> json) {
    return Curve(
      label: json['label'], 
      startPoint: Coordinate.fromJson(json['start']), 
      endPoint: Coordinate.fromJson(json['end']), 
      controlPoint: Coordinate.fromJson(json['control']),
    );
  }

  @override
  Curve offset(double x, double y) {
    return copyWith(
      startPoint: startPoint.offset(x, y),
      endPoint: endPoint.offset(x, y),
      controlPoint: controlPoint.offset(x, y),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Curve &&
    runtimeType == other.runtimeType &&
    label == other.label &&
    startPoint == other.startPoint &&
    endPoint == other.endPoint &&
    controlPoint == other.controlPoint;
  
  @override
  int get hashCode => super.hashCode ^ label.hashCode ^ startPoint.hashCode ^ endPoint.hashCode ^ controlPoint.hashCode;

}
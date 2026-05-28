
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

const String drawingTypeCurve = 'curve';

@immutable
class CurveCommand extends DrawingCommand {

  final Coordinate startPoint;
  final Coordinate endPoint;
  final Coordinate controlPoint;

  const CurveCommand({
    required super.id,
    required super.label,
    required this.startPoint,
    required this.endPoint,
    required this.controlPoint,
  });

  CurveCommand copyWith({
    String? label,
    Coordinate? startPoint,
    Coordinate? endPoint,
    Coordinate? controlPoint,
  }) {
    return CurveCommand(
      id: id,
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
      'id': id,
      'label': label,
      'start': startPoint.toJson(),
      'end': endPoint.toJson(),
      'control': controlPoint.toJson(),
    };
  }

  static CurveCommand fromJson(Map<String, dynamic> json) {
    return CurveCommand(
      id: json['id'] as String,
      label: json['label'] as String, 
      startPoint: Coordinate.fromJson(json['start']), 
      endPoint: Coordinate.fromJson(json['end']), 
      controlPoint: Coordinate.fromJson(json['control']),
    );
  }

  @override
  CurveCommand offset(double x, double y) {
    return copyWith(
      startPoint: startPoint.offset(x, y),
      endPoint: endPoint.offset(x, y),
      controlPoint: controlPoint.offset(x, y),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is CurveCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    startPoint == other.startPoint &&
    endPoint == other.endPoint &&
    controlPoint == other.controlPoint;
  
  @override
  int get hashCode => super.hashCode ^ startPoint.hashCode ^ endPoint.hashCode ^ controlPoint.hashCode;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  // TODO: implement isComplete
  bool get isComplete => false;

  @override
  bool isValid(Drawing drawing) {
    // TODO: implement isValid
    return false;
  }
}
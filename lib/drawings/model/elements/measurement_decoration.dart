
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';
import 'package:knitty_griddy/drawings/model/elements/curve.dart';
import 'package:knitty_griddy/drawings/model/elements/drawing_decoration.dart';
import 'package:knitty_griddy/drawings/model/elements/line.dart';
import 'package:knitty_griddy/drawings/model/elements/point.dart';

const String drawingTypeMeasurementDecoration = 'measurementdecoration';

enum MeasurementDecorationType {
  free,
  horizontal,
  vertical
}

enum MeasurementDecorationUnit {
  cm,
  mm,
  inches
}

@immutable
class MeasurementDecoration extends DrawingDecoration {
  // A measurement decoration can be between two points, along a line, or along a set of curves
  final Coordinate startCoord;
  final Coordinate endCoord;
  final List<Curve> curves;
  final MeasurementDecorationType measurementDecorationType;
  final MeasurementDecorationUnit measurementDecorationUnit;

  const MeasurementDecoration({
    required super.label,
    this.startCoord = const Coordinate(),
    this.endCoord = const Coordinate(),
    this.curves = const[],
    this.measurementDecorationType = MeasurementDecorationType.free,
    this.measurementDecorationUnit = MeasurementDecorationUnit.mm,
  });

  MeasurementDecoration copyWith({
    String? label,
    Coordinate? startCoord,
    Coordinate? endCoord,
    List<Curve>? curves,
    MeasurementDecorationType? measurementDecorationType,
    MeasurementDecorationUnit? measurementDecorationUnit,
  }) {
    return MeasurementDecoration(
      label: label?? this.label,
      startCoord: startCoord?? this.startCoord,
      endCoord: endCoord?? this.endCoord,
      curves: curves?? this.curves,
      measurementDecorationType: measurementDecorationType?? this.measurementDecorationType,
      measurementDecorationUnit: measurementDecorationUnit?? this.measurementDecorationUnit,
    );
  }

  MeasurementDecoration.fromPoints({
    required super.label,
    required Point startPoint,
    required Point endPoint,
    required this.measurementDecorationType,
    required this.measurementDecorationUnit,
  }) : startCoord = startPoint.coordinate, endCoord = endPoint.coordinate, curves = const[];

  MeasurementDecoration.fromLine({
    required super.label,
    required Line line,
    required this.measurementDecorationType,
    required this.measurementDecorationUnit,
  }) : startCoord = line.startPoint, endCoord = line.endPoint, curves = const[];

  MeasurementDecoration.fromCurves({
    required super.label,
    required List<Curve> curves,
    required this.measurementDecorationType,
    required this.measurementDecorationUnit,
  }) : startCoord = curves.first.startPoint, endCoord = curves.last.endPoint, curves = List.from(curves);

  @override
  MeasurementDecoration offset(double x, double y) {
    return copyWith(
      startCoord: startCoord.offset(x, y),
      endCoord: endCoord.offset(x, y),
      curves: curves.map((c) => c.offset(x, y)).toList(),
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': drawingTypeMeasurementDecoration,
      'label': label,
      'start': startCoord.toJson(),
      'end': endCoord.toJson(),
      'curves': curves.map((c) => toJson()).toList(),
      'mtype': measurementDecorationType.name,
      'munit': measurementDecorationUnit.name,
    };
  }

  static MeasurementDecoration fromJson(Map<String, dynamic> json) {
    List<Curve> curves = [];
    List<Map<String, dynamic>> curveObjects = (json['curves'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> curveObject in curveObjects) {
      curves.add(Curve.fromJson(curveObject));
    }

    return MeasurementDecoration(
      label: json['label'],
      startCoord: Coordinate.fromJson(json['start']),
      endCoord: Coordinate.fromJson(json['end']),
      curves: curves,
      measurementDecorationType: MeasurementDecorationType.values.byName(json['mtype']),
      measurementDecorationUnit: MeasurementDecorationUnit.values.byName(json['munit']),
    );
  }

}
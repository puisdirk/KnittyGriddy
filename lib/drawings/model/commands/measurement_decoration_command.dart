import 'package:flutter/widgets.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/coordinate.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_decoration_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

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
class MeasurementDecorationCommand extends DrawingDecorationCommand {
  // A measurement decoration can be between two points, along a line, or along a set of curves
  final Coordinate startCoord;
  final Coordinate endCoord;
  final List<CurveCommand> curves;
  final MeasurementDecorationType measurementDecorationType;
  final MeasurementDecorationUnit measurementDecorationUnit;

  final bool validated;
  final bool valid;

  const MeasurementDecorationCommand({
    required super.id,
    required super.label,
    this.startCoord = const Coordinate(),
    this.endCoord = const Coordinate(),
    this.curves = const[],
    this.measurementDecorationType = MeasurementDecorationType.free,
    this.measurementDecorationUnit = MeasurementDecorationUnit.mm,
    this.validated = false,
    this.valid = false,
  });

  MeasurementDecorationCommand copyWith({
    String? label,
    Coordinate? startCoord,
    Coordinate? endCoord,
    List<CurveCommand>? curves,
    MeasurementDecorationType? measurementDecorationType,
    MeasurementDecorationUnit? measurementDecorationUnit,
    bool? validated,
    bool? valid,
  }) {
    return MeasurementDecorationCommand(
      id: id,
      label: label?? this.label,
      startCoord: startCoord?? this.startCoord,
      endCoord: endCoord?? this.endCoord,
      curves: curves?? this.curves,
      measurementDecorationType: measurementDecorationType?? this.measurementDecorationType,
      measurementDecorationUnit: measurementDecorationUnit?? this.measurementDecorationUnit,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
    );
  }

  @override
  DrawingCommand deleteReference({required String commandId}) {
    // TODO: implement deleteReference
    return this;
  }

  MeasurementDecorationCommand.fromPoints({
    required super.id,
    required super.label,
    required PointCommand startPoint,
    required PointCommand endPoint,
    required this.measurementDecorationType,
    required this.measurementDecorationUnit,
  }) : valid = false, validated = false, startCoord = const Coordinate() /*startPoint.coordinate*/, endCoord = const Coordinate() /*endPoint.coordinate*/, curves = const[];

/*  MeasurementDecorationCommand.fromLine({
    required super.id,
    required super.label,
    required LineCommand line,
    required this.measurementDecorationType,
    required this.measurementDecorationUnit,
  }) : startCoord = line.startPoint, endCoord = line.endPoint, curves = const[];
*/
/*
  MeasurementDecorationCommand.fromCurves({
    required super.id,
    required super.label,
    required List<CurveCommand> curves,
    required this.measurementDecorationType,
    required this.measurementDecorationUnit,
  }) : valid = false, validated = false, startCoord = curves.first.startPoint, endCoord = curves.last.endPoint, curves = List.from(curves);
*/

  @override
  MeasurementDecorationCommand offset(double x, double y) {
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
      'id': id,
      'label': label,
      'start': startCoord.toJson(),
      'end': endCoord.toJson(),
      'curves': curves.map((c) => toJson()).toList(),
      'mtype': measurementDecorationType.name,
      'munit': measurementDecorationUnit.name,
    };
  }

  static MeasurementDecorationCommand fromJson(Map<String, dynamic> json) {
    List<CurveCommand> curves = [];
    List<Map<String, dynamic>> curveObjects = (json['curves'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> curveObject in curveObjects) {
      curves.add(CurveCommand.fromJson(curveObject));
    }

    return MeasurementDecorationCommand(
      id: json['id'] as String,
      label: json['label'] as String,
      startCoord: Coordinate.fromJson(json['start']),
      endCoord: Coordinate.fromJson(json['end']),
      curves: curves,
      measurementDecorationType: MeasurementDecorationType.values.byName(json['mtype']),
      measurementDecorationUnit: MeasurementDecorationUnit.values.byName(json['munit']),
    );
  }

  @override
  void paint(Canvas canvas, Size size, TextStyle style, Drawing drawing) {
    // TODO: implement paint
  }
  
  @override
  bool get isValidated => validated;

  @override
  DrawingCommand clearValidation() {
    return copyWith(validated: false, valid: false);
  }
  
  @override
  DrawingCommand validate(Drawing drawing) {
    // TODO: implement
    return this;
  }

}
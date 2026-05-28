
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

const String drawingTypePoint = 'point';

const String originId = '063f22af-bc7f-4e77-bc8b-60e48c821259';
const PointCommand origin = PointCommand(id: originId, label: 'origin');

enum PointDefinitionType {
  relativeToPoint(label: 'Relative to a point'),
  onLine(label: 'On a line');

  final String label;

  const PointDefinitionType({required this.label});
}

enum RelativePointDirection {
  north(label: 'North'),
  south(label: 'South'),
  east(label: 'East'),
  west(label: 'West'),
  northEast(label: 'North-East'),
  northWest(label: 'North-West'),
  southEast(label: 'South-East'),
  southWest(label: 'South-West'),
  angle(label: 'At angle');

  final String label;

  const RelativePointDirection({required this.label});
}

@immutable
class PointCommand extends DrawingCommand {
  final PointDefinitionType pointDefinitionType;
  final String onLineId;
  final String fromPointId;
  final String distanceFormula;
  final RelativePointDirection direction;
  final String directionAngleFormula;

  const PointCommand({
    required super.id,
    required super.label,
    PointDefinitionType? pointDefinitionType,
    this.onLineId = '',
    this.fromPointId = '',
    this.distanceFormula = '',
    RelativePointDirection? direction,
    this.directionAngleFormula = '',
  }) : pointDefinitionType = pointDefinitionType?? PointDefinitionType.relativeToPoint,
    direction = direction?? RelativePointDirection.north;

  PointCommand copyWith({
    String? label,
    PointDefinitionType? pointDefinitionType,
    String? onLineId,
    String? fromPointId,
    String? distanceFormula,
    RelativePointDirection? direction,
    String? directionAngleFormula,
  }) {
    return PointCommand(
      id: id,
      label: label?? this.label,
      pointDefinitionType: pointDefinitionType?? this.pointDefinitionType,
      onLineId: onLineId?? this.onLineId,
      fromPointId: fromPointId?? this.fromPointId,
      distanceFormula: distanceFormula?? this.distanceFormula,
      direction: direction?? this.direction,
      directionAngleFormula: directionAngleFormula?? this.directionAngleFormula,
    );
  }

  @override
  PointCommand offset(double x, double y) {
    return copyWith(/*coordinate: coordinate.offset(x, y)*/);
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': drawingTypePoint,
      'id': id,
      'label': label,
      'pdt': pointDefinitionType.name,
      'onlineid': onLineId,
      'frompointid': fromPointId,
      'distance': distanceFormula,
      'direction': direction.name,
      'angle': directionAngleFormula,
    };
  }

  static PointCommand fromJson(Map<String, dynamic> json) {
    return PointCommand(
      id: json['id'] as String,
      label: json['label'] as String, 
      pointDefinitionType: PointDefinitionType.values.byName(json['pdt'] as String),
      onLineId: json['onlineid'] as String,
      fromPointId: json['frompointid'] as String,
      distanceFormula: json['distance'] as String,
      direction: RelativePointDirection.values.byName(json['direction'] as String),
      directionAngleFormula: json['angle'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PointCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    pointDefinitionType == other.pointDefinitionType &&
    onLineId == other.onLineId &&
    fromPointId == other.fromPointId &&
    distanceFormula == other.distanceFormula &&
    direction == other.direction &&
    directionAngleFormula == other.directionAngleFormula;

  @override
  int get hashCode => super.hashCode ^ pointDefinitionType.hashCode ^ 
    onLineId.hashCode ^ fromPointId.hashCode ^ distanceFormula.hashCode ^ 
    direction.hashCode ^ directionAngleFormula.hashCode;

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
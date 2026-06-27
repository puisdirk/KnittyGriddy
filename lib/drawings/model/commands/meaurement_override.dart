import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';

class MeasurementOverride {
  final String measurementId;
  final String measurementLabel;
  final String formula;
  final Unit unit;

  const MeasurementOverride({
    required this.measurementId,
    required this.measurementLabel,
    required this.formula,
    required this.unit,
  });

  MeasurementOverride copyWith({
    String? measurementLabel,
    String? formula,
    Unit? unit,
  }) {
    return MeasurementOverride(
      measurementId: measurementId, 
      measurementLabel: measurementLabel?? this.measurementLabel,
      formula: formula?? this.formula,
      unit: unit?? this.unit,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is MeasurementOverride &&
      runtimeType == other.runtimeType &&
      measurementId == other.measurementId &&
      measurementLabel == other.measurementLabel &&
      formula == other.formula &&
      unit == other.unit;
  
  @override
  int get hashCode => super.hashCode ^ measurementId.hashCode ^ measurementLabel.hashCode ^ formula.hashCode ^ unit.hashCode;

  Map<String, Object> toJson() {
    return {
      'measurementid': measurementId,
      'measurementlabel': measurementLabel,
      'formula': formula,
      'unit': unit.name
    };
  }

  static MeasurementOverride fromJson(Map<String, dynamic> json) {
    return MeasurementOverride(
      measurementId: json['measurementid'] as String,
      measurementLabel: json['measurementlabel'] as String,
      formula: json['formula'] as String,
      unit: Unit.values.byName(json['unit'] as String),
    );
  }
}
class MeasurementOverride {
  final String measurementId;
  final String measurementLabel;
  final String formula;

  const MeasurementOverride({
    required this.measurementId,
    required this.measurementLabel,
    required this.formula,
  });

  MeasurementOverride copyWith({
    String? formula,
  }) {
    return MeasurementOverride(
      measurementId: measurementId, 
      measurementLabel: measurementLabel,
      formula: formula?? this.formula
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is MeasurementOverride &&
      runtimeType == other.runtimeType &&
      measurementId == other.measurementId &&
      measurementLabel == other.measurementLabel &&
      formula == other.formula;
  
  Map<String, Object> toJson() {
    return {
      'measurementid': measurementId,
      'measurementlabel': measurementLabel,
      'formula': formula,
    };
  }

  static MeasurementOverride fromJson(Map<String, dynamic> json) {
    return MeasurementOverride(
      measurementId: json['measurementid'] as String,
      measurementLabel: json['measurementlabel'] as String,
      formula: json['formula'] as String,
    );
  }
}
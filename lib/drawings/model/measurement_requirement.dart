
import 'package:flutter/material.dart';

@immutable
class MeasurementRequirement {
  final String label;

  const MeasurementRequirement({
    required this.label
  });

  Map<String, Object> toJson() {
    return {
      'label': label,
    };
  }

  static MeasurementRequirement fromJson(Map<String, dynamic> json) {
    return MeasurementRequirement(
      label: json['label']
    );
  }  
}
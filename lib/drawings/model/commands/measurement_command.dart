import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

enum Unit {
  mm(label: 'Millimeter', shortLabel: 'mm'),
  cm(label: 'Centimeter', shortLabel: 'cm'),
  meter(label: 'Meter', shortLabel: 'm'),
  inches(label: 'Inches', shortLabel: '"'),
  feet(label: 'Feet', shortLabel: 'ft');
  
  final String label;
  final String shortLabel;
  const Unit({required this.label, required this.shortLabel});
}

@immutable
class MeasurementCommand extends DrawingCommand {
  final double minValue;
  final double maxValue;
  final double value;
  final int decimals;
  final Unit unit;

  final bool validated;
  final bool valid;

  const MeasurementCommand({
    required super.id,
    required super.label,
    List<String>? errors,
    this.minValue = 0,
    this.maxValue = 100,
    this.value = 50,
    this.decimals = 0,
    this.unit = Unit.mm,
    this.valid = false,
    this.validated = false,
  }) : super(errors: errors?? const[]);

  MeasurementCommand copyWith({
    String? label,
    double? minValue,
    double? maxValue,
    double? value,
    int? decimals,
    Unit? unit,
    bool? validated,
    bool? valid,
    List<String>? errors,
  }) {
    double min = minValue?? this.minValue;
    double max = maxValue?? this.maxValue;
    double val = value?? this.value;
    if (val < min) val = min;
    if (val > max) val = max;
    if (decimals != null) {
      // Force refresh of the stepper controls
      min += 0.0000000001;
      max += 0.0000000001;
      val += 0.0000000001;
    }
    return MeasurementCommand(
      id: id, 
      label: label?? this.label,
      minValue: min,
      maxValue: max,
      value: val,
      decimals: decimals?? this.decimals,
      unit: unit?? this.unit,
      valid: valid?? this.valid,
      validated: validated?? this.validated,
      errors: errors?? this.errors,
    );
  }

  double get valueInMM => MathUtitilies.valueInMM(value, unit);

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is MeasurementCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      minValue == other.minValue &&
      maxValue == other.maxValue &&
      value == other.value &&
      decimals == other.decimals &&
      unit == other.unit &&
      valid == other.valid &&
      validated == other.validated &&
      listEquals(errors, other.errors);
  
  @override
  int get hashCode => super.hashCode ^ id.hashCode ^ label.hashCode ^
    minValue.hashCode ^ maxValue.hashCode ^ value.hashCode ^ decimals.hashCode ^ unit.hashCode ^
    valid.hashCode ^ validated.hashCode ^ errors.hashCode;

  @override
  DrawingCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  DrawingCommand deleteReference({required String commandId}) {
    return this;
  }

  @override
  bool get isValidated => validated;

  @override
  DrawingCommand offset(double x, double y) {
    return this;
  }

  @override
  void paint(Canvas canvas, Size size, TextStyle style, Drawing drawing) {
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.measurementCommand.name,
      'min': minValue,
      'max': maxValue,
      'val': value,
      'dec': decimals,
      'unit': unit.name,
    };
  }

  static MeasurementCommand fromJson(Map<String, dynamic> json) {
    return MeasurementCommand(
      id: json['id'] as String, 
      label: json['label'] as String,
      minValue: json['min'] as double,
      maxValue: json['max'] as double,
      value: json['val'] as double,
      decimals: json['dec'] as int,
      unit: Unit.values.byName(json['unit'] as String),
    );
  }

  @override
  MeasurementCommand validate(Drawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (minValue >= maxValue) {
      isvalid = false;
      retryValidation = false;
      errors.add('Minimum must be smaller than maximum');
    }

    if (value < minValue || value > maxValue) {
      isvalid = false;
      retryValidation = false;
      errors.add('Value must be between minimum and maximum');
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }
}
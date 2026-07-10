import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';

import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

enum Unit {
  mm(label: 'Millimeter', shortLabel: 'mm'),
  cm(label: 'Centimeter', shortLabel: 'cm'),
  meter(label: 'Meter', shortLabel: 'm'),
  inches(label: 'Inches', shortLabel: '"'),
  feet(label: 'Feet', shortLabel: 'ft'),
  angle(label: 'Degrees', shortLabel: '°');
  
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

  const MeasurementCommand({
    required super.id,
    required super.version,
    required super.label,
    this.minValue = 0,
    this.maxValue = 100,
    this.value = 50,
    this.decimals = 0,
    this.unit = Unit.cm,
    super.valid,
    super.validated,
    super.errors,
    super.initiallyOpen,
  });

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
    bool? initiallyOpen,
  }) {
    double min = minValue?? this.minValue;
    double max = maxValue?? this.maxValue;
    double val = value?? this.value;
    if (val < min) val = min;
    if (val > max) val = max;
    return MeasurementCommand(
      id: id, 
      version: version + 1,
      label: label?? this.label,
      minValue: min,
      maxValue: max,
      value: val,
      decimals: decimals?? this.decimals,
      unit: unit?? this.unit,
      valid: valid?? this.valid,
      validated: validated?? this.validated,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 330;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    return Rect.zero;
  }

  @override
  MeasurementCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    return {};
  }

  double get valueInMM => MathUtitilies.valueInMM(value, unit);

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is MeasurementCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
//      version == other.version &&
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
    minValue.hashCode ^ maxValue.hashCode ^ value.hashCode ^ decimals.hashCode ^ unit.hashCode;

  @override
  MeasurementCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  MeasurementCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  MeasurementCommand changePartDrawingReference({required String oldId, required String newId}) => this;

  @override
  MeasurementCommand deleteReference({required String commandId}) {
    return this;
  }

  @override
  MeasurementCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return this;
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[]}) {
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.measurementCommand.name,
      'id': id,
      'label': label,
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
      version: 0,
      label: json['label'] as String,
      minValue: json['min'] as double,
      maxValue: json['max'] as double,
      value: json['val'] as double,
      decimals: json['dec'] as int,
      unit: Unit.values.byName(json['unit'] as String),
    );
  }

  @override
  MeasurementCommand validate(AbstractDrawing drawing) {
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
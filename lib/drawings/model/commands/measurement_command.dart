import 'dart:convert';

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
  angle(label: 'Degrees', shortLabel: '°'),
  colour(label: 'Colour', shortLabel: ''),
  noUnit(label: 'None', shortLabel: '');
  
  final String label;
  final String shortLabel;
  const Unit({required this.label, required this.shortLabel});
}

@immutable
class MeasurementCommand extends DrawingCommand {
  final double minValue;
  final double maxValue;
  final double value;
  final int colourValue;
  final int decimals;
  final Unit unit;

  static const int kDefaultColour = 0xFF000000;

  const MeasurementCommand({
    required super.id,
    required super.version,
    required super.label,
    this.minValue = 0,
    this.maxValue = 100,
    this.value = 50,
    this.colourValue = kDefaultColour,
    this.decimals = 0,
    this.unit = Unit.cm,
    super.valid,
    super.validated,
    super.errors,
    super.initiallyOpen,
  });

  MeasurementCommand copyWith({
    String? id,
    String? label,
    double? minValue,
    double? maxValue,
    double? value,
    int? colourValue,
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
      id: id?? this.id, 
      version: version + 1,
      label: label?? this.label,
      minValue: min,
      maxValue: max,
      value: val,
      colourValue: colourValue?? this.colourValue,
      decimals: decimals?? this.decimals,
      unit: unit?? this.unit,
      valid: valid?? this.valid,
      validated: validated?? this.validated,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  MeasurementCommand abstractCopyWith({
    String? id, 
    String? label, 
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen
  }) {
    return copyWith(
      id: id?? this.id,
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => unit == Unit.colour ? 140 : 330;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) => Rect.zero;

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
      label == other.label &&
      minValue == other.minValue &&
      maxValue == other.maxValue &&
      value == other.value &&
      colourValue == other.colourValue &&
      decimals == other.decimals &&
      unit == other.unit &&
      valid == other.valid &&
      validated == other.validated &&
      listEquals(errors, other.errors);
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
      other is MeasurementCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      minValue == other.minValue &&
      maxValue == other.maxValue &&
      value == other.value &&
      colourValue == other.colourValue &&
      decimals == other.decimals &&
      unit == other.unit;

  @override
  int get hashCode => super.hashCode ^ id.hashCode ^ label.hashCode ^
    minValue.hashCode ^ maxValue.hashCode ^ value.hashCode ^ colourValue.hashCode ^ decimals.hashCode ^ unit.hashCode;

  @override
  MeasurementCommand changePartDrawingReference({required String oldId, required String newId}) => this;

  @override
  MeasurementCommand deleteReference({required String commandId}) => this;

  @override
  MeasurementCommand dependentLabelChanged(String oldLabel, String newLabel) => this;

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], bool drawDirectionArrow = false, bool forPreview = false}) {
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]}) => '';

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.measurementCommand.name,
      'id': id,
      'label': label,
      'min': minValue,
      'max': maxValue,
      'val': value,
      'col': colourValue,
      'dec': decimals,
      'unit': unit.name,
    };
  }

  @override
  String get contentHashCode => jsonEncode({
      'type': DrawingCommandTypes.measurementCommand.name,
      'label': label,
      'min': minValue,
      'max': maxValue,
      'val': value,
      'col': colourValue,
      'dec': decimals,
      'unit': unit.name,
    });

  static MeasurementCommand fromJson(Map<String, dynamic> json) {
    return MeasurementCommand(
      id: json['id'] as String, 
      version: 0,
      label: json['label'] as String,
      minValue: json['min'] as double,
      maxValue: json['max'] as double,
      value: json['val'] as double,
      colourValue: json.containsKey('col') ? json['col'] as int : kDefaultColour,
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

    if (unit != Unit.colour) {
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
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }
}


// A colour that has its own value or refers to a measurement with unit Unit.colour
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';

@immutable
class ColourReference {

  final String measurementId;
  final String measurementLabel;
  final int colorValue;

  const ColourReference({
    this.measurementId = '',
    this.measurementLabel = '',
    this.colorValue = 0xFF000000,
  });

  ColourReference copyWith({
    String? measurementId,
    String? measurementLabel,
    int? colorValue,
  }) {
    return ColourReference(
      measurementId: measurementId?? this.measurementId,
      measurementLabel: measurementLabel?? this.measurementLabel,
      colorValue: colorValue?? this.colorValue,
    );
  }

  Color get color => Color(colorValue);

  ColourReference checkForUpdate(AbstractDrawing drawing) {
    if (measurementId.isEmpty) return this;

    MeasurementCommand? mcmd = drawing.measurementById(measurementId);
    if (mcmd == null) {
      return copyWith(measurementId: '');
    } else if (mcmd.unit != Unit.colour) {
      // we keep the ref for now in case the user goes back to unit colour
      return this;
    } else if (mcmd.colourValue != colorValue) {
      return copyWith(colorValue: mcmd.colourValue);
    }

    return this;
  }

  ColourReference deleteReference({required String commandId}) {
    return copyWith(
      measurementId: measurementId == commandId ? '' : measurementId
    );
  }

  ColourReference dependentLabelChanged(String oldLabel, String newLabel) {
    if (measurementLabel == oldLabel) {
      return copyWith(measurementLabel: newLabel);
    }
    return this;
  }

  Map<String, Object> toJson() {
    return {
      'mid': measurementId,
      'col': colorValue,
    };
  }

  static ColourReference fromJson(Map<String, dynamic> json) {
    return ColourReference(
      measurementId: json['mid'] as String,
      colorValue: json['col'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ColourReference &&
    runtimeType == other.runtimeType &&
    measurementId == other.measurementId &&
    colorValue == other.colorValue;
  
  @override
  int get hashCode => super.hashCode ^ measurementId.hashCode ^ colorValue.hashCode;
}
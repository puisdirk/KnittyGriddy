
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/meaurement_override.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';

@immutable
class IncludedPartCommand extends DrawingCommand {

  final PartInfo? partInfo;
  final String anchorPointId;
  final List<MeasurementOverride> measurementOverrides;

  const IncludedPartCommand({
    required super.id,
    required super.label,
    required super.version,
    this.partInfo,
    this.anchorPointId = originId,
    this.measurementOverrides = const[],
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  IncludedPartCommand copyWith({
    String? label,
    PartInfo? partInfo,
    String? anchorPointId,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    List<MeasurementOverride>? measurementOverrides,
  }) {
    return IncludedPartCommand(
      id: id,
      version: version + 1,
      label: label?? this.label, 
      partInfo: partInfo?? this.partInfo,
      anchorPointId: anchorPointId?? this.anchorPointId,
      measurementOverrides: measurementOverrides?? this.measurementOverrides,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 200 + (measurementOverrides.length * 50);

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    // TODO: implement getBoundingBox
    return Rect.zero;
  }

  @override
  IncludedPartCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  IncludedPartCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    return {anchorPointId};
  }

  @override
  IncludedPartCommand deleteReference({required String commandId}) {
    if (anchorPointId == commandId) {
      return copyWith(anchorPointId: '');
    }
    // TODO: may need to clean measurementoverrides
    return this;
  }

  @override
  IncludedPartCommand dependentLabelChanged(String oldLabel, String newLabel) {
    // TODO: may need to clean measurementoverrides
    return this;
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.includedPartCommand.name,
      'id': id,
      'label': label,
      'partinfo': partInfo == null ? {} : partInfo!.toJson(),
      'anchor': anchorPointId,
      'moverrides': measurementOverrides.map((m) => m.toJson()).toList(),
    };
  }

  static IncludedPartCommand fromJson(Map<String, dynamic> json) {
    List<MeasurementOverride> moverrides = [];
    List<Map<String, dynamic>> moverrideObjects = (json['moverrides'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> moverrideObject in moverrideObjects) {
      moverrides.add(MeasurementOverride.fromJson(moverrideObject));
    }

    return IncludedPartCommand(
      id: json['id'] as String, 
      label: json['label'] as String, 
      version: 0,
      partInfo: (json['partinfo'] as Map<String, dynamic>).isEmpty ? null : PartInfo.fromJson(json['partinfo'] as Map<String, dynamic>),
      anchorPointId: json['anchor'] as String,
      measurementOverrides: moverrides,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is IncludedPartCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      version == other.version &&
      partInfo == other.partInfo &&
      anchorPointId == other.anchorPointId &&
      listEquals(measurementOverrides, other.measurementOverrides) &&
      validated == other.validated &&
      valid == other.valid &&
      listEquals(errors, other.errors);

  @override
  int get hashCode => super.hashCode ^ partInfo.hashCode ^ anchorPointId.hashCode ^ measurementOverrides.hashCode;

  @override
  IncludedPartCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false}) {
    if (!valid) return;

    PartDrawing? partDrawing = PartRepository.getPartDrawingById(partInfo!.partDrawingId);
    if (partDrawing == null) return;

    // Copy the measurement override values into the partDrawing
    partDrawing = partDrawing.copyWith(
      commands: partDrawing.commands.map((c) {
        if (c is! MeasurementCommand) {
          return c;
        } else {
          MeasurementOverride mo = measurementOverrides.firstWhere((mo) => mo.measurementId == c.id);
          FormulaParseResult res = FormulaExpression.validate(formula: mo.formula, drawing: drawing);
          return c.copyWith(value: res.result!);
        }
      }).toList()
    ).validate();

    PartCommand partCommand = partDrawing.parts.firstWhere((p) => p.id == partInfo!.partId);

    // Calculate the offset needed
    PointCommand? ownAnchorPoint = drawing.pointById(anchorPointId);
    if (ownAnchorPoint == null) return;
    PointCommand? partAnchorPoint = partDrawing.pointById(partCommand.anchorPointId);
    if (partAnchorPoint == null) return;
    Offset? ownOffset = ownAnchorPoint.getCoordinate(drawing);
    if (ownOffset == null) return;
    Offset? partOffset = partAnchorPoint.getCoordinate(partDrawing);
    if (partOffset == null) return;

    partDrawing = (partDrawing.abstractCopyWith(offset: ownOffset - partOffset) as PartDrawing).validate();

    partCommand.paint(canvas, size, partDrawing, selected);
  }

  @override
  DrawingCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (partInfo == null) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires a part');
    } else {
      // TODO: should check if the part exists and is validated && valid, but not sure if it can ever occur
    }

    // Check if the measurement overrides have valid formula's
    for (MeasurementOverride mo in measurementOverrides) {
        FormulaParseResult res = FormulaExpression.validate(formula: mo.formula, drawing: drawing, label: 'a value');
        if (res.isInvalid) {
          isvalid = false;
          if (!res.shouldRetry) retryValidation = false;
          validationErrors.add('measurement ${mo.measurementLabel}: ${res.errorMessage}');
        }
    }

    if (anchorPointId.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires an anchor point');
    } else if (anchorPointId != originId) {
      PointCommand? anchor = drawing.pointById(anchorPointId);
      if (anchor == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Anchor point does not exist');
      } else {
        if (!anchor.validated) {
          isvalid = false;
        } else if (!anchor.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Anchor point ${anchor.label} has errors');
        }
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }

}
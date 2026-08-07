
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_expression.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/meaurement_override.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';

@immutable
class IncludedPartCommand extends DrawingCommand {

  // Info about the part and its drawing
  final String partDrawingId;
  final String partId;
  final String partLabel;

  // Stored offet drawing and offset info
  final PartDrawing? storedOffsetPartDrawing;
  final Offset? storedOffset;
  final Offset? storedAnchorOffset;

  final String anchorPointId;
  final List<MeasurementOverride> measurementOverrides;

  // Whether we need to recalculate the offset-drawing
  final bool isDirty;

  const IncludedPartCommand({
    required super.id,
    required super.label,
    required super.version,
    this.partDrawingId = '',
    this.partId = '',
    this.partLabel = '',
    this.storedOffsetPartDrawing,
    this.storedOffset,
    this.storedAnchorOffset,
    this.anchorPointId = originId,
    this.measurementOverrides = const[],
    this.isDirty = false,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  IncludedPartCommand copyWith({
    String? label,
    String? anchorPointId,
    String? partDrawingId,
    String? partId,
    String? partLabel,
    PartDrawing? storedOffsetPartDrawing,
    Offset? storedOffset,
    Offset? storedAnchorOffset,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
    List<MeasurementOverride>? measurementOverrides,
  }) {
    bool makeDirty = 
      (anchorPointId != null && anchorPointId != this.anchorPointId) || 
      (partDrawingId != null && partDrawingId != this.partDrawingId) || 
      (partId != null && partId != this.partId) || 
      (measurementOverrides != null && !listEquals(measurementOverrides, this.measurementOverrides));

    return IncludedPartCommand(
      id: id,
      version: version + 1,
      label: label?? this.label, 
      anchorPointId: anchorPointId?? this.anchorPointId,
      partDrawingId: partDrawingId?? this.partDrawingId,
      partId: partId?? this.partId,
      partLabel: partLabel?? this.partLabel,
      storedOffsetPartDrawing: storedOffsetPartDrawing?? this.storedOffsetPartDrawing,
      storedOffset: storedOffset?? this.storedOffset,
      storedAnchorOffset: storedAnchorOffset?? this.storedAnchorOffset,
      isDirty: makeDirty,
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
    if (!valid) return Rect.zero;

    if (storedOffsetPartDrawing == null) return Rect.zero;

    PartCommand partCommand = storedOffsetPartDrawing!.parts.firstWhere((p) => p.id == partId);

    return partCommand.calculateBoundingBox(storedOffsetPartDrawing!);
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
    Set<String> deps = {anchorPointId};
    for (MeasurementOverride override in measurementOverrides) {
      deps.addAll(FormulaExpression.dependencies(formula: override.formula, drawing: drawing));
    }
    return deps;
  }

  @override
  IncludedPartCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(anchorPointId: anchorPointId.replaceAll(oldId, newId));
  }


  @override
  IncludedPartCommand deleteReference({required String commandId}) {
    if (anchorPointId == commandId || anchorPointId.startsWith('$commandId.')) {
      return copyWith(anchorPointId: '');
    }

    return this;
  }

  @override
  IncludedPartCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      measurementOverrides: measurementOverrides.map((mo) => 
        mo.copyWith(
          formula: FormulaExpression.replaceDependentLabel(
            formula: mo.formula, oldLabel: oldLabel, newLabel: newLabel))).toList()
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.includedPartCommand.name,
      'id': id,
      'label': label,
      'partdrawingid': partDrawingId,
      'partid': partId,
      'partlabel': partLabel,
      'anchor': anchorPointId,
      'moverrides': measurementOverrides.map((m) => m.toJson()).toList(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
      'type': DrawingCommandTypes.includedPartCommand.name,
      'label': label,
      'partdrawingid': partDrawingId,
      'partid': partId,
      'partlabel': partLabel,
      'anchor': anchorPointId,
      'moverrides': measurementOverrides.map((m) => m.contentHashCode).toList(),
    });

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
      partDrawingId: json['partdrawingid'] as String,
      partId: json['partid'] as String,
      partLabel: json['partlabel'] as String,
      isDirty: true,
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
      partDrawingId == other.partDrawingId &&
      partId == other.partId &&
      partLabel == other.partLabel &&
      storedOffsetPartDrawing == other.storedOffsetPartDrawing &&
      storedAnchorOffset == other.storedAnchorOffset &&
      storedOffset == other.storedOffset &&
      anchorPointId == other.anchorPointId &&
      listEquals(measurementOverrides, other.measurementOverrides) &&
      isDirty == other.isDirty &&
      validated == other.validated &&
      valid == other.valid &&
      listEquals(errors, other.errors);

  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
      other is IncludedPartCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      partDrawingId == other.partDrawingId &&
      partId == other.partId &&
      partLabel == other.partLabel &&
      anchorPointId == other.anchorPointId &&
      listEquals(measurementOverrides, other.measurementOverrides);

  @override
  int get hashCode => super.hashCode ^ partDrawingId.hashCode ^ partId.hashCode ^ partLabel.hashCode ^
    storedOffsetPartDrawing.hashCode ^ storedAnchorOffset.hashCode ^ storedOffset.hashCode ^ 
    anchorPointId.hashCode ^ measurementOverrides.hashCode ^ isDirty.hashCode;

  @override
  IncludedPartCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  IncludedPartCommand _calculateNewStoredPartDrawing(AbstractDrawing drawing) {
    if (partDrawingId.isEmpty || partId.isEmpty) return this;
    PartDrawing? partDrawing = PartRepository.getPartDrawingById(partDrawingId);
    if (partDrawing == null) return this;

    // Copy the measurement override values into the partDrawing
    PartDrawing partDrawingWithOverrides = partDrawing.copyWith(
      commands: partDrawing.commands.map((c) {
        if (c is! MeasurementCommand) {
          return c;
        } else {
          MeasurementOverride mo = measurementOverrides.firstWhere((mo) => mo.measurementId == c.id);
          FormulaParseResult res = FormulaExpression.validate(formula: mo.formula, drawing: drawing);
          return c.copyWith(value: res.result!);
        }
      }).toList()
    );
    // If the measurement overrides change the drawing, we need to validate to get the new point offsets
    if (!partDrawingWithOverrides.sameContentAs(partDrawing)) {
      partDrawingWithOverrides = partDrawingWithOverrides.validate();
    }

    PartCommand partCommand = partDrawingWithOverrides.parts.firstWhere((p) => p.id == partId);

    // Calculate the offset needed
    PointCommand? ownAnchorPoint = drawing.pointById(anchorPointId);
    if (ownAnchorPoint == null) return this;
    Offset? ownOffset = ownAnchorPoint.getCoordinate(drawing);
    if (ownOffset == null) return this;
    PointCommand? partAnchorPoint = partDrawingWithOverrides.pointById(partCommand.anchorPointId);
    if (partAnchorPoint == null) return this;
    Offset? partOffset = partAnchorPoint.getCoordinate(partDrawingWithOverrides);
    if (partOffset == null) return this;

    return copyWith(
      storedOffsetPartDrawing: 
        partDrawingWithOverrides.abstractCopyWith(offset: ownOffset - partOffset).validate(),
      storedOffset: ownOffset - partOffset,
      storedAnchorOffset: ownOffset,
    );
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    if (!valid) return '';
    if (storedOffsetPartDrawing == null) return '';
    
    PartCommand partCommand = storedOffsetPartDrawing!.parts.firstWhere((p) => p.id == partId);

    return '<g id="${partCommand.label}">${partCommand.toSvg(drawingSize, storedOffsetPartDrawing!, stylings: drawing.commands.whereType<StylingCommand>().toList())}</g>';    
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], bool drawDirectionArrow = false, bool forPreview = false}) {
    if (!valid) return;
    if (storedOffsetPartDrawing == null) return;
    
    PartCommand partCommand = storedOffsetPartDrawing!.parts.firstWhere((p) => p.id == partId);

    partCommand.paint(canvas, size, storedOffsetPartDrawing!, selected, prefixLabel: label, stylings: drawing.commands.whereType<StylingCommand>().toList(), drawDirectionArrow: drawDirectionArrow, forPreview: forPreview);
  }

  @override
  DrawingCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (partDrawingId.isEmpty || partId.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires a part');
    } else {
      // Remark: could check if the part exists and is validated && valid, but I'm pretty sure this can never occur
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

    Offset? newAnchorPointLocation;

    if (anchorPointId.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires an anchor point');
    } else if (anchorPointId == originId) {
      newAnchorPointLocation = origin.getCoordinate(drawing);
    } else {
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
        } else {
          newAnchorPointLocation = anchor.getCoordinate(drawing);
        }
      }
    }

    if (isvalid && (isDirty || newAnchorPointLocation != storedAnchorOffset) ||
      (partDrawingId.isNotEmpty && storedOffsetPartDrawing == null)) {
      IncludedPartCommand copy = _calculateNewStoredPartDrawing(drawing);
      return copy.copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
        errors: validationErrors,
      );
    } else {
      return copyWith(
        valid: isvalid,
        validated: (isvalid || !retryValidation),
        errors: validationErrors,
      );
    }
  }

}
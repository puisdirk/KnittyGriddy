
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';

@immutable
class IncludedPartCommand extends DrawingCommand {

  final PartInfo? partInfo;
  final String anchorPointId;

  const IncludedPartCommand({
    required super.id,
    required super.label,
    required super.version,
    this.partInfo,
    this.anchorPointId = '',
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
  }) {
    return IncludedPartCommand(
      id: id,
      version: version + 1,
      label: label?? this.label, 
      partInfo: partInfo?? this.partInfo,
      anchorPointId: anchorPointId?? this.anchorPointId,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 200;

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
    return this;
  }

  @override
  IncludedPartCommand dependentLabelChanged(String oldLabel, String newLabel) {
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
    };
  }

  static IncludedPartCommand fromJson(Map<String, dynamic> json) {
    return IncludedPartCommand(
      id: json['id'] as String, 
      label: json['label'] as String, 
      version: 0,
      partInfo: (json['partinfo'] as Map<String, dynamic>).isEmpty ? null : PartInfo.fromJson(json['partinfo'] as Map<String, dynamic>),
      anchorPointId: json['anchor'] as String,
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
      validated == other.validated &&
      valid == other.valid &&
      listEquals(errors, other.errors);

  @override
  int get hashCode => super.hashCode ^ partInfo.hashCode ^ anchorPointId.hashCode;

  @override
  IncludedPartCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false}) {
    // TODO: implement paint
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
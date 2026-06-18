
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

@immutable
class IncludedPartCommand extends DrawingCommand {

  final String partId;
  final String anchorPointId;

  const IncludedPartCommand({
    required super.id,
    required super.label,
    required super.version,
    this.partId = '',
    this.anchorPointId = '',
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  IncludedPartCommand copyWith({
    String? label,
    String? partId,
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
      partId: partId?? this.partId,
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
  Rect getBoundingBox(Drawing drawing) {
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
  Set<String> dependencies(Drawing drawing) {
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
      'partid': partId,
      'anchor': anchorPointId,
    };
  }

  static IncludedPartCommand fromJson(Map<String, dynamic> json) {
    return IncludedPartCommand(
      id: json['id'] as String, 
      label: json['label'] as String, 
      version: 0,
      partId: json['partid'] as String,
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
      partId == other.partId &&
      anchorPointId == other.anchorPointId &&
      validated == other.validated &&
      valid == other.valid &&
      listEquals(errors, other.errors);

  @override
  int get hashCode => super.hashCode ^ partId.hashCode ^ anchorPointId.hashCode;

  @override
  IncludedPartCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  void paint(Canvas canvas, Size size, Drawing drawing, bool selected, {bool asPart = false}) {
    // TODO: implement paint
  }

  @override
  DrawingCommand validate(Drawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (partId.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires a part');
    } else {
      // TODO: should check if the part exists and is validated && valid
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
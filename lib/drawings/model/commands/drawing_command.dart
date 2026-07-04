
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';

enum DrawingCommandTypes {
  commentCommand,
  measurementCommand,
  variableCommand,
  pointCommand,
  lineCommand,
  curveCommand,
  partCommand,
  includedPartCommand,
}

@immutable
abstract class DrawingCommand {
  final String id;
  final int version;
  final String label;

  final bool valid;
  final bool validated;
  final List<String> errors;

  final bool initiallyOpen;

  const DrawingCommand({
    required this.id,
    required this.version,
    required this.label,
    this.valid = false,
    this.validated = false,
    this.errors = const[],
    this.initiallyOpen = false,
  });

  double get editHeight;
  
  Map<String, Object> toJson();  
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = ''});
  
  Rect getBoundingBox(AbstractDrawing drawing);

  DrawingCommand deleteReference({required String commandId});
  DrawingCommand changePartDrawingReference({required String oldId, required String newId});
  DrawingCommand dependentLabelChanged(String oldLabel, String newLabel);
  DrawingCommand setInitiallyClosed();

  DrawingCommand clearValidation();
  DrawingCommand validate(AbstractDrawing drawing);

  // Get the Ids of dependent commands
  Set<String> dependencies(AbstractDrawing drawing);

  DrawingCommand markAsCyclic(String cycleDescription);
  bool get hasErrors => validated && !valid && errors.isNotEmpty;

  String previewPath(AbstractDrawing drawing) { return ''; }

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ valid.hashCode ^ validated.hashCode ^ errors.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DrawingCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    valid == other.valid &&
    validated == other.validated &&
    listEquals(errors, other.errors);
}
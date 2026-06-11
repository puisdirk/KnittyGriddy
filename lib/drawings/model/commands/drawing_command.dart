
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

enum DrawingCommandTypes {
  pointCommand,
  lineCommand,
  curveCommand,
  measurementCommand,
  variableCommand,
}

@immutable
abstract class DrawingCommand {
  final String id;
  final String label;

  final bool valid;
  final bool validated;
  final List<String> errors;

  final bool initiallyOpen;

  const DrawingCommand({
    required this.id,
    required this.label,
    this.valid = false,
    this.validated = false,
    this.errors = const[],
    this.initiallyOpen = false,
  });

  double get editHeight;
  
  Map<String, Object> toJson();  
  void paint(Canvas canvas, Size size, Drawing drawing, bool selected);
  
  Rect getBoundingBox(Drawing drawing);

  DrawingCommand deleteReference({required String commandId});
  DrawingCommand setInitiallyClosed();

  DrawingCommand clearValidation();
  DrawingCommand validate(Drawing drawing);

  // Get the Ids of dependent commands
  Set<String> dependencies(Drawing drawing);

  DrawingCommand markAsCyclic(String cycleDescription);

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
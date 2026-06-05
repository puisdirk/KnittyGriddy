
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
  final List<String> errors;

  const DrawingCommand({
    required this.id,
    required this.label,
    required this.errors,
  });

  DrawingCommand offset(double x, double y);
  Map<String, Object> toJson();
  
  void paint(Canvas canvas, Size size, TextStyle style, Drawing drawing);
  
  DrawingCommand deleteReference({required String commandId});

  DrawingCommand clearValidation();
  DrawingCommand validate(Drawing drawing);
  bool get isValidated;
  // Get the Ids of dependent commands
  Set<String> dependencies(Drawing drawing);
  DrawingCommand markAsCyclic(String cycleDescription);

  @override
  int get hashCode => id.hashCode ^ label.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DrawingCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    listEquals(errors, other.errors);
}
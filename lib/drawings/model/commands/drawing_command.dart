
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

@immutable
abstract class DrawingCommand {
  final String id;
  final String label;

  const DrawingCommand({
    required this.id,
    required this.label,
  });

  DrawingCommand offset(double x, double y);
  Map<String, Object> toJson();
  void paint(Canvas canvas, Size size);
  // All needed fields are filled
  bool get isComplete;
  // We have enough info in the drawing to draw this element
  bool isValid(Drawing drawing);

  @override
  int get hashCode => id.hashCode ^ label.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DrawingCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label;
}
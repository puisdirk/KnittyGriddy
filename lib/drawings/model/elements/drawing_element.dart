
import 'package:flutter/material.dart';

@immutable
abstract class DrawingElement {
  final String label;

  const DrawingElement({
    required this.label,
  });

  DrawingElement offset(double x, double y);
  Map<String, Object> toJson();

  @override
  int get hashCode => super.hashCode ^ label.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DrawingElement &&
    runtimeType == other.runtimeType &&
    label == other.label;
}
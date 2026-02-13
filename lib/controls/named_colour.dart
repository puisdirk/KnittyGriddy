
import 'package:flutter/material.dart';

@immutable
class NamedColour {
  final String name;
  final Color color;
  final bool isMainColor;

  const NamedColour({
    required this.name,
    required this.color,
    this.isMainColor = false
  });

  @override
  int get hashCode => name.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is NamedColour &&
      name == other.name &&
      color == other.color;
}

import 'package:flutter/material.dart';

@immutable
class NamedColour {
  final String name;
  final Color color;

  const NamedColour({
    required this.name,
    required this.color,
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
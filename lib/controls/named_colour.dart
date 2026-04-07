
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

  NamedColour copyWith({
    String? name,
    Color? color,
    bool? isMainColor,
  }) {
    return NamedColour(
      name: name?? this.name, 
      color: color?? this.color,
      isMainColor: isMainColor?? this.isMainColor
    );
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode ^ isMainColor.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is NamedColour &&
      name == other.name &&
      color == other.color &&
      isMainColor == other.isMainColor;
}
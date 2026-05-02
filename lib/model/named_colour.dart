
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

  Map<String, Object> toJson() {
    return {
      'name': name,
      'color': {'red': color.red, 'blue': color.blue, 'green': color.green, 'alpha': color.alpha},
      'ismaincolor': isMainColor ? 1 : 0,
    };
  }

  static NamedColour fromJson(Map<String, dynamic> json) {
    return NamedColour(
      name: json['name'] as String, 
      color: Color.fromARGB(json['alpha'] as int, json['red'] as int, json['green'] as int, json['blue'] as int),
      isMainColor: json['ismaincolor'] as int == 1,
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
import 'dart:convert';

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
      'color': color.value,
      'ismaincolor': isMainColor,
    };
  }

  String get contentHashCode => jsonEncode({
      'color': color.value,
      'ismaincolor': isMainColor,
    });

  static NamedColour fromJson(Map<String, dynamic> json) {
    return NamedColour(
      name: json['name'] as String, 
      color: Color(json['color'] as int),
      isMainColor: json['ismaincolor'] as bool,
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
import 'package:flutter/material.dart';

const String placeholderPatternId = '_placeholder_pattern_id_';
const Pattern placeholderPattern = Pattern(
  id: placeholderPatternId,
  name: placeholderPatternId,
);

@immutable
class Pattern {
  final String id;
  final String name;
  final String description;

  const Pattern({
    required this.id,
    required this.name,
    this.description = '',
  });

  Pattern copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return Pattern(
      id: id?? this.id, 
      name: name?? this.name,
      description: description?? this.description,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is Pattern &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description;

    Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static Pattern fromJson(Map<String, dynamic> json) {
    return Pattern(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
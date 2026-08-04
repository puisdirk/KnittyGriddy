import 'package:flutter/material.dart';

@immutable
class KnittingPatternInfo {
  final String id;
  final String name;
  final String description;

  const KnittingPatternInfo({
    required this.id,
    required this.name,
    this.description = '',
  });

  KnittingPatternInfo copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return KnittingPatternInfo(
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
      other is KnittingPatternInfo &&
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

  static KnittingPatternInfo fromJson(Map<String, dynamic> json) {
    return KnittingPatternInfo(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
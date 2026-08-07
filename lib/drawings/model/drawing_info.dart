import 'package:flutter/foundation.dart';

@immutable
class DrawingInfo {
  final String id;
  final String name;
  final String description;
  final String contentHashCode;

  const DrawingInfo({
    required this.id,
    required this.name,
    this.description = '',
    required this.contentHashCode,
  });

  static const DrawingInfo emptyDrawingInfo = DrawingInfo(id: '', name: '', contentHashCode: '');

  DrawingInfo copyWith({
    String? name,
    String? description,
    String? contentHashCode,
  }) {
    return DrawingInfo(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
      contentHashCode: contentHashCode?? this.contentHashCode,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ch': contentHashCode,
    };
  }

  static DrawingInfo fromJson(Map<String, dynamic> json) {
    return DrawingInfo(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      contentHashCode: json['ch'] as String,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ contentHashCode.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is DrawingInfo &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      contentHashCode == other.contentHashCode;

}
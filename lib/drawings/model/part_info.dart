
import 'package:flutter/foundation.dart';

@immutable
class PartInfo {
  final String id;
  final String drawingId;
  final String name;
  final String previewPath;

  const PartInfo({
    required this.id,
    required this.drawingId,
    required this.name,
    required this.previewPath,
  });

  PartInfo copyWith({
    String? name,
    String? previewPath,
  }) {
    return PartInfo(
      id: id, 
      drawingId: drawingId,
      name: name?? this.name, 
      previewPath: previewPath?? this.previewPath
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PartInfo &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      drawingId == other.drawingId &&
      name == other.name &&
      previewPath == other.previewPath;

  @override
  int get hashCode => id.hashCode ^ drawingId.hashCode ^ name.hashCode ^ previewPath.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drawingid': drawingId,
      'name': name,
      'preview': previewPath,
    };
  }

  static PartInfo fromJson(Map<String, dynamic> json) {
    return PartInfo(
      id: json['id'] as String, 
      drawingId: json['drawingid'] as String,
      name: json['name'] as String, 
      previewPath: json['previewPath'] as String, 
    );
  }

}
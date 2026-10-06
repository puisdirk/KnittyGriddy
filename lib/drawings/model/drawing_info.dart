import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/utils/constants.dart';

@immutable
class DrawingInfo {
  final String id;
  final String name;
  final String description;
  final String contentHashCode;
  final Uint8List? previewImage;

  const DrawingInfo({
    required this.id,
    required this.name,
    this.description = '',
    required this.contentHashCode,
    this.previewImage,
  });

  static const DrawingInfo emptyDrawingInfo = DrawingInfo(id: '', name: '', contentHashCode: '');
  static const double previewImageWidth = 80;
  static const double previewImageHeight = 80;

  DrawingInfo copyWith({
    String? name,
    String? description,
    String? contentHashCode,
    Uint8List? previewImage,
  }) {
    return DrawingInfo(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
      contentHashCode: contentHashCode?? this.contentHashCode,
      previewImage: previewImage?? this.previewImage,
    );
  }

  bool get hasPreview => previewImage != null && previewImage!.isNotEmpty;

  Map<String, Object> toJson() {
    return {
      'objectversion': objectversion,
      'id': id,
      'name': name,
      'description': description,
      'ch': contentHashCode,
      'pi': base64.encode(previewImage?? Uint8List(0))
    };
  }

  static DrawingInfo fromJson(Map<String, dynamic> json) {
    return DrawingInfo(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      contentHashCode: json['ch'] as String,
      previewImage: json.containsKey('pi') ? base64.decode(json['pi'] as String) : null,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ contentHashCode.hashCode ^ previewImage.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is DrawingInfo &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      contentHashCode == other.contentHashCode &&
      previewImage == other.previewImage;

}

import 'package:flutter/foundation.dart';

@immutable
class ChartInfo {
  final String id;
  final String name;
  final String description;
  final String contentHashCode;

  const ChartInfo({
    required this.id,
    required this.name,
    required this.contentHashCode,
    this.description = '',
  });

  static const ChartInfo emptyChartInfo = ChartInfo(id: '', name: '', contentHashCode: '');

  ChartInfo copyWith({
    String? name,
    String? description,
    String? contentHashCode,
  }) {
    return ChartInfo(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
      contentHashCode: contentHashCode?? this.contentHashCode
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ch': contentHashCode
    };
  }

  static ChartInfo fromJson(Map<String, dynamic> json) {
    return ChartInfo(
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
      other is ChartInfo &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      contentHashCode == other.contentHashCode;

}
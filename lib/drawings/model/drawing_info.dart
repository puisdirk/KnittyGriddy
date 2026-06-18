import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';

@immutable
class DrawingInfo {
  final String id;
  final String name;
  final String description;
  final List<PartInfo> partInfos;

  const DrawingInfo({
    required this.id,
    required this.name,
    this.description = '',
    this.partInfos = const[],
  });

  DrawingInfo copyWith({
    String? name,
    String? description,
    List<PartInfo>? partInfos,
  }) {
    return DrawingInfo(
      id: id, 
      name: name?? this.name,
      description: description?? this.description,
      partInfos: partInfos?? this.partInfos,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'partinfos': partInfos.map((pi) => pi.toJson()).toList(),
    };
  }

  static DrawingInfo fromJson(Map<String, dynamic> json) {
    List<PartInfo> pis = [];
    List<Map<String, dynamic>> piObjects = (json['partinfos'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> piObject in piObjects) {
      pis.add(PartInfo.fromJson(piObject));
    }

    return DrawingInfo(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      partInfos: pis,
    );
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ partInfos.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is DrawingInfo &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      listEquals(partInfos, other.partInfos);

}
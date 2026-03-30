
import 'package:flutter/painting.dart';

class KnittingSymbolPath {

  final String name;
  final String path;
  final Offset scale;
  final Offset translation;
  final double rotation;

  const KnittingSymbolPath({
    required this.name,
    required this.path,
    Offset? scale,
    Offset? translation,
    double? rotation,
  }) : scale = scale?? const Offset(1,1), translation = translation?? Offset.zero, rotation = rotation?? 0;
  
  KnittingSymbolPath copyWith({
    String? name,
    String? path,
    Offset? scale,
    Offset? translation,
    double? rotation,
  }) {
    return KnittingSymbolPath(
      name: name?? this.name, 
      path: path?? this.path,
      scale: scale?? this.scale,
      rotation: rotation?? this.rotation,
      translation: translation?? this.translation,
    );
  }

  @override
  int get hashCode => name.hashCode ^ path.hashCode ^ scale.hashCode ^ translation.hashCode ^ rotation.hashCode;
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolPath &&
      name == other.name &&
      path == other.path &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation;
}
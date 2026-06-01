import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';

@immutable
class DrawingsModelObject {

  final Drawing drawing;
  final List<DrawingInfo> drawingInfos;

  const DrawingsModelObject({
    this.drawing = placeholderDrawing,
    this.drawingInfos = const[],
  });

  DrawingsModelObject copyWith({
    Drawing? drawing,
    List<DrawingInfo>? drawingInfos,
  }) {
    return DrawingsModelObject(
      drawing: drawing?? this.drawing,
      drawingInfos: drawingInfos?? this.drawingInfos,
    );
  }

  @override
  int get hashCode => drawing.hashCode ^ drawingInfos.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is DrawingsModelObject &&
      runtimeType == other.runtimeType &&
      drawing == other.drawing &&
      listEquals(drawingInfos, other.drawingInfos);
}

import 'package:flutter/cupertino.dart';
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
}
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';

class DrawingsSaveModelObject {
  final Drawing drawing;
  final List<DrawingInfo> drawingInfos;

  const DrawingsSaveModelObject({
    required this.drawing,
    required this.drawingInfos,
  });

  DrawingsSaveModelObject copyWith({
    Drawing? drawing,
    List<DrawingInfo>? drawingInfos,
  }) {
    return DrawingsSaveModelObject(
      drawing: drawing?? this.drawing, 
      drawingInfos: drawingInfos?? this.drawingInfos,
    );
  }
}
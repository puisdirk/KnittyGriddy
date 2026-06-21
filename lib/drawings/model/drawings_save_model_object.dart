import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';

class DrawingsSaveModelObject {
  final Drawing drawing;
  final List<DrawingInfo> drawingInfos;
  final List<PartSet> partSets;

  const DrawingsSaveModelObject({
    required this.drawing,
    required this.drawingInfos,
    required this.partSets,
  });

  DrawingsSaveModelObject copyWith({
    Drawing? drawing,
    List<DrawingInfo>? drawingInfos,
    List<PartSet>? partSets,
  }) {
    return DrawingsSaveModelObject(
      drawing: drawing?? this.drawing, 
      drawingInfos: drawingInfos?? this.drawingInfos,
      partSets: partSets?? this.partSets,
    );
  }
}
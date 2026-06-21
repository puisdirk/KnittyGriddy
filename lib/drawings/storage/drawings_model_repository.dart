import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';

abstract class DrawingsModelRepository {

  Future<List<DrawingInfo>> loadDrawingInfos();
  Future<void> saveDrawingInfos(List<DrawingInfo> drawingInfos);

  Future<Drawing> loadDrawing(String drawingId);
  Future<void> saveDrawing(Drawing drawing);
  Future<void> deleteDrawing(String drawingId);

  Future<void> exportDrawing(Drawing drawing);
  Future<Drawing?> importDrawing();

  Future<List<PartSet>> loadPartSets();
  Future<void> savePartSets(List<PartSet> partSets);

  Future<void> exportPartSet(PartSet partSet);
  Future<PartSet?> importPartSet();

  Future<void> exportPartDrawing(PartDrawing partDrawing);
  Future<PartDrawing?> importPartDrawing();
}
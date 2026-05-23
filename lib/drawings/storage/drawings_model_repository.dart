import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';

abstract class DrawingsModelRepository {

  Future<List<DrawingInfo>> loadDrawingInfos();
  Future<void> saveDrawingInfos(List<DrawingInfo> drawingInfos);

  Future<Drawing> loadDrawing(String drawingId);
  Future<void> saveDrawing(Drawing drawing);
  Future<void> deleteDrawing(String drawingId);

  Future<void> exportDrawing(Drawing drawing);
  Future<Drawing?> importDrawing();
}
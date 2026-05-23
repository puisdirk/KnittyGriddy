
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';

class DrawingsNoOpModelRepository implements DrawingsModelRepository {

  const DrawingsNoOpModelRepository();

  @override
  Future<void> deleteDrawing(String drawingId) async {
  }

  @override
  Future<void> exportDrawing(Drawing drawing) async {
  }

  @override
  Future<Drawing?> importDrawing() async {
    return null;
  }

  @override
  Future<Drawing> loadDrawing(String drawingId) async {
    return const Drawing(id: 'default', name: 'default');
  }

  @override
  Future<List<DrawingInfo>> loadDrawingInfos() async {
    return [];
  }

  @override
  Future<void> saveDrawing(Drawing drawing) async {
  }

  @override
  Future<void> saveDrawingInfos(List<DrawingInfo> drawingInfos) async {
  }
}
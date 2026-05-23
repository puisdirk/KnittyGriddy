
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';

class DrawingsInMemoryModelRepository implements DrawingsModelRepository {
  List<DrawingInfo> drawingInfos = [];
  List<Drawing> drawings = [];
  

  @override
  Future<void> deleteDrawing(String drawingId) async {
    drawingInfos = drawingInfos.where((p) => p.id != drawingId).toList();
  }

  @override
  Future<Drawing> loadDrawing(String chartId) async {
    return drawings.firstWhere((p) => p.id == chartId);
  }

  @override
  Future<List<DrawingInfo>> loadDrawingInfos() async {
    return drawingInfos;
  }

  @override
  Future<void> saveDrawing(Drawing drawing) async {
    if (drawings.any((p) => p.id == drawing.id)) {
      drawings = drawings.map((p) => p.id == drawing.id ? drawing : p).toList();
    } else {
      drawings.add(drawing);
    }
  }

  @override
  Future<void> saveDrawingInfos(List<DrawingInfo> drawingInfos) async {
    drawingInfos = drawingInfos;
  }

  @override
  Future<void> exportDrawing(Drawing drawing) async {
    Map<String, Object> jsonObject = drawing.toJson();
    try {
      String jsonString = jsonEncode(jsonObject);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${drawing.name}.kgd',
        bytes: utf8.encode(jsonString),
      );
    } catch (e) {
      debugPrint('Error while exporting drawing: $e');
    }
  }

  @override
  Future<Drawing?> importDrawing() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a drawing (kgd)',
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        Drawing drawing = Drawing.fromJson(jsonObject);
        return drawing;
      } catch (e) {
        debugPrint('Error while importing drawing: $e');
      }
    }

    return null;
  }
}
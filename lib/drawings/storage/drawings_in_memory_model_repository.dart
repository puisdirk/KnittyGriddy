
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';

class DrawingsInMemoryModelRepository implements DrawingsModelRepository {
  List<DrawingInfo> drawingInfos = [];
  List<Drawing> drawings = [];
  List<PartSet> partSets = [];

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
  
  @override
  Future<void> exportPartDrawing(PartDrawing partDrawing) async {
    Map<String, Object> jsonObject = partDrawing.toJson();
    try {
      String jsonString = jsonEncode(jsonObject);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${partDrawing.name}.kpd',
        bytes: utf8.encode(jsonString),
      );
    } catch (e) {
      debugPrint('Error while exporting part drawing: $e');
    }
  }

  @override
  Future<PartDrawing?> importPartDrawing() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a drawing (kpd)',
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        PartDrawing partdrawing = PartDrawing.fromJson(jsonObject);
        return partdrawing;
      } catch (e) {
        debugPrint('Error while importing part drawing: $e');
      }
    }

    return null;
  }
  
  @override
  Future<List<PartSet>> loadPartSets() async {
    return [];
  }
  
  @override
  Future<void> savePartSets(List<PartSet> partSets) async {
    partSets = List.from(partSets);
  }

  @override
  Future<void> exportPartSet(PartSet partSet) async {
  Map<String, Object> jsonObject = partSet.toJson();

    try {
      String jsonString = jsonEncode(jsonObject);

      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${partSet.name}.kps',
        bytes: utf8.encode(jsonString),
      );
    } catch(e) {
      debugPrint('Error while exporting PartSet: $e');
    }  }
  
  @override
  Future<PartSet?> importPartSet() async {
    // Doesn't seem to work on web?
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a part set (kps)',
      allowMultiple: false,
//      allowedExtensions: ['kps'],
      withData: true
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        PartSet partSet = PartSet.fromJson(jsonObject);
        return partSet;
      } catch (e) {
        debugPrint('Error while importing part set: $e');
      }
    }

    return null;
  }
    
}
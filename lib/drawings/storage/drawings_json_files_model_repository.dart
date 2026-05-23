
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';

import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DrawingsJsonFilesModelRepository implements DrawingsModelRepository {

  String? appDirectoryPath;
  final JsonCodec codec = json;

  DrawingsJsonFilesModelRepository();

  Future<void> _initAppDirectoryPath() async {
    if (appDirectoryPath == null) {
      Directory appDocs = await getApplicationDocumentsDirectory();
      Directory dir = Directory(p.join(appDocs.path, 'KnittyGriddy', 'Drawings'));
      appDirectoryPath = dir.path;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
  }

  @override
  Future<List<DrawingInfo>> loadDrawingInfos() async {
    await _initAppDirectoryPath();
    
    List<DrawingInfo> infos = [];

    File infosFile = File(p.join(appDirectoryPath!, 'drawingInfos.json'));

    // Set to true for a clean slate
    bool deletePrevious = false;

    // ignore: dead_code
    if (deletePrevious) {
     if (infosFile.existsSync()) {
          infosFile.deleteSync();
          infosFile = File(p.join(appDirectoryPath!, 'drawingInfos.json'));
        }
        Directory dir = Directory(appDirectoryPath!);
        List<FileSystemEntity> files = dir.listSync();
        for (FileSystemEntity potentialfile in files) {
          potentialfile.deleteSync();
        }
    }

    if (infosFile.existsSync()) {
      String jsonContents = infosFile.readAsStringSync();
    
      try {
        Map<String, dynamic> jsonObject = jsonDecode(jsonContents);

        if (jsonObject.containsKey('drawingInfos')) {
          List<Map<String, dynamic>> drawingInfoObjects = 
            (jsonObject['drawingInfos'] as List).map((e) => e as Map<String, dynamic>).toList();
          for (Map<String, dynamic> drawingInfoObject in drawingInfoObjects) {
            infos.add(DrawingInfo.fromJson(drawingInfoObject));
          }
        }
      } catch (e) {
        debugPrint('Error while loading drawingInfos: $e');
      }
    }

    return infos;
  }

  @override
  Future<void> saveDrawingInfos(List<DrawingInfo> drawingInfos) async {
    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = {'drawingInfos': drawingInfos.map((pi) => pi.toJson()).toList()};
    try {
      String jsonString = codec.encode(jsonObject);
      File infosFile =  File(p.join(appDirectoryPath!, 'drawingInfos.json'));
      infosFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error while saving drawingInfos: $e');
    }
  }
  
  @override
  Future<Drawing> loadDrawing(String drawingId) async {
    await _initAppDirectoryPath();

    File drawingFile = File(p.join(appDirectoryPath!, '$drawingId.json'));
    if (!drawingFile.existsSync()) {
      throw Exception('Error in loadDrawing: drawing file ${drawingFile.path} does not exist');
    }
    try {
      String jsonString = drawingFile.readAsStringSync();
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return Drawing.fromJson(jsonObject);
    } catch(e) {
      throw Exception('Error in loadDrawing: $e');
    }
  }
  
  @override
  Future<void> saveDrawing(Drawing drawing) async {
    if (drawing.id == placeholderDrawingId) {
      return;
    }

    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = drawing.toJson();

    try {
      String jsonString = codec.encode(jsonObject);
      File drawingFile = File(p.join(appDirectoryPath!, '${drawing.id}.json'));
      drawingFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error in saveDrawing: $e');
    }
  }
  
  @override
  Future<void> deleteDrawing(String drawingId) async {
    await _initAppDirectoryPath();

    File drawingFile = File(p.join(appDirectoryPath!, '$drawingId.json'));
    drawingFile.deleteSync();

  }

  @override
  Future<Drawing?> importDrawing() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a Drawing',
      allowMultiple: false,
      allowedExtensions: ['kgd'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        Drawing drawing = Drawing.fromJson(jsonObject);
        return drawing;
      } catch (e) {
        debugPrint('Error while importing Drawing: $e');
      }
    }

    return null;
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
    } catch(e) {
      debugPrint('Error while exporting Drawing: $e');
    }

  }
}
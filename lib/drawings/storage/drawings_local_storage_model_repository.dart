import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawingsLocalStorageModelRepository implements DrawingsModelRepository {
  final String drawingInfosKey = 'kg_dik';
  final JsonCodec codec = json;

  @override
  Future<List<DrawingInfo>> loadDrawingInfos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? infosJson = prefs.getString(drawingInfosKey);
    if (infosJson == null) return [];

    List<DrawingInfo> infos = [];

    try {
      Map<String, dynamic> jsonObject = jsonDecode(infosJson);

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

    return infos;
  }

  @override
  Future<void> saveDrawingInfos(List<DrawingInfo> drawingInfos) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, Object> jsonObject = {'drawingInfos': drawingInfos.map((pi) => pi.toJson()).toList()};
    try {
      String jsonString = codec.encode(jsonObject);
      prefs.setString(drawingInfosKey, jsonString);
    } catch (e) {
      debugPrint('Error while saving drawingInfos: $e');
    }
  }

  @override
  Future<Drawing> loadDrawing(String drawingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? jsonString = prefs.getString(drawingId);
    if (jsonString == null) throw Exception('Error in loadDrawing: drawing key $drawingId does not exist');

    try {
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return Drawing.fromJson(jsonObject);
    } catch(e) {
      throw Exception('Error in loadDrawing: $e');
    }
  }

  @override
  Future<void> saveDrawing(Drawing drawing) async {
    if (drawing.id == placeholderDrawingId) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, Object> jsonObject = drawing.toJson();

    try {
      String jsonString = codec.encode(jsonObject);
      prefs.setString(drawing.id, jsonString);
    } catch (e) {
      debugPrint('Error in saveDrawing: $e');
    }
  }

  @override
  Future<void> deleteDrawing(String drawingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(drawingId);
  }

  @override
  Future<Drawing?> importDrawing() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a Drawing (kgd)',
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
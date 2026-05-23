
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/model/pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_info.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';

class PatternsInMemoryModelRepository implements PatternsModelRepository {
  List<PatternInfo> patternInfos = [];
  List<Pattern> patterns = [];
  

  @override
  Future<void> deletePattern(String patternId) async {
    patternInfos = patternInfos.where((p) => p.id != patternId).toList();
  }

  @override
  Future<Pattern> loadPattern(String chartId) async {
    return patterns.firstWhere((p) => p.id == chartId);
  }

  @override
  Future<List<PatternInfo>> loadPatternInfos() async {
    return patternInfos;
  }

  @override
  Future<void> savePattern(Pattern pattern) async {
    if (patterns.any((p) => p.id == pattern.id)) {
      patterns = patterns.map((p) => p.id == pattern.id ? pattern : p).toList();
    } else {
      patterns.add(pattern);
    }
  }

  @override
  Future<void> savePatternInfos(List<PatternInfo> patternInfos) async {
    patternInfos = patternInfos;
  }

  @override
  Future<void> exportPattern(Pattern pattern) async {
    Map<String, Object> jsonObject = pattern.toJson();
    try {
      String jsonString = jsonEncode(jsonObject);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${pattern.name}.kgd',
        bytes: utf8.encode(jsonString),
      );
    } catch (e) {
      debugPrint('Error while exporting pattern: $e');
    }
  }

  @override
  Future<Pattern?> importPattern() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a pattern (kgd)',
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        Pattern pattern = Pattern.fromJson(jsonObject);
        return pattern;
      } catch (e) {
        debugPrint('Error while importing pattern: $e');
      }
    }

    return null;
  }
}
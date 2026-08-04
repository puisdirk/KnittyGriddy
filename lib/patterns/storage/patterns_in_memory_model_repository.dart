
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';
import 'package:knitty_griddy/patterns/model/pattern_operation_exception.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';

class PatternsInMemoryModelRepository implements PatternsModelRepository {
  List<KnittingPatternInfo> patternInfos = [];
  List<KnittingPattern> patterns = [];
  

  @override
  Future<void> deletePattern(String patternId) async {
    patternInfos = patternInfos.where((p) => p.id != patternId).toList();
  }

  @override
  Future<KnittingPattern> loadPattern(String chartId) async {
    return patterns.firstWhere((p) => p.id == chartId);
  }

  @override
  Future<List<KnittingPatternInfo>> loadPatternInfos() async {
    return patternInfos;
  }

  @override
  Future<void> savePattern(KnittingPattern pattern) async {
    if (patterns.any((p) => p.id == pattern.id)) {
      patterns = patterns.map((p) => p.id == pattern.id ? pattern : p).toList();
    } else {
      patterns.add(pattern);
    }
  }

  @override
  Future<void> savePatternInfos(List<KnittingPatternInfo> patternInfos) async {
    patternInfos = patternInfos;
  }

  @override
  Future<void> exportPattern(KnittingPattern pattern) async {
    Map<String, Object> jsonObject = pattern.toJson();
    try {
      String jsonString = jsonEncode(jsonObject);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${pattern.name}.kgp',
        bytes: utf8.encode(jsonString),
      );
    } catch (e) {
      throw PatternOperationException(message: 'Error while exporting pattern: $e');
    }
  }

  @override
  Future<KnittingPattern?> importPattern() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a pattern (kgp)',
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        KnittingPattern pattern = KnittingPattern.fromJson(jsonObject);
        return pattern;
      } catch (e) {
        throw PatternOperationException(message: 'Error while importing pattern: $e');
      }
    }

    return null;
  }
}
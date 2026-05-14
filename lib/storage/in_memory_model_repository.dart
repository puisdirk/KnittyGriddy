
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class InMemoryModelRepository implements ModelRepository {
  List<KnittingPattern> patterns = [];
  List<PatternInfo> patternInfos = [];
  List<StitchesSet> stitchSets = [];

  @override
  Future<void> deletePattern(String patternId) async {
    patternInfos = patternInfos.where((p) => p.id != patternId).toList();
  }

  @override
  Future<KnittingPattern> loadPattern(String patternId) async {
    return patterns.firstWhere((p) => p.id == patternId);
  }

  @override
  Future<List<PatternInfo>> loadPatternInfos() async {
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
  Future<void> savePatternInfos(List<PatternInfo> patternInfos) async {
    patternInfos = patternInfos;
  }

  @override
  Future<List<StitchesSet>> loadStitchSets() async {
    return [];
  }

  @override
  Future<void> saveStitchSets(List<StitchesSet> stitchSets) async {
    stitchSets = List.from(stitchSets);
  }

  @override
  Future<void> exportStitchesSet(StitchesSet stitchSet) async {
    Map<String, Object> jsonObject = stitchSet.toJson();

    try {
      String jsonString = jsonEncode(jsonObject);

      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${stitchSet.name}.sts',
        bytes: utf8.encode(jsonString),
      );
    } catch(e) {
      debugPrint('Error while exporting StitchesSet: $e');
    }
  }
  
  @override
  Future<StitchesSet?> importStitchesSet() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a stitches set (sts)',
      allowMultiple: false,
      allowedExtensions: ['sts'],
    );

    if (result != null && result.files.isNotEmpty) {
      
    }
  }
}
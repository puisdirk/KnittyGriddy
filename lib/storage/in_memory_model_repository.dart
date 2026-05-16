
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class InMemoryModelRepository implements ModelRepository {
  List<KnittingPattern> patterns = [];
  List<PatternInfo> patternInfos = [];
  List<StitchSet> stitchSets = [];

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
  Future<List<StitchSet>> loadStitchSets() async {
    return [];
  }

  @override
  Future<void> saveStitchSets(List<StitchSet> stitchSets) async {
    stitchSets = List.from(stitchSets);
  }

  @override
  Future<void> exportStitchesSet(StitchSet stitchSet) async {
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
  Future<StitchSet?> importStitchesSet() async {
    // Doesn't seem to work on web?
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a stitches set (sts)',
      allowMultiple: false,
//      allowedExtensions: ['sts'],
      withData: true
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        StitchSet stitchSet = StitchSet.fromJson(jsonObject);
        return stitchSet;
      } catch (e) {
        debugPrint('Error while importing stitches set: $e');
      }
    }

    return null;
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
      debugPrint('Error while exporting pattern: $e');
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
        debugPrint('Error while importing pattern: $e');
      }
    }

    return null;
  }
}
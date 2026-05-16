
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/storage/model_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class JsonFilesModelRepository implements ModelRepository {

  String? appDirectoryPath;
  final JsonCodec codec = json;

  JsonFilesModelRepository();

  Future<void> _initAppDirectoryPath() async {
    if (appDirectoryPath == null) {
      Directory appDocs = await getApplicationDocumentsDirectory();
      Directory dir = Directory(p.join(appDocs.path, 'KnittyGriddy'));
      appDirectoryPath = dir.path;
      if (!dir.existsSync()) {
        dir.createSync();
      }
    }
  }

  @override
  Future<List<PatternInfo>> loadPatternInfos() async {
    await _initAppDirectoryPath();
    
    List<PatternInfo> infos = [];

    File infosFile = File(p.join(appDirectoryPath!, 'patternInfos.json'));

    // Set to true for a clean slate
    bool deletePrevious = false;

    // ignore: dead_code
    if (deletePrevious) {
     if (infosFile.existsSync()) {
          infosFile.deleteSync();
          infosFile = File(p.join(appDirectoryPath!, 'patternInfos.json'));
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

        if (jsonObject.containsKey('patternInfos')) {
          List<Map<String, dynamic>> patternInfoObjects = 
            (jsonObject['patternInfos'] as List).map((e) => e as Map<String, dynamic>).toList();
          for (Map<String, dynamic> patternInfoObject in patternInfoObjects) {
            infos.add(PatternInfo.fromJson(patternInfoObject));
          }
        }
      } catch (e) {
        debugPrint('Error while loading patternInfos: $e');
      }
    }

    return infos;
  }

  @override
  Future<void> savePatternInfos(List<PatternInfo> patternInfos) async {
    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = {'patternInfos': patternInfos.map((pi) => pi.toJson()).toList()};
    try {
      String jsonString = codec.encode(jsonObject);
      File infosFile =  File(p.join(appDirectoryPath!, 'patternInfos.json'));
      infosFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error while saving patternInfos: $e');
    }
  }
  
  @override
  Future<KnittingPattern> loadPattern(String patternId) async {
    await _initAppDirectoryPath();

    File patternFile = File(p.join(appDirectoryPath!, '$patternId.json'));
    if (!patternFile.existsSync()) {
      throw Exception('Error in loadPattern: Pattern file ${patternFile.path} does not exist');
    }
    try {
      String jsonString = patternFile.readAsStringSync();
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return KnittingPattern.fromJson(jsonObject);
    } catch(e) {
      throw Exception('Error in loadPattern: $e');
    }
  }
  
  @override
  Future<void> savePattern(KnittingPattern pattern) async {
    if (pattern.id == placeholderPatternId) {
      return;
    }

    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = pattern.toJson();

    try {
      String jsonString = codec.encode(jsonObject);
      File patternFile = File(p.join(appDirectoryPath!, '${pattern.id}.json'));
      patternFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error in savePattern: $e');
    }
  }
  
  @override
  Future<void> deletePattern(String patternId) async {
    await _initAppDirectoryPath();

    File patternFile = File(p.join(appDirectoryPath!, '$patternId.json'));
    patternFile.deleteSync();

  }

  @override
  Future<List<StitchSet>> loadStitchSets() async {
    await _initAppDirectoryPath();

    List<StitchSet> sets = [];

    File stitchSetsFile = File(p.join(appDirectoryPath!, 'stitchSets.json'));

    if (stitchSetsFile.existsSync()) {
      String jsonContents = stitchSetsFile.readAsStringSync();

      try {
        Map<String, dynamic> jsonObject = jsonDecode(jsonContents);

        if (jsonObject.containsKey('stitchSets')) {
          List<Map<String, dynamic>> stitchSetObjects = 
            (jsonObject['stitchSets'] as List).map((s) => s as Map<String, dynamic>).toList();
          for (Map<String, dynamic> stitchSetObject in stitchSetObjects) {
            sets.add(StitchSet.fromJson(stitchSetObject));
          }
        }
      } catch (e) {
        debugPrint('Error while loading custom stitch sets: $e');
      }
    }

    return sets;
  }

  @override
  Future<void> saveStitchSets(List<StitchSet> stitchSets) async {
    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = {'stitchSets': stitchSets.map((s) => s.toJson()).toList()};
    try {
      String jsonString = codec.encode(jsonObject);
      File stitchSetsFile = File(p.join(appDirectoryPath!, 'stitchSets.json'));
      stitchSetsFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error while saving stitch sets: $e');
    }
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a stitches set (sts)',
      allowMultiple: false,
      allowedExtensions: ['sts'],
      withData: true,
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
  Future<KnittingPattern?> importPattern() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a pattern',
      allowMultiple: false,
      allowedExtensions: ['kgp'],
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
    } catch(e) {
      debugPrint('Error while exporting pattern: $e');
    }

  }
}
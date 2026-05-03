
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
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
        debugPrint('$e');
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
      debugPrint('$e');
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
      debugPrint('$e');
    }
  }
  
  @override
  Future<void> deletePattern(String patternId) async {
    await _initAppDirectoryPath();

    File patternFile = File(p.join(appDirectoryPath!, '$patternId.json'));
    patternFile.deleteSync();

  }

  @override
  Future<List<StitchDefinition>> loadCustomstitches() async {
    await _initAppDirectoryPath();

    List<StitchDefinition> stitches = [];

    File customStitchesFile = File(p.join(appDirectoryPath!, 'customstitches.json'));

    if (customStitchesFile.existsSync()) {
      String jsonContents = customStitchesFile.readAsStringSync();

      try {
        Map<String, dynamic> jsonObject = jsonDecode(jsonContents);

        if (jsonObject.containsKey('customstitches')) {
          List<Map<String, dynamic>> stitchObjects = 
            (jsonObject['customstitches'] as List).map((e) => e as Map<String, dynamic>).toList();
          for (Map<String, dynamic> stitchObject in stitchObjects) {
            stitches.add(StitchDefinition.fromJson(stitchObject));
          }
        }
      } catch(e) {
        debugPrint('$e');
      }
    }

    return stitches;
  }
  
  @override
  Future<void> saveCustomstitches(List<StitchDefinition> stitches) async {
    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = {'customstitches': stitches.map((s) => s.toJson()).toList()};

    try {
      String jsonString = codec.encode(jsonObject);
      File customStitchesFile = File(p.join(appDirectoryPath!, 'customstitches.json'));
      customStitchesFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('$e');
    }
  }

}
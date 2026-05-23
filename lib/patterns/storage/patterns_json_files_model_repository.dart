
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/patterns/model/pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_info.dart';

import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PatternsJsonFilesModelRepository implements PatternsModelRepository {

  String? appDirectoryPath;
  final JsonCodec codec = json;

  PatternsJsonFilesModelRepository();

  Future<void> _initAppDirectoryPath() async {
    if (appDirectoryPath == null) {
      Directory appDocs = await getApplicationDocumentsDirectory();
      Directory dir = Directory(p.join(appDocs.path, 'KnittyGriddy', 'Patterns'));
      appDirectoryPath = dir.path;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
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
  Future<Pattern> loadPattern(String patternId) async {
    await _initAppDirectoryPath();

    File patternFile = File(p.join(appDirectoryPath!, '$patternId.json'));
    if (!patternFile.existsSync()) {
      throw Exception('Error in loadPattern: pattern file ${patternFile.path} does not exist');
    }
    try {
      String jsonString = patternFile.readAsStringSync();
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return Pattern.fromJson(jsonObject);
    } catch(e) {
      throw Exception('Error in loadPattern: $e');
    }
  }
  
  @override
  Future<void> savePattern(Pattern pattern) async {
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
  Future<Pattern?> importPattern() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a Pattern',
      allowMultiple: false,
      allowedExtensions: ['kgd'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        Pattern pattern = Pattern.fromJson(jsonObject);
        return pattern;
      } catch (e) {
        debugPrint('Error while importing Pattern: $e');
      }
    }

    return null;
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
    } catch(e) {
      debugPrint('Error while exporting Pattern: $e');
    }

  }
}
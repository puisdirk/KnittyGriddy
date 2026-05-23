
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ChartsJsonFilesModelRepository implements ChartsModelRepository {

  String? appDirectoryPath;
  final JsonCodec codec = json;

  ChartsJsonFilesModelRepository();

  Future<void> _initAppDirectoryPath() async {
    if (appDirectoryPath == null) {
      Directory appDocs = await getApplicationDocumentsDirectory();
      Directory dir = Directory(p.join(appDocs.path, 'KnittyGriddy', 'Charts'));
      appDirectoryPath = dir.path;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
  }

  @override
  Future<List<ChartInfo>> loadChartInfos() async {
    await _initAppDirectoryPath();
    
    List<ChartInfo> infos = [];

    File infosFile = File(p.join(appDirectoryPath!, 'chartInfos.json'));

    // Set to true for a clean slate
    bool deletePrevious = false;

    // ignore: dead_code
    if (deletePrevious) {
     if (infosFile.existsSync()) {
          infosFile.deleteSync();
          infosFile = File(p.join(appDirectoryPath!, 'chartInfos.json'));
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

        if (jsonObject.containsKey('chartInfos')) {
          List<Map<String, dynamic>> chartInfoObjects = 
            (jsonObject['chartInfos'] as List).map((e) => e as Map<String, dynamic>).toList();
          for (Map<String, dynamic> chartInfoObject in chartInfoObjects) {
            infos.add(ChartInfo.fromJson(chartInfoObject));
          }
        }
      } catch (e) {
        debugPrint('Error while loading chartInfos: $e');
      }
    }

    return infos;
  }

  @override
  Future<void> saveChartInfos(List<ChartInfo> chartInfos) async {
    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = {'chartInfos': chartInfos.map((pi) => pi.toJson()).toList()};
    try {
      String jsonString = codec.encode(jsonObject);
      File infosFile =  File(p.join(appDirectoryPath!, 'chartInfos.json'));
      infosFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error while saving chartInfos: $e');
    }
  }
  
  @override
  Future<KnittingChart> loadChart(String chartId) async {
    await _initAppDirectoryPath();

    File chartFile = File(p.join(appDirectoryPath!, '$chartId.json'));
    if (!chartFile.existsSync()) {
      throw Exception('Error in loadChart: chart file ${chartFile.path} does not exist');
    }
    try {
      String jsonString = chartFile.readAsStringSync();
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return KnittingChart.fromJson(jsonObject);
    } catch(e) {
      throw Exception('Error in loadChart: $e');
    }
  }
  
  @override
  Future<void> saveChart(KnittingChart chart) async {
    if (chart.id == placeholderChartId) {
      return;
    }

    await _initAppDirectoryPath();

    Map<String, Object> jsonObject = chart.toJson();

    try {
      String jsonString = codec.encode(jsonObject);
      File chartFile = File(p.join(appDirectoryPath!, '${chart.id}.json'));
      chartFile.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint('Error in saveChart: $e');
    }
  }
  
  @override
  Future<void> deleteChart(String chartId) async {
    await _initAppDirectoryPath();

    File chartFile = File(p.join(appDirectoryPath!, '$chartId.json'));
    chartFile.deleteSync();

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
  Future<KnittingChart?> importChart() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Load a chart',
      allowMultiple: false,
      allowedExtensions: ['kgc'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        String jsonString = utf8.decode(result.files.first.bytes!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        KnittingChart chart = KnittingChart.fromJson(jsonObject);
        return chart;
      } catch (e) {
        debugPrint('Error while importing chart: $e');
      }
    }

    return null;
  }

  @override
  Future<void> exportChart(KnittingChart chart) async {
    Map<String, Object> jsonObject = chart.toJson();

    try {
      String jsonString = jsonEncode(jsonObject);

      await FilePicker.platform.saveFile(
        dialogTitle: 'Where do you want to store the output?',
        fileName: '${chart.name}.kgc',
        bytes: utf8.encode(jsonString),
      );
    } catch(e) {
      debugPrint('Error while exporting chart: $e');
    }

  }
}
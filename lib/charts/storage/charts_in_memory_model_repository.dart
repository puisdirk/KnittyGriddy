
import 'dart:convert';

import 'package:knitty_griddy/charts/model/chart_operation_exception.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';
import 'package:knitty_griddy/common/file_system.dart';

class ChartsInMemoryModelRepository implements ChartsModelRepository {
  List<KnittingChart> charts = [];
  List<ChartInfo> chartInfos = [];
  List<StitchSet> stitchSets = [];

  @override
  Future<void> deleteChart(String chartId) async {
    chartInfos = chartInfos.where((p) => p.id != chartId).toList();
  }

  @override
  Future<KnittingChart> loadChart(String chartId) async {
    return charts.firstWhere((p) => p.id == chartId);
  }

  @override
  Future<List<ChartInfo>> loadChartInfos() async {
    return chartInfos;
  }

  @override
  Future<void> saveChart(KnittingChart chart) async {
    if (charts.any((p) => p.id == chart.id)) {
      charts = charts.map((p) => p.id == chart.id ? chart : p).toList();
    } else {
      charts.add(chart);
    }
  }

  @override
  Future<void> saveChartInfos(List<ChartInfo> chartInfos) async {
    chartInfos = chartInfos;
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

      await FileSystem.saveFile(
        prompt: 'Where do you want to store the output?',
        filename: '${stitchSet.name}.sts',
        bytes: utf8.encode(jsonString)
      );
    } catch(e) {
      throw ChartOperationException(message: 'Error while exporting StitchesSet: $e');
    }
  }
  
  @override
  Future<StitchSet?> importStitchesSet() async {
    PickFileResult result = await FileSystem.pickFile(
      prompt: 'Load a stitches set (.sts)', 
      extensions: ['sts']);

    if (result.resultType == PickFileResultType.incorrectExtension) {
      throw ChartOperationException(message: '${result.filename} is not a stitch set (.sts)');
    }

    if (result.resultType == PickFileResultType.success) {
      try {
        String jsonString = utf8.decode(result.data!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        StitchSet stitchSet = StitchSet.fromJson(jsonObject);
        return stitchSet;
      } catch (e) {
        throw ChartOperationException(message: 'Error while importing stitch set: $e');
      }
    }

    return null;
  }

  @override
  Future<void> exportChart(KnittingChart chart) async {
    Map<String, Object> jsonObject = chart.toJson();
    try {
      String jsonString = jsonEncode(jsonObject);
      await FileSystem.saveFile(
        prompt: 'Where do you want to store the output?',
        filename: '${chart.name}.kgc',
        bytes: utf8.encode(jsonString),
      );
    } catch (e) {
      throw ChartOperationException(message: 'Error while exporting chart: $e');
    }
  }

  @override
  Future<KnittingChart?> importChart() async {
    PickFileResult result = await FileSystem.pickFile(
      prompt: 'Load a chart (kgc)',
      extensions: ['kgc']
    );

    if (result.resultType == PickFileResultType.incorrectExtension) {
      throw ChartOperationException(message: '${result.filename} is not a Chart (.kgc)');
    }

    if (result.resultType == PickFileResultType.success) {
      try {
        String jsonString = utf8.decode(result.data!);
        Map<String, dynamic> jsonObject = jsonDecode(jsonString);
        KnittingChart chart = KnittingChart.fromJson(jsonObject);
        return chart;
      } catch (e) {
        throw ChartOperationException(message: 'Error while importing chart: $e');
      }
    }

    return null;
  }
}
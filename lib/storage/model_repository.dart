
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitting_chart.dart';
import 'package:knitty_griddy/model/chart_info.dart';

abstract class ModelRepository {

  Future<List<ChartInfo>> loadChartInfos();
  Future<void> saveChartInfos(List<ChartInfo> chartInfos);

  Future<KnittingChart> loadChart(String chartId);
  Future<void> saveChart(KnittingChart chart);
  Future<void> deleteChart(String chartId);

  Future<void> exportChart(KnittingChart chart);
  Future<KnittingChart?> importChart();

  Future<List<StitchSet>> loadStitchSets();
  Future<void> saveStitchSets(List<StitchSet> stitchSets);

  Future<void> exportStitchesSet(StitchSet stitchSet);
  Future<StitchSet?> importStitchesSet();
}
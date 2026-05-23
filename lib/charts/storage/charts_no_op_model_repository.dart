
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/chart_settings.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';

class ChartsNoOpModelRepository implements ChartsModelRepository {

  const ChartsNoOpModelRepository();

  @override
  Future<List<ChartInfo>> loadChartInfos() async {
    return [];
  }

    @override
  Future<KnittingChart> loadChart(String chartId) async {
    return const KnittingChart(id: 'default', name: 'default', chartSettings: ChartSettings(rows: 10, columns: 10, gridType: GridType.flat));
  }

  @override
  Future<void> saveChart(KnittingChart chart) async {
  }
  
  @override
  Future<void> saveChartInfos(List<ChartInfo> chartInfos) async {
  }

  @override
  Future<void> deleteChart(String chartId) async {
  }

  @override
  Future<List<StitchSet>> loadStitchSets() async {
    return [];
  }

  @override
  Future<void> saveStitchSets(List<StitchSet> stitchSets) async {
  }

  @override
  Future<void> exportStitchesSet(StitchSet stitchSet) async {
  }
  
  @override
  Future<StitchSet?> importStitchesSet() async {
    return null;
  }
  
  @override
  Future<KnittingChart?> importChart() async {
    return null;
  }
  
  @override
  Future<void> exportChart(KnittingChart chart) async {
  }
}
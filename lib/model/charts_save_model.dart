import 'package:flutter/cupertino.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/charts_model.dart';
import 'package:knitty_griddy/model/knitting_chart.dart';
import 'package:knitty_griddy/model/chart_info.dart';

@immutable
class ChartsSaveModel {
  final KnittingChart knittingChart;
  final List<ChartInfo> chartInfos;
  final List<StitchSet> stitchSets;

  const ChartsSaveModel({
    required this.knittingChart,
    required this.chartInfos,
    required this.stitchSets,
  });

  ChartsSaveModel copyWith({
    ChartsModel? griddyModel,
    List<StitchSet>? stitchSets,
  }) {
    return ChartsSaveModel(
      knittingChart: griddyModel?.knittingChart?? knittingChart, 
      chartInfos: griddyModel?.chartInfos?? chartInfos, 
      stitchSets: stitchSets?? this.stitchSets,
    );
  }
}
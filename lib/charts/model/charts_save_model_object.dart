import 'package:flutter/cupertino.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/charts_model_object.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';

@immutable
class ChartsSaveModelObject {
  final KnittingChart knittingChart;
  final List<ChartInfo> chartInfos;
  final List<StitchSet> stitchSets;

  const ChartsSaveModelObject({
    required this.knittingChart,
    required this.chartInfos,
    required this.stitchSets,
  });

  ChartsSaveModelObject copyWith({
    ChartsModelObject? griddyModel,
    List<StitchSet>? stitchSets,
  }) {
    return ChartsSaveModelObject(
      knittingChart: griddyModel?.knittingChart?? knittingChart, 
      chartInfos: griddyModel?.chartInfos?? chartInfos, 
      stitchSets: stitchSets?? this.stitchSets,
    );
  }
}
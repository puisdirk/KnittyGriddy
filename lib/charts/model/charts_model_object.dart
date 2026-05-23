
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/app_state.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';

@immutable
class ChartsModelObject {

  final KnittingChart knittingChart;
  final AppState appState;
  final List<ChartInfo> chartInfos;

  const ChartsModelObject({
    this.knittingChart = placeholderChart,
    this.appState = const AppState(),
    this.chartInfos = const[],
  });

  ChartsModelObject copyWith({
    KnittingChart? knittingChart,
    AppState? appState,
    List<StitchDefinition>? customStitches,
    List<ChartInfo>? chartInfos,
  }) {
    return ChartsModelObject(
      knittingChart: knittingChart?? this.knittingChart,
      appState: appState?? this.appState,
      chartInfos: chartInfos?? this.chartInfos,
    );
  }

}
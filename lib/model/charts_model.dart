
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/chart_info.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';

@immutable
class ChartsModel {

  final KnittingChart knittingChart;
  final AppState appState;
  final List<ChartInfo> chartInfos;

  const ChartsModel({
    this.knittingChart = placeholderChart,
    this.appState = const AppState(),
    this.chartInfos = const[],
  });

  ChartsModel copyWith({
    KnittingChart? knittingChart,
    AppState? appState,
    List<StitchDefinition>? customStitches,
    List<ChartInfo>? chartInfos,
  }) {
    return ChartsModel(
      knittingChart: knittingChart?? this.knittingChart,
      appState: appState?? this.appState,
      chartInfos: chartInfos?? this.chartInfos,
    );
  }

}
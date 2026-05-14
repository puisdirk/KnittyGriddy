
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

@immutable
class GriddyModel {

  final KnittingPattern knittingPattern;
  final AppState appState;
//  final List<StitchDefinition> customStitches;
  final List<PatternInfo> patternInfos;

  const GriddyModel({
    this.knittingPattern = placeholderPattern,
    this.appState = const AppState(),
//    this.customStitches = const[],
    this.patternInfos = const[],
  });

  GriddyModel copyWith({
    KnittingPattern? knittingPattern,
    AppState? appState,
    List<StitchDefinition>? customStitches,
    List<PatternInfo>? patternInfos,
  }) {
    return GriddyModel(
      knittingPattern: knittingPattern?? this.knittingPattern,
      appState: appState?? this.appState,
//      customStitches: customStitches?? this.customStitches,
      patternInfos: patternInfos?? this.patternInfos,
    );
  }

}
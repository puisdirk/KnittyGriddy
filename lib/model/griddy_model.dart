
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

@immutable
class GriddyModel {

  final KnittingPattern knittingPattern;
  final AppState appState;
  final List<StitchDefinition> customStitches;

  const GriddyModel({
    this.knittingPattern = const KnittingPattern(
      patternSettings: PatternSettings(rows: defaultGridRows, columns: defaultGridColumns, gridType: GridType.flat),
    ),
    this.appState = const AppState(),
    this.customStitches = const[],
  });

  GriddyModel copyWith({
    KnittingPattern? knittingPattern,
    AppState? appState,
    List<StitchDefinition>? customStitches,
  }) {
    return GriddyModel(
      knittingPattern: knittingPattern?? this.knittingPattern,
      appState: appState?? this.appState,
      customStitches: customStitches?? this.customStitches,
    );
  }

}
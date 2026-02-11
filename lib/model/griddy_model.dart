
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';

@immutable
class GriddyModel {

  final KnittingPattern knittingPattern;
  final AppState appState;
  // TODO: could keep custom stitch definitions here

  const GriddyModel({
    this.knittingPattern = const KnittingPattern(
      patternSettings: PatternSettings(rows: defaultGridRows, columns: defaultGridColumns),
    ),
    this.appState = const AppState(),
  });

  GriddyModel copyWith({
    KnittingPattern? knittingPattern,
    AppState? appState,
  }) {
    return GriddyModel(
      knittingPattern: knittingPattern?? this.knittingPattern,
      appState: appState?? this.appState,
    );
  }

}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/stitchrepo/stitch_repository.dart';

@immutable
class KnittingPattern {

  final PatternSettings patternSettings;
  final List<StitchCell> stitches;
  final List<StitchDefinition> usedStitches;
  final List<NamedColour> usedColours;

  const KnittingPattern({
    required this.patternSettings,
    this.usedStitches = const[StitchRepository.noStitch, StitchRepository.knit, StitchRepository.purl, StitchRepository.c2r],
    this.usedColours = const[defaultMainColor],
    this.stitches = defaultStitches,
  });

  KnittingPattern copyWith({
    PatternSettings? patternSettings,
    List<StitchCell>? stitches,
    List<StitchDefinition>? usedStitches,
    List<NamedColour>? usedColours,
  }) {
    return KnittingPattern(
      patternSettings: patternSettings?? this.patternSettings,
      stitches: stitches?? this.stitches,
      usedStitches: usedStitches?? this.usedStitches,
      usedColours: usedColours?? this.usedColours,
    );
  }

  StitchCell stitchCell(int row, int column) {
    if (stitches.any((cell) => cell.row == row && cell.column == column)) {
      return stitches.firstWhere((cell) => cell.row == row && cell.column == column);
    }
    return StitchCell.empty(row, column);
  }

  NamedColour get mainColour => usedColours.firstWhere((colour) => colour.isMainColor);
}
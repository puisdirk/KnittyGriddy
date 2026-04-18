
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/named_colour.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repository.dart';

@immutable
class KnittingPattern {

  final PatternSettings patternSettings;
  final List<StitchCell> stitches;
  final List<StitchDefinition> usedStitches;
  final List<NamedColour> usedColours;
  final Selection selection;
  final Set<CellAddress> outline;

  const KnittingPattern({
    required this.patternSettings,
    this.usedStitches = const[StitchRepository.noStitch, StitchRepository.knit, StitchRepository.purl, ],
    this.usedColours = const[defaultMainColor],
    this.stitches = defaultStitches,
    this.selection = emptySelection,
    this.outline = const {},
  });

  KnittingPattern copyWith({
    PatternSettings? patternSettings,
    List<StitchCell>? stitches,
    List<StitchDefinition>? usedStitches,
    List<NamedColour>? usedColours,
    Selection? selection,
    Set<CellAddress>? outline,
  }) {
    return KnittingPattern(
      patternSettings: patternSettings?? this.patternSettings,
      stitches: stitches?? this.stitches,
      usedStitches: usedStitches?? this.usedStitches,
      usedColours: usedColours?? this.usedColours,
      selection: selection?? this.selection,
      outline: outline?? this.outline,
    );
  }

  StitchCell stitchCell(int row, int column) {
    if (stitches.any((cell) => cell.row == row && cell.column == column)) {
      return stitches.firstWhere((cell) => cell.row == row && cell.column == column);
    }
    return StitchCell.empty(row, column);
  }

  NamedColour get mainColour => usedColours.firstWhere((colour) => colour.isMainColor);

  @override
  int get hashCode => 
    patternSettings.hashCode ^ stitches.hashCode ^ usedStitches.hashCode ^ usedColours.hashCode ^ 
    selection.hashCode ^ outline.hashCode;
    
      @override
      bool operator ==(Object other) =>
        identical(this, other) ||
          other is KnittingPattern &&
          patternSettings == other.patternSettings &&
          stitches == other.stitches &&
          usedStitches == other.usedStitches &&
          usedColours == other.usedColours &&
          selection == other.selection &&
          outline == other.outline;

  
}
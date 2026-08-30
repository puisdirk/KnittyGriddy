import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/stitch_cell.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/charts/stitchrepo/knitting_symbol_control.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldStitchCellControl extends StatelessWidget {
  final StitchCell stitchCell;
  final bool showNoStichCells;

  const ChartFieldStitchCellControl({
    required this.stitchCell,
    required this.showNoStichCells,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (stitchCell.row) * stitchCellHeight,
      left: (stitchCell.column) * stitchCellWidth,  
      child: Container(
        color: stitchCell.colour.color,
        height: stitchCellHeight,
        width: stitchCellWidth,
          child: (stitchCell.stitchDefinitionId == BasicStitchesSet.noStitchId && !showNoStichCells) ?
            const SizedBox.shrink() :
            KnittingSymbolControl(
              knittingSymbol: StitchRepository.getStitchDefinitionById(stitchCell.stitchDefinitionId).symbolAt(stitchCell.stitchDefinitionColumn),
              symbolColor: ColorUtilities.contrastingFromColor(stitchCell.colour.color),
              cursor: SystemMouseCursors.basic,
            )
      )
    );
  }
}
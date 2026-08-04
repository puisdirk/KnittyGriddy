import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/stitch_cell.dart';
import 'package:knitty_griddy/charts/stitchrepo/knitting_symbol_control.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldStitchCellControl extends StatelessWidget {
  final StitchCell stitchCell;

  const ChartFieldStitchCellControl({
    required this.stitchCell,
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
          child: KnittingSymbolControl(
            knittingSymbol: StitchRepository.getStitchDefinitionById(stitchCell.stitchDefinitionId).symbolAt(stitchCell.stitchDefinitionColumn),
            symbolColor: ColorUtilities.contrastingFromColor(stitchCell.colour.color),
            cursor: SystemMouseCursors.basic,
          )
      )
    );
  }
}
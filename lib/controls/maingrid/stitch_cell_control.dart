
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/controls/stitchrepo/knitting_symbol_control.dart';
import 'package:provider/provider.dart';

class StitchCellControl extends StatelessWidget {
  final int row;
  final int column;
  final void Function(StitchCell stitchCell) onEnter;
  final void Function(StitchCell stitchCell) onTap;
  final void Function(StitchCell stitchCell) onTapDown;

  const StitchCellControl({
    required this.column,
    required this.row,
    required this.onEnter,
    required this.onTap,
    required this.onTapDown,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, StitchCell>(
      selector: (_, model) => model.stitchAt(column, row),
      builder: (context, stitchCell, _) {
        return Positioned(
          top: (stitchCell.row) * stitchCellHeight,
          left: (stitchCell.column) * stitchCellWidth,  
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              if (event.buttons != 0) {
                onEnter(stitchCell);
              }
            },
            child: GestureDetector(
              onTap: () => onTap(stitchCell),
              onTapDown: (_) => onTapDown(stitchCell),
              child: Container(
                color: stitchCell.colour.color,
                height: stitchCellHeight,
                width: stitchCellWidth,
                  child: KnittingSymbolControl(
                    knittingSymbol: StitchRepository.definitionById(stitchCell.stitchDefinitionId).symbolAt(stitchCell.stitchDefinitionColumn),
                    symbolColor: ColorUtilities.contrastingFromColor(stitchCell.colour.color),
                  )
              ),
            ),
          )
        );
      }
    );
  }
}
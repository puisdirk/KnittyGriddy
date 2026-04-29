import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/editgrid/column_and_row_numbers_panel.dart';
import 'package:knitty_griddy/controls/maingrid/outline_control.dart';
import 'package:knitty_griddy/controls/maingrid/stitches_grid.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class PreviewStitchesGrid extends StatelessWidget {
  const PreviewStitchesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    KnittingPattern pattern = Provider.of<KnittyGriddyModel>(context, listen: false).knittingPattern;

    return SizedBox(
      width: (pattern.patternSettings.columns * stitchCellWidth) + (2 * stitchCellWidth),
      height: (pattern.patternSettings.rows * stitchCellHeight) + (2 * stitchCellHeight),
      child: Stack(
        children: [
          const Positioned(child: ColumnAndRowNumbersPanel()),
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: StitchesGrid(rows: pattern.patternSettings.rows, columns: pattern.patternSettings.columns)
          ),
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: OutlineControl(rows: pattern.patternSettings.rows, columns: pattern.patternSettings.columns)
          ),
        ],
      ),
    );
  }
}
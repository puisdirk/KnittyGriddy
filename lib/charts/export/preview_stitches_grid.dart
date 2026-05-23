import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/editgrid/column_and_row_numbers_panel.dart';
import 'package:knitty_griddy/charts/maingrid/outline_control.dart';
import 'package:knitty_griddy/charts/maingrid/stitches_grid.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class PreviewStitchesGrid extends StatelessWidget {
  const PreviewStitchesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    KnittingChart chart = Provider.of<ChartsModel>(context, listen: false).knittingChart;

    return SizedBox(
      width: (chart.chartSettings.columns * stitchCellWidth) + (2 * stitchCellWidth),
      height: (chart.chartSettings.rows * stitchCellHeight) + (2 * stitchCellHeight),
      child: Stack(
        children: [
          const Positioned(child: ColumnAndRowNumbersPanel()),
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: StitchesGrid(rows: chart.chartSettings.rows, columns: chart.chartSettings.columns)
          ),
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: OutlineControl(rows: chart.chartSettings.rows, columns: chart.chartSettings.columns)
          ),
        ],
      ),
    );
  }
}
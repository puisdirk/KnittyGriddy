import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_columns_and_rows.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_outline_control.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_stitches_grid.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldGrid extends StatelessWidget {
  final bool showNoStichCells;
  final KnittingChart chart;
  
  const ChartFieldGrid({
    required this.chart,
    required this.showNoStichCells,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (chart.chartSettings.columns * stitchCellWidth) + (2 * stitchCellWidth),
      height: (chart.chartSettings.rows * stitchCellHeight) + (2 * stitchCellHeight),
      child: Stack(
        children: [
          Positioned(child: ChartFieldColumnsAndRows(chartSettings: chart.chartSettings,)),
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: ChartFieldStitchesGrid(
              rows: chart.chartSettings.rows, 
              columns: chart.chartSettings.columns, 
              stitches: chart.stitches,
              showNoStichCells: showNoStichCells,
            )
          ),
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: ChartFieldOutlineControl(
              chartSettings: chart.chartSettings,
              outline: chart.outline,)
          ),
        ],
      ),
    );
  }
}
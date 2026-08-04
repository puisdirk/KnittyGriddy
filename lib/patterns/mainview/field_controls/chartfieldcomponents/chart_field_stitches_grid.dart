import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/maingrid/grid_lines_painter.dart';
import 'package:knitty_griddy/charts/model/stitch_cell.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_stitch_cell_control.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldStitchesGrid extends StatelessWidget {
  final int columns;
  final int rows;
  final List<StitchCell> stitches;

  const ChartFieldStitchesGrid({
    required this.columns,
    required this.rows,
    required this.stitches,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: columns * stitchCellWidth,
      height: rows * stitchCellHeight,
      child: Stack(
        children: [
          for (int row = 0; row < rows; row++)
            for (int col = 0; col < columns; col++)
              ChartFieldStitchCellControl(stitchCell: stitches.firstWhere((cell) => cell.column == col && cell.row == row)
            ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(columns * stitchCellWidth, rows * stitchCellHeight),
              painter: GridLinesPainter(rows: rows, columns: columns),
            ),
          ),
        ],
      )
    );
  }
}
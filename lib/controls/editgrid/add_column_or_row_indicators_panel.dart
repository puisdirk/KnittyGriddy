
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/editgrid/add_column_indicator.dart';
import 'package:knitty_griddy/controls/editgrid/add_row_indicator.dart';
import 'package:knitty_griddy/controls/editgrid/delete_column_indicator.dart';
import 'package:knitty_griddy/controls/editgrid/delete_row_indicator.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class AddColumnOrRowIndicatorsPanel extends StatelessWidget {
  final int rows;
  final int columns;

  const AddColumnOrRowIndicatorsPanel({
    required this.rows,
    required this.columns,  
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, AppState>(
      selector: (_, model) => model.appState,
      builder: (context, appState, _) {
        return SizedBox(
          width: (columns * stitchCellWidth) + (4 * columnsAndRowNumbersWidth),
          height: (rows * stitchCellHeight) + (4 * columnsAndRowNumbersHeight),
          child: appState.currentTool == Tool.select ?
            const Placeholder(color: Colors.transparent,) :
            Stack(
              children: [
                // Add columns
                for (int col = 0; col <= columns; col++)
                  Positioned(
                    left: (1.5 * stitchCellWidth) + (col * stitchCellWidth),
                    child: AddColumnIndicator(column: col, height: (rows * stitchCellHeight) + (4 * stitchCellHeight))
                  ),
                // Add rows
                for (int row = 0; row <= rows; row++)
                  Positioned(
                    top: (1.5 * stitchCellHeight) + (row * stitchCellHeight),
                    child: AddRowIndicator(row: row, width: (columns * stitchCellWidth) + (4 * stitchCellWidth))
                  ),
                // Delete columns
                for (int col = 0; col < columns; col++)
                  Positioned(
                    left: (2 * stitchCellWidth) + (col * stitchCellWidth),
                    top: stitchCellHeight,
                    child: DeleteColumnIndicator(column: col, height: (rows * stitchCellHeight) + (2 * stitchCellHeight))
                  ),
                // Delete rows
                for (int row = 0; row < rows; row++)
                  Positioned(
                    top: (2 * stitchCellHeight) + (row * stitchCellHeight),
                    left: stitchCellWidth,
                    child: DeleteRowIndicator(row: row, width: (columns * stitchCellWidth) + (2 * stitchCellWidth))
                  ),
              ],
            )
        );
      }
    );
  }
}
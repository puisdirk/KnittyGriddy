
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/charts/editgrid/add_column_or_row_indicators_panel.dart';
import 'package:knitty_griddy/charts/editgrid/column_and_row_numbers_panel.dart';
import 'package:knitty_griddy/charts/maingrid/outline_control.dart';
import 'package:knitty_griddy/charts/maingrid/selection_layer_panel.dart';
import 'package:knitty_griddy/charts/maingrid/stitches_grid.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/chart_settings.dart';
import 'package:provider/provider.dart';

class ChartControl extends StatelessWidget {

  const ChartControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, ChartSettings>(
      selector: (_, model) => model.settings,
      builder: (context, chartSettings, _) {
        return SizedBox(
          width: (chartSettings.columns * stitchCellWidth) + (4 * columnsAndRowNumbersWidth),
          height: (chartSettings.rows * stitchCellHeight) + (4 * columnsAndRowNumbersHeight),
          child: Stack(
            children: [
              // colored background
              Positioned(
                top: 2 * stitchCellHeight,
                left: 2 * stitchCellWidth,
                child: SizedBox(
                  width: chartSettings.columns * stitchCellWidth,
                  height: chartSettings.rows * stitchCellHeight,
                  child: Container(color: const Color.fromARGB(30, 30, 30, 30),)
                )
              ),
              Positioned(top: 2 * stitchCellHeight, left: 2 * stitchCellWidth, 
                child: StitchesGrid(
                  rows: chartSettings.rows, columns: chartSettings.columns, 
                )
              ),
              const Positioned(top: stitchCellHeight, left: stitchCellWidth,
                child: ColumnAndRowNumbersPanel()),
              Positioned(
                child: AddColumnOrRowIndicatorsPanel(rows: chartSettings.rows, columns: chartSettings.columns,)),
              Positioned(left: stitchCellWidth, top: stitchCellHeight,
                child: SelectionLayerPanel(rows: chartSettings.rows, columns: chartSettings.columns,)),
              Positioned(top: 2 * stitchCellHeight, left: 2 * stitchCellWidth,
                child: IgnorePointer(child: OutlineControl(rows: chartSettings.rows, columns: chartSettings.columns,))),
            ],
          ),
        );
      },
    );
  }
}
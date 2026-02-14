
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/editgrid/add_column_or_row_indicators_panel.dart';
import 'package:knitty_griddy/controls/editgrid/column_and_row_numbers_panel.dart';
import 'package:knitty_griddy/controls/outline_layer.dart';
import 'package:knitty_griddy/controls/selectionlayer/selection_layer_panel.dart';
import 'package:knitty_griddy/controls/stitches_grid.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:provider/provider.dart';

class PatternControl extends StatelessWidget {

  const PatternControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, PatternSettings>(
      selector: (_, model) => model.settings,
      builder: (context, patternSettings, _) {
        return SingleChildScrollView(
          child: SizedBox(
            width: (patternSettings.columns * stitchCellWidth) + (4 * columnsAndRowNumbersWidth),
            height: (patternSettings.rows * stitchCellHeight) + (4 * columnsAndRowNumbersHeight),
            child: Stack(
              children: [
                // colored background
                Positioned(
                  top: 2 * stitchCellHeight,
                  left: 2 * stitchCellWidth,
                  child: SizedBox(
                    width: patternSettings.columns * stitchCellWidth,
                    height: patternSettings.rows * stitchCellHeight,
                    child: Container(color: const Color.fromARGB(30, 30, 30, 30),)
                  )
                ),
                Positioned(top: 2 * stitchCellHeight, left: 2 * stitchCellWidth, 
                  child: StitchesGrid(
                    rows: patternSettings.rows, columns: patternSettings.columns, 
                  )
                ),
                const Positioned(top: stitchCellHeight, left: stitchCellWidth,
                  child: ColumnAndRowNumbersPanel()),
                Positioned(
                  child: AddColumnOrRowIndicatorsPanel(rows: patternSettings.rows, columns: patternSettings.columns,)),
                Positioned(top: stitchCellHeight, left: stitchCellWidth,
                  child: IgnorePointer(child: OutlineLayer(rows: patternSettings.rows, columns: patternSettings.columns,))),
                Positioned(top: 2 * stitchCellHeight, left: 2 * stitchCellWidth, 
                  child: IgnorePointer(child: SelectionLayerPanel(rows: patternSettings.rows, columns: patternSettings.columns,))),
              ],
            ),
          )
        );

      },
    );
  }
}
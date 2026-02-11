
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/add_column_or_row_indicator.dart';
import 'package:knitty_griddy/controls/column_and_row_number_controls.dart';
import 'package:knitty_griddy/controls/outline_layer.dart';
import 'package:knitty_griddy/controls/selection_layer.dart';
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
            width: (patternSettings.columns * stitchCellWidth) + (2 * columnsAndRowNumbersWidth),
            height: (patternSettings.rows * stitchCellHeight) + (2 * columnsAndRowNumbersHeight),
            child: Stack(
              children: [
                // colored background
                Positioned(
                  top: stitchCellHeight,
                  left: stitchCellWidth,
                  child: SizedBox(
                    width: patternSettings.columns * stitchCellWidth,
                    height: patternSettings.rows * stitchCellHeight,
                    child: Container(color: const Color.fromARGB(30, 30, 30, 30),)
                  )
                ),
                Positioned(top: stitchCellHeight, left: stitchCellWidth, 
                  child: StitchesGrid(
                    rows: patternSettings.rows, columns: patternSettings.columns, 
                  )
                ),
                Positioned(
                  child: ColumnAndRowNumberControls(patternSettings: patternSettings)),
                Positioned(top: stitchCellHeight, left: stitchCellWidth, 
                  child: AddColumnOrRowIndicator(rows: patternSettings.rows, columns: patternSettings.columns,)),
                Positioned(
                  child: OutlineLayer(rows: patternSettings.rows, columns: patternSettings.columns,)),
                Positioned(top: stitchCellHeight, left: stitchCellWidth, 
                  child: SelectionLayer(rows: patternSettings.rows, columns: patternSettings.columns,)),
              ],
            ),
          )
        );

      },
    );
  }
}
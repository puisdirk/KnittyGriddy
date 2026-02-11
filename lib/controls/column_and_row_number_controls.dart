
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';

class ColumnAndRowNumberControls extends StatelessWidget {
  final PatternSettings patternSettings;
  
  const ColumnAndRowNumberControls({
    required this.patternSettings,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (patternSettings.columns * stitchCellWidth) + (2 * columnsAndRowNumbersWidth),
      height: (patternSettings.rows * stitchCellHeight) + (2 * columnsAndRowNumbersHeight),
      child: Stack(
        children: [
          // TODO: order dependent on settings
          for (int row = 0; row < patternSettings.rows; row++)
            Positioned(
              top: 0, left: stitchCellWidth + (row * stitchCellWidth), 
              child: SizedBox(
                width: stitchCellWidth, height: stitchCellHeight,
                child: Center(child: Text('${patternSettings.rows - row}'),),
              )
            ),
          for (int row = 0; row < patternSettings.rows; row++)
            Positioned(
              bottom: 0, left: stitchCellWidth + (row * stitchCellWidth), 
              child: SizedBox(
                width: stitchCellWidth, height: stitchCellHeight,
                child: Center(child: Text('${patternSettings.rows - row}'),),
              )
            ),
          for (int column = 0; column < patternSettings.columns; column++)
            Positioned(
              left: 0, top: stitchCellHeight + (column * stitchCellHeight), 
              child: SizedBox(
                width: stitchCellWidth, height: stitchCellHeight,
                child: Center(child: Text('${patternSettings.columns - column}'),),
              )
            ),
          for (int column = 0; column < patternSettings.columns; column++)
            Positioned(
              right: 0, top: stitchCellHeight + (column * stitchCellHeight), 
              child: SizedBox(
                width: stitchCellWidth, height: stitchCellHeight,
                child: Center(child: Text('${patternSettings.columns - column}'),),
              )
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:provider/provider.dart';

class ColumnAndRowNumbersPanel extends StatelessWidget {
  
  const ColumnAndRowNumbersPanel({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, PatternSettings>(
      selector: (_, model) => model.settings,
      builder: (context, patternSettings, _) {
        // Get the numbers from the model
        List<String> leftSideRowIndicators = patternSettings.getLeftSideRowIndicators();
        List<String> rightSideRowIndicators = patternSettings.getRightSideRowIndicators();
        List<String> topSideColumnIndicators = patternSettings.getTopSideColumnIndicators();
        List<String> bottomSideColumnIndicators = patternSettings.getBottomSideColumnIndicators();

        return SizedBox(
          width: (patternSettings.columns * stitchCellWidth) + (2 * columnsAndRowNumbersWidth),
          height: (patternSettings.rows * stitchCellHeight) + (2 * columnsAndRowNumbersHeight),
          child: Stack(
            children: [
              // TODO: order dependent on settings
              // rows left side
              for (int row = 0; row < leftSideRowIndicators.length; row++)
                Positioned(
                  left: 0, top: stitchCellWidth + (row * stitchCellWidth), 
                  child: SizedBox(
                    width: stitchCellWidth, height: stitchCellHeight,
                    child: Center(child: Text(leftSideRowIndicators[row]),),
                  )
                ),
              // rows right side
              for (int row = 0; row < rightSideRowIndicators.length; row++)
                Positioned(
                  right: 0, top: stitchCellWidth + (row * stitchCellWidth), 
                  child: SizedBox(
                    width: stitchCellWidth, height: stitchCellHeight,
                    child: Center(child: Text(rightSideRowIndicators[row]),),
                  )
                ),
              // columns top side
              for (int column = 0; column < topSideColumnIndicators.length; column++)
                Positioned(
                  top: 0, left: stitchCellHeight + (column * stitchCellHeight), 
                  child: SizedBox(
                    width: stitchCellWidth, height: stitchCellHeight,
                    child: Center(child: Text(topSideColumnIndicators[column]),),
                  )
                ),
              // columns bottom side
              for (int column = 0; column < bottomSideColumnIndicators.length; column++)
                Positioned(
                  bottom: 0, left: stitchCellHeight + (column * stitchCellHeight), 
                  child: SizedBox(
                    width: stitchCellWidth, height: stitchCellHeight,
                    child: Center(child: Text(bottomSideColumnIndicators[column]),),
                  )
                ),
            ],
          ),
        );
      }
    );
  }
}
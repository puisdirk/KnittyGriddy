import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/chart_settings.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldColumnsAndRows extends StatelessWidget {
  final ChartSettings chartSettings;

  const ChartFieldColumnsAndRows({
    required this.chartSettings,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    List<String> leftSideRowIndicators = chartSettings.getLeftSideRowIndicators();
    List<String> rightSideRowIndicators = chartSettings.getRightSideRowIndicators();
    List<String> topSideColumnIndicators = chartSettings.getTopSideColumnIndicators();
    List<String> bottomSideColumnIndicators = chartSettings.getBottomSideColumnIndicators();

    return SizedBox(
      width: (chartSettings.columns * stitchCellWidth) + (2 * columnsAndRowNumbersWidth),
      height: (chartSettings.rows * stitchCellHeight) + (2 * columnsAndRowNumbersHeight),
      child: Stack(
        children: [
          // rows left side
          for (int row = 0; row < leftSideRowIndicators.length; row++)
            Positioned(
              left: 0, top: stitchCellHeight + (row * stitchCellHeight), 
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
}
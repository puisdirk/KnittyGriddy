import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/cell_address.dart';
import 'package:knitty_griddy/charts/model/chart_settings.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldOutlineControl extends StatelessWidget {
  final ChartSettings chartSettings;
  final Set<CellAddress> outline;
  
  const ChartFieldOutlineControl({
    required this.chartSettings,
    required this.outline,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: chartSettings.columns * stitchCellWidth,
      height: chartSettings.rows * stitchCellHeight,
      child: Stack(
        children: [
          for (CellAddress address in outline)
            Positioned(
              top: address.row * stitchCellHeight,
              left: address.column * stitchCellWidth,
              child: SizedBox(
                width: stitchCellWidth,
                height: stitchCellHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: outline.contains(CellAddress(column: address.column, row: address.row - 1)) ? BorderSide.none : BorderSide(width: chartSettings.outlineThickness, color: chartSettings.outlineColor),
                      bottom: outline.contains(CellAddress(column: address.column, row: address.row + 1)) ? BorderSide.none : BorderSide(width: chartSettings.outlineThickness, color: chartSettings.outlineColor),
                      left: outline.contains(CellAddress(column: address.column - 1, row: address.row)) ? BorderSide.none : BorderSide(width: chartSettings.outlineThickness, color: chartSettings.outlineColor),
                      right: outline.contains(CellAddress(column: address.column + 1, row: address.row)) ? BorderSide.none : BorderSide(width: chartSettings.outlineThickness, color: chartSettings.outlineColor),
                    )
                  ),
                ),
              )
            ),
        ],
      ),
    );
  }
}
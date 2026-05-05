
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/controls/maingrid/stitch_cell_control.dart';
import 'package:provider/provider.dart';

class StitchesGrid extends StatelessWidget {
  final int rows;
  final int columns;

  const StitchesGrid({
    required this.rows,
    required this.columns,
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
            StitchCellControl(
              column: col,
              row: row,
              onEnter: (stitchCell) {
                AppState appState = Provider.of<KnittyGriddyModel>(context, listen: false).appState;

                // Paint stitches or colours while moving the mouse
                if (appState.mouseOption == MouseOption.painting) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinitionId != appState.selectedStitch?.id) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                }
              },
              onTap: (stitchCell) {
                AppState appState = Provider.of<KnittyGriddyModel>(context, listen: false).appState;

                // Click to change stitch, colour, or selection
                if (appState.mouseOption == MouseOption.singleclick) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinitionId != appState.selectedStitch?.id) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                } else if (appState.currentTool == Tool.select) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).toggleCell(stitchCell.column, stitchCell.row);
                }
              },
              onTapDown: (stitchCell) {
                AppState appState = Provider.of<KnittyGriddyModel>(context, listen: false).appState;

                // Change initial stitch or colour when painting
                if (appState.mouseOption == MouseOption.painting) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinitionId != appState.selectedStitch?.id) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                }
              },
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

class GridLinesPainter extends CustomPainter {
  final int rows;
  final int columns;

  GridLinesPainter({
    required this.rows,
    required this.columns,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    Paint gridLinesPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..blendMode = BlendMode.difference;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gridLinesPaint);

    for (int row = 1; row < rows; row++) {
      canvas.drawLine(Offset(0, row * stitchCellHeight), Offset(size.width, row * stitchCellHeight), gridLinesPaint);
    }
    for (int column = 1; column < columns; column++) {
      canvas.drawLine(Offset(column * stitchCellWidth, 0), Offset(column * stitchCellWidth, size.height), gridLinesPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridLinesPainter oldDelegate) {
    return oldDelegate.rows != rows || oldDelegate.columns != columns;
  }

}
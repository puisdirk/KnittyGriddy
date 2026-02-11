
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/stitch_cell_control.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:provider/provider.dart';

class StitchesGrid extends StatefulWidget {
  final int rows;
  final int columns;

  const StitchesGrid({
    required this.rows,
    required this.columns,
    super.key
  });

  @override
  State<StitchesGrid> createState() => _StitchesGridState();
}

class _StitchesGridState extends State<StitchesGrid> {
  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, AppState>(
      selector: (_, model) => model.appState,
      builder: (context, appState, _) {
        return Selector<KnittyGriddyModel, List<StitchCell>>(
          selector: (_, model) => model.stitches,
          builder: (context, stitches, _) {
            return SizedBox(
              width: widget.columns * stitchCellWidth,
              height: widget.rows * stitchCellHeight,
              child: Stack(
                children: [
                  for (StitchCell stitchCell in stitches)
                    StitchCellControl(
                      stitchCell: stitchCell, 
                    ),
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(widget.columns * stitchCellWidth, widget.rows * stitchCellHeight),
                      painter: GridLinesPainter(rows: widget.rows, columns: widget.columns),
                    ),
                  ),
                ],
              )
            );
          }
        );
      }
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
      ..strokeWidth = 1;

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
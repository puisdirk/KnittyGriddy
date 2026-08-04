import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

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

import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchPartsBorders extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  // The space between the parts and the symbol
  final double symbolRowSpace;

  const StitchPartsBorders({
    required this.stitchDefinition,
    required this.symbolRowSpace,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: StitchPartsBordersPainter(
            stitchDefinition: stitchDefinition,
            symbolRowSpace: symbolRowSpace,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

class StitchPartsBordersPainter extends CustomPainter {
  final StitchDefinition stitchDefinition;
  final double symbolRowSpace;

  const StitchPartsBordersPainter({
    required this.stitchDefinition,
    required this.symbolRowSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint ink = Paint()
    ..color = Colors.black.withAlpha(90)
    ..style = PaintingStyle.stroke;

    // The symbol
    canvas.drawRect(
      Rect.fromLTWH(
        0, 
        size.height - stitchCellHeight, 
        stitchDefinition.columns * stitchCellWidth, 
        stitchCellHeight
      ), 
      ink
    );

    // The parts
    for (int col = 0; col < stitchDefinition.columns; col++) {
      for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
        canvas.drawRect(
          Rect.fromLTWH(
            (col * stitchCellWidth), 
            size.height - stitchCellHeight - symbolRowSpace - (row * stitchCellHeight) - stitchCellHeight, 
            stitchCellWidth,
            stitchCellHeight
          ), 
          ink
        );
      }
    }

  }

  @override
  bool shouldRepaint(covariant StitchPartsBordersPainter oldDelegate) {
    return stitchDefinition != oldDelegate.stitchDefinition || symbolRowSpace != oldDelegate.symbolRowSpace;
  }

}
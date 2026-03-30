import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchPathsSelectionMarker extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int? selectedColumn;
  final int? selectedRow;

  const StitchPathsSelectionMarker({
    required this.stitchDefinition,
    required this.selectedColumn,
    required this.selectedRow, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: SelectionMarkerPainter(
            selectColumn: selectedColumn,
            selectedRow: selectedRow,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

class SelectionMarkerPainter extends CustomPainter {
  
  final int? selectColumn;
  final int? selectedRow;

  const SelectionMarkerPainter({
    required this.selectColumn,
    required this.selectedRow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectColumn == null && selectedRow == null) {
      return;
    }

    Paint ink = Paint()
      ..color = Colors.green.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    if (selectedRow == null) {
      // Whole column
      canvas.drawRect(Rect.fromLTWH((selectColumn! * stitchCellWidth), 0, stitchCellWidth, size.height), ink);
    } else {
      // Single path
      canvas.drawRect(Rect.fromLTWH(
        selectColumn! * stitchCellWidth, 
        selectedRow! * stitchCellHeight, 
        stitchCellWidth, stitchCellHeight), ink);
    }
  }

  @override
  bool shouldRepaint(covariant SelectionMarkerPainter oldDelegate) {
    return selectColumn != oldDelegate.selectColumn || selectedRow != oldDelegate.selectedRow;
  }

}
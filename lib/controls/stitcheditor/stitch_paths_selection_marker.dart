import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/controls/stitcheditor/edit_stitch_parts_control.dart';
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
            selectedColumn: selectedColumn,
            selectedRow: selectedRow,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

class SelectionMarkerPainter extends CustomPainter {
  
  final int? selectedColumn;
  final int? selectedRow;

  const SelectionMarkerPainter({
    required this.selectedColumn,
    required this.selectedRow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedColumn == null && selectedRow == null) {
      return;
    }

    Paint ink = Paint()
      ..color = Colors.green.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    if (selectedRow == null) {
      // Whole column
      canvas.drawRect(Rect.fromLTWH((selectedColumn! * stitchCellWidth), 0, stitchCellWidth, size.height), ink);
    } else {
      // Single path
      canvas.drawRect(Rect.fromLTWH(
        selectedColumn! * stitchCellWidth, 
        size.height - (stitchCellHeight + EditStitchPartsControl.spacer) - ((selectedRow! + 1) * stitchCellHeight),
        stitchCellWidth, stitchCellHeight), ink);
    }
  }

  @override
  bool shouldRepaint(covariant SelectionMarkerPainter oldDelegate) {
    return selectedColumn != oldDelegate.selectedColumn || selectedRow != oldDelegate.selectedRow;
  }

}
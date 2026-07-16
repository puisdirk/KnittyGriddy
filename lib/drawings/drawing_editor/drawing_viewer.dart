import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/tape_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
  
class DrawingViewer extends StatelessWidget {
  final AbstractDrawing drawing;
  final String? selectedCommandId;

  const DrawingViewer({
    required this.drawing,
    required this.selectedCommandId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5))
          ),
          child: InteractiveViewer(
            maxScale: 5,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: DrawingPainter(drawing: drawing, selectedCommandId: selectedCommandId),
                size: constraints.biggest,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final AbstractDrawing drawing;
  final String? selectedCommandId;

  const DrawingPainter({
    required this.drawing,
    required this.selectedCommandId,
  });

  static int paintcycle = 0;
  void _printTiming(String message) {
    if (printDebugTiming) {
      print(message);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    int lastTick = 0;
    Stopwatch stopwatch = Stopwatch()..start();
    _printTiming('------------------------- repainting ${paintcycle++} --------------------------------------------');

    // Scale to show the complete drawing
    Rect bbox = drawing.getBoundingBox();

    // Draw somewhat away from the edges
    bbox = bbox.inflate(40);
    bbox = Rect.fromLTWH(bbox.left, -bbox.bottom, bbox.width, bbox.height);

    double missingLeftSide = -(size.width / 2) - bbox.left;
    double missingRightSide = bbox.right - (size.width / 2);
    double missingAtTop = -(size.height / 2) - bbox.top;
    double missingAtBottom = bbox.bottom - (size.height / 2);
    
    // Drawing with origin in middle and scaled to include everything
    double horMissing = 0;
    if (missingLeftSide > horMissing) horMissing = missingLeftSide;
    if (missingRightSide > horMissing) horMissing = missingRightSide;
    horMissing *= 2;

    double vertMissing = 0;
    if (missingAtTop > vertMissing) vertMissing = missingAtTop;
    if (missingAtBottom > vertMissing) vertMissing = missingAtBottom;
    vertMissing *= 2;

    double missing = max(horMissing, vertMissing);
    if (missing > 0) {
      canvas.scale(size.longestSide / (missing + size.longestSide));
      canvas.translate(missing / 2, missing / 2);
    }

    _printTiming('got bbox (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;

    // Draw origin
    Color originColor = Colors.grey.shade700;
    if (drawing.parts.any((p) => p.anchorPointId == originId)) {
      originColor = partColor;
    }
    if (drawing.parts.any((p) => p.anchorPointId == originId && p.id == selectedCommandId)) {
      originColor = selectedColor;
    }
    Offset middle = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(middle, 2, Paint()..color = originColor..style = PaintingStyle.stroke);

    // draw origin label
    var style = TextStyle(color: Colors.grey[400]);
    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        fontSize: 10,
        fontFamily: style.fontFamily,
        fontStyle: style.fontStyle,
        fontWeight: style.fontWeight,
        textAlign: TextAlign.justify,
      ),
    )
    ..pushStyle(style.getTextStyle())
    ..addText('origin');
    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph, middle);

    _printTiming('drew origin (${stopwatch.elapsedMilliseconds - lastTick})');
    lastTick = stopwatch.elapsedMilliseconds;

    DrawingCommand? selectedCommand;
    bool drawDirectionArrows = false;
    if (selectedCommandId != null) {
        selectedCommand = drawing.commandById(selectedCommandId!);
        if (selectedCommand != null) {
          drawDirectionArrows = selectedCommand is TapeCommand && selectedCommand.tapeType == TapeType.linesAndcurves;
        }
    }

    // We draw each command, but we draw the selected one last
    for (DrawingCommand command in drawing.commands) {
      if (command.id != selectedCommandId) {
        _printTiming('start drawing ${command.label} (${stopwatch.elapsedMilliseconds - lastTick})');
        lastTick = stopwatch.elapsedMilliseconds;
        command.paint(canvas, size, drawing, false, drawDirectionArrow: drawDirectionArrows);
        _printTiming('done drawing ${command.label} (${stopwatch.elapsedMilliseconds - lastTick})');
        lastTick = stopwatch.elapsedMilliseconds;
      }
    }
    if (selectedCommand != null) {
      _printTiming('start drawing selected command (${stopwatch.elapsedMilliseconds - lastTick})');
      lastTick = stopwatch.elapsedMilliseconds;
      selectedCommand.paint(canvas, size, drawing, true);
      _printTiming('done drawing selected command (${stopwatch.elapsedMilliseconds - lastTick})');
      lastTick = stopwatch.elapsedMilliseconds;
    }

    _printTiming('-------------------- done drawing in ${stopwatch.elapsedMilliseconds}msec ---------------------');
    
    stopwatch.stop();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.drawing != drawing || selectedCommandId != oldDelegate.selectedCommandId;
  }

}
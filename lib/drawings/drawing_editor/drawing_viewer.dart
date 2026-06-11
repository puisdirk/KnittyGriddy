import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';
  
class DrawingViewer extends StatelessWidget {
  final String? selectedCommandId;

  const DrawingViewer({
    required this.selectedCommandId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Selector<DrawingsModel, Drawing>(
          selector: (_, model) => model.drawing,
          builder: (context, drawing, _) {
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
          }
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final Drawing drawing;
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
    bbox = bbox.inflate(20);
    bbox = Rect.fromLTWH(bbox.left, -bbox.bottom, bbox.width, bbox.height);
    double missingLeftSide = -(size.width / 2) - bbox.left;
    double missingRightSide = bbox.right - (size.width / 2);
    double missingAtTop = -(size.height / 2) - bbox.top;
    double missingAtBottom = bbox.bottom - (size.height / 2);
    
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

    Offset middle = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(middle, 2, Paint()..color = Colors.grey.shade700..style = PaintingStyle.stroke);

    // draw point label
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

    // We draw each command, but we draw the selected one last
    for (DrawingCommand command in drawing.commands) {
      if (command.id != selectedCommandId) {
        _printTiming('start drawing ${command.label} (${stopwatch.elapsedMilliseconds - lastTick})');
        lastTick = stopwatch.elapsedMilliseconds;
        command.paint(canvas, size, drawing, false);
        _printTiming('done drawing ${command.label} (${stopwatch.elapsedMilliseconds - lastTick})');
        lastTick = stopwatch.elapsedMilliseconds;
      }
    }
    if (selectedCommandId != null) {
      _printTiming('start drawing selected command (${stopwatch.elapsedMilliseconds - lastTick})');
      lastTick = stopwatch.elapsedMilliseconds;
      drawing.commands.firstWhere((c) => c.id == selectedCommandId).paint(canvas, size, drawing, true);
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
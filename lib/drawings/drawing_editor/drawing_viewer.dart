import 'dart:ui';

import 'package:flutter/foundation.dart';
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
              child: CustomPaint(
                painter: DrawingPainter(drawing: drawing, selectedCommandId: selectedCommandId),
                size: constraints.biggest,
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

  @override
  void paint(Canvas canvas, Size size) {
    // Prepare for text drawing
    var style = TextStyle(color: Colors.grey[400]);

    Offset middle = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(middle, 2, Paint()..color = Colors.grey.shade700..style = PaintingStyle.stroke);
    // draw point label
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

    // We draw each command, but we draw the selected one last
    for (DrawingCommand command in drawing.commands) {
      if (command.id != selectedCommandId) command.paint(canvas, size, drawing, false);
    }
    if (selectedCommandId != null) drawing.commands.firstWhere((c) => c.id == selectedCommandId).paint(canvas, size, drawing, true);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return !listEquals(oldDelegate.drawing.commands, drawing.commands) || selectedCommandId != oldDelegate.selectedCommandId;
  }

}
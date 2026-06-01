import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class DrawingViewer extends StatelessWidget {
  const DrawingViewer({super.key});

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
                painter: DrawingPainter(drawing: drawing),
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

  const DrawingPainter({
    required this.drawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Prepare for text drawing
    var style = TextStyle(color: Colors.grey[400]);

    Offset middle = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(middle, 2, Paint()..color = Colors.red..style = PaintingStyle.stroke);
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

    for (DrawingCommand command in drawing.commands) {
      command.paint(canvas, size, style, drawing);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return !listEquals(oldDelegate.drawing.commands, drawing.commands);
  }

}
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
            return CustomPaint(
              painter: DrawingPainter(drawing: drawing),
              size: constraints.biggest,
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
    Offset middle = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(middle, 2, Paint()..color = Colors.red..style = PaintingStyle.stroke);

    for (DrawingCommand command in drawing.commands) {
      command.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return !listEquals(oldDelegate.drawing.commands, drawing.commands);
  }

}
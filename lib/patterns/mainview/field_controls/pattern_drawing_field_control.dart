import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';

class PatternDrawingFieldControl extends StatelessWidget {
  final double opacity;
  final Drawing? drawing;
  final bool selected;
  final void Function() onSelect;

  const PatternDrawingFieldControl({
    required this.opacity,
    required this.drawing,
    required this.selected,
    required this.onSelect,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    Rect bbox = drawing == null ? Rect.zero : drawing!.getBoundingBox().inflate(20);

    return drawing == null ? GestureDetector(onTap: onSelect, child: Container(color: Colors.transparent,)) :
    GestureDetector(
      onTap: onSelect,
      child: Container(
        color: Colors.transparent,
        child: FittedBox(
          child: SizedBox(
            width: bbox.width,
            height: bbox.height,
            child: LayoutBuilder(
              builder: (context, constraints) {              
                return ClipRect(
                  child: Opacity(
                    opacity: opacity == 0 ? 0 : opacity / 255,
                    child: CustomPaint(
                      painter: DrawingPainter(drawing: drawing!),
                      size: constraints.biggest,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
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
    for (DrawingCommand command in drawing.commands) {
      command.paint(canvas, size, drawing, false, forPreview: true);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.drawing != drawing;
  }

}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol_path.dart';
import 'package:path_drawing/path_drawing.dart';

class KnittingSymbolPathControl extends StatelessWidget {
  final KnittingSymbolPath knittingSymbolPath;
  final double iconSize;
  final Color? symbolColor;
  final void Function()? onTap;

  const KnittingSymbolPathControl({
    required this.knittingSymbolPath,
    double? iconSize,
    this.symbolColor,
    this.onTap,
    super.key
  }) : iconSize = iconSize?? stitchCellHeight;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: iconSize, 
          height: iconSize, 
          child: ClipRect(
            child: Transform.translate(
              offset: knittingSymbolPath.translation,
              child: Transform.scale(
                scaleX: knittingSymbolPath.scale.dx,
                scaleY: knittingSymbolPath.scale.dy,
                  child: Transform.rotate(
                    angle: knittingSymbolPath.rotation,
                    child: CustomPaint(
                      size: Size(iconSize, iconSize),
                      painter: KnittingSymbolPathPainter(
                        knittingSymbolPath: knittingSymbolPath, 
                        symbolColor: symbolColor?? Colors.black,
                        iconSize: iconSize,
                      ),
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KnittingSymbolPathPainter extends CustomPainter {
  final KnittingSymbolPath knittingSymbolPath;
  final Color symbolColor;
  final double iconSize;

  const KnittingSymbolPathPainter({
    required this.knittingSymbolPath,
    required this.symbolColor,
    required this.iconSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (knittingSymbolPath.path.isNotEmpty) {
      Paint ink = Paint()
        ..color = symbolColor
        ..style = PaintingStyle.fill;
      
      Path p = parseSvgPathData(knittingSymbolPath.path);

      canvas.save();
      canvas.scale(iconSize / stitchCellHeight);
      canvas.drawPath(p, ink);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant KnittingSymbolPathPainter oldDelegate) {
    return oldDelegate.knittingSymbolPath != knittingSymbolPath || oldDelegate.symbolColor != symbolColor;
  }

}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';

class KnittingSymbolPartControl extends StatelessWidget {
  final KnittingSymbolPart knittingSymbolPart;
  final Color? symbolColor;
  final void Function()? onTap;

  const KnittingSymbolPartControl({
    required this.knittingSymbolPart,
    this.symbolColor,
    this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: stitchCellWidth, 
          height: stitchCellHeight, 
          child: ClipRect(
            child: Transform.translate(
              offset: knittingSymbolPart.translation,
              child: Transform.scale(
                scaleX: knittingSymbolPart.scale.dx,
                scaleY: knittingSymbolPart.scale.dy,
                child: Transform.rotate(
                  angle: knittingSymbolPart.rotation,
                  child: CustomPaint(
                    size: const Size(stitchCellWidth, stitchCellHeight),
                    painter: KnittingSymbolPartPainter(
                      knittingSymbolPart: knittingSymbolPart, 
                      symbolColor: symbolColor?? Colors.black,
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

class KnittingSymbolPartPainter extends CustomPainter {
  final KnittingSymbolPart knittingSymbolPart;
  final Color symbolColor;

  const KnittingSymbolPartPainter({
    required this.knittingSymbolPart,
    required this.symbolColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
      canvas.save();

      knittingSymbolPart.draw(canvas, size, symbolColor);

      canvas.restore();
  }

  @override
  bool shouldRepaint(covariant KnittingSymbolPartPainter oldDelegate) {
    return 
      oldDelegate.knittingSymbolPart != knittingSymbolPart || 
      oldDelegate.symbolColor != symbolColor;
  }

}
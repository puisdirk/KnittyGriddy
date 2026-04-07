
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';

class KnittingSymbolPartControl extends StatelessWidget {
  final KnittingSymbolPart knittingSymbolPart;
  final double iconSize;
  final Color? symbolColor;
  final void Function()? onTap;

  const KnittingSymbolPartControl({
    required this.knittingSymbolPart,
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
              offset: knittingSymbolPart.translation,
              child: Transform.scale(
                scaleX: knittingSymbolPart.scale.dx,
                scaleY: knittingSymbolPart.scale.dy,
                child: Transform.rotate(
                  angle: knittingSymbolPart.rotation,
                  child: CustomPaint(
                    size: Size(iconSize, iconSize),
                    painter: KnittingSymbolPartPainter(
                      knittingSymbolPart: knittingSymbolPart, 
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

class KnittingSymbolPartPainter extends CustomPainter {
  final KnittingSymbolPart knittingSymbolPart;
  final Color symbolColor;
  final double iconSize;

  const KnittingSymbolPartPainter({
    required this.knittingSymbolPart,
    required this.symbolColor,
    required this.iconSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
      canvas.save();

      canvas.scale(iconSize / stitchCellHeight);

      knittingSymbolPart.draw(canvas, size, symbolColor);

      canvas.restore();
  }

  @override
  bool shouldRepaint(covariant KnittingSymbolPartPainter oldDelegate) {
    return 
      oldDelegate.knittingSymbolPart != knittingSymbolPart || 
      oldDelegate.symbolColor != symbolColor ||
      oldDelegate.iconSize != iconSize;
  }

}
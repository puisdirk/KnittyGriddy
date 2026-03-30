
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_path.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:path_drawing/path_drawing.dart';

class StitchPartIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int stitchDefinitionColumn;
  final double iconSize;
  final Color? iconColor;

  const StitchPartIcon({
    required this.stitchDefinition,
    int? stitchDefinitionColumn,
    double? iconSize,
    this.iconColor,
    super.key
  }) : stitchDefinitionColumn = stitchDefinitionColumn?? 0, iconSize = iconSize?? 38;

  @override
  Widget build(BuildContext context) {
    KnittingSymbol icon = stitchDefinition.symbolAt(stitchDefinitionColumn);

    return 
      CustomPaint(
        size: const Size(stitchCellWidth, stitchCellHeight), 
        painter: StitchIconDataPainter(knittingSymbol: icon, iconColor: iconColor?? Colors.black, iconSize: iconSize)
      );
  }
}

class StitchIconDataPainter extends CustomPainter {

  final KnittingSymbol knittingSymbol;
  final Color iconColor;
  final double iconSize;

  const StitchIconDataPainter({
    required this.knittingSymbol,
    required this.iconColor,
    required this.iconSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (knittingSymbol.paths.isNotEmpty) {
      Paint ink = Paint()
        ..color = iconColor
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.scale(iconSize / stitchCellHeight);
      canvas.scale(knittingSymbol.scale.dx, knittingSymbol.scale.dy);
      canvas.rotate(knittingSymbol.rotation);
      canvas.translate(knittingSymbol.translation.dx, knittingSymbol.translation.dy);

      for (KnittingSymbolPath path in knittingSymbol.paths) {
        canvas.save();

        canvas.scale(path.scale.dx, path.scale.dy);
        canvas.rotate(path.rotation);
        canvas.translate(path.translation.dx, path.translation.dy);

        Path p = parseSvgPathData(path.path);
        canvas.drawPath(p, ink);

        canvas.restore();
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant StitchIconDataPainter oldDelegate) {
    return oldDelegate.knittingSymbol != knittingSymbol || oldDelegate.iconColor != iconColor || oldDelegate.iconSize != iconSize;
  }

}
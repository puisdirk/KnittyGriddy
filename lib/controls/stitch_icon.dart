import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/stitchrepo/knitting_symbol_control.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final Color? iconColor;
  final double iconSize;

  const StitchIcon({
    required this.stitchDefinition,
    double? iconSize,
    this.iconColor,
    super.key
  }) : iconSize = iconSize?? stitchCellHeight;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: iconSize / stitchCellHeight,
      child: Center(
        child: SizedBox(
          width: stitchCellWidth,
          height: stitchCellHeight,
          child:
            Row(
              children: [
                for (int column = 0; column < stitchDefinition.columns; column++) 
                  KnittingSymbolControl(knittingSymbol: stitchDefinition.symbolAt(column), symbolColor: iconColor)
              ],
            ),
        )
      ),
    );
  }
}
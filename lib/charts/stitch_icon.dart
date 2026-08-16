import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/charts/stitchrepo/knitting_symbol_control.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';

class StitchIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final Color? iconColor;
  final double iconSize;
  final bool withBorder;

  const StitchIcon({
    required this.stitchDefinition,
    double? iconSize,
    this.iconColor,
    this.withBorder = false,
    super.key
  }) : iconSize = iconSize?? stitchCellHeight;

  @override
  Widget build(BuildContext context) {
    return FittedScale(
      scale: iconSize / stitchCellHeight,
      child: SizedBox(
        width: stitchCellWidth * stitchDefinition.columns,
        height: stitchCellHeight,
        child:
          Stack(
            children: [
              for (int column = 0; column < stitchDefinition.columns; column++) 
                Positioned(
                  left: column * stitchCellWidth, 
                  child: KnittingSymbolControl(knittingSymbol: stitchDefinition.symbolAt(column), symbolColor: iconColor)
                ),
              if (withBorder)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade600
                    )
                  ),
                )
            ],
          ),
      ),
    );
  }
}
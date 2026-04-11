
import 'package:fitted_scale/fitted_scale.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/knitting_symbol_part_control.dart';

class StitchPartIcon extends StatelessWidget {
  final KnittingSymbolPart part;
  final Color? iconColor;
  final double iconSize;

  const StitchPartIcon({
    required this.part,
    double? iconSize,
    this.iconColor,  
    super.key
  }) : iconSize = iconSize?? stitchCellHeight;

  @override
  Widget build(BuildContext context) {
    return FittedScale(
      scale: iconSize / stitchCellHeight,
      child: Center(
        child: SizedBox(
          width: stitchCellWidth,
          height: stitchCellHeight,
          child: KnittingSymbolPartControl(knittingSymbolPart: part, symbolColor: iconColor?? Colors.black,),
        ),
      ),
    );
  }
}
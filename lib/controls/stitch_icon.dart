
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_part_icon.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final Color? iconColor;
  final double iconSize;

  const StitchIcon({
    required this.stitchDefinition,
    this.iconSize = 38,
    this.iconColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child:     
          stitchDefinition.columns == 1 ? 
            StitchPartIcon(stitchDefinition: stitchDefinition, iconSize: iconSize, iconColor: iconColor,) : 
            Row(
              children: [
                for (int column = 0; column < stitchDefinition.columns; column++) 
                  StitchPartIcon(stitchDefinition: stitchDefinition, stitchDefinitionColumn: column, iconSize: iconSize, iconColor: iconColor,),
              ],
            ),
      )
    );
  }
}
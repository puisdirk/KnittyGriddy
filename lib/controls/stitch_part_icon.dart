
import 'package:flutter/material.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchPartIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int stitchDefinitionColumn;
  final double iconSize;
  final Color? iconColor;

  const StitchPartIcon({
    required this.stitchDefinition,
    int? stitchDefinitionColumn,
    this.iconSize = 38,
    this.iconColor,
    super.key
  }) : stitchDefinitionColumn = stitchDefinitionColumn?? 1;

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = stitchDefinition.iconAt(stitchDefinitionColumn);
    return 
      icons.length == 1 ? 
      Icon(icons.first, size: iconSize, color: iconColor,) : 
      Stack(
        children: [
          for (IconData icon in icons)
            Positioned(child: Icon(icon, size: iconSize, color: iconColor,))
        ],
      );
  }
}
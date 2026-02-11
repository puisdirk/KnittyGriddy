
import 'package:flutter/material.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchPartIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int stitchDefinitionColumn;

  const StitchPartIcon({
    required this.stitchDefinition,
    int? stitchDefinitionColumn,
    super.key
  }) : stitchDefinitionColumn = stitchDefinitionColumn?? 1;

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = stitchDefinition.iconAt(stitchDefinitionColumn);
    return 
      icons.length == 1 ? 
      Icon(icons.first) : 
      Stack(
        children: [
          for (IconData icon in icons)
            Positioned(child: Icon(icon))
        ],
      );
  }
}
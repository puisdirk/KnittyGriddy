
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_part_icon.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;

  const StitchIcon({
    required this.stitchDefinition,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return stitchDefinition.columns == 1 ? 
      StitchPartIcon(stitchDefinition: stitchDefinition) : 
      Row(
        children: [
          for (int column = 1; column <= stitchDefinition.columns; column++) 
            StitchPartIcon(stitchDefinition: stitchDefinition, stitchDefinitionColumn: column),
        ],
      );

  }
}
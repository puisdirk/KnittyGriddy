import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MoveStitchToSetMenu extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final StitchSet currentStitchSet;

  const MoveStitchToSetMenu({
    required this.stitchDefinition,
    required this.currentStitchSet,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    List<StitchSet> otherSets = StitchRepository.instance.sets.where((s) => s.id != currentStitchSet.id).toList();
    return MenuAnchor(
      menuChildren: [
        for (StitchSet stitchSet in otherSets)
          MenuItemButton(
            onPressed: () {
              Provider.of<KnittyGriddyModel>(context, listen: false).moveStitchToSet(
                stitchDefinition: stitchDefinition, 
                sourceSetId: currentStitchSet.id, 
                targetSetId: stitchSet.id);
            },
            child: Text(stitchSet.name),
          )
      ],
      builder: (_, menuController, __) {
        return IconButton(
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          }, 
          icon: const Icon(Symbols.drive_file_move, weight: 700,),
        );
      },
    );
  }
}
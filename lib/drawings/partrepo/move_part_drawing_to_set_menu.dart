
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MovePartDrawingToSetMenu extends StatelessWidget {
  final PartDrawing partDrawing;
  final PartSet currentPartSet;

  const MovePartDrawingToSetMenu({
    required this.partDrawing,
    required this.currentPartSet,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    List<PartSet> otherSets = PartRepository.instance.sets.where((s) => s.id != currentPartSet.id).toList();
    return MenuAnchor(
      menuChildren: [
        for (PartSet partSet in otherSets)
          MenuItemButton(
            onPressed: () {
              Provider.of<DrawingsModel>(context, listen: false).movePartToSet(
                partDrawing: partDrawing, 
                sourceSetId: currentPartSet.id, 
                targetSetId: partSet.id);
            },
            child: Text(partSet.name),
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
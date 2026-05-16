import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/pattern_chooser/change_stitch_set_name_control.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class StitchSetNameControl extends StatefulWidget {
  final StitchSet stitchSet;

  const StitchSetNameControl({
    required this.stitchSet,
    super.key
  });

  @override
  State<StitchSetNameControl> createState() => _StitchSetNameControlState();
}

class _StitchSetNameControlState extends State<StitchSetNameControl> {
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return editing ?
      ChangeStitchSetNameControl(
        name: widget.stitchSet.name,
        nameChanged: (newName) {
          Provider.of<KnittyGriddyModel>(context, listen: false).renameStitchSet(widget.stitchSet.id, newName);
          setState(() => editing = false);
        }
      )
      :
      Row (
        children: [
          // TODO: icon if there is one
          Text(widget.stitchSet.name),
          IconButton(
            onPressed: () => setState(() => editing = true), 
            icon: const Icon(Icons.edit, size: 16,)
          ),
        ],
     );
  }
}
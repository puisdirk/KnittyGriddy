import 'package:flutter/material.dart';
import 'package:knitty_griddy/change_name_control.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
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
      ChangeNameControl(
        name: widget.stitchSet.name,
        nameChanged: (newName) {
          Provider.of<ChartsModel>(context, listen: false).renameStitchSet(widget.stitchSet.id, newName);
          setState(() => editing = false);
        }
      )
      :
      Row (
        children: [
          Text(widget.stitchSet.name),
          IconButton(
            onPressed: () => setState(() => editing = true), 
            icon: const Icon(Icons.edit, size: 16,)
          ),
        ],
     );
  }
}
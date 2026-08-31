
import 'package:flutter/material.dart';
import 'package:knitty_griddy/common/change_name_control.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';
import 'package:provider/provider.dart';

class PartSetNameControl extends StatefulWidget {
  final PartSet partSet;

  const PartSetNameControl({
    required this.partSet,
    super.key
  });

  @override
  State<PartSetNameControl> createState() => _PartSetNameControlState();
}

class _PartSetNameControlState extends State<PartSetNameControl> {
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return editing ?
      ChangeNameControl(
        name: widget.partSet.name,
        nameChanged: (newName) {
          Provider.of<DrawingsModel>(context, listen: false).renamePartSet(widget.partSet.id, newName);
          setState(() => editing = false);
        }
      )
      :
      Row (
        children: [
          Text(widget.partSet.name),
          IconButton(
            onPressed: () => setState(() => editing = true), 
            icon: const Icon(Icons.edit, size: 16,)
          ),
        ],
     );
  }
}
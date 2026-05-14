import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class StitchSetNameControl extends StatefulWidget {
  final StitchesSet stitchSet;

  const StitchSetNameControl({
    required this.stitchSet,
    super.key
  });

  @override
  State<StitchSetNameControl> createState() => _StitchSetNameControlState();
}

class _StitchSetNameControlState extends State<StitchSetNameControl> {
  late TextEditingController _nameController;
  late String _name;
  bool editing = false;

  void _nameChanged() {
    setState(() {
      _name = _nameController.text;
    });
  }

  @override
  void initState() {
    _name = widget.stitchSet.name;
    _nameController = TextEditingController(text: _name);
    _nameController.addListener(_nameChanged);

    super.initState();
  }

  @override
  void dispose() {
    _nameController.removeListener(_nameChanged);
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return editing ?
      Row (
        children: [
          SizedBox(
            width: 100,
            child: TextField(
              autofocus: true,
              onTapOutside: (_) {
                setState(() {
                  editing = false;
                  Provider.of<KnittyGriddyModel>(context, listen: false).renameStitchSet(widget.stitchSet.id, _name);
                });
              },
              controller: _nameController
            ),
          ),
          const Icon(Icons.check, color: Colors.green, size: 16,),
        ],
      ) :
      Row (
        children: [
          // TODO: icon if there is one
          Text(_name),
          IconButton(
            onPressed: () => setState(() => editing = true), 
            icon: const Icon(Icons.edit, size: 16,)
          ),
        ],
     );
  }
}
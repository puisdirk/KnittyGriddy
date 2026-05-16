import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class ChangeStitchSetNameControl extends StatefulWidget {
  final String name;
  final Function(String newName) nameChanged;

  const ChangeStitchSetNameControl({
    required this.name,
    required this.nameChanged,
    super.key
  });

  @override
  State<ChangeStitchSetNameControl> createState() => _ChangeStitchSetNameControlState();
}

class _ChangeStitchSetNameControlState extends State<ChangeStitchSetNameControl> {
  late TextEditingController _nameController;
  late String _name;

  void _nameChanged() {
    setState(() {
      _name = _nameController.text;
    });
  }

  @override
  void initState() {
    _name = widget.name;
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
    return Row (
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            autofocus: true,
            onTapOutside: (_) {
              widget.nameChanged(_name);
            },
            controller: _nameController
          ),
        ),
        const Icon(Icons.check, color: Colors.green, size: 16,),
      ],
    );
  }
}
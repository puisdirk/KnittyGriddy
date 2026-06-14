import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_commands_list.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_viewer.dart';

class DrawingEditorControl extends StatefulWidget {
  const DrawingEditorControl({super.key});

  @override
  State<DrawingEditorControl> createState() => _DrawingEditorControlState();
}

class _DrawingEditorControlState extends State<DrawingEditorControl> {
  String? selectedCommandId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(//flex: 2, 
          child: DrawingViewer(selectedCommandId: selectedCommandId,)
        ),
        //Expanded(flex: 1, 
        SizedBox(
          width: 400,
          child: DrawingCommandsList(
            selectedCommandId: selectedCommandId,
            onSelect: (id) => setState(() => selectedCommandId = id),
          )
        ),
      ],
    );
  }
}
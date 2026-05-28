import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_commands_list.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_viewer.dart';

class DrawingEditorControl extends StatelessWidget {
  const DrawingEditorControl({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 2, 
          child: DrawingViewer()
        ),
        Expanded(flex: 1, 
          child: DrawingCommandsList()
        ),
      ],
    );
  }
}
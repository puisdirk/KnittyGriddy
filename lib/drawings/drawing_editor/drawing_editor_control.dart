import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_viewer.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_commands_list.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';

class DrawingEditorControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final void Function(AbstractDrawing newDrawing) onDrawingChanged;

  const DrawingEditorControl({
    required this.drawing,
    required this.onDrawingChanged,
    super.key
  });

  @override
  State<DrawingEditorControl> createState() => _DrawingEditorControlState();
}

class _DrawingEditorControlState extends State<DrawingEditorControl> {
  String? selectedCommandId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DrawingViewer(
            drawing: widget.drawing, 
            selectedCommandId: selectedCommandId,
          )
        ),
        SizedBox(
          width: 410,
          child: DrawingCommandsList(
            drawing: widget.drawing,
            selectedCommandId: selectedCommandId,
            onSelect: (id) => setState(() => selectedCommandId = id),
            onDrawingChanged: widget.onDrawingChanged,
          )
        ),
      ],
    );
  }
}
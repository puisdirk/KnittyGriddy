import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';

class UndoRedoToolbar extends StatefulWidget {
  final bool canUndo;
  final bool canRedo;
  final void Function() undo;
  final void Function() redo;

  const UndoRedoToolbar({
    required this.canUndo,
    required this.canRedo,
    required this.undo,
    required this.redo,
    super.key
  });

  @override
  State<UndoRedoToolbar> createState() => _UndoRedoToolbarState();
}

class _UndoRedoToolbarState extends State<UndoRedoToolbar> {

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          hspacing,
          TextButton.icon(
            onPressed: widget.canUndo ? () => widget.undo() : null, 
            label: const Text('Undo'),
            icon: const Icon(Icons.undo),
          ),
          TextButton.icon(
            onPressed: widget.canRedo ? () => widget.redo() : null, 
            label: const Text('Redo'),
            icon: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }
}
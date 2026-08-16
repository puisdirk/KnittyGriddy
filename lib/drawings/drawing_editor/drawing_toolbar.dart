import 'package:flutter/material.dart';

class DrawingToolbar extends StatefulWidget {
  final bool canUndo;
  final bool canRedo;
  final void Function() undo;
  final void Function() redo;

  const DrawingToolbar({
    required this.canUndo,
    required this.canRedo,
    required this.undo,
    required this.redo,
    super.key
  });

  @override
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 10,),
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
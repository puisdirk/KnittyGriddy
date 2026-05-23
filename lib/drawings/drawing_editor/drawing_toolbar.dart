import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 10,),
          Selector<DrawingsModel, bool>(
            selector: (_, model) => model.canUndo,
            builder: (context, canUndo, _) {
              return TextButton.icon(
                onPressed: canUndo ? () => Provider.of<DrawingsModel>(context, listen: false).undo() : null, 
                label: const Text('Undo'),
                icon: const Icon(Icons.undo),
              );
            },
          ),
          Selector<DrawingsModel, bool>(
            selector: (_, model) => model.canRedo,
            builder: (context, canRedo, _) {
              return TextButton.icon(
                onPressed: canRedo ? () => Provider.of<DrawingsModel>(context, listen: false).redo() : null, 
                label: const Text('Redo'),
                icon: const Icon(Icons.redo),
              );
            },
          )
        ],
      ),
    );
  }
}
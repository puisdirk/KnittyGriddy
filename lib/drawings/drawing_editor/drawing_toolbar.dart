import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class DrawingToolbar extends StatefulWidget {
  final Drawing drawing;
  final bool showDrawingNameAndDescription;

  const DrawingToolbar({
    required this.drawing,
    required this.showDrawingNameAndDescription,
    super.key
  });

  @override
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  void _nameChanged() {
    Provider.of<DrawingsModel>(context, listen: false).setDrawingName(nameController.text);
  }

  void _descriptionChanged() {
    Provider.of<DrawingsModel>(context, listen: false).setDrawingDescription(descriptionController.text);
  }

  @override
  void initState() {
    nameController = TextEditingController(text: widget.drawing.name);
    nameController.addListener(_nameChanged);

    descriptionController = TextEditingController(text: widget.drawing.description);
    descriptionController.addListener(_descriptionChanged);

    super.initState();
  }

  @override
  void dispose() {
    nameController.removeListener(_nameChanged);
    nameController.dispose();

    descriptionController.removeListener(_descriptionChanged);
    descriptionController.dispose();

    super.dispose();
  }

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
          ),
          if (widget.showDrawingNameAndDescription)
            const SizedBox(width: 20,),
          if (widget.showDrawingNameAndDescription)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10,),
                    const Text('Name'),
                    const SizedBox(width: 10,),
                    SizedBox(width: 200,
                    child: TextField(controller: nameController,),
                    ),
                  ],
                ),
                const SizedBox(width: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10,),
                    const Text('Description'),
                    const SizedBox(width: 10,),
                    SizedBox(width: 600,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
              ],
            )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class DrawingToolbar extends StatefulWidget {
  final AbstractDrawing drawing;
  final bool showDrawingNameAndDescription;
  final void Function(AbstractDrawing newDrawing) onDrawingChanged;
  final bool canUndo;
  final bool canRedo;
  final void Function() undo;
  final void Function() redo;

  const DrawingToolbar({
    required this.drawing,
    required this.showDrawingNameAndDescription,
    required this.onDrawingChanged,
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
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;

  void _nameChanged() {
    widget.onDrawingChanged(widget.drawing.abstractCopyWith(name: nameController.text));
    if (widget.drawing is Drawing) {
      Provider.of<DrawingsModel>(context, listen: false).updateDrawingInfo();
    }
  }

  void _descriptionChanged() {
    widget.onDrawingChanged(widget.drawing.abstractCopyWith(description: descriptionController.text));
    if (widget.drawing is Drawing) {
      Provider.of<DrawingsModel>(context, listen: false).updateDrawingInfo();
    }
  }

  void _categoryChanged() {
    if (widget.drawing is PartDrawing) {
      widget.onDrawingChanged((widget.drawing as PartDrawing).copyWith(category: categoryController.text));
    }
  }

  @override
  void initState() {
    nameController = TextEditingController(text: widget.drawing.name);
    nameController.addListener(_nameChanged);

    descriptionController = TextEditingController(text: widget.drawing.description);
    descriptionController.addListener(_descriptionChanged);

    if (widget.drawing is PartDrawing) {
      categoryController = TextEditingController(text: (widget.drawing as PartDrawing).category);
      categoryController.addListener(_categoryChanged);
    }

    super.initState();
  }

  @override
  void dispose() {
    nameController.removeListener(_nameChanged);
    nameController.dispose();

    descriptionController.removeListener(_descriptionChanged);
    descriptionController.dispose();

    if (widget.drawing is PartDrawing) {
      categoryController.removeListener(_categoryChanged);
      categoryController.dispose();
    }

    super.dispose();
  }

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
                    hspacing,
                    const Text('Name'),
                    hspacing,
                    SizedBox(width: 200,
                      child: TextField(controller: nameController,),
                    ),
                    if (widget.drawing is PartDrawing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          hspacing,
                          hspacing,
                          const Text('Category'),
                          hspacing,
                          SizedBox(width: 200,
                            child: TextField(controller: categoryController,),
                          ),
                        ],
                      )
                  ],
                ),
                vspacing,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    hspacing,
                    const Text('Description'),
                    hspacing,
                    SizedBox(width: 600,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                vspacing,
              ],
            )
        ],
      ),
    );
  }
}
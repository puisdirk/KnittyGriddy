import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class DrawingToolbar extends StatefulWidget {
  final AbstractDrawing drawing;
  final bool showToolbarContents;
  final void Function(AbstractDrawing? newDrawing) onDrawingChanged;
  final bool canUndo;
  final bool canRedo;
  final void Function() undo;
  final void Function() redo;

  const DrawingToolbar({
    required this.drawing,
    required this.showToolbarContents,
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

  late String name;
  late String description;
  late String category;

  void _nameChanged() {
    setState(() => name = nameController.text);
  }

  void _descriptionChanged() {
    setState(() => description = descriptionController.text);
  }

  void _categoryChanged() {
    setState(() => category = categoryController.text);
  }

  @override
  void initState() {
    name = widget.drawing.name;
    nameController = TextEditingController(text: name);
    nameController.addListener(_nameChanged);

    description = widget.drawing.description;
    descriptionController = TextEditingController(text: description);
    descriptionController.addListener(_descriptionChanged);

    if (widget.drawing is PartDrawing) {
      category = (widget.drawing as PartDrawing).category;
      categoryController = TextEditingController(text: category);
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
          if (widget.showToolbarContents)
            const SizedBox(width: 20,),
          if (widget.showToolbarContents)
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
                      ),
                    hspacing,
                    hspacing,
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: () {
                            if (widget.drawing is Drawing) {
                              widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                                name: name,
                                description: description,
                              ));
                              Provider.of<DrawingsModel>(context, listen: false).updateDrawingInfo();
                            } else {
                              widget.onDrawingChanged((widget.drawing as PartDrawing).copyWith(
                                name: name,
                                description: description,
                                category: category,
                              ));
                            }
                           },
                          icon: const Icon(Icons.check)
                        ),
                        hspacing,
                        IconButton.outlined(
                          onPressed: () {
                            setState(() {
                              name = widget.drawing.name;
                              nameController.text = widget.drawing.name;
                              description = widget.drawing.description;
                              descriptionController.text = widget.drawing.description;
                              if (widget.drawing is PartDrawing) {
                                category = (widget.drawing as PartDrawing).category;
                                categoryController.text = (widget.drawing as PartDrawing).category;
                              }
                            });
                            widget.onDrawingChanged(null);
                          },
                          icon: const Icon(Icons.close)
                        ),
                      ],
                    ),
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
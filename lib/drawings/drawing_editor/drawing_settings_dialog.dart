import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';

class DrawingSettingsDialog extends StatefulWidget {

  final AbstractDrawing drawing;

  const DrawingSettingsDialog({
    required this.drawing,
    super.key
  });

  @override
  State<DrawingSettingsDialog> createState() => _DrawingSettingsDialogState();
}

class _DrawingSettingsDialogState extends State<DrawingSettingsDialog> {
  late String name;
  late String description;
  late String category;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;

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

    category = (widget.drawing is PartDrawing) ? (widget.drawing as PartDrawing).category : '';
    categoryController = TextEditingController(text: category);
    categoryController.addListener(_categoryChanged);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant DrawingSettingsDialog oldWidget) {
    nameController.text = widget.drawing.name;
    descriptionController.text = widget.drawing.description;
    categoryController.text = (widget.drawing is PartDrawing) ? (widget.drawing as PartDrawing).category : '';

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    nameController.removeListener(_nameChanged);
    nameController.dispose();

    descriptionController.removeListener(_descriptionChanged);
    descriptionController.dispose();

    categoryController.removeListener(_categoryChanged);
    categoryController.dispose();

    super.dispose();
  }

  static const double _kLabelWidth = 80;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Drawing settings'),
      content: SizedBox(
        width: 400,
        height: 490,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Name', textAlign: TextAlign.right)),
                hspacing,
                SizedBox(width: 300,
                  child: TextField(
                    controller: nameController,
                  ),)
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Description', textAlign: TextAlign.right)),
                hspacing,
                SizedBox(width: 300,
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 3,
                  ),)
              ],
            ),
            vspacing,
            if (widget.drawing is PartDrawing)
              Row(
                children: [
                  const SizedBox(width: _kLabelWidth, child: Text('Category', textAlign: TextAlign.right)),
                  hspacing,
                  SizedBox(width: 300,
                    child: TextField(
                      controller: categoryController,
                    ),)
                ],
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          }, 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.drawing is PartDrawing) {
              Navigator.of(context).pop(
                (widget.drawing as PartDrawing).copyWith(
                  name: name,
                  description: description,
                  category: category
                )
              );
            } else {
              Navigator.of(context).pop(
                widget.drawing.abstractCopyWith(
                  name: name, 
                  description: description,
              ));
            }
          }, 
          child: const Text('Ok')
        )

      ],
    );
  }
}
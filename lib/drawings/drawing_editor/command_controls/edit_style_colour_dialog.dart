import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditStyleColourDialog extends StatefulWidget {
  final Color colour;

  const EditStyleColourDialog({
    required this.colour,
    super.key
  });

  @override
  State<EditStyleColourDialog> createState() => _EditStyleColourDialogState();
}

class _EditStyleColourDialogState extends State<EditStyleColourDialog> {
  late Color pickerColor;

  @override
  void initState() {
    pickerColor = widget.colour;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change colour'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor, 
          onColorChanged: (value) => setState(() => pickerColor = value),
          displayThumbColor: true,
          portraitOnly: true,
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
            Navigator.of(context).pop(pickerColor);
          }, 
          child: const Text('Ok')
        )
      ],
    );
  }
}
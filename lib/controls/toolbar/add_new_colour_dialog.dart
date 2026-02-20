import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class AddNewColourDialog extends StatefulWidget {
  final List<NamedColour> usedColours;

  const AddNewColourDialog({
    required this.usedColours,
    super.key
  });

  @override
  State<AddNewColourDialog> createState() => _AddNewColourDialogState();
}

class _AddNewColourDialogState extends State<AddNewColourDialog> {
  Color pickerColor = Colors.white;
  String pickerColorName = '';
  late TextEditingController pickerColorNameController;
  bool isValidColourName = false;

  void _pickerColorNameChanged() {
    setState(() {
      pickerColorName = pickerColorNameController.text;
      isValidColourName = pickerColorNameController.text.isNotEmpty && !widget.usedColours.any((uc) => uc.name == pickerColorNameController.text);
    });
  }

  @override
  void initState() {
    pickerColorNameController = TextEditingController(text: pickerColorName);
    pickerColorNameController.addListener(_pickerColorNameChanged);
    super.initState();
  }

  @override
  void dispose() {
    pickerColorNameController.removeListener(_pickerColorNameChanged);
    pickerColorNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new colour'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (newColor) => setState(() => pickerColor = newColor),
              displayThumbColor: true,
              portraitOnly: true,
            ),
            Row(
              children: [
                const Text('Name: '),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: pickerColorNameController,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: 
            isValidColourName ?
            () {
              Provider.of<KnittyGriddyModel>(context, listen: false).addNamedColour(pickerColor, pickerColorName);
              Navigator.of(context).pop();
            } :
            null,
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
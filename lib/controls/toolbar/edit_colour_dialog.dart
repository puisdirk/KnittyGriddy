import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class EditColourDialog extends StatefulWidget {
  final NamedColour colour;
  final List<NamedColour> usedColours;

  const EditColourDialog({
    required this.colour, 
    required this.usedColours,
    super.key
  });

  @override
  State<EditColourDialog> createState() => _EditColourDialogState();
}

class _EditColourDialogState extends State<EditColourDialog> {
  late Color pickerColor;
  late String pickerColorName;
  late TextEditingController pickerColorNameController;
  bool isValidColourName = true;

  void _pickerColorNameChanged() {
    setState(() {
      pickerColorName = pickerColorNameController.text;
      isValidColourName = pickerColorNameController.text.isNotEmpty && 
        !widget.usedColours.any((nc) => nc != widget.colour && nc.name == pickerColorNameController.text);
    });
  }

  @override
  void initState() {
    pickerColor = widget.colour.color;
    pickerColorName = widget.colour.name;

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
        title: Text('Edit colour "${widget.colour.name}"'),
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
                  Text('Name: ', style: isValidColourName ? 
                    Theme.of(context).textTheme.bodyMedium : 
                    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red)
                  ),
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
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop();
          }, 
          child: const Text('Cancel')
          ),
          ElevatedButton(
            onPressed: 
              isValidColourName ?
                () {
                  Provider.of<KnittyGriddyModel>(context, listen: false).setNamedColour(widget.colour, pickerColor, pickerColorNameController.text);
                  Navigator.of(context).pop();
                } :
                null,
            child: const Text('Ok'),
          ),
        ],
      );
    }
}
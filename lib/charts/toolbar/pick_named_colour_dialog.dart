import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/named_colour.dart';
import 'package:knitty_griddy/pick_colour_control.dart';

class PickNamedColourDialog extends StatefulWidget {
  final NamedColour initialColour;
  final List<NamedColour> usedColours;

  const PickNamedColourDialog({
    this.initialColour = const NamedColour(name: '', color: Colors.white),
    required this.usedColours,
    super.key
  });

  @override
  State<PickNamedColourDialog> createState() => _PickNamedColourDialogState();
}

class _PickNamedColourDialogState extends State<PickNamedColourDialog> {
  late NamedColour newNamedColour;
  late TextEditingController pickerColorNameController;
  bool get isValidColourName => 
    pickerColorNameController.text.isNotEmpty && 
    widget.usedColours.where((uc) => uc.name == pickerColorNameController.text).isEmpty;

  void _pickerColorNameChanged() {
    setState(() {
      newNamedColour = newNamedColour.copyWith(name: pickerColorNameController.text);
    });
  }

  @override
  void initState() {
    newNamedColour = widget.initialColour;

    pickerColorNameController = TextEditingController(text: newNamedColour.name);
    pickerColorNameController.addListener(_pickerColorNameChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PickNamedColourDialog oldWidget) {
    newNamedColour = widget.initialColour;
    pickerColorNameController.text = newNamedColour.name;

    super.didUpdateWidget(oldWidget);
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
      title: const Text(''),
      content: SizedBox(
        height: 510,
        child: Column(
          children: [
            PickColourControl(
              initialColor: newNamedColour.color,
              onChanged: (newColor) => setState(() => newNamedColour = newNamedColour.copyWith(color: newColor)),
              knownColours: widget.usedColours.map((uc) => uc.color).toList(),
            ),
            Row(
              children: [
                TooltipVisibility(
                  visible: !isValidColourName,
                  child: Tooltip(
                    message: pickerColorNameController.text.isEmpty ? 'You must provide a name' : 'This name is already used',
                    child: Text('Name: ', style: isValidColourName ?
                      Theme.of(context).textTheme.bodyMedium! :
                      Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red)
                    ),
                  ),
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
              Navigator.of(context).pop(newNamedColour);
            } :
            null,
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
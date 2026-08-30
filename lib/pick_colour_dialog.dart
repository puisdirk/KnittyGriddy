import 'package:flutter/material.dart';
import 'package:knitty_griddy/pick_colour_control.dart';
import 'package:knitty_griddy/utils/constants.dart';

class PickColourDialog extends StatefulWidget {
  final List<Color> knownColours;
  final Color initialColor;

  const PickColourDialog({
    this.knownColours = const[],
    this.initialColor = Colors.black,
    super.key
  });

  @override
  State<PickColourDialog> createState() => _PickColourDialogState();
}

class _PickColourDialogState extends State<PickColourDialog> {
  late Color currentColour;

  void _colorChanged(Color newColor) {
    setState(() => currentColour = newColor);
  }

  @override
  void initState() {
    currentColour = widget.initialColor;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PickColourDialog oldWidget) {
    currentColour = widget.initialColor;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a colour'),
      content: SizedBox(
        height: kColourPickerHeight + (widget.knownColours.isNotEmpty ? kKnowColoursHeight : 0),
        child: PickColourControl(
          initialColor: currentColour,
          knownColours: widget.knownColours,
          onChanged: _colorChanged,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context, null), 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, currentColour), 
          child: const Text('OK')
        )
      ],
    );
  }
}
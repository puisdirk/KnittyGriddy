import 'dart:math';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/colour_reference.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/common/pick_colour_control.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class PickColourReferenceDialog extends StatefulWidget {
  final AbstractDrawing drawing;
  final List<Color> knownColours;
  final ColourReference initialColor;

  const PickColourReferenceDialog({
    required this.drawing,
    this.knownColours = const[],
    this.initialColor = const ColourReference(),
    super.key
  });

  @override
  State<PickColourReferenceDialog> createState() => _PickColourReferenceDialogState();
}

class _PickColourReferenceDialogState extends State<PickColourReferenceDialog> {
  late ColourReference currentColour;

  void _colorChanged(Color newColor) {
    setState(() => currentColour = currentColour.copyWith(
      measurementId: '',
      measurementLabel: '',
      colorValue: newColor.value,
    ));
  }

  void _colourReferenceChanged(MeasurementCommand cmd) {
    setState(() =>
      currentColour = currentColour.copyWith(
        measurementId: cmd.id,
        measurementLabel: cmd.label,
        colorValue: cmd.colourValue
      )
    );
  }

  @override
  void initState() {
    currentColour = widget.initialColor;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PickColourReferenceDialog oldWidget) {
    currentColour = widget.initialColor;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = 0;
    for (MeasurementCommand cmd in widget.drawing.measurements.where((m) => m.unit == Unit.colour)) {
      cardWidth = max(cardWidth, MathUtitilies.textSize('@${cmd.label}', Theme.of(context).textTheme.bodyMedium!).width);
    }
    cardWidth += (4 * hspacewidth) + 20;

    return AlertDialog(
      title: const Text('Pick a colour'),
      content: SizedBox(
        width: 370,
        height: kColourPickerHeight + 
                (widget.knownColours.isNotEmpty ? kKnowColoursHeight : 0) +
                (widget.drawing.measurements.where((m) => m.unit == Unit.colour).isNotEmpty ? kColourMeasurementsHeight : 0),
        child: Column(
          children: [
            SizedBox(
              height: kColourPickerHeight + (widget.knownColours.isNotEmpty ? kKnowColoursHeight : 0),
              child: PickColourControl(
                initialColor: currentColour.color,
                knownColours: widget.knownColours,
                onChanged: _colorChanged,
              ),
            ),
            if (widget.drawing.measurements.where((m) => m.unit == Unit.colour).isNotEmpty)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Colour measurements'),
                ],
              ),
            if (widget.drawing.measurements.where((m) => m.unit == Unit.colour).isNotEmpty)
              SizedBox(
                width: 370,
                height: kColourMeasurementsHeight - 20,
                child: SingleChildScrollView(
                  child: Wrap(
                    children: [
                      for (MeasurementCommand cmd in widget.drawing.measurements.where((m) => m.unit == Unit.colour))
                        SizedBox(
                          width: cardWidth,
                          height: 50,
                          child: Card(
                            color: cmd.id == currentColour.measurementId ? Colors.blue.withAlpha(60) : null,
                            child: InkWell(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              splashColor: Colors.blue.withAlpha(30),
                              onTap: () => _colourReferenceChanged(cmd),
                              child: Row(
                                children: [
                                  hspacing,
                                  ColorIndicator(
                                    width: 20, 
                                    height: 20, 
                                    borderColor: Colors.grey,
                                    borderRadius: 6,
                                    hasBorder: true,
                                    color: Color(cmd.colourValue),
                                  ),
                                  hspacing,
                                  Text('@${cmd.label}'),
                                  hspacing,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          ],
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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_viewer.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/panel_field_components/colour_well.dart';
import 'package:knitty_griddy/common/pick_colour_control.dart';
import 'package:knitty_griddy/utils/constants.dart';

class DrawingMeasurementsDialog extends StatefulWidget {
  final Drawing drawing;
  final List<Color> knownColours;

  const DrawingMeasurementsDialog({
    required this.drawing,
    required this.knownColours,
    super.key
  });

  @override
  State<DrawingMeasurementsDialog> createState() => _DrawingMeasurementsDialogState();
}

class _DrawingMeasurementsDialogState extends State<DrawingMeasurementsDialog> {
  late Drawing alteredDrawing;

  @override
  void initState() {
    alteredDrawing = widget.drawing;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant DrawingMeasurementsDialog oldWidget) {
    alteredDrawing = widget.drawing;
    
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change measurements'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  for (MeasurementCommand cmd in alteredDrawing.measurements)
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(cmd.label),
                              ),
                            ),
                            hspacing,
                            if (cmd.unit == Unit.colour)
                              CustomPopup(
                                content: SizedBox(
                                  width: 370,
                                  height: 470,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 350,
                                            child: Center(
                                              child: PickColourControl(
                                                initialColor: Color(cmd.colourValue),
                                                knownColours: widget.knownColours,
                                                knownColoursLabel: 'Pattern colours',
                                                onChanged: (Color newColor) {
                                                  setState(() => alteredDrawing = alteredDrawing.copyWith(
                                                    commands: alteredDrawing.commands.map((c) => c.id != cmd.id ? c :
                                                      (c as MeasurementCommand).copyWith(colourValue: newColor.value)
                                                    ).toList()
                                                  ).validate());
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                contentDecoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  color: Colors.white
                                ),
                                arrowColor: Colors.grey,
                                child: ColourWell(
                                  selected: false,
                                  color: Color(cmd.colourValue)
                                )
                              ),
                            if (cmd.unit != Unit.colour)
                              SizedBox(
                                width: 160,
                                child: SpinBox(
                                  min: cmd.minValue,
                                  max: cmd.maxValue,
                                  value: cmd.value,
                                  decimals: cmd.decimals,
                                  step: 1 / pow(10, cmd.decimals),
                                  onChanged: (value) {
                                    setState(() => alteredDrawing = alteredDrawing.copyWith(
                                      commands: alteredDrawing.commands.map((c) => c.id != cmd.id ? c :
                                        (c as MeasurementCommand).copyWith(value: value)
                                      ).toList()
                                    ).validate());
                                  },
                                ),
                              ),
                          ],
                        ),
                        vspacing,
                      ],
                    ),
                ],
              )
            ),
            SizedBox(
              width: 250,
              child: DrawingViewer(
                drawing: alteredDrawing, 
                selectedCommandId: null
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
          onPressed: () => Navigator.pop(context, alteredDrawing), 
          child: const Text('OK')
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/drawing_part_icon.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/meaurement_override.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/drawing_editor/part_chooser.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class IncludedPartCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final IncludedPartCommand command;
  final bool sorting;
  final bool editing;
  final void Function(IncludedPartCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(IncludedPartCommand newCommand) onChanged;

  const IncludedPartCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<IncludedPartCommandControl> createState() => _IncludedPartCommandControlState();
}

class _IncludedPartCommandControlState extends State<IncludedPartCommandControl> {

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      widget.onChangeLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  Widget createViewContent() {
    String content = '';

    if (widget.command.partInfo != null) {
      content += widget.command.partInfo!.partLabel;
    }

    return Row(
      children: [
        const Icon(Symbols.apparel),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold,),
                TextSpan(text: content.isEmpty ? ' ???' : ' $content', style: smallStyle,)
              ]
            )
          ),
        )
      ],
    );
  }

  void setMeasurementOverrideFormula(MeasurementOverride moverride, String newFormula) {
    widget.onChanged(widget.command.copyWith(
      measurementOverrides: widget.command.measurementOverrides.map((m) => 
        m.measurementId != moverride.measurementId ? m : m.copyWith(formula: newFormula)).toList()
    ));
  }

  Widget createEditContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Symbols.apparel),
            hspacing,
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(
              key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: labelChanged,
            ),
          ],
        ),
        vspacing,
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Part'),
            hspacing,
            if (widget.command.partInfo != null)
              DrawingPartIcon(partInfo: widget.command.partInfo!, size: 32,),
            OutlinedButton.icon(
              iconAlignment: IconAlignment.end,
              onPressed: () async {
                PartInfo? partInfo = await showDialog(barrierDismissible: false, context: context, builder: (context) => 
                  PartChooser(selectedPartInfo: widget.command.partInfo),
                );
                if (partInfo != widget.command.partInfo) {
                  widget.onChanged(widget.command.copyWith(partInfo: partInfo));
                } 
              },
              icon: const Icon(Icons.edit, size: 16,),
              label: Text(widget.command.partInfo == null ? 'No part selected' : widget.command.partInfo!.partLabel, style: smallStyle,)
            ),
          ]
        ),
        vspacing,
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Anchor'),
            hspacing,
            DropdownButton<String>(
              key: GlobalObjectKey('${widget.command.id}-anchor'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in widget.drawing.points)
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.anchorPointId) {
                  widget.onChanged(
                    widget.command.copyWith(
                      anchorPointId: value?? '',
//                      partInfo: widget.command.partInfo?? widget.command.partInfo!.copyWith(storedOffsetPartDrawing: null)
                    )//.clearValidation().validate(widget.drawing) as IncludedPartCommand
                  );
                }
              },
              value: widget.command.anchorPointId,
            ),
          ],
        ),
        vspacing,
        Column(
          children: [
            for (MeasurementOverride moverride in widget.command.measurementOverrides)
              Column(
                children: [
                  Row(
                    children: [
                      SmallLabel(label: moverride.measurementLabel, width: 100,),
                      hspacing,
                      FormulaFieldControl(
                        formula: moverride.formula, 
                        width: 200, 
                        excludeCommand: widget.command, 
                        onFormulaChanged: (newFormula) => setMeasurementOverrideFormula(moverride, newFormula),
                        unitLabel: moverride.unit.shortLabel,
                      )
                    ],
                  ),
                  vspacing,
                ],
              )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
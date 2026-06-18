import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MeasurementCommandControl extends StatefulWidget {
  final MeasurementCommand command;
  final bool sorting;
  final bool editing;

  const MeasurementCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<MeasurementCommandControl> createState() => _MeasurementCommandControlState();
}

class _MeasurementCommandControlState extends State<MeasurementCommandControl> {

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommandLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget createViewContent() {
    return Row(
      children: [
        const Icon(Symbols.square_foot),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold),
                TextSpan(
                  text: ' ${widget.command.value.toStringAsFixed(widget.command.decimals)} ${widget.command.unit.shortLabel}', 
                  style: smallStyle
                )
              ]
            )
          ),
        ),
      ],
    );
  }

  Widget createEditContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Measurement', style: smallStyle,)
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
            hspacing,
            const SmallLabel(label: 'Unit'),
            hspacing,
            DropdownButton<Unit>(
              key: GlobalObjectKey('${widget.command.id}-unit'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (Unit unit in Unit.values)
                  DropdownMenuItem(value: unit, child: Text(unit.label))
              ],
              value: widget.command.unit,
              onChanged: (value) {
                if (value != widget.command.unit) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(unit: value));
                }
              },
            ),

          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Decimals'),
            hspacing,
            SizedBox(
              width: 180,
              child: SpinBox(
                key: GlobalObjectKey('${widget.command.id}-dec'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.decimals.toDouble()) {
                    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(decimals: value.toInt()));
                  }
                },
                min: 0,
                max: 5,
                value: widget.command.decimals.toDouble(),
              ),
            )
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Min'),
            hspacing,
            SizedBox(
              width: 180,
              child: SpinBox(
                key: GlobalObjectKey('${widget.command.id}-min'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.minValue) {
                    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(minValue: value));
                  }
                },
                step: 1 / pow(10, widget.command.decimals),
                decimals: widget.command.decimals,
                value: widget.command.minValue,
                min: -100000,
                max: widget.command.maxValue,
              ),
            )
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Max'),
            hspacing,
            SizedBox(
              width: 180,
              child: SpinBox(
                key: GlobalObjectKey('${widget.command.id}-max'),
                textStyle: smallStyle,
                onChanged:(value) {
                  if (value != widget.command.maxValue) {
                    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(maxValue: value));
                  }
                },
                step: 1 / pow(10, widget.command.decimals),
                decimals: widget.command.decimals,
                value: widget.command.maxValue,
                min: widget.command.minValue,
                max: 100000,
              ),
            )
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Default'),
            hspacing,
            SizedBox(
              width: 180,
              child: SpinBox(
                key: GlobalObjectKey('${widget.command.id}-def'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.decimals) {
                    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(value: value));
                  }
                },
                step: 1 / pow(10, widget.command.decimals),
                decimals: widget.command.decimals,
                value: widget.command.value,
                min: widget.command.minValue,
                max: widget.command.maxValue,
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
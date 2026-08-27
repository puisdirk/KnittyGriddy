import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class MeasurementCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final MeasurementCommand command;
  final bool sorting;
  final bool editing;
  final void Function(MeasurementCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(MeasurementCommand newCommand) onChanged;

  const MeasurementCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<MeasurementCommandControl> createState() => _MeasurementCommandControlState();
}

class _MeasurementCommandControlState extends State<MeasurementCommandControl> {

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      widget.onChangeLabel(widget.command.copyWith(label: newText), widget.command.label);
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
            Icon(Symbols.square_foot),
            hspacing,
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(
              key: ValueKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: labelChanged,
            ),
            hspacing,
            const SmallLabel(label: 'Unit'),
            hspacing,
            DropdownButton<Unit>(
              key: ValueKey('${widget.command.id}-unit'),
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
                  if (value == Unit.angle) {
                    widget.onChanged(widget.command.copyWith(unit: value, minValue: -360, maxValue: 360));
                  } else {
                    widget.onChanged(widget.command.copyWith(unit: value));
                  }
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
                key: ValueKey('${widget.command.id}-dec'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.decimals.toDouble()) {
                    widget.onChanged(widget.command.copyWith(decimals: value.toInt()));
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
                key: ValueKey('${widget.command.id}-min'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.minValue) {
                    widget.onChanged(widget.command.copyWith(minValue: value));
                  }
                },
                step: 1 / pow(10, widget.command.decimals),
                decimals: widget.command.decimals,
                value: widget.command.minValue,
                min: widget.command.unit == Unit.angle ? -360 : -100000,
                max: widget.command.unit == Unit.angle ? 360 : widget.command.maxValue,
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
                key: ValueKey('${widget.command.id}-max'),
                textStyle: smallStyle,
                onChanged:(value) {
                  if (value != widget.command.maxValue) {
                    widget.onChanged(widget.command.copyWith(maxValue: value));
                  }
                },
                step: 1 / pow(10, widget.command.decimals),
                decimals: widget.command.decimals,
                value: widget.command.maxValue,
                min: widget.command.unit == Unit.angle ? -360 : widget.command.minValue,
                max: widget.command.unit == Unit.angle ? 360 : 100000,
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
                key: ValueKey('${widget.command.id}-def'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.value) {
                    widget.onChanged(widget.command.copyWith(value: value));
                  }
                },
                step: 1 / pow(10, widget.command.decimals),
                decimals: widget.command.decimals,
                value: widget.command.value,
                min: widget.command.unit == Unit.angle ? -360 : widget.command.minValue,
                max: widget.command.unit == Unit.angle ? 360 : widget.command.maxValue,
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
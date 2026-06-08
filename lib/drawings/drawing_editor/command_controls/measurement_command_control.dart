import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
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
  late TextEditingController labelController;

  void labelChanged() {
    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: labelController.text));
  }

  @override
  void initState() {
    labelController = TextEditingController(text: widget.command.label);
    labelController.addListener(labelChanged);

    super.initState();
  }

  @override
  void dispose() {
    labelController.removeListener(labelChanged);
    labelController.dispose();

    super.dispose();
  }

  Widget createViewContent() {
    return Row(
      children: [
        Text(widget.command.label, style: smallStyleBold,),
        hspacing,
        Text('${widget.command.value.toStringAsFixed(widget.command.decimals)} ${widget.command.unit.shortLabel}', style: smallStyle,),
        const Spacer(),
        if (!widget.sorting && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
          Tooltip(
            message: widget.command.errors.join('\n'),
            child: const Icon(Icons.error_outline),
          ),
        if (!widget.sorting && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
          hspacing,
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
              key: GlobalObjectKey('${widget.command.id}-label'),
              controller: labelController, 
              width: 100
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
                Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(unit: value));
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
                onChanged: (value) => 
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(decimals: value.toInt())),
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
                onChanged: (value) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(minValue: value)),
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
                onChanged:(value) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(maxValue: value)),
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
                onChanged: (value) => 
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(value: value)),
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
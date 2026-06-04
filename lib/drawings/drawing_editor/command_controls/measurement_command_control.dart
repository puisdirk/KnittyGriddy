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
  final void Function(MeasurementCommand newCommand) finishedEditing;
  final bool sorting;

  const MeasurementCommandControl({
    required this.command,
    required this.finishedEditing,
    required this.sorting,
    super.key
  });

  @override
  State<MeasurementCommandControl> createState() => _MeasurementCommandControlState();
}

class _MeasurementCommandControlState extends State<MeasurementCommandControl> {
  bool editing = false;
  late MeasurementCommand changedCommand;

  late TextEditingController labelController;

  void labelChanged() {
    setState(() => changedCommand = changedCommand.copyWith(label: labelController.text));
  }

  @override
  void initState() {
    changedCommand = widget.command.copyWith();

    labelController = TextEditingController(text: changedCommand.label);
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
        Text(changedCommand.label, style: smallStyleBold,),
        hspacing,
        Text('${changedCommand.value.toStringAsFixed(changedCommand.decimals)} ${changedCommand.unit.shortLabel}', style: smallStyle,),
        const Spacer(),
        if (!widget.sorting && widget.command.isValidated && !widget.command.valid && widget.command.errors.isNotEmpty)
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
            SmallTextField(controller: labelController, width: 100),
            hspacing,
            const SmallLabel(label: 'Unit'),
            hspacing,
            DropdownButton<Unit>(
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
              value: changedCommand.unit,
              onChanged: (value) {
                setState(() => changedCommand = changedCommand.copyWith(unit: value));
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
                textStyle: smallStyle,
                onChanged: (value) => setState(() {
                  changedCommand = changedCommand.copyWith(decimals: value.toInt());
                }),
                min: 0,
                max: 5,
                value: changedCommand.decimals.toDouble(),
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
                textStyle: smallStyle,
                onChanged: (value) => setState(() {
                  changedCommand = changedCommand.copyWith(minValue: value);
                }),
                step: 1 / pow(10, changedCommand.decimals),
                decimals: changedCommand.decimals,
                value: changedCommand.minValue,
                min: -100000,
                max: changedCommand.maxValue,
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
                textStyle: smallStyle,
                onChanged: (value) => setState(() {
                  changedCommand = changedCommand.copyWith(maxValue: value);
                }),
                step: 1 / pow(10, changedCommand.decimals),
                decimals: changedCommand.decimals,
                value: changedCommand.maxValue,
                min: changedCommand.minValue,
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
                textStyle: smallStyle,
                onChanged: (value) => setState(() {
                  changedCommand = changedCommand.copyWith(value: value);
                }),
                step: 1 / pow(10, changedCommand.decimals),
                decimals: changedCommand.decimals,
                value: changedCommand.value,
                min: changedCommand.minValue,
                max: changedCommand.maxValue,
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double controlHeight = 60;
    if (editing && !widget.sorting) {
      controlHeight = 320;
    }

    return SizedBox(
      height: controlHeight,
      child: Container(
        decoration: BoxDecoration(
          color: (widget.command.validated && !widget.command.valid) ? Colors.red.withAlpha(20) : Colors.grey.shade100,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: (editing && !widget.sorting) ? createEditContent() : createViewContent(),
              ),
              if (!widget.sorting)
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (editing) {
                        widget.finishedEditing(changedCommand);
                      }
                      setState(() => editing = !editing);
                    }, 
                    icon: editing ? const Icon(Icons.check) : const Icon(Icons.edit),
                  ),
                  if (editing)
                    IconButton(
                      onPressed: () => widget.finishedEditing(changedCommand), 
                      icon: const Icon(Icons.refresh)
                    ),
                  const Spacer(),
                  if (editing && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
                    Tooltip(
                      message: widget.command.errors.join('\n'),
                      child: const Icon(Icons.error_outline),
                    ),
                  if (editing && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
                    const Spacer(),
                  if (editing)
                    IconButton(
                      onPressed: () => Provider.of<DrawingsModel>(context, listen: false).deleteCommand(commandId: changedCommand.id), 
                      icon: const Icon(Icons.delete)
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
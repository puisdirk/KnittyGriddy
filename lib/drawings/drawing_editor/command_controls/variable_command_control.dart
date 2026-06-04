import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class VariableCommandControl extends StatefulWidget {
  final VariableCommand command;
  final void Function(VariableCommand newCommand) finishedEditing;
  final bool sorting;

  const VariableCommandControl({
    required this.command,
    required this.finishedEditing,
    required this.sorting,
    super.key
  });

  @override
  State<VariableCommandControl> createState() => _VariableCommandControlState();
}

class _VariableCommandControlState extends State<VariableCommandControl> {
  bool editing = false;
  late VariableCommand changedCommand;

  late TextEditingController labelController;
  late TextEditingController formulaController;
  late FocusNode formulaFocusNode;

  void labelChanged() {
    setState(() => changedCommand = changedCommand.copyWith(label: labelController.text));
  }

  void formulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(formula: formulaController.text));
  }

  @override
  void initState() {
    changedCommand = widget.command.copyWith();

    labelController = TextEditingController(text: changedCommand.label);
    labelController.addListener(labelChanged);

    formulaController = TextEditingController(text: changedCommand.formula);
    formulaController.addListener(formulaChanged);
    formulaFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    labelController.removeListener(labelChanged);
    labelController.dispose();

    formulaController.removeListener(formulaChanged);
    formulaController.dispose();
    formulaFocusNode.dispose();

    super.dispose();
  }

  Widget createViewContent() {
    return Row(
      children: [
        Text(changedCommand.label, style: smallStyleBold,),
        hspacing,
        Text(changedCommand.formula, style: smallStyle,),
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
            Text('Variable', style: smallStyle,)
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(controller: labelController, width: 100),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Formula'),
            hspacing,
            FormulaFieldControl(
              excludeCommand: changedCommand,
              controller: formulaController, 
              focusNode: formulaFocusNode,
              width: 200, 
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double controlHeight = 60;
    if (editing && !widget.sorting) {
      controlHeight = 165;
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
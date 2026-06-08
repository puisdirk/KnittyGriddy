import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class VariableCommandControl extends StatefulWidget {
  final VariableCommand command;
  final bool sorting;
  final bool editing;

  const VariableCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<VariableCommandControl> createState() => _VariableCommandControlState();
}

class _VariableCommandControlState extends State<VariableCommandControl> {
  late TextEditingController labelController;

  void labelChanged() {
    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: labelController.text));
  }

  void formulaChanged(String formula) {
    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(formula: formula));
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
        Text(widget.command.formula, style: smallStyle,),
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
            Text('Variable', style: smallStyle,)
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
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Formula'),
            hspacing,
            FormulaFieldControl(
              key: GlobalObjectKey('${widget.command.id}-form'),
              excludeCommand: widget.command,
              width: 200,
              formula: widget.command.formula,
              onFormulaChanged: formulaChanged,
            ),
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
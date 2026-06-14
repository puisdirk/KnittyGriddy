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
  
  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: newText));
    }
  }

  void formulaChanged(String newFormula) {
    if (widget.command.formula != newFormula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(formula: newFormula));
    }
  }

  Widget createViewContent() {
//    String content = '???';
//    if (widget.command.valid) {
//      content = widget.command.storedValue!.toString();
//    }
    return Row(
      children: [
        const Icon(Symbols.settop_component),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold,),
                TextSpan(text: widget.command.formula, style: smallStyle)
              ]
            )
          )
        )
      ]
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
              initialText: widget.command.label,
              width: 100,
              onTextChanged: labelChanged,
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
              width: 240,
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
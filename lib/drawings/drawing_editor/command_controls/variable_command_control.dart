import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class VariableCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final VariableCommand command;
  final bool sorting;
  final bool editing;
  final void Function(VariableCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(VariableCommand newCommand) onChanged;

  const VariableCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<VariableCommandControl> createState() => _VariableCommandControlState();
}

class _VariableCommandControlState extends State<VariableCommandControl> {
  
  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      widget.onChangeLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  void formulaChanged(String newFormula) {
    if (widget.command.formula != newFormula) {
      widget.onChanged(widget.command.copyWith(formula: newFormula));
    }
  }

  Widget createViewContent() {
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
                TextSpan(text: '${widget.command.label} ', style: smallStyleBold,),
                TextSpan(text: widget.command.formula.isEmpty ? '???' : widget.command.formula, style: smallStyle)
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
            Icon(Symbols.settop_component),
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
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Formula'),
            hspacing,
            FormulaFieldControl(
              drawing: widget.drawing,
              key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-form'),
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
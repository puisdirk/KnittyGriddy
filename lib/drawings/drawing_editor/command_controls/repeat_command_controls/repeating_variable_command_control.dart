import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_variable_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepeatingVariableCommandControl extends StatelessWidget {
  final AbstractDrawing drawing;
  final RepeatingVariableCommand command;
  final RepeatCommand repeatContext;
  final bool sorting;
  final bool editing;
  final void Function(RepeatingVariableCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatingVariableCommand newCommand) onChanged;

  const RepeatingVariableCommandControl({
    required this.drawing,
    required this.command,
    required this.repeatContext,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  void labelChanged(String newText) {
    if (command.label != newText) {
      onChangeLabel(
        command.copyWith(
          label: newText,
          wrappedVariable: command.wrappedVariable.copyWith(label: newText)
        ), 
        command.label
      );
    }
  }

  void formulaChanged(String newFormula) {
    if (command.wrappedVariable.formula != newFormula) {
      onChanged(command.copyWith(
        wrappedVariable: command.wrappedVariable.copyWith(
          formula: newFormula
        )
      ));
    }
  }

  Widget createViewContent() {
    return Row(
      children: [
        const Icon(Symbols.settop_component),
        hspacing,
        SizedBox(
          width: command.hasErrors ? repeatcommandControlViewWidth : repeatcommandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: '${command.label} ', style: smallStyleBold,),
                TextSpan(text: command.wrappedVariable.formula.isEmpty ? '???' : command.wrappedVariable.formula, style: smallStyle)
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
              key: ValueKey('${command.id}-${command.version}-label'),
              initialText: command.label,
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
              key: ValueKey('${command.id}-${command.version}-form'),
              drawing: drawing,
              repeatContext: repeatContext,
              excludeLabels: [command.label],
              width: 210,
              formula: command.wrappedVariable.formula,
              onFormulaChanged: formulaChanged,
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (editing && !sorting) ? createEditContent() : createViewContent();
  }
}
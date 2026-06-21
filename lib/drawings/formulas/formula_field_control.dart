
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_function.dart';
import 'package:knitty_griddy/drawings/formulas/function_chooser.dart';
import 'package:knitty_griddy/drawings/formulas/measurement_command_chooser.dart';
import 'package:knitty_griddy/drawings/formulas/variable_command_chooser.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';

class FormulaFieldControl extends StatefulWidget {
  final String formula;
  final double width;
  final String? unitLabel;
  final DrawingCommand excludeCommand;
  final void Function(String newFormula) onFormulaChanged;

  const FormulaFieldControl({
    required this.formula,
    required this.width,
    this.unitLabel,
    required this.excludeCommand,
    required this.onFormulaChanged,
    super.key
  });

  @override
  State<FormulaFieldControl> createState() => _FormulaFieldControlState();
}

class _FormulaFieldControlState extends State<FormulaFieldControl> {
  late TextEditingController controller;
  late FocusNode focusNode;

  void focusChanged() {
    if (!focusNode.hasFocus) {
      widget.onFormulaChanged(controller.text);
    }
  }

  @override
  void initState() {
    controller = TextEditingController(text: widget.formula);
    focusNode = FocusNode();
    focusNode.addListener(focusChanged);

    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(focusChanged);
    focusNode.dispose();

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiTriggerAutocomplete(
      optionsAlignment: OptionsAlignment.top,
      textEditingController: controller,
      focusNode: focusNode,
      autocompleteTriggers: [
        AutocompleteTrigger(
          trigger: '@', 
          optionsViewBuilder: (context, autocompleteQuery, textEditingController) {
            return MeasurementCommandChooser(
              query: autocompleteQuery.query.toLowerCase(),
              onChooseMeasurement: (MeasurementCommand command) {
                final MultiTriggerAutocompleteState autocompleteState = MultiTriggerAutocomplete.of(context);
                autocompleteState.acceptAutocompleteOption(command.label.replaceAll(' ', '_'));
              }
            );
          }
        ),
        AutocompleteTrigger(
          trigger: '!', 
          optionsViewBuilder: (context, autocompleteQuery, textEditingController) {
            return VariableCommandChooser(
              excludeCommand: widget.excludeCommand,
              query: autocompleteQuery.query.toLowerCase(),
              onChooseVariable: (VariableCommand command) {
                final MultiTriggerAutocompleteState autocompleteState = MultiTriggerAutocomplete.of(context);
                autocompleteState.acceptAutocompleteOption(command.label.replaceAll(' ', '_'));
              }
            );
          }
        ),
        AutocompleteTrigger(
          trigger: '#', 
          optionsViewBuilder: (context, autocompleteQuery, textEditingController) {
            return FunctionChooser(
              query: autocompleteQuery.query.toLowerCase(),
              onChooseFunction: (FormulaFunction func) {
                MultiTriggerAutocomplete.of(context).acceptAutocompleteOption(func.insert);
              }
            );
          },
        )
      ],
      fieldViewBuilder: (context, textEditingController, focusNode) {
        return SizedBox(
          width: widget.width,
          child: Stack(
            children: [
              Positioned(
                child: TextField(
                  decoration: InputDecoration(
                    constraints: const BoxConstraints.tightFor(height: 40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  style: smallStyle,
                  focusNode: focusNode,
                  controller: textEditingController,
                ),
              ),
              const Positioned(
                right: 10, bottom: 0,
                child: Tooltip(
                  message: '!: variables\n@: measurements\n#: functions',
                  child: Text('f', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
              ),
              if (widget.unitLabel != null)
                Positioned(
                  right: 5,
                  child: Text(widget.unitLabel!, style: const TextStyle(fontSize: 24)),
                ),
            ]
          ),
        );
      },
    );
  }
}
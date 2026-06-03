import 'package:flutter/material.dart';
//import 'package:knitty_griddy/drawings/formulas/drawing_commands_chooser.dart';
import 'package:knitty_griddy/drawings/formulas/formula_function.dart';
import 'package:knitty_griddy/drawings/formulas/function_chooser.dart';
import 'package:knitty_griddy/drawings/formulas/measurement_command_chooser.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';

class FormulaFieldControl extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double width;
  final DrawingCommand excludeCommand;

  const FormulaFieldControl({
    required this.controller,
    required this.focusNode,
    required this.width,
    required this.excludeCommand,
    super.key
  });

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
                autocompleteState.acceptAutocompleteOption(command.label);
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
        // TODO: add function names on #
/*        AutocompleteTrigger(
          trigger: '\$', 
          optionsViewBuilder: (context, autocompleteQuery, textEditingController) {
            return DrawingCommandsChooser(
              forCommand: excludeCommand,
              query: autocompleteQuery.query,
              onChooseCommand: (DrawingCommand command) {
                final MultiTriggerAutocompleteState autocomplete = MultiTriggerAutocomplete.of(context);
                autocomplete.acceptAutocompleteOption(command.label);
                // TODO: add a $<label>. trigger for the properties
              }
            );
          },
        )
*/
      ],
      fieldViewBuilder: (context, textEditingController, focusNode) {
        return SizedBox(
          width: width,
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
                child: Text('f', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              )
            ]
          ),
        );
      },
    );
  }
}
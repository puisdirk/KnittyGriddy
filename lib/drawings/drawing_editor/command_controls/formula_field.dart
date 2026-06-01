import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/drawing_commands_chooser.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';

class FormulaField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double width;
  final DrawingCommand excludeCommand;

  const FormulaField({
    required this.controller,
    required this.focusNode,
    required this.width,
    required this.excludeCommand,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return MultiTriggerAutocomplete(
      textEditingController: controller,
      focusNode: focusNode,
      // TODO: use state for these
      autocompleteTriggers: [
        AutocompleteTrigger(
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
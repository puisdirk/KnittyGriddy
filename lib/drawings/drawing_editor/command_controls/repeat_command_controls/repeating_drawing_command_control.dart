import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/repeat_command_controls/repeating_curve_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/repeat_command_controls/repeating_line_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/repeat_command_controls/repeating_point_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/repeat_command_controls/repeating_text_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/repeat_command_controls/repeating_variable_command_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_text_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_variable_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepeatingDrawingCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final RepeatingDrawingCommand command;
  final RepeatCommand repeatContext;
  final bool sorting;
  final bool selected;
  final void Function() onSelect;
  final void Function() onDelete;
  final void Function(RepeatingDrawingCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatingDrawingCommand newCommand) onChanged;

  const RepeatingDrawingCommandControl({
    required this.drawing,
    required this.command,
    required this.repeatContext,
    required this.sorting,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<RepeatingDrawingCommandControl> createState() => _RepeatingDrawingCommandControlState();
}

class _RepeatingDrawingCommandControlState extends State<RepeatingDrawingCommandControl> {
  late bool editing;

  @override
  void initState() {
    editing = widget.command.initiallyOpen;

    super.initState();
  }

  Widget createStatusControls() {
    if (editing) {
      return Column(
        children: [
          IconButton(
            onPressed: () {
              // Make sure the control stays closed
              if (editing && widget.command.initiallyOpen) {
                Future.delayed(const Duration(milliseconds: 250), () => widget.onChanged(widget.command.setInitiallyClosed()));
              }
              setState(() => editing = !editing);
            }, 
            icon: editing ? const Icon(Symbols.top_panel_close) : const Icon(Symbols.top_panel_open),
          ),
          const Spacer(),
          if (widget.command.hasErrors)
            Tooltip(
              message: widget.command.errors.join('\n'),
              child: const Icon(Icons.error_outline),
            ),
          if (widget.command.hasErrors)
            const Spacer(),
          IconButton(
            onPressed: widget.onDelete, 
            icon: const Icon(Icons.delete)
          ),
        ],
      );
    } 
    
    return Row(
      children: [
        if (widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
          Tooltip(
            message: widget.command.errors.join('\n'),
            child: const Icon(Icons.error_outline),
          ),
        IconButton(
          onPressed: () {
            // Make sure the control stays closed
            if (editing && widget.command.initiallyOpen) {
              Future.delayed(const Duration(milliseconds: 250), () => widget.onChanged(widget.command.setInitiallyClosed()));
            }
            setState(() => editing = !editing);
          }, 
          icon: editing ? const Icon(Symbols.top_panel_close) : const Icon(Symbols.top_panel_open),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double controlHeight = 60;
    if (editing && !widget.sorting) {
      controlHeight = widget.command.editHeight;
    }

    return GestureDetector(
      onTap: widget.onSelect,
      child: SizedBox(
        height: controlHeight,
        child: Container(
          decoration: BoxDecoration(
            color: (widget.command.validated && !widget.command.valid) ? Colors.red.withAlpha(20) : Colors.grey.shade100,
            border: Border.all(color: widget.selected ? selectedColor : Colors.grey, width: widget.selected ? 2 : 1),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                if (widget.command is RepeatingPointCommand)
                  RepeatingPointCommandControl(
                    key: ValueKey(widget.command.id),
                    drawing: widget.drawing,
                    command: widget.command as RepeatingPointCommand, 
                    repeatContext: widget.repeatContext,
                    sorting: widget.sorting,
                    editing: editing,
                    onChangeLabel: widget.onChangeLabel,
                    onChanged: widget.onChanged,
                  ),

                if (widget.command is RepeatingLineCommand) 
                  RepeatingLineCommandControl(
                    key: ValueKey(widget.command.id),
                    drawing: widget.drawing,
                    command: widget.command as RepeatingLineCommand, 
                    repeatContext: widget.repeatContext,
                    sorting: widget.sorting,
                    editing:editing,
                    onChangeLabel: widget.onChangeLabel,
                    onChanged: widget.onChanged,
                  ),
    
                if (widget.command is RepeatingCurveCommand)
                  RepeatingCurveCommandControl(
                    key: ValueKey(widget.command.id),
                    drawing: widget.drawing,
                    command: widget.command as RepeatingCurveCommand, 
                    repeatContext: widget.repeatContext,
                    sorting: widget.sorting,
                    editing: editing,
                    onChangeLabel: widget.onChangeLabel,
                    onChanged: widget.onChanged,
                  ),

                if (widget.command is RepeatingVariableCommand)
                  RepeatingVariableCommandControl(
                    key: ValueKey(widget.command.id),
                    drawing: widget.drawing,
                    command: widget.command as RepeatingVariableCommand, 
                    repeatContext: widget.repeatContext,
                    sorting: widget.sorting,
                    editing: editing,
                    onChangeLabel: widget.onChangeLabel,
                    onChanged: widget.onChanged,
                  ),

                if (widget.command is RepeatingTextCommand)
                  RepeatingTextCommandControl(
                    key: ValueKey(widget.command.id),
                    drawing: widget.drawing,
                    command: widget.command as RepeatingTextCommand,
                    repeatContext: widget.repeatContext,
                    sorting: widget.sorting,
                    editing: editing,
                    onChangeLabel: widget.onChangeLabel,
                    onChanged: widget.onChanged,
                  ),

                const Spacer(),
                if (!widget.sorting)
                  createStatusControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
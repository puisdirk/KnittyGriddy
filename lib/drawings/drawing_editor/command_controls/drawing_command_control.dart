import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/comment_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/curve_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/included_part_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/line_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/measurement_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/part_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/point_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/variable_command_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/comment_command.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class DrawingCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final DrawingCommand command;
  final bool sorting;
  final bool selected;
  final void Function() onSelect;
  final void Function() onDelete;
  final void Function(DrawingCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(DrawingCommand newCommand) onChanged;

  const DrawingCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<DrawingCommandControl> createState() => _DrawingCommandControlState();
}

class _DrawingCommandControlState extends State<DrawingCommandControl> {
  late bool editing;

  @override
  void initState() {
    editing = widget.command.initiallyOpen;

    super.initState();
  }

  Widget createCommandControl() {
    if (widget.command is CommentCommand) {
      return CommentCommandControl(
        drawing: widget.drawing, 
        command: widget.command as CommentCommand, 
        sorting: widget.sorting, 
        editing: editing, 
        onChangeLabel: widget.onChangeLabel, 
        onChanged: widget.onChanged);
    }

    if (widget.command is PointCommand) {
      return PointCommandControl(
        drawing: widget.drawing,
        command: widget.command as PointCommand, 
        sorting: widget.sorting,
        editing: editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }

    if (widget.command is LineCommand) {
      return LineCommandControl(
        drawing: widget.drawing,
        command: widget.command as LineCommand, 
        sorting: widget.sorting,
        editing:editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }
    
    if (widget.command is CurveCommand) {
      return CurveCommandControl(
        drawing: widget.drawing,
        command: widget.command as CurveCommand, 
        sorting: widget.sorting,
        editing: editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }
    
    if (widget.command is MeasurementCommand) {
      return MeasurementCommandControl(
        drawing: widget.drawing,
        command: widget.command as MeasurementCommand, 
        sorting: widget.sorting,
        editing: editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }

    if (widget.command is VariableCommand) {
      return VariableCommandControl(
        drawing: widget.drawing,
        command: widget.command as VariableCommand, 
        sorting: widget.sorting,
        editing: editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }

    if (widget.command is PartCommand) {
      return PartCommandControl(
        drawing: widget.drawing,
        command: widget.command as PartCommand, 
        sorting: widget.sorting, 
        editing: editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }

    if (widget.command is IncludedPartCommand) {
      return IncludedPartCommandControl(
        drawing: widget.drawing,
        command: widget.command as IncludedPartCommand, 
        sorting: widget.sorting, 
        editing: editing,
        onChangeLabel: widget.onChangeLabel,
        onChanged: widget.onChanged,
      );
    }

    return const Placeholder();
  }

  Widget createStatusControls() {
    if (editing) {
      return Column(
        children: [
          IconButton(
            onPressed: () {
              // Make sure the control stays closed
              if (editing) {
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
            if (editing) {
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
                createCommandControl(),
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
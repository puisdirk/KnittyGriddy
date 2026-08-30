import 'package:flutter/material.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/repeat_command_controls/repeating_drawing_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_text_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_variable_command.dart';
import 'package:knitty_griddy/drawings/model/commands/text_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepeatCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final RepeatCommand command;
  final bool sorting;
  final bool editing;
  final void Function(RepeatCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatCommand newCommand) onChanged;

  const RepeatCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<RepeatCommandControl> createState() => _RepeatCommandControlState();
}

class _RepeatCommandControlState extends State<RepeatCommandControl> {
  bool sorting = false;
  String? selectedRepeatCommandId;

  void labelChanged(String newText) {
    // TODO: will dependentLabelChanged be called by this?
    if (widget.command.label != newText) {
      widget.onChangeLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  void repeatValueFormulaChanged(String newText) {
    if (widget.command.repeatValueFormula != newText) {
      widget.onChanged(widget.command.copyWith(repeatValueFormula: newText));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget createViewContent() {
    String content = '???';
    if (widget.command.repeatValueFormula.isNotEmpty) {
      content = widget.command.repeatValueFormula;
    }

    return Row(
      children: [
        const Icon(Symbols.cycle, weight: 500,),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold),
                TextSpan(text: content, style: smallStyle,)
              ]  
            ),
          )
        )
      ],
    );
  }

  Widget createEditContent() {
    return GestureDetector(
      onTap: () {
        setState(() => selectedRepeatCommandId = null);
        // TODO: let outer layer know we got selected?
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.cycle, weight: 500,),
          vspacing,
          Row(
            children: [
              const SmallLabel(label: 'Label'),
              hspacing,
              SmallTextField(
                key: ValueKey('${widget.command.id}-${widget.command.version}-label'),
                initialText: widget.command.label, 
                width: 100, 
                onTextChanged: labelChanged
              ),
            ],
          ),
          vspacing,
          Row(
            children: [
              const SmallLabel(label: 'Repeats'),
              hspacing,
              FormulaFieldControl(
                drawing: widget.drawing, 
                key: ValueKey('${widget.command.id}-${widget.command.version}-repeats'),
                formula: widget.command.repeatValueFormula, 
                width: 240, 
                excludeCommand: widget.command,
                onFormulaChanged: repeatValueFormulaChanged
              ),
            ],
          ),
          vspacing,
          SizedBox(
            width: 330,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: 'Add variable',
                  child: IconButton(
                    onPressed: () {
                      String newLabel = widget.drawing.nextLabel('v');
                      String newId = const UuidV4Gen().get();
                      widget.onChanged(widget.command.copyWith(
                        commands: [
                          ...widget.command.commands,
                          RepeatingVariableCommand(
                            id: newId, 
                            version: 0, 
                            label: newLabel,
                            initiallyOpen: true,
                            wrappedVariable: VariableCommand(id: newId, version: 0, label: newLabel)
                          )
                        ]
                      ));
                    }, 
                    icon: const Icon(Symbols.settop_component)
                  ),
                ),
                const SizedBox(
                  height: 45,
                  child: VerticalDivider(indent: 10, endIndent: 10)
                ),
                IconButton(
                    onPressed: () {
                      String newLabel = widget.drawing.nextLabel('p');
                      String newId = const UuidV4Gen().get();
                      widget.onChanged(widget.command.copyWith(
                        commands: [
                          ...widget.command.commands,
                          RepeatingPointCommand(
                            id: newId, 
                            version: 0, 
                            label: newLabel,
                            initiallyOpen: true,
                            wrappedPoint:PointCommand(id: newId, version: 0, label: newLabel)
                          )
                        ]
                      ));
                    }, 
                  icon: const Icon(Symbols.line_start_circle)
                ),
                IconButton(
                    onPressed: () {
                      String newLabel = widget.drawing.nextLabel('l');
                      String newId = const UuidV4Gen().get();
                      widget.onChanged(widget.command.copyWith(
                        commands: [
                          ...widget.command.commands,
                          RepeatingLineCommand(
                            id: newId, 
                            version: 0, 
                            label: newLabel,
                            initiallyOpen: true,
                            wrappedLine: LineCommand(id: newId, version: 0, label: newLabel)
                          )
                        ]
                      ));
                    }, 
                  icon: const Icon(Symbols.pen_size_2)
                ),
                IconButton(
                    onPressed: () {
                      String newLabel = widget.drawing.nextLabel('c');
                      String newId = const UuidV4Gen().get();
                      widget.onChanged(widget.command.copyWith(
                        commands: [
                          ...widget.command.commands,
                          RepeatingCurveCommand(
                            id: newId, 
                            version: 0, 
                            label: newLabel,
                            initiallyOpen: true,
                            wrappedCurve: CurveCommand(id: newId, version: 0, label: newLabel)
                          )
                        ]
                      ));
                    }, 
                  icon: const Icon(Symbols.line_curve)
                ),
                const SizedBox(
                  height: 45,
                  child: VerticalDivider(indent: 10, endIndent: 10)
                ),
                IconButton(
                    onPressed: () {
                      String newLabel = widget.drawing.nextLabel('text');
                      String newId = const UuidV4Gen().get();
                      widget.onChanged(widget.command.copyWith(
                        commands: [
                          ...widget.command.commands,
                          RepeatingTextCommand(
                            id: newId, 
                            version: 0, 
                            label: newLabel,
                            initiallyOpen: true,
                            wrappedText: TextCommand(id: newId, version: 0, label: newLabel)
                          )
                        ]
                      ));
                    }, 
                  icon: const Icon(Symbols.title)
                ),
                if (widget.command.commands.length > 1)
                  const SizedBox(
                    height: 45,
                    child: VerticalDivider(indent: 10, endIndent: 10)
                  ),
                if (widget.command.commands.length > 1)
                  Container(
                    decoration: BoxDecoration(
                      color: sorting ? Colors.blue.withAlpha(60) : null,
                      shape: BoxShape.circle
                    ),
                    child: Tooltip(
                      message: sorting ? 'End reordering' : 'Reorder',
                      child: IconButton(
                        isSelected: sorting,
                        onPressed: () => setState(() => sorting = !sorting), 
                        icon: const Icon(Icons.sort),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          vspacing,
          Expanded(
            child: SizedBox(
              width: 330,
              child: ReorderableListView(
                buildDefaultDragHandles: sorting,
                children: [
                  for (RepeatingDrawingCommand command in widget.command.commands.reversed)
                    RepeatingDrawingCommandControl(
                      key: ValueKey('${widget.command.id}-${command.id}'),
                      drawing: widget.drawing, 
                      command: command, 
                      repeatContext: widget.command,
                      sorting: sorting, 
                      selected: command.id == selectedRepeatCommandId, 
                      onSelect: () => setState(() => selectedRepeatCommandId = command.id), 
                      onDelete: () {
                        setState(() => selectedRepeatCommandId = null,);
                        widget.onChanged(widget.command.copyWith(
                          commands: widget.command.commands.where((c) => c.id != command.id).toList()
                        ));
                      }, 
                      onChangeLabel: (newCommand, oldLabel) {
                        // We don't tell other commands about this if the change was a double-label correction
                        bool isDoubleLabelCorrection = 
                          widget.drawing.commands.any((c) => c.id != newCommand.id && c.label == oldLabel) ||
                          widget.command.commands.any((c) => c.id != newCommand.id && c.label == oldLabel);
                        
                        // We only need to change the dependent labels of repeat commands; not of the outer layer
                        widget.onChanged(widget.command.copyWith(
                          commands: widget.command.commands.map((c) {
                            if (c.id != newCommand.id) {
                              return isDoubleLabelCorrection ? c : c.dependentLabelChanged(oldLabel.replaceAll(' ', '_'), newCommand.label.replaceAll(' ', '_'));
                            } else if (c.initiallyOpen) {
                              return newCommand.setInitiallyClosed();
                            } else {
                              return newCommand;
                            }
                          }).toList()
                        ));
                      }, 
                      onChanged: (newCommand) {
                        widget.onChanged(widget.command.copyWith(
                          commands: widget.command.commands.map((c) => c.id != newCommand.id ? c : newCommand).toList()
                        ));
                      },
                    )
                ], 
                onReorder: (oldIndex, newIndex) {
                  List<RepeatingDrawingCommand> reorderedCommands = List.from(widget.command.commands.reversed);
                  RepeatingDrawingCommand temp = reorderedCommands.removeAt(oldIndex);
                  reorderedCommands.insert((newIndex > oldIndex) ? newIndex - 1 : newIndex, temp);

                  widget.onChanged(widget.command.copyWith(
                    commands: reorderedCommands.reversed.toList()
                  ));
                },
              ),
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
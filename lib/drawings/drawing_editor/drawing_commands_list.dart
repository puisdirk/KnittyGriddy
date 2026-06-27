import 'package:flutter/material.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/drawing_command_control.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/comment_command.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/meaurement_override.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';
import 'package:material_symbols_icons/symbols.dart';

class DrawingCommandsList extends StatefulWidget {
  final AbstractDrawing drawing;
  final String? selectedCommandId;
  final void Function(String? id) onSelect;
  final void Function(AbstractDrawing newDrawing) onDrawingChanged;

  const DrawingCommandsList({
    required this.drawing,
    required this.onDrawingChanged,
    required this.selectedCommandId,
    required this.onSelect,
    super.key
  });

  @override
  State<DrawingCommandsList> createState() => _DrawingCommandsListState();
}

class _DrawingCommandsListState extends State<DrawingCommandsList> {
  bool sorting = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelect(null),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Tooltip(
                  message: 'Add comment',
                  child: IconButton(
                    onPressed: () {
                      widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                        commands: [
                          ...widget.drawing.commands,
                          CommentCommand(
                            id: const UuidV4Gen().get(), 
                            label: '', 
                            version: 0, 
                            comment: '',
                            initiallyOpen: true,
                          ),
                        ]
                      ));
                    }, 
                    icon: const Icon(Icons.comment_outlined),
                  ),
                ),
                const SizedBox(
                  height: 45,
                  child: VerticalDivider(indent: 10, endIndent: 10)
                ),
                Tooltip(
                  message: 'Add measurement',
                  child: IconButton(
                    onPressed: () {
                      widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                        commands: [
                          ...widget.drawing.commands, 
                          MeasurementCommand(
                            id: const UuidV4Gen().get(), 
                            version: 0, 
                            label: widget.drawing.nextLabel('m'),
                            initiallyOpen: true,
                          )
                        ]
                      ));
                      // We deselect on measurements 
                      widget.onSelect(null);
                    },
                    icon: const Icon(Symbols.square_foot),
                  ),
                ),
                Tooltip(
                  message: 'Add variable',
                  child: IconButton(
                    onPressed: () {
                      widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                        commands: [
                          ...widget.drawing.commands, 
                          VariableCommand(
                            id: const UuidV4Gen().get(), 
                            version: 0, 
                            label: widget.drawing.nextLabel('v'),
                            initiallyOpen: true,
                          )
                        ]
                      ));
                      // We deselect on variables
                      widget.onSelect(null);
                    },
                    icon: const Icon(Symbols.settop_component),
                  ),
                ),
                const SizedBox(
                  height: 45,
                  child: VerticalDivider(indent: 10, endIndent: 10)
                ),
                Tooltip(
                  message: 'Add point',
                  child: IconButton(
                    onPressed: () {
                      String newId = const UuidV4Gen().get();
                      widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                        commands: [
                          ...widget.drawing.commands,
                          PointCommand(
                            id: newId, 
                            version: 0,
                            label: widget.drawing.nextLabel('p'),
                            initiallyOpen: true,
                          )
                        ]
                      ));
                      widget.onSelect(newId);
                    },
                    icon: const Icon(Symbols.line_start_circle),
                  ),
                ),
                Tooltip(
                  message: 'Add line',
                  child: IconButton(
                    onPressed: () {
                      String newId = const UuidV4Gen().get();
                      widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                        commands: [
                          ...widget.drawing.commands,
                          LineCommand(
                            id: newId, 
                            version: 0,
                            label: widget.drawing.nextLabel('l'),
                            initiallyOpen: true,
                          )
                        ]
                      ));
                      widget.onSelect(newId);
                    },
                    icon: const Icon(Symbols.pen_size_2),
                  ),
                ),
                Tooltip(
                  message: 'Add curve',
                  child: IconButton(
                    onPressed: () {
                      String newId = const UuidV4Gen().get();
                      widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                        commands: [
                          ...widget.drawing.commands,
                          CurveCommand(
                            id: newId, 
                            version: 0,
                            label: widget.drawing.nextLabel('c'),
                            initiallyOpen: true,
                          )
                        ]
                      ));
                      widget.onSelect(newId);
                    },
                    icon: const Icon(Symbols.line_curve),
                  ),
                ),
                const SizedBox(
                  height: 45,
                  child: VerticalDivider(indent: 10, endIndent: 10)
                ),
                if (widget.drawing is PartDrawing)
                  Tooltip(
                    message: 'Add part',
                    child: IconButton(
                      onPressed: () {
                        String newId = const UuidV4Gen().get();
                        widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                          commands: [
                            ...widget.drawing.commands,
                            PartCommand(
                              id: newId, 
                              version: 0,
                              label: widget.drawing.nextLabel('part'),
                              initiallyOpen: true,
                            )
                          ]
                        ));
                        widget.onSelect(newId);
                      },
                      icon: const Icon(Icons.extension_outlined),
                    ),
                  ),
                if (widget.drawing is Drawing)
                    Tooltip(
                      message: 'Include part',
                      child: IconButton(
                      onPressed: () {
                        String newId = const UuidV4Gen().get();
                        widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                          commands: [
                            ...widget.drawing.commands,
                            IncludedPartCommand(
                              id: newId, 
                              version: 0,
                              label: widget.drawing.nextLabel('subpart'),
                              initiallyOpen: true,
                            )
                          ]
                        ));
                        widget.onSelect(newId);
                      }, 
                      icon: const Icon(Symbols.apparel)),
                    ),
                if (widget.drawing.commands.length > 1)
                  const SizedBox(
                    height: 45,
                    child: VerticalDivider(indent: 10, endIndent: 10)
                  ),
                if (widget.drawing.commands.length > 1)
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
                if (widget.drawing.commands.length < 2)
                  const SizedBox(width: 40,),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ReorderableListView(
                buildDefaultDragHandles: sorting,
                children: [
                  for (DrawingCommand command in widget.drawing.commands)
                    DrawingCommandControl(
                      key: GlobalObjectKey(command.id),
                      drawing: widget.drawing,
                      command: command, 
                      sorting: sorting, 
                      selected: command.id == widget.selectedCommandId,
                      onSelect: () => widget.onSelect(command.id),
                      onDelete: () {
                        widget.onSelect(null);
                        widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                          commands: widget.drawing.commands
                            .where((c) => c.id != command.id)
                            .map((c) => c.deleteReference(commandId: command.id)).toList()
                        ).validate());
                      },
                      onChangeLabel: (DrawingCommand newCommand, String oldLabel) {
                        // We don't tell other commands about this if the change was a double-label correction
                        bool isDoubleLabelCorrection = widget.drawing.commands.any((c) => c.id != newCommand.id && c.label == oldLabel);

                        widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                          commands: widget.drawing.commands.map((c) {
                            if (c.id != command.id) {
                               return isDoubleLabelCorrection ? c : c.dependentLabelChanged(oldLabel.replaceAll(' ', '_'), newCommand.label.replaceAll(' ', '_'));
                            } else {
                              return newCommand.setInitiallyClosed();
                            }
                          }).toList()
                        ).validate());
                      },
                      onChanged: (newCommand) {
                        // If it is an includedPartCommand, we also update the includedDrawings and create the MeasurementOverrides
                        if (newCommand is IncludedPartCommand) {
                          List<MeasurementOverride> moverrides = [];
                          if (newCommand.partInfo != null && 
                              (newCommand.measurementOverrides.isEmpty || newCommand.partInfo!.partId != (command as IncludedPartCommand).partInfo?.partId)) {
                            PartDrawing? partDrawing = PartRepository.getPartDrawingById(newCommand.partInfo!.partDrawingId);
                            if (partDrawing != null) {
                              for (MeasurementCommand mcmd in partDrawing.measurements) {
                                String formula = mcmd.value.toString();
                                if (widget.drawing.measurements.any((m) => m.label == mcmd.label)) {
                                  formula = '@${mcmd.label.replaceAll(' ', '_')}';
                                }
                                moverrides.add(
                                  MeasurementOverride(
                                    measurementId: mcmd.id, 
                                    measurementLabel: mcmd.label,
                                    formula: formula,
                                    unit: mcmd.unit,
                                  )
                                );
                              }
                              newCommand = newCommand.copyWith(measurementOverrides: moverrides);
                            }
                          }

                          widget.onDrawingChanged((widget.drawing as Drawing).copyWith(
                            commands: widget.drawing.commands.map((c) => c.id != command.id ? c : newCommand.setInitiallyClosed()).toList()
                          ).validate().updateIncludedDrawings());
                        } else {
                          widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                            commands: widget.drawing.commands.map((c) => c.id != command.id ? c : newCommand.setInitiallyClosed()).toList()
                          ).validate());
                        }
                      },
                    ),
                ],
                onReorder: (oldIndex, newIndex) {
                  List<DrawingCommand> reorderedCommands = List.from(widget.drawing.commands);
                  DrawingCommand temp = reorderedCommands.removeAt(oldIndex);
                  reorderedCommands.insert((newIndex > oldIndex) ? newIndex - 1 : newIndex, temp);

                  widget.onDrawingChanged(widget.drawing.abstractCopyWith(
                    commands: reorderedCommands
                  ));
                },
                
              ),
            ),
          ],
        ),
      )
    );
  }
}
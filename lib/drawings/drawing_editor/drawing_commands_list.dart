import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/curve_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/drawing_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/line_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/measurement_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/point_command_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/variable_command_control.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class DrawingCommandsList extends StatefulWidget {
  final String? selectedCommandId;
  final void Function(String? id) onSelect;

  const DrawingCommandsList({
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
        child: Selector<DrawingsModel, Drawing>(
          selector: (_, model) => model.drawing,
          builder: (context, drawing, _) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Tooltip(
                      message: 'Add measurement',
                      child: IconButton(
                        onPressed: () {
                          Provider.of<DrawingsModel>(context, listen: false).addMeasurementCommand();
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
                          Provider.of<DrawingsModel>(context, listen: false).addVariableCommand();
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
                          String newId = Provider.of<DrawingsModel>(context, listen: false).addPointCommand();
                          widget.onSelect(newId);
                        },
                        icon: const Icon(Symbols.line_start_circle),
                      ),
                    ),
                    Tooltip(
                      message: 'Add line',
                      child: IconButton(
                        onPressed: () {
                          String newId = Provider.of<DrawingsModel>(context, listen: false).addLineCommand();
                          widget.onSelect(newId);
                        },
                        icon: const Icon(Symbols.pen_size_2),
                      ),
                    ),
                    Tooltip(
                      message: 'Add curve',
                      child: IconButton(
                        onPressed: () {
                          String newId = Provider.of<DrawingsModel>(context, listen: false).addCurveCommand();
                          widget.onSelect(newId);
                        },
                        icon: const Icon(Symbols.line_curve),
                      ),
                    ),
                    const Spacer(),
                    if (drawing.commands.length > 1)
                      Container(
                        decoration: BoxDecoration(
                          color: sorting ? Colors.blue.withAlpha(60) : null,
                          shape: BoxShape.circle
                        ),
                        child: IconButton(
                          isSelected: sorting,
                          onPressed: () => setState(() => sorting = !sorting), 
                          icon: const Icon(Icons.sort),
                        ),
                      ),
                    if (drawing.commands.length < 2)
                      const SizedBox(width: 40,),
                  ],
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: ReorderableListView(
                    buildDefaultDragHandles: sorting,
                    children: [
                      for (DrawingCommand command in drawing.commands)
                        DrawingCommandControl(
                          key: GlobalObjectKey(command.id),
                          command: command, 
                          sorting: sorting, 
                          selected: command.id == widget.selectedCommandId,
                          onSelect: () => widget.onSelect(command.id),
                          onDelete: () {
                            widget.onSelect(null);
                            Provider.of<DrawingsModel>(context, listen: false).deleteCommand(commandId: command.id);
                          },
                        ),
                    ],
                    onReorder: (oldIndex, newIndex) {
                      Provider.of<DrawingsModel>(context, listen: false).reorderCommands(oldIndex, (newIndex > oldIndex) ? newIndex - 1 : newIndex);
                    },
                    
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
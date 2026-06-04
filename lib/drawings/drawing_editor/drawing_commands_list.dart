import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/curve_command_control.dart';
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
  const DrawingCommandsList({super.key});

  @override
  State<DrawingCommandsList> createState() => _DrawingCommandsListState();
}

class _DrawingCommandsListState extends State<DrawingCommandsList> {

  String selectedCommandId = '';
  bool sorting = false;

  Widget createCommandControl(Drawing drawing, DrawingCommand command) {
    if (command is PointCommand) {
      return PointCommandControl(
        key: GlobalObjectKey(command.id),
        command: command, 
        finishedEditing: (newCommand) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(newCommand),
        sorting: sorting,
      );
    } else if (command is LineCommand) {
      return LineCommandControl(
        key: GlobalObjectKey(command.id),
        command: command, 
        finishedEditing: (newCommand) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(newCommand),
        sorting: sorting,
      );
    } else if (command is CurveCommand) {
      return CurveCommandControl(
        key: GlobalObjectKey(command.id),
        command: command, 
        finishedEditing: (newCommand) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(newCommand),
        sorting: sorting,
      );
    } else if (command is MeasurementCommand) {
      return MeasurementCommandControl(
        key: GlobalObjectKey(command.id),
        command: command, 
        finishedEditing: (newCommand) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(newCommand), 
        sorting: sorting
      );
    } else if (command is VariableCommand) {
      return VariableCommandControl(
        key: GlobalObjectKey(command.id),
        command: command, 
        finishedEditing: (newCommand) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(newCommand), 
        sorting: sorting
      );
    }

    // TODO: other types

    return const Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        String newId = Provider.of<DrawingsModel>(context, listen: false).addMeasurementCommand();
                        setState(() => selectedCommandId = newId);
                      },
                      icon: const Icon(Symbols.square_foot),
                    ),
                  ),
                  Tooltip(
                    message: 'Add variable',
                    child: IconButton(
                      onPressed: () {
                        String newId = Provider.of<DrawingsModel>(context, listen: false).addVariableCommand();
                        setState(() => selectedCommandId = newId);
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
                        setState(() => selectedCommandId = newId);
                      },
                      icon: const Icon(Symbols.line_start_circle),
                    ),
                  ),
                  Tooltip(
                    message: 'Add line',
                    child: IconButton(
                      onPressed: () {
                        String newId = Provider.of<DrawingsModel>(context, listen: false).addLineCommand();
                        setState(() => selectedCommandId = newId);
                      },
                      icon: const Icon(Symbols.pen_size_2),
                    ),
                  ),
                  Tooltip(
                    message: 'Add curve',
                    child: IconButton(
                      onPressed: () {
                        String newId = Provider.of<DrawingsModel>(context, listen: false).addCurveCommand();
                        setState(() => selectedCommandId = newId);
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
                      createCommandControl(drawing, command),
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
    );
  }
}
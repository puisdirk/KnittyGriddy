import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/point_command_control.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:provider/provider.dart';

class DrawingCommandsList extends StatefulWidget {
  const DrawingCommandsList({super.key});

  @override
  State<DrawingCommandsList> createState() => _DrawingCommandsListState();
}

class _DrawingCommandsListState extends State<DrawingCommandsList> {

  String selectedCommandId = '';

  Widget createCommandControl(Drawing drawing, DrawingCommand command) {
    bool valid = command.isValid(drawing);

    if (command is PointCommand) {
      return PointCommandControl(
        command: command, 
        valid: valid,
        finishedEditing: (newCommand) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(newCommand),
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
                children: [
                  OutlinedButton(
                    onPressed: () {
                      String newId = Provider.of<DrawingsModel>(context, listen: false).addPointCommand();
                      setState(() => selectedCommandId = newId);
                    },
                    child: const Text('Add Point')
                  )
                ],
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView(
                  children: [
                    for (DrawingCommand command in drawing.commands)
                      createCommandControl(drawing, command),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
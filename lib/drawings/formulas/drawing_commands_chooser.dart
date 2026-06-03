import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class DrawingCommandsChooser extends StatelessWidget {
  final DrawingCommand forCommand;
  final String query;
  final ValueSetter<DrawingCommand> onChooseCommand;

  final TextStyle smallStyle = const TextStyle(fontSize: 10, color: Colors.black);

  const DrawingCommandsChooser({
    required this.forCommand,
    required this.query,
    required this.onChooseCommand,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;
    final List<DrawingCommand> commands = [
      origin, 
      ...drawing.commands
    ].where((c) => c.id != forCommand.id && c.label.contains(query)).toList();

    if (commands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      shape: const RoundedRectangleBorder(),
      elevation: 10,
      clipBehavior: Clip.hardEdge,
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: commands.length,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: Colors.white,
            title: Text(commands.elementAt(index).label, style: smallStyle,),
            onTap: () => onChooseCommand(commands.elementAt(index)),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';

class VariableCommandChooser extends StatelessWidget {
  final DrawingCommand? excludeCommand;
  final String query;
  final ValueSetter<VariableCommand> onChooseVariable;

  const VariableCommandChooser({
    this.excludeCommand,
    required this.query,
    required this.onChooseVariable,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final List<VariableCommand> variables = 
      Provider.of<DrawingsModel>(context, listen: false).drawing.variables.where(
        (m) => m.id != excludeCommand?.id && m.label.toLowerCase().contains(query)).toList();
    if (variables.isEmpty) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(),
        elevation: 10,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: variables.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200,),
          itemBuilder: (context, index) {
            return ListTile(
              tileColor: Colors.white,
              title: Text(variables.elementAt(index).label, style: smallStyle,),
              onTap: () => onChooseVariable(variables.elementAt(index)), 
            );
          },
        ),
      ),
    );
  }
}
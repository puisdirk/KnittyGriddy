import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class VariableCommandChooser extends StatelessWidget {
  final List<String> variableLabels;
  final String query;
  final ValueSetter<String> onChooseVariable;

  const VariableCommandChooser({
    required this.variableLabels,
    required this.query,
    required this.onChooseVariable,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    final List<String> variables = variableLabels.where((v) => v.toLowerCase().contains(query)).toList();

    if (variables.isEmpty) {
      return const SizedBox.shrink();
    }

    variables.sort();

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
              title: Text(variables.elementAt(index), style: smallStyle,),
              onTap: () => onChooseVariable(variables.elementAt(index)), 
            );
          },
        ),
      ),
    );
  }
}
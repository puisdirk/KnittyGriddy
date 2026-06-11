import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_function.dart';
import 'package:knitty_griddy/utils/constants.dart';

class FunctionChooser extends StatelessWidget {
  final String query;
  final ValueSetter<FormulaFunction> onChooseFunction;

  const FunctionChooser({
    required this.query,
    required this.onChooseFunction,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    List<FormulaFunction> queried = List.from(FormulaFunction.values.where((f) => f.name.toLowerCase().contains(query)));

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
          itemCount: queried.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200,),
          itemBuilder: (context, index) {
            return ListTile(
              tileColor: Colors.white,
              title: Text(queried.elementAt(index).signature, style: smallStyle,),
              onTap: () => onChooseFunction(queried.elementAt(index)),
            );
          },
        ),
      ),
    );

  }
}
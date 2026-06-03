import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';

class MeasurementCommandChooser extends StatelessWidget {
  final String query;
  final ValueSetter<MeasurementCommand> onChooseMeasurement;

  const MeasurementCommandChooser({
    required this.query,
    required this.onChooseMeasurement,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final List<MeasurementCommand> measurements = 
      Provider.of<DrawingsModel>(context, listen: false).drawing.measurements.where((m) => m.label.toLowerCase().contains(query)).toList();
    if (measurements.isEmpty) {
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
          itemCount: measurements.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200,),
          itemBuilder: (context, index) {
            return ListTile(
              tileColor: Colors.white,
              title: Text(measurements.elementAt(index).label, style: smallStyle,),
              onTap: () => onChooseMeasurement(measurements.elementAt(index)), 
            );
          },
        ),
      ),
    );
  }
}
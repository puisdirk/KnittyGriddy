import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/chart_picker.dart';
import 'package:knitty_griddy/charts/export/chart_settings_popup.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class PatternChartFieldToolbar extends StatefulWidget {
  final PatternChartField field;
  final void Function(PatternChartField newField) onChanged;

  const PatternChartFieldToolbar({
    required this.field,
    required this.onChanged,
    super.key
  });

  @override
  State<PatternChartFieldToolbar> createState() => _PatternChartFieldToolbarState();
}

class _PatternChartFieldToolbarState extends State<PatternChartFieldToolbar> {
  late PatternChartField field;

  @override
  void initState() {
    field = widget.field;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternChartFieldToolbar oldWidget) {
    field = widget.field;

    super.didUpdateWidget(oldWidget);
  }

  void _updateField(PatternChartField newField) {
    setState(() => field = newField);
    widget.onChanged(newField);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            ChartInfo? newChartInfo = await showDialog(
              context: context, 
              barrierDismissible: false,
              builder: (context) => const ChartPicker(),
            );

            if (newChartInfo != null && newChartInfo != ChartInfo.emptyChartInfo) {
              if (context.mounted) {
                KnittingChart newChart = await Provider.of<ChartsModel>(context, listen: false).getChart(newChartInfo);
                _updateField(field.copyWith(chart: newChart));
              }
            }
          }, 
          label: field.chart == null ? 
            const Text('No chart selected', style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)) :
            Text(field.chart!.name, style: const TextStyle(color: Colors.black)),
          icon: const Icon(Icons.grid_on, color: Colors.black),
        ),
        hspacing,hspacing,
        if (field.chart != null)
          Row(
            children: [
              CustomPopup(
                content: ChartSettingsPopup(
                  settings: field.viewSettings, 
                  onChanged: (newSettings) => _updateField(field.copyWith(viewSettings: newSettings)),
                ),
                backgroundColor: Colors.transparent,
                contentDecoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Colors.white.withAlpha(150)
                ),
                arrowColor: Colors.grey,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                ),
              ),
            ]
        )
      ]
    );
  }
}
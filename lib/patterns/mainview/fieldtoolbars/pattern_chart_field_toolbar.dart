import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/chart_picker.dart';
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
        TextButton.icon(
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
        hspacing,
        if (field.chart != null)
          Row(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Grid'),
                    ),
                  ),
                  Checkbox(
                    value: field.viewSettings.showGrid, 
                    onChanged: (bool? value) => _updateField(field.copyWith(viewSettings: field.viewSettings.copyWith(showGrid: value == true)))
                  )
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Stitches'),
                    ),
                  ),
                  hspacing,
                  Checkbox(
                    value: field.viewSettings.showStitches, 
                    onChanged: (bool? value) => _updateField(field.copyWith(viewSettings: field.viewSettings.copyWith(showStitches: value == true)))
                  )
                ],
              ),
              hspacing, hspacing,
              if (field.viewSettings.showStitches)
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Descriptions'),
                    ),
                  ),
                  hspacing,
                  Checkbox(
                    value: field.viewSettings.showStitchDescriptions, 
                    onChanged: (bool? value) => _updateField(field.copyWith(viewSettings: field.viewSettings.copyWith(showStitchDescriptions: value == true)))
                  )
                ],
              ),
              hspacing, hspacing,
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Colours'),
                    ),
                  ),
                  hspacing,
                  Checkbox(
                    value: field.viewSettings.showColours, 
                    onChanged: (bool? value) => _updateField(field.copyWith(viewSettings: field.viewSettings.copyWith(showColours: value == true)))
                  )
                ],
              ),
              hspacing, hspacing,
              if (field.viewSettings.showLegend && field.viewSettings.showGrid)
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Position'),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  DropdownButton<LegendPosition>(
                    autofocus: false, 
                    focusColor: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    underline: Container(),
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    items: const [
                      DropdownMenuItem(value: LegendPosition.left, child: Text('Left')),
                      DropdownMenuItem(value: LegendPosition.right, child: Text('Right')),
                      DropdownMenuItem(value: LegendPosition.top, child: Text('Top')),
                      DropdownMenuItem(value: LegendPosition.bottom, child: Text('Bottom')),
                    ], 
                    value: field.viewSettings.legendPosition,
                    onChanged: (LegendPosition? position) { 
                      if (position != null) { 
                        _updateField(field.copyWith(viewSettings: field.viewSettings.copyWith(legendPosition: position)));
                      } 
                    },
                  )
                ],
              )
            ]
        )
      ]
    );
  }
}
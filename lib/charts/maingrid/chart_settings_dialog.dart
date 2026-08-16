import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/charts/model/chart_settings.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/pick_colour_dialog.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartSettingsDialog extends StatefulWidget {
  final KnittingChart knittingChart;

  const ChartSettingsDialog({
    required this.knittingChart,  
    super.key
  });

  @override
  State<ChartSettingsDialog> createState() => _ChartSettingsDialogState();
}

class _ChartSettingsDialogState extends State<ChartSettingsDialog> {
  late KnittingChart newChart;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  // We don't immediately set rows and cols to avoid losing stitches
  late double rows;
  late double cols;

  void _nameChanged() {
    if (nameController.text != newChart.name) {
      setState(() => newChart = newChart.copyWith(name: nameController.text));
    }
  }

  void _descriptionChanged() {
    if (descriptionController.text != newChart.description) {
      setState(() => newChart = newChart.copyWith(description: descriptionController.text));
    }
  }

  @override
  void initState() {
    newChart = widget.knittingChart;

    nameController = TextEditingController(text: newChart.name);
    nameController.addListener(_nameChanged);

    descriptionController = TextEditingController(text: newChart.description);
    descriptionController.addListener(_descriptionChanged);

    rows = newChart.chartSettings.rows.toDouble();
    cols = newChart.chartSettings.columns.toDouble();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChartSettingsDialog oldWidget) {
    newChart = widget.knittingChart;

    nameController.text = newChart.name;
    descriptionController.text = newChart.description;

    rows = newChart.chartSettings.rows.toDouble();
    cols = newChart.chartSettings.columns.toDouble();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    nameController.removeListener(_nameChanged);
    nameController.dispose();

    descriptionController.removeListener(_descriptionChanged);
    descriptionController.dispose();

    super.dispose();
  }

  static const double _kLabelWidth = 120;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chart settings'),
      content: SizedBox(
        width: 400,
        height: 490,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 80, child: Text('Name', textAlign: TextAlign.right,)),
                hspacing,
                SizedBox(width: 300,
                  child: TextField(
                    controller: nameController,
                  ),
                )
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: 80, child: Text('Description', textAlign: TextAlign.right,)),
                hspacing,
                SizedBox(width: 300,
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 3,
                  ),
                )
              ],
            ),
            vspacing,
            vspacing,
            vspacing,
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Numbering'),
              ],
            ),
            vspacing,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<GridType>(
                  emptySelectionAllowed: false,
                  multiSelectionEnabled: false,
                  showSelectedIcon: false,
                  segments: [
                    for (GridType gridType in GridType.values)
                      ButtonSegment(
                        value: gridType,
                        label: Text(gridType.toString()),
                      ),
                  ], 
                  selected: {newChart.chartSettings.gridType},
                  onSelectionChanged: (Set<GridType>? newGridType) =>
                    setState(() => newChart = newChart.copyWith(
                      chartSettings: newChart.chartSettings.copyWith(
                        gridType: newGridType!.first
                      )
                    ))
                ),
              ],
            ),
            vspacing,
            vspacing,
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Rows', textAlign: TextAlign.right,),),
                hspacing,
                SizedBox(
                  width: 160,
                  child: SpinBox(
                    value: rows,
                    min: 1,
                    max: 300,
                    onChanged: (value) {
                      setState(() => rows = value);
                    },
                  ),
                )
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Columns', textAlign: TextAlign.right,),),
                hspacing,
                SizedBox(
                  width: 160,
                  child: SpinBox(
                    value: cols,
                    min: 1,
                    max: 300,
                    onChanged: (value) {
                      setState(() => cols = value);
                    },
                  ),
                )
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Outline color', textAlign: TextAlign.right,),),
                hspacing,
                ColorIndicator(
                  width: 40,
                  height: 30,
                  borderRadius: 6,
                  hasBorder: true,
                  color: newChart.chartSettings.outlineColor,
                  onSelect: () async {
                    Color? newColor = await showDialog(
                      barrierDismissible: false,
                      barrierColor: Colors.transparent,
                      context: context, 
                      builder: (context) => PickColourDialog(
                        initialColor: newChart.chartSettings.outlineColor,
                        knownColours: newChart.knownColours,
                      )
                    );
                    if (newColor != null && newColor != newChart.chartSettings.outlineColor) {
                      setState(() => newChart = newChart.copyWith(
                        chartSettings: newChart.chartSettings.copyWith(
                          outlineColor: newColor
                        )
                      ));
                    }
                  },
                )
              ],
            ),
            vspacing,
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, child: Text('Outline thickness', textAlign: TextAlign.right,),),
                hspacing,
                SizedBox(
                  width: 160,
                  child: SpinBox(
                    value: newChart.chartSettings.outlineThickness,
                    min: .1,
                    max: 10,
                    step: .1,
                    decimals: 1,
                    onChanged: (value) => setState(() => newChart = newChart.copyWith(
                      chartSettings: newChart.chartSettings.copyWith(outlineThickness: value)
                    )),
                  ),
                )
              ],
            ),
          ]
        )
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          }, 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () {
            if (rows.toInt() != newChart.chartSettings.rows || cols.toInt() != newChart.chartSettings.columns) {
              newChart = newChart.setNumberOfRowsAndCols(rows.toInt(), cols.toInt());
            }
            if (newChart != widget.knittingChart) {
              Navigator.of(context).pop(newChart);
            } else {
              Navigator.of(context).pop(null);
            }
          }, 
          child: const Text('Ok')
        )
      ],
    );
  }
}
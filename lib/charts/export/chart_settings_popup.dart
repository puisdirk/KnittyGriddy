import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartSettingsPopup extends StatefulWidget {
  final KnittingChartViewSettings settings;
  final void Function(KnittingChartViewSettings newSettings) onChanged;

  const ChartSettingsPopup({
    required this.settings,
    required this.onChanged,
    super.key
  });

  @override
  State<ChartSettingsPopup> createState() => _ChartSettingsPopupState();
}

class _ChartSettingsPopupState extends State<ChartSettingsPopup> {
  late KnittingChartViewSettings settings;

  @override
  void initState() {
    settings = widget.settings;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChartSettingsPopup oldWidget) {
    settings = widget.settings;

    super.didUpdateWidget(oldWidget);
  }

  _updateSettings(KnittingChartViewSettings newSettings) {
    setState(() => settings = newSettings);
    widget.onChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 350, //410,
      child: Column(
        children: [
          const Text('Chart'),
          CheckboxListTile(
            title: const Text('Show Grid'),
            value: settings.showGrid, 
            onChanged: (bool? value) => _updateSettings(settings.copyWith(showGrid: value == true)),
          ),
          /*vspacing,
          CheckboxListTile(
            title: const Text('Show \'No Stitch\' cells'),
            value: settings.showNoStichCells, 
            onChanged: (bool? value) => _updateSettings(settings.copyWith(showNoStichCells: value == true)),
          ),
          vspacing,*/
          const SizedBox(
            height: 20,
            child: Divider(indent: 15, endIndent: 15, color: Colors.grey,),
          ),
          const Text('Legend:'),
          vspacing,
          CheckboxListTile(
            title: const Text('Show stitches'),
            value: settings.showStitches, 
            onChanged: (bool? value) => _updateSettings(settings.copyWith(showStitches: value == true)),
          ),
          vspacing,
          CheckboxListTile(
            title: const Text('Show descriptions'),
            value: settings.showStitchDescriptions, 
            onChanged: settings.showStitches ? (bool? value) => _updateSettings(settings.copyWith(showStitchDescriptions: value == true)) : null,
          ),
          vspacing,
          CheckboxListTile(
            title: const Text('Show colours'),
            value: settings.showColours, 
            onChanged: (bool? value) => _updateSettings(settings.copyWith(showColours: value == true)),
          ),
          vspacing,
          Row(
            children: [
              const SizedBox(width: 15,),
              const Text('Position', style: TextStyle(fontSize: 16),),
              const Spacer(),
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
                value: settings.legendPosition,
                onChanged: (settings.showLegend && settings.showGrid) ? (LegendPosition? position) { 
                  if (position != null) { 
                    _updateSettings(settings.copyWith(legendPosition: position));
                  } 
                } : null,
              ),
            ],
          )
        ],
      ),
    );
  }
}
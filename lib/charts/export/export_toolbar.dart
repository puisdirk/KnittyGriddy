import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:knitty_griddy/charts/export/chart_settings_popup.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ExportToolbar extends StatelessWidget {
  final double height;
  final KnittingChartViewSettings exportSetting;
  final Function(KnittingChartViewSettings newSettings) settingsChanged;

  final Function() exportToChart;
  final Function() exportToPNG;
  final Function() exportToSVG;

  const ExportToolbar({
    required this.height,
    required this.exportSetting,
    required this.settingsChanged,
    required this.exportToChart,
    required this.exportToPNG,
    required this.exportToSVG,
    super.key}
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Spacer(),
          CustomPopup(
            content: ChartSettingsPopup(
              settings: exportSetting, 
              onChanged: (newSettings) => settingsChanged( newSettings),
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
          const Spacer(),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Export'),
                ),
              ),
              hspacing,
              OutlinedButton(
                onPressed: exportToChart, 
                child: const Text('Chart')
              ),
              hspacing,
              OutlinedButton(
                onPressed: exportToPNG, 
                child: const Text('PNG'),
              ),
              hspacing,
              OutlinedButton(
                onPressed: exportToSVG, 
                child: const Text('SVG'),
              ),
            ],
          ),
          const SizedBox(width: 20,),
        ],
      ),
    );
  }
}
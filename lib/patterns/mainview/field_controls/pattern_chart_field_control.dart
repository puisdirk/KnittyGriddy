import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/charts/export/preview_legend.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_grid.dart';

class PatternChartFieldControl extends StatelessWidget {
  final double opacity;
  final KnittingChart? chart;
  final KnittingChartViewSettings viewSettings;
  final bool selected;
  final void Function() onSelect;
  
  const PatternChartFieldControl({
    required this.opacity,
    required this.chart,
    required this.viewSettings,
    required this.selected,
    required this.onSelect,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return chart == null ? GestureDetector(onTap: onSelect, child: Container(color: Colors.transparent,)) :
      GestureDetector(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: opacity == 0 ? 0 : opacity / 255,
            child: FittedBox(
              child: viewSettings.showLegend == false ?
                Visibility(
                  visible: viewSettings.showGrid,
                  child: ChartFieldGrid(chart: chart!,)
                ) :
                viewSettings.legendHorizontal ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (viewSettings.legendPosition == LegendPosition.top)
                        PreviewLegend(exportSettings: viewSettings,),
                      Visibility(
                        visible: viewSettings.showGrid,
                        child: ChartFieldGrid(chart: chart!)
                      ),
                      if (viewSettings.legendPosition == LegendPosition.bottom)
                        PreviewLegend(exportSettings: viewSettings,)
                    ],
                  ) :
                  Row(
                    children: [
                      if (viewSettings.legendPosition == LegendPosition.left)
                        PreviewLegend(exportSettings: viewSettings,),
                      Visibility(
                        visible: viewSettings.showGrid,
                        child: ChartFieldGrid(chart: chart!)
                      ),
                      if (viewSettings.legendPosition == LegendPosition.right)
                        PreviewLegend(exportSettings: viewSettings,),
                    ],
                  ),
            ),
          ),
        ),
      );
  }
}
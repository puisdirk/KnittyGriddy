import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_grid.dart';
import 'package:knitty_griddy/patterns/mainview/field_controls/chartfieldcomponents/chart_field_preview_legend.dart';

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
    if (chart == null) {
      return GestureDetector(onTap: onSelect, child: Container(color: Colors.transparent,));
    }
    KnittingChart prunedChart = chart!.pruneUnusedStitchesAndColours();
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: opacity == 0 ? 0 : opacity / 255,
            child: FittedBox(
              child: viewSettings.showLegend == false ?
                Visibility(
                  visible: viewSettings.showGrid,
                  child: ChartFieldGrid(chart: prunedChart, showNoStichCells: viewSettings.showNoStichCells,)
                ) :
                viewSettings.legendHorizontal ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (viewSettings.legendPosition == LegendPosition.top)
                        ChartFieldPreviewLegend(chart: prunedChart, exportSettings: viewSettings,),
                      Visibility(
                        visible: viewSettings.showGrid,
                        child: ChartFieldGrid(chart: prunedChart, showNoStichCells: viewSettings.showNoStichCells)
                      ),
                      if (viewSettings.legendPosition == LegendPosition.bottom)
                        ChartFieldPreviewLegend(chart: prunedChart, exportSettings: viewSettings,)
                    ],
                  ) :
                  Row(
                    children: [
                      if (viewSettings.legendPosition == LegendPosition.left)
                        ChartFieldPreviewLegend(chart: prunedChart, exportSettings: viewSettings,),
                      Visibility(
                        visible: viewSettings.showGrid,
                        child: ChartFieldGrid(chart: prunedChart, showNoStichCells: viewSettings.showNoStichCells)
                      ),
                      if (viewSettings.legendPosition == LegendPosition.right)
                        ChartFieldPreviewLegend(chart: prunedChart, exportSettings: viewSettings,),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
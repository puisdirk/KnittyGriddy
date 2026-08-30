import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitch_icon.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/named_colour.dart';
import 'package:knitty_griddy/utils/constants.dart';

class ChartFieldPreviewLegend extends StatelessWidget {
  final KnittingChart chart;
  final KnittingChartViewSettings exportSettings;

  const ChartFieldPreviewLegend({
    required this.chart,
    required this.exportSettings,
    super.key  
  });

  Widget createStitchEntry(StitchDefinition def) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StitchIcon(stitchDefinition: def, iconSize: 16, withBorder: true,),
        hspacing,
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.name),
            if (exportSettings.showStitchDescriptions && def.description.isNotEmpty)
              Text(def.description),
          ],
        )
      ],
    );
  }

  Widget createColourEntry(NamedColour colour) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 30, 
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: colour.color,
            ),
          ),
        ),
        hspacing,
        Text(colour.name),
        const SizedBox(width: 20,)
      ]
    );
  }

  List<Widget> legendWidgetsHorizontal(KnittingChart chart) {
    List<Widget> widgets = [];

    const int maxColumns = 3;

    if (exportSettings.showStitches && chart.usedStitches.isNotEmpty) {
      int numberOfStsPerColumn = (chart.usedStitches.length / maxColumns).ceil();

      List<Widget> stsColumns = [];

      List<StitchDefinition> usedStitches = List.from(chart.usedStitches);
      
      for (int col = 0; col < maxColumns && usedStitches.isNotEmpty; col++) {
        List<Widget> colWidgets = [];
        for (int colSt = 0; colSt < numberOfStsPerColumn && usedStitches.isNotEmpty; colSt++) {
          StitchDefinition def = usedStitches.removeAt(0);
          colWidgets.add(createStitchEntry(def));
          colWidgets.add(const SizedBox(height: 10,));
        }
        // Add the remaining stitches to the last column
        if (col == (maxColumns - 1)) {
          while (usedStitches.isNotEmpty) {
            StitchDefinition def = usedStitches.first;
            usedStitches.removeAt(0);
            colWidgets.add(createStitchEntry(def));
            colWidgets.add(const SizedBox(height: 10,));
          }
        }

        stsColumns.add(Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: colWidgets,));
        stsColumns.add(hspacing);
      }
      widgets.add(Row(children: stsColumns,));
    }

    if (exportSettings.showColours && chart.usedColours.isNotEmpty) {
      int numberOfColorsPerColumn = (chart.usedColours.length / maxColumns).ceil();

      List<Widget> colourColumns = [];

      List<NamedColour> usedColours = List.from(chart.usedColours);

      for (int column = 0; column < maxColumns && usedColours.isNotEmpty; column++) {
        List<Widget> columnWidgets = [];
        for (int colCol = 0; colCol < numberOfColorsPerColumn && usedColours.isNotEmpty; colCol++) {
          NamedColour def = usedColours.removeAt(0);
          columnWidgets.add(createColourEntry(def));
          columnWidgets.add(const SizedBox(height: 10,));
        }
        // Add the remaining colours to the last column
        if (column == (maxColumns - 1)) {
          while (usedColours.isNotEmpty) {
            NamedColour def = usedColours.removeAt(0);
            columnWidgets.add(createColourEntry(def));
            columnWidgets.add(const SizedBox(height: 10,));
          }
        }

        colourColumns.add(Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: columnWidgets,));
        colourColumns.add(hspacing);
      }

      if (exportSettings.showStitches) {
        widgets.add(const SizedBox(height: 10,));
      }
      widgets.add(Row(children: colourColumns,));
    }

    return widgets;
  }

  List<Widget> legendWidgetsVertical(KnittingChart chart) {
    List<Widget> widgets = [];
    if (exportSettings.showStitches) {
      for (StitchDefinition def in chart.usedStitches) {
        widgets.add(createStitchEntry(def));
        widgets.add(const SizedBox(height: 10,));
      }
    }

    if (exportSettings.showColours) {
      if (exportSettings.showStitches) {
        widgets.add(const SizedBox(height: 20,));
      }
      for (NamedColour colour in chart.usedColours) {
        widgets.add(createColourEntry(colour));
        widgets.add(const SizedBox(height: 10,));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return exportSettings.legendVertical ?
      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: legendWidgetsVertical(chart),) : 
      Column(mainAxisAlignment: MainAxisAlignment.center, children: legendWidgetsHorizontal(chart),);
  }
}
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/charts/model/cell_address.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/named_colour.dart';
import 'package:knitty_griddy/charts/model/stitch_cell.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/common/file_system.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class SvgElement {
  final Size dimensions;
  final String svgString;

  const SvgElement({
    required this.dimensions,
    required this.svgString,
  });
}

class KnittingChartSvgService {
  final KnittingChart chart;
  final KnittingChartViewSettings viewSettings;
  final TextStyle textStyle;

  static const double _gap = 10;

  const KnittingChartSvgService({
    required this.chart,
    required this.viewSettings
  }) : textStyle = const TextStyle(fontFamily: 'roboto', fontSize: 14);

  Future<void> exportKnittingChartToSVG() async {

    SvgElement completeDrawing = getCompleteSvg();

    await FileSystem.saveFile(
      prompt: 'Where do you want to store the output?',
      filename: '${chart.name}.svg',
      bytes: utf8.encode(completeDrawing.svgString));
  }

  SvgElement getCompleteSvg() {
    SvgElement chartAndLegendGroup = _getChartAndLegendGroup();
    const double inset = 20;
    Size completeSize = Size(
      chartAndLegendGroup.dimensions.width + inset,
      chartAndLegendGroup.dimensions.height + (inset * 2)
    );
    String completeSvg = '<svg width="${completeSize.width}" height="${completeSize.height}" viewBox="0 0 ${completeSize.width} ${completeSize.height}" xmlns="http://www.w3.org/2000/svg">';
    completeSvg += '<defs><clipPath id="stitchclippath"><rect x="0" y="0" width="$stitchCellWidth" height="$stitchCellHeight"/></clipPath></defs>';
    completeSvg += '<g class="inset" transform="translate($inset, ${inset * 2})">';
    completeSvg += chartAndLegendGroup.svgString;
    completeSvg += '</g>';
    completeSvg += '</svg>';

    return SvgElement(dimensions: completeSize, svgString: completeSvg);
  }

  SvgElement _getChartAndLegendGroup() {

    if (!viewSettings.showGrid && !viewSettings.showLegend) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    SvgElement chartElement = _getChartAsSvg();
    SvgElement legendElement = _getLegendAsSvg();

    String chartAndLegendGroup = '';
    Size completeSize = Size.zero;

    if (viewSettings.showGrid && !viewSettings.showLegend) {
      chartAndLegendGroup = chartElement.svgString;
      completeSize = chartElement.dimensions;
    } else if (viewSettings.showLegend && !viewSettings.showGrid) {
      chartAndLegendGroup = legendElement.svgString;
      completeSize = legendElement.dimensions;
    } else {
      // Show both chart and legend
      chartAndLegendGroup = '<g class="chartandlegend">';
      switch (viewSettings.legendPosition) {
        case LegendPosition.right:
          double chartYOffset = 0;
          if (legendElement.dimensions.height > chartElement.dimensions.height) {
            chartYOffset = (legendElement.dimensions.height / 2) - (chartElement.dimensions.height / 2);
          }
          double legendYOffset = 0;
          if (chartElement.dimensions.height > legendElement.dimensions.height) {
            legendYOffset = (chartElement.dimensions.height / 2) - (legendElement.dimensions.height / 2);
          }
          double legendXOffset = chartElement.dimensions.width + _gap;
          completeSize = Size(
            chartElement.dimensions.width + _gap + legendElement.dimensions.width, 
            max(chartElement.dimensions.height, legendElement.dimensions.height)
          );          
          chartAndLegendGroup += '<g class="chartgrouptransformer" transform="translate(0, $chartYOffset)">${chartElement.svgString}</g>';
          chartAndLegendGroup += '<g class="legendgrouptransformer" transform="translate($legendXOffset, $legendYOffset)">${legendElement.svgString}</g>';
          break;
        case LegendPosition.left:
          double chartYOffset = 0;
          if (legendElement.dimensions.height > chartElement.dimensions.height) {
            chartYOffset = (legendElement.dimensions.height / 2) - (chartElement.dimensions.height / 2);
          }
          double legendYOffset = 0;
          if (chartElement.dimensions.height > chartElement.dimensions.height) {
            legendYOffset = (chartElement.dimensions.height / 2) - (legendElement.dimensions.height / 2);
          }
          double chartXOffset = legendElement.dimensions.width + _gap;
          completeSize = Size(
            chartElement.dimensions.width + _gap + legendElement.dimensions.width, 
            max(chartElement.dimensions.height, legendElement.dimensions.height)
          );          
          chartAndLegendGroup += '<g class="legendgrouptransformer" transform="translate(0, $legendYOffset)">${legendElement.svgString}</g>';
          chartAndLegendGroup += '<g class="chartgrouptransformer" transform="translate($chartXOffset, $chartYOffset)">${chartElement.svgString}</g>';
          break;
        case LegendPosition.top:
          double center = max(chartElement.dimensions.width, legendElement.dimensions.width) / 2;
          double chartXOffset = center - (chartElement.dimensions.width / 2);
          double legendXOffset = center - (legendElement.dimensions.width / 2);
          double chartYOffset = legendElement.dimensions.height + _gap;
          completeSize = Size(
            max(chartElement.dimensions.width, legendElement.dimensions.width),
            chartElement.dimensions.height + _gap + legendElement.dimensions.height, 
          );          
          chartAndLegendGroup += '<g class="legendgrouptransformer" transform="translate($legendXOffset, 0)">${legendElement.svgString}</g>';
          chartAndLegendGroup += '<g class="chartgrouptransformer" transform="translate($chartXOffset, $chartYOffset)">${chartElement.svgString}</g>';
          break;
        case LegendPosition.bottom:
          double center = max(legendElement.dimensions.width, chartElement.dimensions.width) / 2;
          double chartXOffset = center - (chartElement.dimensions.width / 2);
          double legendXOffset = center - (legendElement.dimensions.width / 2);
          double legendYOffset = chartElement.dimensions.height + _gap;
          completeSize = Size(
            max(chartElement.dimensions.width, legendElement.dimensions.width),
            chartElement.dimensions.height + _gap + legendElement.dimensions.height, 
          );          
          chartAndLegendGroup += '<g class="chartgrouptransformer" transform="translate($chartXOffset, 0)">${chartElement.svgString}</g>';
          chartAndLegendGroup += '<g class="legendgrouptransformer" transform="translate($legendXOffset, $legendYOffset)">${legendElement.svgString}</g>';
          break;
      }

      chartAndLegendGroup += '</g>';
    }

    return SvgElement(dimensions: completeSize, svgString: chartAndLegendGroup);
  }

  SvgElement _getChartAsSvg() {
    if (!viewSettings.showGrid) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    String gridCells = _getGridCellsString();
    String gridLines = _getGridLinesString();
    String outline = _getGridOutlineString();
    String columnAndRowNumbers = _getColumnAndRowNumbersString();
    
    return SvgElement(
      dimensions: Size(
        (chart.chartSettings.columns * stitchCellWidth) + (2 * stitchCellWidth),
        (chart.chartSettings.rows * stitchCellHeight) + (2 * stitchCellHeight)), 
      svgString: '<g class="chartgroup">$gridCells$gridLines$outline$columnAndRowNumbers</g>'
    );
  }

  SvgElement _getLegendAsSvg() {
    if (!viewSettings.showLegend) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    if (viewSettings.legendHorizontal) {
      return _getHorizontalLegendAsSvg();
    } else {
      return _getVerticalLegendAsSvg();
    }
  }

  SvgElement _getHorizontalLegendAsSvg() {
    double totalHeight = 0;
    double totalWidth = 0;

    String legendString = '<g class="horizontal_legend">';

    SvgElement stitchesGroup = _getHorizontalStitchesGroup();
    SvgElement coloursGroup = _getHorizontalColoursGroup();

    totalWidth = max(stitchesGroup.dimensions.width, coloursGroup.dimensions.width);
    totalHeight = stitchesGroup.dimensions.height + coloursGroup.dimensions.height;

    if (viewSettings.showStitches && !viewSettings.showColours) {
      legendString += stitchesGroup.svgString;
    } else if (viewSettings.showColours && ! viewSettings.showColours) {
      legendString += coloursGroup.svgString;
    } else if (viewSettings.showStitches && viewSettings.showColours) {
      // Center both on half the totalWidth
      double stitchesGroupXOffset = stitchesGroup.dimensions.width == totalWidth ? 0 : (totalWidth - stitchesGroup.dimensions.width) / 2;
      double coloursGroupXOffset = coloursGroup.dimensions.width == totalWidth ? 0 : (totalWidth - coloursGroup.dimensions.width) / 2;
      double coloursGroupYOffset = stitchesGroup.dimensions.height + _gap;
      totalHeight += _gap;

      legendString += '<g class="stitchesgrouptransformer" transform="translate($stitchesGroupXOffset, 0)">${stitchesGroup.svgString}</g>';
      legendString += '<g class="coloursgrouptransformer" transform="translate($coloursGroupXOffset, $coloursGroupYOffset)">${coloursGroup.svgString}</g>';
    }

    legendString += '</g>';

    return SvgElement(dimensions: Size(totalWidth, totalHeight), svgString: legendString);
  }

  SvgElement _getHorizontalStitchesGroup() {

    if (!viewSettings.showStitches || chart.usedStitches.isEmpty) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    // The stitches are laid out in maximum 3 columns
    const int maxColumns = 3;
    // The highest of these columns is the total height of this block
    // The total width is the sum of each column's widest stitch block with gaps between the columns
    double totalHeight = 0;
    double totalWidth = 0;

    String stitchesGroupString = '<g class="stitchesgroup">';

    // Divide the stitches evenly over the columns
    int numberOfStitchesPerColumn = (chart.usedStitches.length / maxColumns).ceil();

    // We keep plucking from the list
    List<StitchDefinition> usedStitches = List.from(chart.usedStitches);

    for (int col = 0; col < maxColumns && usedStitches.isNotEmpty; col++) {
      String columnString = '<g class="stitchesColumn">';
      double columnWidth = 0;
      double columnHeight = 0;
      if (col > 0) {
        totalWidth += _gap;
      }

      for (int columnStitch = 0; (col == (maxColumns - 1) || columnStitch < numberOfStitchesPerColumn) && usedStitches.isNotEmpty; columnStitch++) {
        StitchDefinition stitchDefinition = usedStitches.removeAt(0);
        SvgElement stitchBlock = _getStitchBlock(stitchDefinition);
        if (stitchBlock.dimensions.width > columnWidth) {
          columnWidth = stitchBlock.dimensions.width;
        }
        columnString += '<g class="stitchblocktransformer" transform="translate(0, $columnHeight)">${stitchBlock.svgString}</g>';
        columnHeight += _gap + stitchBlock.dimensions.height;
      }

      columnString += '</g>';

      stitchesGroupString += '<g class="stitchescolumntransformer" transform="translate($totalWidth, 0)">$columnString</g>';

      if (columnHeight > totalHeight) {
        totalHeight = columnHeight;
      }
      totalWidth += columnWidth;
    }

    stitchesGroupString += '</g>';

    return SvgElement(dimensions: Size(totalWidth, totalHeight), svgString: stitchesGroupString);
  }

  SvgElement _getStitchBlock(StitchDefinition stitchDefinition) {
    // This block consists of an icon, gap, name an description
    // If the description is shown, the icon needs to be centered as name and description form a column
    SvgElement stitchIcon = _getStitchIcon(stitchDefinition);
    SvgElement stitchInfo = _getStitchInfo(stitchDefinition);

    double center = max(stitchIcon.dimensions.height, stitchInfo.dimensions.height) / 2;

    String legendStitchSvg = '<g class="legendstitch">';
    legendStitchSvg += '<g class="stitchicontransformer" transform="translate(0, ${center - (stitchIcon.dimensions.height / 2)})">${stitchIcon.svgString}</g>';
    legendStitchSvg += '<g class="stitchinfotransformer" transform="translate(${stitchIcon.dimensions.width + _gap}, ${center - (stitchInfo.dimensions.height / 2)})">${stitchInfo.svgString}</g>';
    legendStitchSvg += '</g>';

    return SvgElement(
      dimensions: Size(
        stitchIcon.dimensions.width + _gap + stitchInfo.dimensions.width, 
        max(stitchIcon.dimensions.height, stitchInfo.dimensions.height)
      ), 
      svgString: legendStitchSvg
    );
  }

  SvgElement _getStitchIcon(StitchDefinition def) {
    double scale = 16.0 / stitchCellHeight;
    String svg = '<g class="stitchicon" transform="translate(0, -${scale * stitchCellHeight}) scale($scale)">';
    svg += '<rect x="0" y="0" width="${stitchCellWidth * def.columns}" height="$stitchCellHeight" fill="none" stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade600)}"/>';
    for (int symbolIdx = 0; symbolIdx < def.columns; symbolIdx++) {
/*      svg += '<g clip-path="url(#stitchclippath)" transform="translate(${symbolIdx * stitchCellWidth}, 0)">';
      svg += def.symbolAt(symbolIdx).toSvg(Colors.black);
      svg += '</g>';*/

      svg += '<g transform="translate(${symbolIdx * stitchCellWidth}, 0)">';
      svg += '<g clip-path="url(#stitchclippath)">';
      svg += def.symbolAt(symbolIdx).toSvg(Colors.black);
      svg += '</g>';
      svg += '</g>';
    }
    svg += '</g>';

    return SvgElement(dimensions: Size(scale * (def.columns * stitchCellWidth), scale * stitchCellHeight), svgString: svg);
  }

  SvgElement _getStitchInfo(StitchDefinition def) {
    String svg = '<g class="stitchinfo">';
    svg += '<text font-family="Roboto" font-size="14" fill="black" x="0" y="-2">${def.name}';
    if (viewSettings.showStitchDescriptions && def.description.isNotEmpty) {
      List<String> descriptionLines = def.description.split('\n');
      for (String line in descriptionLines) {
        svg += '<tspan x="0" dy="1.4em">$line</tspan>';
      }
    }
    svg += '</text>';
    svg += '</g>';

    Size nameSize = MathUtitilies.textSize(def.name, textStyle);
    Size descriptionSize = viewSettings.showStitchDescriptions && def.description.isNotEmpty ? 
      MathUtitilies.textSize(def.description, textStyle, maxLines: null) : Size.zero;

    Size totalSize = Size(
      max(nameSize.width, descriptionSize.width), 
      nameSize.height + descriptionSize.height);

    return SvgElement(dimensions: totalSize, svgString: svg);
  }

  SvgElement _getHorizontalColoursGroup() {

    if (!viewSettings.showColours || chart.usedColours.isEmpty) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    // The colours are laid out in maximum 3 columns
    const int maxColumns = 3;
    // The highest of these columns is the total height of this block
    // The total width is the sum of each column's widest stitch block with gaps between the columns
    double totalHeight = 0;
    double totalWidth = 0;

    String coloursGroupString = '<g class="coloursgroup">';

    // Divide the colours evenly over the columns
    int numberOfColoursPerColumn = (chart.usedColours.length / maxColumns).ceil();

    // We keep plucking from the list
    List<NamedColour> usedColours = List.from(chart.usedColours);

    for (int col = 0; col < maxColumns && usedColours.isNotEmpty; col++) {
      String columnString = '<g class="coloursColumn">';
      double columnWidth = 0;
      double columnHeight = 0;
      if (col > 0) {
        totalWidth += _gap;
      }

      for (int columnColour = 0; (col == (maxColumns - 1) || columnColour < numberOfColoursPerColumn) && usedColours.isNotEmpty; columnColour++) {
        NamedColour namedColour = usedColours.removeAt(0);
        SvgElement colourBlock = _getColourBlock(namedColour);
        if (colourBlock.dimensions.width > columnWidth) {
          columnWidth = colourBlock.dimensions.width;
        }
        columnString += '<g class="colourblocktransformer" transform="translate(0, $columnHeight)">${colourBlock.svgString}</g>';
        columnHeight += _gap + colourBlock.dimensions.height;
      }

      columnString += '</g>';

      coloursGroupString += '<g class="colourcolumntransformer" transform="translate($totalWidth, 0)">$columnString</g>';

      if (columnHeight > totalHeight) {
        totalHeight = columnHeight;
      }
      totalWidth += columnWidth;
    }

    coloursGroupString += '</g>';

    return SvgElement(dimensions: Size(totalWidth, totalHeight), svgString: coloursGroupString);
  }

  SvgElement _getColourBlock(NamedColour color) {
    SvgElement colourPill = _getColourPill(color);
    SvgElement colourInfo = _getColourInfo(color);
    
    double center = max(colourPill.dimensions.height, colourInfo.dimensions.height) / 2;

    String completeSvg = '<g class="legendcolour">';
    completeSvg += '<g class="colourpilltransformer" transform="translate(0, ${center - (colourPill.dimensions.height / 2)})">${colourPill.svgString}</g>';
    completeSvg += '<g class="colourinfotransformer" transform="translate(${colourPill.dimensions.width + _gap}, ${center - colourInfo.dimensions.height / 2})">${colourInfo.svgString}</g>';
    completeSvg += '</g>';

    return SvgElement(
      dimensions: Size(
        colourPill.dimensions.width + _gap + colourInfo.dimensions.width, 
        max(colourPill.dimensions.height, colourInfo.dimensions.height)
      ), 
      svgString: completeSvg
    );
  }

  SvgElement _getColourPill(NamedColour colour) {
    String svg = '<g class="colourpill">';
    svg += '<rect class="colourpill" x="0" y="0" width="30" height="20" rx="5" ry="5" ';
    svg += 'stroke="${ColorUtilities.colorToSvhHex(Colors.grey.shade500)}" ';
    svg += 'fill="${ColorUtilities.colorToSvhHex(colour.color)}" ${ColorUtilities.fillOpacity(colour.color)}/>';
    svg += '</g>';

    return SvgElement(dimensions: const Size(30, 20), svgString: svg);
  }

  SvgElement _getColourInfo(NamedColour colour) {
    String svg = '<g class="colourinfo">';
    svg += '<text font-family="Roboto" font-size="14" fill="black" x="0" y="14">${colour.name}</text>';
    svg += '</g>';

    return SvgElement(
      dimensions: MathUtitilies.textSize(colour.name, textStyle), 
      svgString: svg
    );
  }

  SvgElement _getVerticalLegendAsSvg() {
    double totalHeight = 0;
    double totalWidth = 0;

    String legendString = '<g class="vertical_legend">';

    SvgElement stitchesGroup = _getVerticalStitchesGroup();
    SvgElement coloursGroup = _getVerticalColoursGroup();

    totalWidth = max(stitchesGroup.dimensions.width, coloursGroup.dimensions.width);
    totalHeight = stitchesGroup.dimensions.height + coloursGroup.dimensions.height;

    if (viewSettings.showStitches && !viewSettings.showColours) {
      legendString += stitchesGroup.svgString;
    } else if (viewSettings.showColours && !viewSettings.showStitches) {
      legendString += coloursGroup.svgString;
    } else if (viewSettings.showStitches && viewSettings.showColours) {
      totalHeight += _gap;
      legendString += stitchesGroup.svgString;
      legendString += '<g class="coloursgrouptransformer" transform="translate(0, ${stitchesGroup.dimensions.height + _gap})">${coloursGroup.svgString}</g>';
    }

    legendString += '</g>';

    return SvgElement(dimensions: Size(totalWidth, totalHeight), svgString: legendString);
  }

  SvgElement _getVerticalStitchesGroup() {
    if (!viewSettings.showStitches || chart.usedStitches.isEmpty) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    double totalWidth = 0;
    double totalHeight = 0;

    String groupString = '<g class="stitchesgroup">';

    for (StitchDefinition def in chart.usedStitches) {
      SvgElement stitchBlock = _getStitchBlock(def);
      groupString += '<g class="legendstitchtransformer" transform="translate(0, $totalHeight)">${stitchBlock.svgString}</g>';
      totalHeight += stitchBlock.dimensions.height + (def == chart.usedStitches.last ? 0 : _gap);
      if (stitchBlock.dimensions.width > totalWidth) {
        totalWidth = stitchBlock.dimensions.width;
      }
    }

    groupString += '</g>';

    return SvgElement(dimensions: Size(totalWidth, totalHeight), svgString: groupString);
  }

  SvgElement _getVerticalColoursGroup() {
    if (!viewSettings.showColours || chart.usedColours.isEmpty) {
      return const SvgElement(dimensions: Size.zero, svgString: '');
    }

    double totalWidth = 0;
    double totalHeight = 0;

    String groupString = '<g class="coloursgroup">';

    for (NamedColour col in chart.usedColours) {
      SvgElement colourBlock = _getColourBlock(col);
      groupString += '<g class="legendcolourtransformer" transform="translate(0, $totalHeight)">${colourBlock.svgString}</g>';
      totalHeight += colourBlock.dimensions.height + (col == chart.usedColours.last ? 0 : _gap);
      if (colourBlock.dimensions.width > totalWidth) {
        totalWidth = colourBlock.dimensions.width;
      }
    }

    groupString += '</g>';

    return SvgElement(dimensions: Size(totalWidth, totalHeight), svgString: groupString);
  }

  String _getGridCellsString() {
        String gridCellsGroup = '<g class="gridcells" transform="translate($stitchCellWidth, $stitchCellHeight)">';
    for (StitchCell cell in chart.stitches) {
      gridCellsGroup += '<g class="stitchcell" transform="translate(${cell.column * stitchCellWidth}, ${cell.row * stitchCellHeight})">';
      gridCellsGroup += '<g clip-path="url(#stitchclippath)">';
      gridCellsGroup += '<rect x="0" y="0" width="$stitchCellWidth" height="$stitchCellHeight" fill="${ColorUtilities.colorToSvhHex(cell.colour.color)}" ${ColorUtilities.fillOpacity(cell.colour.color)}/>';
      gridCellsGroup += StitchRepository.getStitchDefinitionById(cell.stitchDefinitionId).symbolAt(cell.stitchDefinitionColumn).toSvg(ColorUtilities.contrastingFromColor(cell.colour.color));
      gridCellsGroup += '</g>';
      gridCellsGroup += '</g>';
    }
    gridCellsGroup += '</g>';

    return gridCellsGroup;
  }

  String _getGridLinesString() {
    Color gridColor = Colors.grey.shade600;
    String gridLinesGroup = '<g class="gridlines" transform="translate($stitchCellWidth, $stitchCellHeight)">';
    gridLinesGroup += '<rect x="0" y="0" width="${chart.chartSettings.columns * stitchCellWidth}" height="${chart.chartSettings.rows * stitchCellHeight}" ';
    gridLinesGroup += 'fill="none" stroke="${ColorUtilities.colorToSvhHex(gridColor)}" ${ColorUtilities.strokeOpacity(gridColor)} stroke-width="1"/>';
    for (int col = 1; col < chart.chartSettings.columns; col++) {
      gridLinesGroup += '<line x1="${col * stitchCellWidth}" y1="0" x2="${col * stitchCellWidth}" y2="${chart.chartSettings.rows * stitchCellWidth}" ';
      gridLinesGroup += 'fill="none" stroke="${ColorUtilities.colorToSvhHex(gridColor)}" ${ColorUtilities.strokeOpacity(gridColor)} stroke-width="1"/>';
    }
    for (int row = 1; row < chart.chartSettings.rows; row++) {
      gridLinesGroup += '<line x1="0" y1="${row * stitchCellHeight}" x2="${chart.chartSettings.columns * stitchCellWidth}" y2="${row * stitchCellHeight}" ';
      gridLinesGroup += 'fill="none" stroke="${ColorUtilities.colorToSvhHex(gridColor)}" ${ColorUtilities.strokeOpacity(gridColor)} stroke-width="1"/>';
    }
    gridLinesGroup += '</g>';

    return gridLinesGroup;
  }

  String _getGridOutlineString() {
    Color outlineColor = chart.chartSettings.outlineColor;
    String outlineGroup = '<g class="outline" transform="translate($stitchCellWidth, $stitchCellHeight)">';
    for (CellAddress address in chart.outline) {
      // top
      if (!chart.outline.contains(CellAddress(column: address.column, row: address.row - 1))) {
        outlineGroup += '<line x1="${address.column * stitchCellWidth}" y1="${address.row * stitchCellHeight}" x2="${(address.column * stitchCellWidth) + stitchCellWidth}" y2="${address.row * stitchCellHeight}" fill="none" stroke="${ColorUtilities.colorToSvhHex(outlineColor)}" ${ColorUtilities.strokeOpacity(outlineColor)} stroke-width="2"/>';
      }
      // bottom
      if (!chart.outline.contains(CellAddress(column: address.column, row: address.row + 1))) {
        outlineGroup += '<line x1="${(address.column * stitchCellWidth)}" y1="${(address.row * stitchCellHeight) + stitchCellHeight}" x2="${(address.column * stitchCellWidth) + stitchCellWidth}" y2="${(address.row * stitchCellHeight) + stitchCellHeight}" fill="none" stroke="${ColorUtilities.colorToSvhHex(outlineColor)}" ${ColorUtilities.strokeOpacity(outlineColor)} stroke-width="2"/>';
      }
      // left
      if (!chart.outline.contains(CellAddress(column: address.column - 1, row: address.row))) {
        outlineGroup += '<line x1="${address.column * stitchCellWidth}" y1="${address.row * stitchCellHeight}" x2="${address.column * stitchCellWidth}" y2="${(address.row * stitchCellHeight) + stitchCellHeight}" fill="none" stroke="${ColorUtilities.colorToSvhHex(outlineColor)}" ${ColorUtilities.strokeOpacity(outlineColor)} stroke-width="2"/>';
      }
      // right
      if (!chart.outline.contains(CellAddress(column: address.column + 1, row: address.row))) {
        outlineGroup += '<line x1="${(address.column * stitchCellWidth) + stitchCellWidth}" y1="${address.row * stitchCellHeight}" x2="${(address.column * stitchCellWidth) + stitchCellWidth}" y2="${(address.row * stitchCellHeight) + stitchCellHeight}" fill="none" stroke="${ColorUtilities.colorToSvhHex(outlineColor)}" ${ColorUtilities.strokeOpacity(outlineColor)} stroke-width="2"/>';
      }

    }
    outlineGroup += '</g>';

    return outlineGroup;
  }

  String _getColumnAndRowNumbersString() {
    List<String> leftSideRowIndicators = chart.chartSettings.getLeftSideRowIndicators();
    List<String> rightSideRowIndicators = chart.chartSettings.getRightSideRowIndicators();
    List<String> topSideColumnIndicators = chart.chartSettings.getTopSideColumnIndicators();
    List<String> bottomSideColumnIndicators = chart.chartSettings.getBottomSideColumnIndicators();
    String columnAndRowNumbersGroup = '<g class="columnrownrs">';
    // Rows left side
    for (int row = 0; row < leftSideRowIndicators.length; row++) {
      columnAndRowNumbersGroup += '<text x="${stitchCellWidth / 2}" y="${stitchCellHeight + (row * stitchCellHeight) + (stitchCellHeight / 2) + 8}" ';
      columnAndRowNumbersGroup += 'text-anchor="middle" font-family="Roboto" font-size="14" fill="black" ';
      columnAndRowNumbersGroup += '>${leftSideRowIndicators[row]}</text>';
    }
    // Rows right side
    for (int row = 0; row < rightSideRowIndicators.length; row++) {
      columnAndRowNumbersGroup += '<text x="${stitchCellWidth + (chart.chartSettings.columns * stitchCellWidth) + (stitchCellWidth / 2)}" y="${stitchCellHeight + (row * stitchCellHeight) + (stitchCellHeight / 2) + 8}" ';
      columnAndRowNumbersGroup += 'text-anchor="middle" font-family="Roboto" font-size="14" fill="black" ';
      columnAndRowNumbersGroup += '>${rightSideRowIndicators[row]}</text>';
    }
    // Columns top
    for (int col = 0; col < topSideColumnIndicators.length; col++) {
      columnAndRowNumbersGroup += '<text x="${stitchCellWidth + (col * stitchCellWidth) + (stitchCellWidth / 2)}" y="${(stitchCellHeight / 2) + 8}" ';
      columnAndRowNumbersGroup += 'text-anchor="middle" font-family="Roboto" font-size="14" fill="black" ';
      columnAndRowNumbersGroup += '>${topSideColumnIndicators[col]}</text>';
    }
    // Columns bottom
    for (int col = 0; col < bottomSideColumnIndicators.length; col++) {
      columnAndRowNumbersGroup += '<text x="${stitchCellWidth + (col * stitchCellWidth) + (stitchCellWidth / 2)}" y="${stitchCellHeight + (chart.chartSettings.rows * stitchCellHeight) + (stitchCellHeight / 2) + 8}" ';
      columnAndRowNumbersGroup += 'text-anchor="middle" font-family="Roboto" font-size="14" fill="black" ';
      columnAndRowNumbersGroup += '>${bottomSideColumnIndicators[col]}</text>';
    }
    columnAndRowNumbersGroup += '</g>';

    return columnAndRowNumbersGroup;
  }

}
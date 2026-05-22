
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/charts/export/export_settings.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/knitting_chart.dart';
import 'package:knitty_griddy/model/named_colour.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';

class SvgService {
  static Future<void> exportToSVG(KnittingChart chart, ExportSettings exportSetting, Size drawingSize, Size legendSize) async {
    
    // Draw the grid itself by asking each stitchcell for its svg
    // Position those
    String gridCellsGroup = '<g class="gridcells" transform="translate($stitchCellWidth, $stitchCellHeight)">';
    for (StitchCell cell in chart.stitches) {
      gridCellsGroup += '<g class="stitchcell" transform="translate(${cell.column * stitchCellWidth}, ${cell.row * stitchCellHeight})" clip-path="url(#stitchclippath)">';
      gridCellsGroup += '<rect x="0" y="0" width="$stitchCellWidth" height="$stitchCellHeight" fill="rgb(${cell.colour.color.red}, ${cell.colour.color.green}, ${cell.colour.color.blue}" fill-opacity="${cell.colour.color.alpha / 255}"/>';
      gridCellsGroup += StitchRepository.getStitchDefinitionById(cell.stitchDefinitionId).symbolAt(cell.stitchDefinitionColumn).toSvg(ColorUtilities.contrastingFromColor(cell.colour.color));
      gridCellsGroup += '</g>';
    }
    gridCellsGroup += '</g>';

    // Draw the grid lines
    Color gridColor = Colors.grey.shade600;
    String gridLinesGroup = '<g class="gridlines" transform="translate($stitchCellWidth, $stitchCellHeight)">';
    gridLinesGroup += '<rect x="0" y="0" width="${chart.chartSettings.columns * stitchCellWidth}" height="${chart.chartSettings.rows * stitchCellHeight}" ';
    gridLinesGroup += 'fill="none" stroke="rgb(${gridColor.red}, ${gridColor.green}, ${gridColor.blue})" stroke-opacity="${gridColor.alpha / 255}" stroke-width="1"/>';
    for (int col = 1; col < chart.chartSettings.columns; col++) {
      gridLinesGroup += '<line x1="${col * stitchCellWidth}" y1="0" x2="${col * stitchCellWidth}" y2="${chart.chartSettings.rows * stitchCellWidth}" ';
      gridLinesGroup += 'fill="none" stroke="rgb(${gridColor.red}, ${gridColor.green}, ${gridColor.blue})" stroke-opacity="${gridColor.alpha / 255}" stroke-width="1"/>';
    }
    for (int row = 1; row < chart.chartSettings.rows; row++) {
      gridLinesGroup += '<line x1="0" y1="${row * stitchCellHeight}" x2="${chart.chartSettings.columns * stitchCellWidth}" y2="${row * stitchCellHeight}" ';
      gridLinesGroup += 'fill="none" stroke="rgb(${gridColor.red}, ${gridColor.green}, ${gridColor.blue})" stroke-opacity="${gridColor.alpha / 255}" stroke-width="1"/>';
    }
    gridLinesGroup += '</g>';

    // Draw the outline
    Color outlineColor = Colors.orange;
    String outlineGroup = '<g class="outline" transform="translate($stitchCellWidth, $stitchCellHeight)">';
    for (CellAddress address in chart.outline) {
      // top
      if (!chart.outline.contains(CellAddress(column: address.column, row: address.row - 1))) {
        outlineGroup += '<line x1="${address.column * stitchCellWidth}" y1="${address.row * stitchCellHeight}" x2="${(address.column * stitchCellWidth) + stitchCellWidth}" y2="${address.row * stitchCellHeight}" fill="none" stroke="rgb(${outlineColor.red}, ${outlineColor.green}, ${outlineColor.blue})" stroke-width="2"/>';
      }
      // bottom
      if (!chart.outline.contains(CellAddress(column: address.column, row: address.row + 1))) {
        outlineGroup += '<line x1="${(address.column * stitchCellWidth)}" y1="${(address.row * stitchCellHeight) + stitchCellHeight}" x2="${(address.column * stitchCellWidth) + stitchCellWidth}" y2="${(address.row * stitchCellHeight) + stitchCellHeight}" fill="none" stroke="rgb(${outlineColor.red}, ${outlineColor.green}, ${outlineColor.blue})" stroke-width="2"/>';
      }
      // left
      if (!chart.outline.contains(CellAddress(column: address.column - 1, row: address.row))) {
        outlineGroup += '<line x1="${address.column * stitchCellWidth}" y1="${address.row * stitchCellHeight}" x2="${address.column * stitchCellWidth}" y2="${(address.row * stitchCellHeight) + stitchCellHeight}" fill="none" stroke="rgb(${outlineColor.red}, ${outlineColor.green}, ${outlineColor.blue})" stroke-width="2"/>';
      }
      // right
      if (!chart.outline.contains(CellAddress(column: address.column + 1, row: address.row))) {
        outlineGroup += '<line x1="${(address.column * stitchCellWidth) + stitchCellWidth}" y1="${address.row * stitchCellHeight}" x2="${(address.column * stitchCellWidth) + stitchCellWidth}" y2="${(address.row * stitchCellHeight) + stitchCellHeight}" fill="none" stroke="rgb(${outlineColor.red}, ${outlineColor.green}, ${outlineColor.blue})" stroke-width="2"/>';
      }

    }
    outlineGroup += '</g>';

    // Draw the column and row numbers
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

    // Draw the legend
    String legendGroupChildren = '';
    double totalLegendHeight = 0;
    double totalLegendWidth = legendSize.width;
    if (exportSetting.showLegend) {
      if (exportSetting.legendVertical) {
        if (exportSetting.showStitches) {
          for (StitchDefinition def in chart.usedStitches) {
            int stitchHeight = 20;
            if (exportSetting.showStitchDescriptions && def.description.isNotEmpty) {
              stitchHeight = 20 + (def.description.split('\n').length * 20);
            }

            legendGroupChildren += '<g class="legendstitch" transform="translate(0, $totalLegendHeight)">';
            legendGroupChildren += SvgService._createStitchEntry(def, exportSetting.showStitchDescriptions, stitchHeight);
            legendGroupChildren += '</g>';

            totalLegendHeight += stitchHeight + 10;
          }
        }

        if (exportSetting.showColours && chart.usedColours.isNotEmpty) {
          totalLegendHeight += 20;
          for (NamedColour colour in chart.usedColours) {
            legendGroupChildren += '<g class="legendcolour" transform="translate(0, $totalLegendHeight)">';
            legendGroupChildren += SvgService._createColourEntry(colour);
            legendGroupChildren += '</g>';

            totalLegendHeight += 30;
          }
        }
      } else { // Legend is at top or bottom
        const int maxColumns = 3;
        const charWidth = 6.5;
        double legendWidth = 0;

        if (exportSetting.showStitches && chart.usedStitches.isNotEmpty) {
          int numberOfStsPerColumn = (chart.usedStitches.length / maxColumns).ceil();
          double highestColumnHeight = 0;

          List<StitchDefinition> usedStitches = List.from(chart.usedStitches);

          String stitchColumnsGroup = '<g class="stitchcolunmns">';

          for (int col = 0; col < maxColumns && usedStitches.isNotEmpty; col++) {
            String columnstitches = '<g class="stitchcolumn" transform="translate($legendWidth, 0)">';
            double columnHeight = 0;
            double columWidth = 0;
            for (int colSt = 0; colSt < numberOfStsPerColumn && usedStitches.isNotEmpty; colSt++) {
              StitchDefinition def = usedStitches.removeAt(0);
              int stitchHeight = 20;
              double stitchWidth = ((def.columns * stitchCellWidth) * (16.0 / stitchCellWidth)) + 10 + (def.name.length * charWidth);
              if (exportSetting.showStitchDescriptions && def.description.isNotEmpty) {
                stitchHeight = 20 + (def.description.split('\n').length * 20);
                int largestNumChars = 0;
                for (String line in def.description.split('\n')) {
                  if (line.length > largestNumChars) {
                    largestNumChars = line.length;
                  }
                }
                stitchWidth = ((def.columns * stitchCellWidth) * (16.0 / stitchCellWidth)) + 10 + (largestNumChars * charWidth);
              }
              if (stitchWidth > columWidth) {
                columWidth = stitchWidth;
              }
              columnstitches += '<g class="legendstitch" transform="translate(0, $columnHeight)">';
              columnstitches += SvgService._createStitchEntry(def, exportSetting.showStitchDescriptions, stitchHeight);
              columnstitches += '</g>';

              columnHeight += stitchHeight + 10;
            }

            // add remaining sts
            if (col == (maxColumns - 1)) {
              while (usedStitches.isNotEmpty) {
                StitchDefinition def = usedStitches.removeAt(0);
                int stitchHeight = 20;
                double stitchWidth = ((def.columns * stitchCellWidth) * (16.0 / stitchCellWidth)) + 10 + (def.name.length * charWidth);
                if (exportSetting.showStitchDescriptions && def.description.isNotEmpty) {
                  stitchHeight = 20 + (def.description.split('\n').length * 20);
                  int largestNumChars = 0;
                  for (String line in def.description.split('\n')) {
                    if (line.length > largestNumChars) {
                      largestNumChars = line.length;
                    }
                  }
                  stitchWidth = ((def.columns * stitchCellWidth) * (16.0 / stitchCellWidth)) + 10 + (largestNumChars * charWidth);
                }
                if (stitchWidth > columWidth) {
                  columWidth = stitchWidth;
                }
                columnstitches += '<g class="legendstitch" transform="translate(0, $columnHeight)">';
                columnstitches += SvgService._createStitchEntry(def, exportSetting.showStitchDescriptions, stitchHeight);
                columnstitches += '</g>';

                columnHeight += stitchHeight + 10;
              }
            }

            columnstitches += '</g>';
            stitchColumnsGroup += columnstitches;
            stitchColumnsGroup += '</g>';
            legendWidth += columWidth;

            if (columnHeight > highestColumnHeight) {
              highestColumnHeight = columnHeight;
            }
          } // end of 'for each column
          totalLegendHeight += highestColumnHeight;

          legendGroupChildren += stitchColumnsGroup;
        }

        if (exportSetting.showColours && chart.usedColours.isNotEmpty) {
          int numberOfColorsPerColumn = (chart.usedColours.length / maxColumns).ceil();
          double highestColumnHeight = 0;
          double colourColumsWidth = 0;

          List<NamedColour> usedColours = List.from(chart.usedColours);

          String colourColumnsGroup = '<g class="colourcolumns" transform="translate(0, $totalLegendHeight)">';

          for (int column = 0; column < maxColumns && usedColours.isNotEmpty; column++) {
            double columnHeight = 0;
            double columnWidth = 0;
            String columnColours = '<g class="colourcolumn" transform="translate($colourColumsWidth, 0)">';

            for (int columnColour = 0; columnColour < numberOfColorsPerColumn && usedColours.isNotEmpty; columnColour++) {
              NamedColour colour = usedColours.removeAt(0);
              double colourWidth = 30 + 10 + (colour.name.length * charWidth);
              if (colourWidth > columnWidth) {
                columnWidth = colourWidth;
              }

              columnColours += '<g class="legendcolour" transform="translate(0, $columnHeight)">';
              columnColours += _createColourEntry(colour);
              columnColours += '</g>';

              columnHeight += 30;
            }
            // Add the remaining colours
            if (column == (maxColumns - 1)) {
              while (usedColours.isNotEmpty) {
                NamedColour colour = usedColours.removeAt(0);
                double colourWidth = 30 + 10 + (colour.name.length * charWidth);
                if (colourWidth > columnWidth) {
                  columnWidth = colourWidth;
                }

                columnColours += '<g class="legendcolour" transform="translate(0, $columnHeight)">';
                columnColours += _createColourEntry(colour);
                columnColours += '</g>';

                columnHeight += 30;
              }

              if (columnHeight > highestColumnHeight) {
                highestColumnHeight = columnHeight;
              }
            }

            columnColours += '</g>';
            colourColumnsGroup += columnColours;
          }

          colourColumnsGroup += '</g>';

          totalLegendHeight += highestColumnHeight;
          legendGroupChildren += colourColumnsGroup;
        }

      }
    }

    String legendGroup = '<g class="legend"></g>';
    if (exportSetting.showLegend) {
      switch (exportSetting.legendPosition) {
        case LegendPosition.right:
          double y = ((chart.chartSettings.rows * stitchCellHeight) / 2) - (totalLegendHeight / 2);
          if (y < 30) {
            y = 30;
          }
          legendGroup = '<g class="legend" transform="translate(${((chart.chartSettings.columns + 2) * stitchCellWidth) + 20}, $y)">$legendGroupChildren</g>';
          break;
        case LegendPosition.left:
          double y = ((chart.chartSettings.rows * stitchCellHeight) / 2) - (totalLegendHeight / 2);
          if (y < 30) {
            y = 30;
          }
          legendGroup = '<g class="legend" transform="translate(0, $y)">$legendGroupChildren</g>';
          break;
        case LegendPosition.top:
          double x = (((chart.chartSettings.columns + 2) * stitchCellWidth) / 2) - (totalLegendWidth / 2);
          if (x < 30) {
            x = 30;
          }
          legendGroup = '<g class="legend" transform="translate($x, 0)">$legendGroupChildren</g>';
          break;
        case LegendPosition.bottom:
          double x = (((chart.chartSettings.columns + 2) * stitchCellWidth) / 2) - (totalLegendWidth / 2);
          if (x < 30) {
            x = 30;
          }
          legendGroup = '<g class="legend" transform="translate($x, ${((chart.chartSettings.rows + 2) * stitchCellHeight) + 10})">$legendGroupChildren</g>';
          break;
      }
    }

    String chartGroup = '';
    switch (exportSetting.legendPosition) {
      case LegendPosition.top:
        double x = (totalLegendWidth / 2) - (((chart.chartSettings.rows + 2) * stitchCellHeight) + 10) / 2;
        if (x < 30) {
          x = 30;
        }
        chartGroup = '<g class="chart" transform="translate($x, ${totalLegendHeight + 20})">';
        break;
      case LegendPosition.bottom:
        double x = (totalLegendWidth / 2) - (((chart.chartSettings.rows + 2) * stitchCellHeight) + 10) / 2;
        if (x < 30) {
          x = 30;
        }
        chartGroup = '<g class="chart" transform="translate($x, 0)">';
        break;
      case LegendPosition.left:
        chartGroup = '<g class="chart" transform="translate($totalLegendWidth, 0)">';
        break;
      case LegendPosition.right:
        chartGroup = '<g class="chart">';
    }
    
    chartGroup += gridCellsGroup;
    chartGroup += gridLinesGroup;
    chartGroup += outlineGroup;
    chartGroup += columnAndRowNumbersGroup;
    chartGroup += '</g>';

    String completeDrawing = '<svg width="${drawingSize.width}" height="${drawingSize.height}" viewBox="0 0 ${drawingSize.width} ${drawingSize.height}" xmlns="http://www.w3.org/2000/svg">';
    completeDrawing += '<defs><clipPath id="stitchclippath"><rect x="0" y="0" width="$stitchCellWidth" height="$stitchCellHeight"/></clipPath></defs>';
    completeDrawing += '<g class="inset" transform="translate(20, 20)">';
    completeDrawing += chartGroup;
    completeDrawing += legendGroup;
    completeDrawing += '</g>';
    completeDrawing += '</svg>';
    
    await FilePicker.platform.saveFile(
      dialogTitle: 'Where do you want to store the output?',
      fileName: '${chart.name}.svg',
      bytes: utf8.encode(completeDrawing),
    );
  }

  static String _createStitchEntry(StitchDefinition def, bool showDescription, int stitchHeight) {
    String svg = '';

    // The icon    
    svg += '<g class="stitchicon" transform="translate(0, ${(stitchHeight / 2) - (stitchCellHeight / 2)}) scale(${16.0 / stitchCellHeight})">';
    for (int symbolIdx = 0; symbolIdx < def.columns; symbolIdx++) {
      svg += '<g clip-path="url(#stitchclippath)" transform="translate(${symbolIdx * stitchCellWidth}, 0)">';
      svg += def.symbolAt(symbolIdx).toSvg(Colors.black);
      svg += '</g>';
    }
    svg += '</g>';

    // Name and description
    svg += '<g class="stitchinfo" transform="translate(${((def.columns * stitchCellWidth) * (16.0 / stitchCellWidth)) + 10}, 0)">';
    svg += '<text font-family="Roboto" font-size="14" fill="black" x="0" y="2">${def.name}';
    if (showDescription) {
      List<String> descriptionLines = def.description.split('\n');
      for (String line in descriptionLines) {
        svg += '<tspan x="0" dy="1.4em">$line</tspan>';
      }
    }
    svg += '</text>';
    svg += '</g>';

    return svg;
  }

  static String _createColourEntry(NamedColour colour) {
    String svg = '';

    final Color pillBorder = Colors.grey.shade500;

    // The colour pill
    svg += '<rect class="colourpill" x="0" y="0" width="30" height="20" rx="5" ry="5" ';
    svg += 'stroke="rgb(${pillBorder.red}, ${pillBorder.green}, ${pillBorder.blue})" ';
    svg += 'fill="rgb(${colour.color.red}, ${colour.color.green}, ${colour.color.blue})" fill-opacity="${colour.color.alpha / 255}"/>';

    // The name
    svg += '<g class="colourinfo" transform="translate(40, 8)">';
    svg += '<text font-family="Roboto" font-size="14" fill="black" x="0" y="8">${colour.name}</text>';
    svg += '</g>';

    return svg;
  }
}
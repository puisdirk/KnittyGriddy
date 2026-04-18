
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/controls/stitchrepo/knitting_symbol_control.dart';
import 'package:provider/provider.dart';

class StitchCellControl extends StatelessWidget {
  final StitchCell stitchCell;

  const StitchCellControl({
    required this.stitchCell,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, AppState>(
      selector: (_, model) => model.appState,
      builder: (context, appState, _) {
        return Positioned(
          top: (stitchCell.row) * stitchCellHeight,
          left: (stitchCell.column) * stitchCellWidth,  
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              // Paint stitches or colours while moving the mouse
              if (appState.mouseOption == MouseOption.painting && event.buttons != 0) {
                if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinition != appState.selectedStitch) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                }
              }
            },
            child: GestureDetector(
              onTap: () {
                // Click to change stitch, colour, or selection
                if (appState.mouseOption == MouseOption.singleclick) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinition != appState.selectedStitch) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                } else if (appState.currentTool == Tool.select) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).toggleCell(stitchCell.column, stitchCell.row);
                }
              },
              onTapDown: (details) {
                // Change initial stitch or colour when painting
                if (appState.mouseOption == MouseOption.painting) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinition != appState.selectedStitch) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                }
              },
              child: Container(
                color: stitchCell.colour.color,
                height: stitchCellHeight,
                width: stitchCellWidth,
                  child: KnittingSymbolControl(
                    knittingSymbol: stitchCell.stitchDefinition.symbolAt(stitchCell.stitchDefinitionColumn),
                    symbolColor: ColorUtilities.contrastingFromColor(stitchCell.colour.color),
                  )
              ),
            ),
          )
        );
      }
    );
  }
}
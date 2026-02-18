
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/stitch_part_icon.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
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
          top: (stitchCell.row - 1) * stitchCellHeight,
          left: (stitchCell.column - 1) * stitchCellWidth,  
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              if (appState.mouseOption == MouseOption.painting && event.buttons != 0) {
                if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinition != appState.selectedStitch) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                }
              } else if (appState.currentTool == Tool.select) {
                  
              }
            },
            child: GestureDetector(
              onTap: () {
                if (appState.mouseOption == MouseOption.singleclick) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinition != appState.selectedStitch) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                } else if (appState.currentTool == Tool.select) {
                  Provider.of<KnittyGriddyModel>(context, listen: false).selectInRect(
                    fromRow: stitchCell.row, upToRow: stitchCell.row, fromColumn: stitchCell.column, upToColumn: stitchCell.column);
                }
              },
              onTapDown: (details) {
                if (appState.mouseOption == MouseOption.painting) {
                  if (appState.currentTool == Tool.stitch && stitchCell.stitchDefinition != appState.selectedStitch) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitch(stitchCell.row, stitchCell.column, appState.selectedStitch!);
                  } else if (appState.currentTool == Tool.colour && stitchCell.colour != appState.selectedColour) {
                    Provider.of<KnittyGriddyModel>(context, listen: false).setStitchColour(stitchCell.row, stitchCell.column, appState.selectedColour!);
                  }
                } else if (appState.currentTool == Tool.select) {
                
                }
              },
              child: Selector<KnittyGriddyModel, Selection>(
                selector: (_, model) => model.selection,
                builder: (context, selection, _) {
                  return Container(
                    color: stitchCell.colour.color,
                    height: stitchCellHeight,
                    width: stitchCellWidth,
                    child: StitchPartIcon(
                      stitchDefinition: stitchCell.stitchDefinition, 
                      stitchDefinitionColumn: stitchCell.stitchDefinitionColumn,
                    ),
                  );
                }
              ),
            ),
          )
        );
      }
    );
  }
}
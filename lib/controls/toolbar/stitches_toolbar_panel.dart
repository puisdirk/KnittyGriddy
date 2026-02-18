
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:provider/provider.dart';

class StitchesToolbarPanel extends StatelessWidget {

  const StitchesToolbarPanel({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Selector<KnittyGriddyModel, List<StitchDefinition>>(
        selector: (_, model) => model.usedStitches,
        builder: (context, usedStitches, _) {
          // Making width dependent on largest stich icon + name
          double spacerwidth = 14;
          double widestStitchWidth = 0;
          for (StitchDefinition def in usedStitches) {
            double width = (spacerwidth * 3) + (def.columns * 28.0) + (def.name.length * 10);
            if (width > widestStitchWidth) {
              widestStitchWidth = width;
            }
          }
          return Column(
            children: [
              Selector<KnittyGriddyModel, AppState>(
                selector: (_, model) => model.appState,
                builder: (context, appState, _) {
                  return Wrap(alignment: WrapAlignment.start,
                    children: [
                      for (StitchDefinition stitchDefinition in usedStitches)
                        SizedBox(
                          width: widestStitchWidth, height: 50,
                          child: Card(
                            // Highlight the button for single click or paint mode
                            color: appState.currentTool != Tool.select ? appState.selectedStitch == stitchDefinition ? Colors.blue.withAlpha(60) : null : null,
                            child: Selector<KnittyGriddyModel, Selection>(
                              selector: (_, model) => model.selection,
                              builder: (context, selection, _) {
                                return InkWell(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: (appState.currentTool == Tool.select && selection.numberOfColumns < stitchDefinition.columns) ?
                                    null :
                                    () {
                                    switch (appState.currentTool) {
                                      case Tool.stitch:
                                      case Tool.colour:
                                        Provider.of<KnittyGriddyModel>(context, listen: false).appUseStitch(stitchDefinition);
                                        break;
                                      case Tool.select:
                                        Provider.of<KnittyGriddyModel>(context, listen: false).fillSelectionWithStitch(stitchDefinition);
                                        break;
                                      default:
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: spacerwidth,),
                                      StitchIcon(stitchDefinition: stitchDefinition, iconSize: 16,),
                                      SizedBox(width: spacerwidth,),
                                      Text(stitchDefinition.name, 
                                        style: 
                                          (appState.currentTool == Tool.select && (selection.isEmpty || selection.numberOfColumns < stitchDefinition.columns)) ?
                                            Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade400) : 
                                            Theme.of(context).textTheme.bodyMedium!
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20,),
              Align(
                alignment: Alignment.bottomCenter, 
                child: IconButton.outlined(
                  onPressed: () {
                  // TODO: show stitches repo to select a stitch
                }, 
                icon: const Icon(Icons.add)),
                // TODO: add a fill button to fill with preset patterns
              ),
            ],
          );
        },
      ),
    );
  }
}
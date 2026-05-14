import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repo_page.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:provider/provider.dart';

class StitchesToolbarPanel extends StatelessWidget {

  static const double _spacerwidth = 14;
  static const double _iconSize = 16;

  const StitchesToolbarPanel({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Selector<KnittyGriddyModel, List<StitchDefinition>>(
        selector: (_, model) => model.usedStitches,
        builder: (context, usedStitches, _) {
          return Column(
            children: [
              Selector<KnittyGriddyModel, AppState>(
                selector: (_, model) => model.appState,
                builder: (context, appState, _) {
                  return Wrap(alignment: WrapAlignment.start,
                    children: [
                      for (StitchDefinition stitchDefinition in usedStitches)
                        Builder(
                          builder: (context) {
                            double cardWidth = 
                              _spacerwidth + 
                              (stitchDefinition.columns * _iconSize) + 
                              _spacerwidth + 
                              MathUtitilies.textSize(stitchDefinition.name, Theme.of(context).textTheme.bodyMedium!).width + 
                              _spacerwidth + _spacerwidth + (appState.currentTool == Tool.select ? _iconSize + (2 * _spacerwidth) : 0);
                              
                            return SizedBox(
                              width: cardWidth, height: 50,
                              child: Card(
                                // Highlight the button for single click or paint mode
                                color: appState.currentTool != Tool.select ? appState.selectedStitch == stitchDefinition ? Colors.blue.withAlpha(60) : null : null,
                                child: Selector<KnittyGriddyModel, Selection>(
                                  selector: (_, model) => model.selection,
                                  builder: (context, selection, _) {
                                    return InkWell(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      splashColor: Colors.blue.withAlpha(30),
                                      // Disable the stitch button in select mode if the selection has less columns than needed
                                      onTap: (appState.currentTool == Tool.select && !selection.hasWidthOf(stitchDefinition.columns)) ?
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
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: _spacerwidth, ),
                                          StitchIcon(
                                            stitchDefinition: stitchDefinition, 
                                            iconSize: _iconSize, 
                                            iconColor: (appState.currentTool == Tool.select && !selection.hasWidthOf(stitchDefinition.columns)) ? Colors.grey.shade400 : Colors.black,),
                                          const SizedBox(width: _spacerwidth, ),
                                          Text(stitchDefinition.name, 
                                            style: 
                                              (appState.currentTool == Tool.select && (selection.isEmpty || !selection.hasWidthOf(stitchDefinition.columns))) ?
                                                Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade400) : 
                                                Theme.of(context).textTheme.bodyMedium!
                                          ),
                                          const SizedBox(width: _spacerwidth, ),
                                          if (appState.currentTool == Tool.select)
                                            IconButton(
                                              onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleStitchDefinition(stitchDefinition), 
                                              icon: const Icon(Icons.select_all),
                                              iconSize: _iconSize,
                                            )
                                        ],
                                      ),
                                    );
                                  }
                                ),
                              ),
                            );
                          }
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20,),
              Align(
                alignment: Alignment.bottomCenter, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.outlined(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const StitchRepoPage())
                        );
                      }, 
                      icon: const Icon(Icons.add)
                    ),
                    const SizedBox(width: 20,),
                    IconButton.outlined(
                      onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).pruneUnusedStitches(),
                      icon: const Icon(Icons.content_cut)
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
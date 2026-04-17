import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:provider/provider.dart';

class GridSettingsControl extends StatelessWidget {
  const GridSettingsControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, AppState>(
      selector: (_, model) => model.appState,
      builder: (context, appstate, _) {
        return appstate.mouseOption != MouseOption.settings ?
          const SizedBox(height: 1,) :
          Selector<KnittyGriddyModel, PatternSettings>(
            selector: (_, model) => model.settings,
            builder: (context, settings, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20,),
                  const Text('Numbering:'),
                  const SizedBox(width: 10,),
                  SegmentedButton<GridType>(
                    emptySelectionAllowed: false,
                    multiSelectionEnabled: false,
                    showSelectedIcon: false,
                    segments: [
                      for (GridType gridType in GridType.values)
                        ButtonSegment(
                          value: gridType,
                          label: Text(gridType.toString()),
                        ),
                    ], 
                    selected: {settings.gridType},
                    onSelectionChanged: (Set<GridType>? newGridType) => Provider.of<KnittyGriddyModel>(context, listen: false).useGridType(newGridType!.first),
                  ),
                ],
              );
            }
          );
      }
    );
  }
}
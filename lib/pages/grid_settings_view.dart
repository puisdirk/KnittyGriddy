
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:provider/provider.dart';

class GridSettingsView extends StatelessWidget {
  final Function() onClose;

  const GridSettingsView({
    required this.onClose,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400, height: 200, 
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Grid type'),
                  Selector<KnittyGriddyModel, PatternSettings>(
                    selector: (_, model) => model.settings,
                    builder: (context, settings, _) {
                      return SegmentedButton<GridType>(
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
                      );
                    }
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onClose, child: const Text('Close'))
              ],
            )
          ],
        )
      )
    );
  }
}
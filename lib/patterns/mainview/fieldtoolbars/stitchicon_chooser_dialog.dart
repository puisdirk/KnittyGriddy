
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitch_icon.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class StitchiconChooserDialog extends StatefulWidget {
  const StitchiconChooserDialog({super.key});

  @override
  State<StitchiconChooserDialog> createState() => _StitchiconChooserDialogState();
}

class _StitchiconChooserDialogState extends State<StitchiconChooserDialog> {
  String filterText = '';
  late TextEditingController filterController;
  late StitchDefinition? selectedDefinition;  
  void _filterChanged() {
    setState(() => filterText = filterController.text);
  }

  @override
  void initState() {
    filterController = TextEditingController(text: filterText);
    filterController.addListener(_filterChanged);

    selectedDefinition = null;

    super.initState();
  }

  @override
  void dispose() {
    filterController.removeListener(_filterChanged);
    filterController.dispose();

    super.dispose();
  }

  static const double _spacerwidth = 12;
  static const double _iconWidth = 16;

  Widget createCategory(String category, List<StitchDefinition> stitchesInCategory) {
    List<Widget> cards = [];
    for (StitchDefinition sd in stitchesInCategory) {
      bool stitchSelected = sd == selectedDefinition;
      double cardWidth = 
        _spacerwidth + 
        (sd.columns * _iconWidth) + 
        _spacerwidth + 
        MathUtitilies.textSize(sd.name, Theme.of(context).textTheme.bodyMedium!).width + 
        _spacerwidth + _spacerwidth;

      cards.add(SizedBox(
        width: cardWidth, 
        height: 50,
        child: Card(
          color: stitchSelected ? Colors.blue.withAlpha(60) : null,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            splashColor: Colors.blue.withAlpha(30),
            onTap: () => setState(() => selectedDefinition = sd),
            onDoubleTap: () {
              Navigator.pop(context, sd);
            },
            child: Row(
              children: [
                const SizedBox(width: _spacerwidth,),
                StitchIcon(stitchDefinition: sd, iconSize: _iconWidth, iconColor: stitchSelected ? Colors.white : null,),
                const SizedBox(width: _spacerwidth,),
                Text(sd.name,
                  style: stitchSelected ?
                    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white) : 
                    Theme.of(context).textTheme.bodyMedium!
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        const SizedBox(height: 10,),
        Text(category),
        Wrap(children: cards,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a stitch symbol'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                const Text('Filter:'),
                const SizedBox(width: 20,),
                SizedBox(
                  width: 500,
                  child: TextField(controller: filterController, autofocus: true,),  
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Expanded(
              child: Selector<ChartsModel, List<StitchSet>>(
                selector: (_, model) => model.filteredStitchSets(filterText),
                builder: (context, stitchSets, _) {
                  return DefaultTabController(
                    length: stitchSets.length,
                    child: Column(
                      children: [
                        TabBar(tabs: [
                          for (StitchSet stitchSet in stitchSets)
                            Tab(text: stitchSet.name,)
                        ]),
                        Expanded(
                          child: TabBarView(
                            children: [
                              for (StitchSet stitchSet in stitchSets)
                                ListView(
                                  children: [
                                    for (String category in Set.from(stitchSet.definitions.map((d) => d.category)))
                                      createCategory(category, stitchSet.definitions.where((d) => d.category == category).toList()),
                                  ],
                                ),
                            ]
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(), 
          label: const Text('Cancel'),
          icon: const Icon(Symbols.close_small, weight: 700,),
        ),
        ElevatedButton.icon(
          onPressed: selectedDefinition == null ? null : () => Navigator.pop(context, selectedDefinition), 
          label: const Text('Ok'),
          icon: const Icon(Icons.check),
        )
      ],
    );
  }
}
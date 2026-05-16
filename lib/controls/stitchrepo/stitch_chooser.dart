
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class StitchChooser extends StatefulWidget {
  const StitchChooser({super.key});

  @override
  State<StitchChooser> createState() => _StitchChooserState();
}

class _StitchChooserState extends State<StitchChooser> {
  String filterText = '';
  late TextEditingController filterController;
  
  void _filterChanged() {
    setState(() => filterText = filterController.text);
  }

  @override
  void initState() {
    filterController = TextEditingController(text: filterText);
    filterController.addListener(_filterChanged);

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

  Widget createCategory(KnittingPattern pattern, String category, List<StitchDefinition> stitchesInCategory) {
    List<Widget> cards = [];
    for (StitchDefinition sd in stitchesInCategory) {
      bool stitchInPattern = pattern.stitches.any((cell) => cell.stitchDefinitionId == sd.id);
      bool stitchSelected = pattern.usedStitches.contains(sd);
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
          color: stitchInPattern ? Colors.purple.shade100.withAlpha(60) : stitchSelected ? Colors.blue.withAlpha(60) : null,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            splashColor: Colors.blue.withAlpha(30),
            onTap: stitchInPattern ? null : () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleUsedStitch(sd),
            child: Row(
              children: [
                const SizedBox(width: _spacerwidth,),
                StitchIcon(stitchDefinition: sd, iconSize: _iconWidth, iconColor: stitchInPattern || stitchSelected ? Colors.white : null,),
                const SizedBox(width: _spacerwidth,),
                Text(sd.name,
                  style: stitchInPattern || stitchSelected ?
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
      title: const Text('Add or remove stitches'),
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
              child: Selector<KnittyGriddyModel, List<StitchSet>>(
                selector: (_, model) => model.filteredStitchSets(filterText),
                builder: (context, stitchSets, _) {
                  return Selector<KnittyGriddyModel, KnittingPattern>(
                    selector: (_, model) => model.knittingPattern,
                    builder: (context, pattern, _) {
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
                                          createCategory(pattern, category, stitchSet.definitions.where((d) => d.category == category).toList()),
                                      ],
                                    ),
                                ]
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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
          label: const Text('close'),
          icon: const Icon(Symbols.close_small, weight: 700,),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/stitchrepo/stitch_repository.dart';
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

  static const double _spacerwidth = 14;

  Widget createCategory(KnittingPattern pattern, MapEntry<String, List<StitchDefinition>> entry) {
    double widestStitchWidth = 0;
    for (StitchDefinition def in entry.value) {
      double width = (_spacerwidth * 3) + (def.columns * 28.0) + (def.name.length * 10);
      if (width > widestStitchWidth) {
        widestStitchWidth = width;
      }
    }

    List<Widget> cards = [];
    for (StitchDefinition sd in entry.value) {
      bool stitchInPattern = pattern.stitches.any((cell) => cell.stitchDefinition == sd);
      bool stitchSelected = pattern.usedStitches.contains(sd);

      cards.add(SizedBox(
        width: widestStitchWidth, height: 50,
        child: Card(
          color: stitchSelected ? Colors.blue.withAlpha(60) : null,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            splashColor: Colors.blue.withAlpha(30),
            onTap: stitchInPattern ? null : () => Provider.of<KnittyGriddyModel>(context, listen: false).toggleUsedStitch(sd),
            child: Row(
              children: [
                const SizedBox(width: 14,),
                StitchIcon(stitchDefinition: sd, iconSize: 16, iconColor: stitchInPattern || stitchSelected ? Colors.white : null,),
                const SizedBox(width: 14,),
                Text(sd.name,
                  style: sd == StitchRepository.noStitch || stitchInPattern || stitchSelected ?
                    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white) : 
                    Theme.of(context).textTheme.bodyMedium!
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.key), Wrap(children: cards,)],);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Filter:'),
            const SizedBox(width: 20,),
            SizedBox(
              width: 500,
              child: TextField(controller: filterController, autofocus: true,),  
            )
          ],
        ),
        const SizedBox(height: 20,),
        Selector<KnittyGriddyModel, Map<String, List<StitchDefinition>>>(
          selector: (_, model) => model.selectStitchDefinitionsPerCategory(filterText),
          builder: (context, filteredStitches, _) {
            return Selector<KnittyGriddyModel, KnittingPattern>(
              selector: (_, model) => model.knittingPattern,
              builder: (context, pattern, _) {
                return Expanded(
                  child: ListView(
                    children: [
                      for (MapEntry<String, List<StitchDefinition>> entry in filteredStitches.entries)
                        createCategory(pattern, entry),
                    ],
                  ),
                );
              }
            );
          }
        )
      ],
    );
  }
}
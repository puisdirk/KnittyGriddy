import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/controls/stitch_part_icon.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/model/knitting_symbol_parts.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:provider/provider.dart';

class StitchPartsChooser extends StatefulWidget {
  const StitchPartsChooser({
    super.key
  });

  @override
  State<StitchPartsChooser> createState() => _StitchPartsChooserState();
}

class _StitchPartsChooserState extends State<StitchPartsChooser> {

  List<StitchDefinition> _selectedStitches = [];
  List<KnittingSymbolPart> _selectedParts = [];
  
  static const double _spacerwidth = 14;
  static const double _iconWidth = 16;

  void _togglePart(KnittingSymbolPart part) {
    if (_selectedParts.contains(part)) {
      setState(() {
        _selectedParts = _selectedParts.where((p) => p != part).toList();
      });
    } else {
      setState(() {
        _selectedParts = [..._selectedParts, part];
      });
    }
  }

  void _toggleStitch(StitchDefinition def) {
    if (_selectedStitches.contains(def)) {
      setState(() {
        _selectedStitches = _selectedStitches.where((s) => s != def).toList();
      });
    } else {
      setState(() {
        _selectedStitches = [..._selectedStitches, def];
      });
    }
  }

  List<List<KnittingSymbolPart>> get _mergedSymbols {
    if (_selectedStitches.isEmpty && _selectedParts.isEmpty) {
      return [];
    }

    if (_selectedStitches.isEmpty) {
      return [_selectedParts];
    }

    int width = 0;
    for (StitchDefinition def in _selectedStitches) {
      if (def.columns > width) {
        width = def.columns;
      }
    }
    List<List<KnittingSymbolPart>> res = List.generate(width, (idx) => []);

    res[0].addAll(_selectedParts);

    for (StitchDefinition def in _selectedStitches) {
      for (int idx = 0; idx < def.columns; idx++) {
        res[idx].addAll(def.symbolAt(idx).parts);
      }
    }

    return res;
  }

  Widget createStandardPartsCategory() {
    List<Widget> cards = [];
    for (KnittingSymbolPart part in KnittingSymbolParts.parts) {
      
      double cardWidth = 
        _spacerwidth +
        _iconWidth +
        _spacerwidth +
        MathUtitilies.textSize(part.name, Theme.of(context).textTheme.bodyMedium!).width +
        _spacerwidth + _spacerwidth;

      cards.add(SizedBox(
        width: cardWidth, 
        height: 50,
        child: Card(
          color: _selectedParts.contains(part) ? Colors.blue.withAlpha(60) : null,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            splashColor: Colors.black.withAlpha(30),
            onTap: () => _togglePart(part),
            child: Row(
              children: [
                const SizedBox(width: _spacerwidth,),
                StitchPartIcon(part: part, iconSize: _iconWidth,),
                const SizedBox(width: _spacerwidth,),
                Text(part.name),
                const SizedBox(width: _spacerwidth,)
              ],
            ),
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Basic symbols')),
        const SizedBox(height: 10,),
        Wrap(children: cards,),
      ],
    );
  }

  Widget createCategory(String category, List<StitchDefinition> stitchesInCategory) {
    List<Widget> cards = [];
    for (StitchDefinition sd in stitchesInCategory) {
      bool stitchSelected = _selectedStitches.contains(sd);

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
            onTap: () => _toggleStitch(sd),
            child: Row(
              children: [
                const SizedBox(width: _spacerwidth,),
                StitchIcon(stitchDefinition: sd, iconSize: _iconWidth),
                const SizedBox(width: _spacerwidth,),
                Text(sd.name),
                const SizedBox(width: _spacerwidth,),
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
        Wrap(children: cards,)
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select shapes'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Selector<KnittyGriddyModel, List<StitchSet>>(
          selector: (_, model) => model.filteredStitchSets(''),
          builder: (context, stitchSets, _) {
           return DefaultTabController(
            length: stitchSets.length,
            child: Column(
              children: [
                createStandardPartsCategory(),
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
                              createCategory(category, stitchSet.definitions.where((d) => d.category == category).toList())
                          ],
                        )
                    ]
                  )
                )
              ],
             ),
           );
          }
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(<List<KnittingSymbolPart>>[]), 
          label: const Text('Cancel'),
          icon: const Icon(Icons.cancel_outlined),
        ),
        ElevatedButton.icon(
          onPressed: (_selectedParts.isEmpty && _selectedStitches.isEmpty) ? null : () => Navigator.of(context).pop(_mergedSymbols), 
          label: const Text('OK'),
          icon: const Icon(Icons.check),
        )
      ],
    );
  }
}
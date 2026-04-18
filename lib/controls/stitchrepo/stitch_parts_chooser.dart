import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitch_icon.dart';
import 'package:knitty_griddy/controls/stitch_part_icon.dart';
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
        const Text('Basic symbols'),
        Wrap(children: cards,),
      ],
    );
  }

  Widget createCategory(MapEntry<String, List<StitchDefinition>> entry) {
    List<Widget> cards = [];
    for (StitchDefinition sd in entry.value) {
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
        Text(entry.key), 
        Wrap(children: cards,)
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select paths'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Selector<KnittyGriddyModel, Map<String, List<StitchDefinition>>>(
          selector: (_, model) => model.selectStitchDefinitionsPerCategory(''),
          builder: (context, stitchDefinitions, _) {
           return ListView(
              children: [
                createStandardPartsCategory(),
                for (MapEntry<String, List<StitchDefinition>> entry in stitchDefinitions.entries)
                  createCategory(entry),
              ],
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
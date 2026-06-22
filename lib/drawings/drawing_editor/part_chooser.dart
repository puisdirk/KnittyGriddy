
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_part_icon.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/drawings/model/part_set_info.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PartChooser extends StatefulWidget {
  final PartInfo? selectedPartInfo;

  const PartChooser({
    required this.selectedPartInfo,
    super.key
  });

  @override
  State<PartChooser> createState() => _PartChooserState();
}

class _PartChooserState extends State<PartChooser> {
  late PartInfo? selectedPartInfo;
  
  String filterText = '';
  late TextEditingController filterController;
  
  void _filterChanged() {
    setState(() => filterText = filterController.text);
  }

  @override
  void initState() {
    filterController = TextEditingController(text: filterText);
    filterController.addListener(_filterChanged);

    selectedPartInfo = widget.selectedPartInfo;

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

  Widget createCategory(String category, List<PartInfo> partsInCategory) {
    List<Widget> cards = [];
    for (PartInfo info in partsInCategory) {
      double cardWidth = 
        _spacerwidth + 
        _iconWidth + 
        _spacerwidth + 
        MathUtitilies.textSize(info.partLabel, Theme.of(context).textTheme.bodyMedium!).width + 
        _spacerwidth + _spacerwidth;

      cards.add(SizedBox(
        width: cardWidth, 
        height: 50,
        child: Card(
          color: info == selectedPartInfo ? Colors.blue.withAlpha(60) : null,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            splashColor: Colors.blue.withAlpha(30),
            onTap: () => setState(() => selectedPartInfo = info),
            child: Row(
              children: [
                const SizedBox(width: _spacerwidth,),
                DrawingPartIcon(partInfo: info, size: _iconWidth, iconColor: selectedPartInfo == info ? Colors.white : null,),
                const SizedBox(width: _spacerwidth,),
                Text(info.partLabel,
                  style: info == selectedPartInfo ?
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
      title: const Text('Select Part'),
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
              child: Selector<DrawingsModel, List<PartSetInfo>>(
                selector: (_, model) => model.filteredPartSetInfos(filterText),
                builder: (context, partSetsInfos, _) {
                  return DefaultTabController(
                    length: partSetsInfos.length,
                    child: Column(
                      children: [
                        TabBar(tabs: [
                          for (PartSetInfo partSetInfo in partSetsInfos)
                            Tab(text: partSetInfo.setName,)
                        ]),
                        Expanded(
                          child: TabBarView(
                            children: [
                              for (PartSetInfo partSetInfo in partSetsInfos)
                                ListView(
                                  children: [
                                    for (String category in Set.from(partSetInfo.partInfos.map((d) => d.category)))
                                      createCategory(category, partSetInfo.partInfos.where((d) => d.category == category).map((d) => d).toList()),
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
          onPressed: () => Navigator.of(context).pop(null), 
          label: const Text('Cancel'),
          icon: const Icon(Icons.cancel_outlined),
        ),
        ElevatedButton.icon(
          onPressed: selectedPartInfo == null ? null : () => Navigator.of(context).pop(selectedPartInfo), 
          label: const Text('Choose'),
          icon: const Icon(Symbols.close_small, weight: 700,),
        )
      ],
    );
  }
}
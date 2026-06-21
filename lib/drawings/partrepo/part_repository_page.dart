import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set_name_control.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set_panel.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/partrepo/basic_parts_set.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PartRepositoryPage extends StatefulWidget {
  const PartRepositoryPage({super.key});

  @override
  State<PartRepositoryPage> createState() => _PartRepositoryPageState();
}

class _PartRepositoryPageState extends State<PartRepositoryPage> with TickerProviderStateMixin {
  String _filterText = '';
  late TextEditingController _filterController;
  late TabController _tabController;
  int tabIdx = 0;

  void _filterChanged() {
    setState(() => _filterText = _filterController.text);
  }

  @override
  void initState() {
    _filterController = TextEditingController(text: _filterText);
    _filterController.addListener(_filterChanged);

    _tabController = TabController(length: PartRepository.instance.sets.length, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterChanged);
    _filterController.dispose();

    _tabController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DrawingsModel, List<PartSet>>(
      selector: (_, model) => model.filteredPartSets(_filterText),
      builder: (context, filteredPartSets, _) {
        _tabController = TabController(length: filteredPartSets.length, vsync: this);
        if (tabIdx >= 0 && tabIdx < filteredPartSets.length) {
          _tabController.index = tabIdx;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.apparel),
                hspacing,
                Text('Part Repository'),
              ],
            ),
            backgroundColor: Colors.grey.shade300,
            bottom: PreferredSize(
              preferredSize: const Size(2000, 100), 
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10,),
                      const Text('Filter:'),
                      const SizedBox(width: 10,),
                      SizedBox(
                        width: 500,
                        child: TextField(controller: _filterController, autofocus: true,),
                      ),
                      const Spacer(),
                      if (!PartRepository.hasPartSet(BasicPartsSet.basicPartsSetId))
                      OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<DrawingsModel>(context, listen: false).restoreBasicPartSet();
                          int newTabIdx = PartRepository.indexOfSet(BasicPartsSet.basicPartsSetId);
                          setState(() => tabIdx = newTabIdx);
                        },
                        label: const Text('Restore Basic Set'),
                        icon: const Icon(Symbols.refresh, weight: 700,),
                      ),
                      const SizedBox(width: 10,),
                      OutlinedButton.icon(
                        onPressed: () async {
                          String? id = await Provider.of<DrawingsModel>(context, listen: false).importPartSet();
                          if (id != null) {
                            int newTabIdx = PartRepository.indexOfSet(id);
                            if (newTabIdx != -1) {
                              setState(() => tabIdx = newTabIdx);
                            }
                          }
                        }, 
                        label: const Text('Import Set'),
                        icon: const Icon(Symbols.download, weight: 700,),
                      ),
                      const SizedBox(width: 10,),
                      OutlinedButton.icon(
                        onPressed: () {
                          String id = Provider.of<DrawingsModel>(context, listen: false).createPartSet('Untitled', []);
                          int newTabIdx = PartRepository.indexOfSet(id);
                          if (newTabIdx != -1) {
                            setState(() => tabIdx = newTabIdx);
                          }
                        },
                        label: const Text('New Set'),
                        icon: const Icon(Symbols.create_new_folder, weight: 700,),
                      ),
                      const SizedBox(width: 10,)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      for (PartSet partSet in filteredPartSets)
                        Tab(
                          child: PartSetNameControl(partSet: partSet),
                          ),
                    ]
                  ),
                ],
              )
            )
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child:TabBarView(
                controller: _tabController,
                children: [
                  for (PartSet partSet in filteredPartSets)
                    PartSetPanel(partSet: partSet),
                ]
              ),
            )
          )
        );
      }
    );
  }
}
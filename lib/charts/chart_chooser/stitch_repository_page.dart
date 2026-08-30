import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/chart_chooser/stitch_set_name_control.dart';
import 'package:knitty_griddy/charts/chart_chooser/stitch_set_panel.dart';
import 'package:knitty_griddy/charts/model/chart_operation_exception.dart';
import 'package:knitty_griddy/charts/stitch_icon.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class StitchRepositoryPage extends StatefulWidget {
  const StitchRepositoryPage({super.key});

  @override
  State<StitchRepositoryPage> createState() => _StitchRepositoryPageState();
}

class _StitchRepositoryPageState extends State<StitchRepositoryPage> with TickerProviderStateMixin {
  String _filterText = '';
  late TextEditingController _filterController;
  late TabController _tabController;
  int tabIdx = 0;

  void _filterChanged() {
    setState(() => _filterText = _filterController.text);
  }

  void _tabChanged() {
//    setState(() => currentSetName = StitchRepository.getSetName(_tabController.index));
  }

  @override
  void initState() {
    _filterController = TextEditingController(text: _filterText);
    _filterController.addListener(_filterChanged);

    _tabController = TabController(length: StitchRepository.instance.sets.length, vsync: this);
    _tabController.addListener(_tabChanged);

    super.initState();
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterChanged);
    _filterController.dispose();

    _tabController.removeListener(_tabChanged);
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ChartsModel, List<StitchSet>>(
      selector: (_, model) => model.filteredStitchSets(_filterText),
      builder: (context, filteredStitchSets, _) {
        _tabController = TabController(length: filteredStitchSets.length, vsync: this);
        if (tabIdx >= 0 && tabIdx < filteredStitchSets.length) {
          _tabController.index = tabIdx;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StitchIcon(stitchDefinition: BasicStitchesSet.sssp, iconSize: 32,),
                hspacing,
                Text('Stitch Repository'),
              ],
            ),
            backgroundColor: Colors.grey.shade300,
            bottom: PreferredSize(
              preferredSize: const Size(2000, 100), 
              child: Column(
                children: [
                  Row(
                    children: [
                      hspacing,
                      const Text('Filter:'),
                      hspacing,
                      SizedBox(
                        width: 500,
                        child: TextField(controller: _filterController, autofocus: true,),
                      ),
                      const Spacer(),
                      if (!StitchRepository.hasStitchSet(BasicStitchesSet.basicStitchSetId))
                      OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<ChartsModel>(context, listen: false).restoreBasicStitchSet();
                          int newTabIdx = StitchRepository.indexOfSet(BasicStitchesSet.basicStitchSetId);
                          setState(() => tabIdx = newTabIdx);
                        },
                        label: const Text('Restore Basic Set'),
                        icon: const Icon(Symbols.refresh, weight: 700,),
                      ),
                      hspacing,
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            String? id = await Provider.of<ChartsModel>(context, listen: false).importStitchesSet();
                            if (id != null) {
                              int newTabIdx = StitchRepository.indexOfSet(id);
                              if (newTabIdx != -1) {
                                setState(() => tabIdx = newTabIdx);
                              }
                            }
                          } on ChartOperationException catch(e) {
                            if (context.mounted) {
                              showDialog(context: context, builder: (context) => 
                                AlertDialog(
                                  content: SizedBox(width: 400, height: 50, child: Text(e.message)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context), 
                                      child: const Text('Close'),
                                    ),
                                  ],
                                )  
                              );
                            }
                          }
                        }, 
                        label: const Text('Import Set'),
                        icon: const Icon(Symbols.download, weight: 700,),
                      ),
                      hspacing,
                      OutlinedButton.icon(
                        onPressed: () {
                          String id = Provider.of<ChartsModel>(context, listen: false).createStitchSet('Untitled', []);
                          int newTabIdx = StitchRepository.indexOfSet(id);
                          if (newTabIdx != -1) {
                            setState(() => tabIdx = newTabIdx);
                          }
                        },
                        label: const Text('New Set'),
                        icon: const Icon(Symbols.create_new_folder, weight: 700,),
                      ),
                      hspacing
                    ],
                  ),
                  const SizedBox(height: 10,),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      for (StitchSet stitchSet in filteredStitchSets)
                        Tab(
                          child: StitchSetNameControl(stitchSet: stitchSet),
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
                  for (StitchSet stitchSet in filteredStitchSets)
                    StitchSetPanel(stitchSet: stitchSet),
                ]
              ),
            )
          )
        );
      }
    );
  }
}
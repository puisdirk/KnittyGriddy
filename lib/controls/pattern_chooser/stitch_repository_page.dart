import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/pattern_chooser/stitch_set_name_control.dart';
import 'package:knitty_griddy/controls/pattern_chooser/stitches_set_panel.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
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
    return Selector<KnittyGriddyModel, List<StitchesSet>>(
      selector: (_, model) => model.filteredStitchSets(_filterText),
      builder: (context, filteredStitchSets, _) {
        _tabController = TabController(length: filteredStitchSets.length, vsync: this);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Stitch Repository'),
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
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Provider.of<KnittyGriddyModel>(context, listen: false).importStitchesSet();
                        }, 
                        label: const Text('Import set'),
                        icon: const Icon(Symbols.download, weight: 700,),
                      ),
                      const SizedBox(width: 10,),
                      OutlinedButton.icon(
                        onPressed: () => Provider.of<KnittyGriddyModel>(context, listen: false).createStitchSet('Untitled', []),
                        label: const Text('New set'),
                        icon: const Icon(Symbols.create_new_folder, weight: 700,),
                      ),
                      const SizedBox(width: 10,)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      for (StitchesSet stitchSet in filteredStitchSets)
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
                  for (StitchesSet stitchSet in filteredStitchSets)
                    StitchesSetPanel(stitchSet: stitchSet),
                ]
              ),
            )
          )
        );
      }
    );
  }
}
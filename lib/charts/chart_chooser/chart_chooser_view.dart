
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/maingrid/chart_page.dart';
import 'package:knitty_griddy/charts/chart_chooser/chart_card.dart';
import 'package:knitty_griddy/charts/chart_chooser/stitch_repository_page.dart';
import 'package:knitty_griddy/charts/model/chart_operation_exception.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/stitch_icon.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ChartChooserView extends StatefulWidget {
  const ChartChooserView({super.key});

  @override
  State<ChartChooserView> createState() => _ChartChooserViewState();
}

class _ChartChooserViewState extends State<ChartChooserView> {

  List<Widget> _createChartCards(List<ChartInfo> chartInfos) {
    List<Widget> cards = [];
    for (ChartInfo chartInfo in chartInfos) {
      cards.add(SizedBox(
        width: 300,
        height: 130,
        child: ChartCard(chartInfo: chartInfo,),
      ));
    }
    
    // add a + card
    cards.add(SizedBox(
      width: 130,
      height: 130,
      child: Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Provider.of<ChartsModel>(context, listen: false).createNewChart('Unnamed');
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChartPage(),));
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_on),
              Icon(Icons.add, size: 48,)
            ],
          ),
        )
      )
    ));

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10,),
        Row(
          children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  await Provider.of<ChartsModel>(context, listen: false).importChart();
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
              label: const Text('Import Chart'),
              icon: const Icon(Symbols.download, weight: 700,),
            ),
            hspacing,
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => const StitchRepositoryPage(),)),
              label: const Text('Stitches'),
              icon: const StitchIcon(stitchDefinition: BasicStitchesSet.sssp, iconSize: 32, iconColor: Color.fromARGB(255, 41, 99, 138),) // const Icon(Symbols.auto_stories, weight: 700,),
            ),
            hspacing
          ],
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Selector<ChartsModel, List<ChartInfo>>(
                selector: (_, model) => model.chartInfos,
                builder: (context, chartInfos, _) {
                  List<Widget> chartCards = _createChartCards(chartInfos);
                  return SingleChildScrollView(
                    child: Wrap(
                      children: chartCards,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
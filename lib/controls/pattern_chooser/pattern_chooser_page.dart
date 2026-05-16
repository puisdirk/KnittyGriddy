
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/maingrid/pattern_page.dart';
import 'package:knitty_griddy/controls/pattern_chooser/pattern_card.dart';
import 'package:knitty_griddy/controls/pattern_chooser/stitch_repository_page.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PatternChooserPage extends StatefulWidget {
  const PatternChooserPage({super.key});

  @override
  State<PatternChooserPage> createState() => _PatternChooserPageState();
}

class _PatternChooserPageState extends State<PatternChooserPage> {

  List<Widget> _createPatternCards(List<PatternInfo> patternInfos) {
    List<Widget> cards = [];
    for (PatternInfo patternInfo in patternInfos) {
      cards.add(SizedBox(
        width: 300,
        height: 100,
        child: PatternCard(patternInfo: patternInfo,),
      ));
    }
    
    // add a + card
    cards.add(SizedBox(
      width: 100,
      height: 100,
      child: Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Provider.of<KnittyGriddyModel>(context, listen: false).createNewPattern('Unnamed');
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PatternPage(),));
          },
          child: const Center(
            child:  Icon(Icons.add, size: 48,)
          ),
        )
      )
    ));

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knitty-Griddy'),
        backgroundColor: Colors.grey.shade300,
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Provider.of<KnittyGriddyModel>(context, listen: false).importPattern();
            }, 
            label: const Text('Import Pattern'),
            icon: const Icon(Symbols.download, weight: 700,),
          ),
          const SizedBox(width: 10,),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(
                builder: (context) => const StitchRepositoryPage(),)),
            label: const Text('Stitches'),
            icon: const Icon(Symbols.auto_stories, weight: 700,),
          ),
          const SizedBox(width: 10,)
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Selector<KnittyGriddyModel, List<PatternInfo>>(
            selector: (_, model) => model.patternInfos,
            builder: (context, patterInfos, _) {
              List<Widget> patternCards = _createPatternCards(patterInfos);
              return SingleChildScrollView(
                child: Wrap(
                  children: patternCards,
                ),
              );
            },
          ),
        ),
      )
    );
  }
}
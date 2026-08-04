import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/model/charts_model.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_page.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';
import 'package:knitty_griddy/patterns/model/pattern_operation_exception.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/patterns/pattern_chooser/pattern_card.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PatternChooserView extends StatefulWidget {
  const PatternChooserView({super.key});

  @override
  State<PatternChooserView> createState() => _PatternChooserViewState();
}

class _PatternChooserViewState extends State<PatternChooserView> {

  List<Widget> _createPatternCards(List<KnittingPatternInfo> patternInfos) {
    List<Widget> cards = [];
    for (KnittingPatternInfo patternInfo in patternInfos) {
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
            Provider.of<PatternsModel>(context, listen: false).createNewPattern('Unnamed');
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => 
                PatternPage(knittingPattern: Provider.of<PatternsModel>(context, listen: false).pattern),
              )
            );
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
    return Column(
      children: [
        vspacing,
        Row(
          children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  KnittingPattern? pattern = await Provider.of<PatternsModel>(context, listen: false).importPattern();
                  
                  if (pattern != null) {
                    for (PatternField field in pattern.fields) {
                      if (field is PatternChartField && field.chart != null) {
                        // Store unknown charts
                        if (context.mounted) {
                          if (!Provider.of<ChartsModel>(context, listen: false).hasChart(field.chart!)) {
                            // Store it (will also load stitchdefinitions)
                            KnittingChart newChart = await Provider.of<ChartsModel>(context, listen: false).saveChartAndAux(field.chart!);

                            pattern = pattern!.copyWith(
                              fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternChartField).copyWith(
                                chart: newChart)).toList()
                            );
                            if (context.mounted) {
                              Provider.of<PatternsModel>(context, listen: false).savePattern(pattern);
                            }
                          }

                        }
                      } else if (field is PatternTextEditorField) {
                        // TODO: load knitting symbols
                      } else if (field is PatternDrawingField && field.drawing != null) {
                        if (context.mounted) {
                          if (!Provider.of<DrawingsModel>(context, listen: false).hasDrawing(field.drawing!)) {
                            // Store it (will also load the parts)
                            Drawing newDrawing = await Provider.of<DrawingsModel>(context, listen: false).saveDrawingAndAux(field.drawing!);

                            pattern = pattern!.copyWith(
                              fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternDrawingField).copyWith(
                                drawing: newDrawing
                              )).toList()
                            );
                            if (context.mounted) {
                              Provider.of<PatternsModel>(context, listen: false).savePattern(pattern);
                            }
                          }
                        }
                      } else {
                        print('Possibly forgot some code here in pattern_chooser_view');
                      }

                      // TODO: for drawings, load parts

                      // TODO: other field types
                      

                    }
                  }

                } on PatternOperationException catch(e) {
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
              label: const Text('Import Pattern'),
              icon: const Icon(Symbols.download, weight: 700,),
            ),
            hspacing,
/*            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => const StitchRepositoryPage(),)),
              label: const Text('Stitches'),
              icon: const StitchIcon(stitchDefinition: BasicStitchesSet.sssp, iconSize: 32, iconColor: Color.fromARGB(255, 41, 99, 138),) // const Icon(Symbols.auto_stories, weight: 700,),
            ),
            hspacing,
  */
          ],
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Selector<PatternsModel, List<KnittingPatternInfo>>(
                selector: (_, model) => model.patternInfos,
                builder: (context, patternInfos, _) {
                  List<Widget> patternCards = _createPatternCards(patternInfos);
                  return SingleChildScrollView(
                    child: Wrap(
                      children: patternCards,
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
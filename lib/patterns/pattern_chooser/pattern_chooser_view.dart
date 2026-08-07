import 'package:flutter/material.dart';
import 'package:id_gen/id_gen.dart';
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
                        KnittingChart chart = field.chart!;
                        // Store unknown charts
                        if (context.mounted) {
                          if (!Provider.of<ChartsModel>(context, listen: false).hasChart(chart)) {
                            // Maybe it has one with the same contents
                            KnittingChart? similar = await Provider.of<ChartsModel>(context, listen: false).getSimilarChart(chart);
                            if (similar != null) {
                              pattern = pattern!.copyWith(
                                fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternChartField).copyWith(
                                  chart: similar)
                                ).toList()
                              );
                              if (context.mounted) {
                                Provider.of<PatternsModel>(context, listen: false).savePattern(pattern);
                              }
                            } else {
                              // We don't have this chart or something similar, so we want to store it (will also load stitchdefinitions)

                              // we may have a chart with the same id
                              if (context.mounted) {
                                if (Provider.of<ChartsModel>(context, listen: false).hasChartWithId(chart.id)) {
                                  String newId = const UuidV4Gen().get();
                                  chart = chart.copyWith(id: newId);
                                  pattern = pattern!.copyWith(
                                    fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternChartField).copyWith(
                                      chart: chart
                                    )).toList()
                                  );
                                }
                              }

                              if (context.mounted) {
                                KnittingChart newChart = await Provider.of<ChartsModel>(context, listen: false).saveChartAndAux(chart);

                                pattern = pattern!.copyWith(
                                  fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternChartField).copyWith(
                                    chart: newChart)
                                  ).toList()
                                );
                                if (context.mounted) {
                                  Provider.of<PatternsModel>(context, listen: false).savePattern(pattern);
                                }
                              }
                            }
                          }

                        }
                      } else if (field is PatternTextEditorField) {
                        // TODO: load knitting symbols
                      } else if (field is PatternDrawingField && field.drawing != null) {
                        Drawing drawing = field.drawing!;

                        if (context.mounted) {
                          if (!Provider.of<DrawingsModel>(context, listen: false).hasDrawing(drawing)) {
                            // Maybe there is one with the same contents
                            Drawing? similar = await Provider.of<DrawingsModel>(context, listen: false).getSimilarDrawing(drawing);
                            if (similar != null) {
                              pattern = pattern!.copyWith(
                                fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternDrawingField).copyWith(
                                  drawing: similar
                                )).toList()
                              );
                              if (context.mounted) {
                                Provider.of<PatternsModel>(context, listen: false).savePattern(pattern);
                              }
                            } else {
                              // we may have a drawing with the same id
                              if (context.mounted) {
                                if (Provider.of<DrawingsModel>(context, listen: false).hasDrawingWithId(drawing.id)) {
                                  String newId = const UuidV4Gen().get();
                                  drawing = drawing.copyWith(id: newId);
                                  pattern = pattern!.copyWith(
                                    fields: pattern.fields.map((f) => f.id != field.id ? f : (f as PatternDrawingField).copyWith(
                                      drawing: drawing
                                    )).toList()
                                  );
                                }
                              }
                              // Store it (will also load the parts)
                              if (context.mounted) {
                                Drawing newDrawing = await Provider.of<DrawingsModel>(context, listen: false).saveDrawingAndAux(drawing);
                              
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
                          }
                        }
                      }
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
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_chooser/drawing_card.dart';
import 'package:knitty_griddy/drawings/drawing_editor/drawing_editor_page.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class DrawingChooserView extends StatefulWidget {
  const DrawingChooserView({super.key});

  @override
  State<DrawingChooserView> createState() => _DrawingChooserViewState();
}

class _DrawingChooserViewState extends State<DrawingChooserView> {

    List<Widget> _createDrawingCards(List<DrawingInfo> drawingInfos) {
    List<Widget> cards = [];
    for (DrawingInfo drawingInfo in drawingInfos) {
      cards.add(SizedBox(
        width: 300,
        height: 100,
        child: DrawingCard(drawingInfo: drawingInfo,),
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
            Provider.of<DrawingsModel>(context, listen: false).createNewDrawing('Unnamed');
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawingEditorPage(),));
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
        const SizedBox(height: 10,),
        Row(
          children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                Provider.of<DrawingsModel>(context, listen: false).importDrawing();
              }, 
              label: const Text('Import Drawing'),
              icon: const Icon(Symbols.download, weight: 700,),
            ),
            const SizedBox(width: 10,),
          ],
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Selector<DrawingsModel, List<DrawingInfo>>(
                selector: (_, model) => model.drawingInfos,
                builder: (context, drawingInfos, _) {
                  List<Widget> drawingCards = _createDrawingCards(drawingInfos);
                  return SingleChildScrollView(
                    child: Wrap(
                      children: drawingCards,
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
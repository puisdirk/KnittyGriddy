import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_chooser/drawing_card.dart';
import 'package:knitty_griddy/drawings/model/drawing_operation_exception.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository_page.dart';
import 'package:knitty_griddy/drawings/drawing_editor/edit_drawing_page.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => 
              Selector<DrawingsModel, Drawing>(
                selector: (_, model) => model.drawing,
                builder: (context, drawing, _) {
                  return EditDrawingPage(drawing: drawing,);
                }
              ),
            ));
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
              onPressed: () async {
                try {
                  await Provider.of<DrawingsModel>(context, listen: false).importDrawing();
                } on DrawingOperationException catch(e) {
                  if (context.mounted) {
                    showDialog(context: context, builder: (context) => 
                      AlertDialog(
                        content: SizedBox(width: 400, height: 100, child: Text(e.message)),
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
              label: const Text('Import Drawing'),
              icon: const Icon(Symbols.download, weight: 700,),
            ),
            hspacing,
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => const PartRepositoryPage(),)), 
              label: const Text('Parts'),
              icon: const Icon(Symbols.apparel),
            ),
            hspacing,
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
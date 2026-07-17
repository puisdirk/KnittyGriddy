
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/edit_drawing_page.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawing_operation_exception.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class DrawingCard extends StatelessWidget {
  final DrawingInfo drawingInfo;

  const DrawingCard({
    required this.drawingInfo,
    super.key
  });

  _confirmToDelete(BuildContext context) {
    AlertDialog dlg = AlertDialog(
      title: const Text('Are you sure'),
      content: Text('Are you sure you want to delete drawing ${drawingInfo.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Provider.of<DrawingsModel>(context, listen: false).deleteDrawing(drawingInfo.id);
          }, 
          child: const Text('Yes')
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => dlg);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () async {
          try {
            await Provider.of<DrawingsModel>(context, listen: false).loadDrawing(drawingInfo.id);

            if (context.mounted) {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => Selector<DrawingsModel, Drawing>(
                    selector: (_, model) => model.drawing,
                    builder: (context, drawing, _) {
                      return EditDrawingPage(drawing: drawing,);
                    }
                  ),
                )
              );
            }
          } on DrawingOperationException catch(e) {
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
        child: SizedBox(
          width: 300,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                mouseCursor: SystemMouseCursors.click,
                trailing: IconButton(
                  onPressed: () => _confirmToDelete(context), 
                  icon: const Icon(Icons.delete)
                ),
                title: Text(drawingInfo.name, overflow: TextOverflow.ellipsis,),
                subtitle: Text(
                  drawingInfo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
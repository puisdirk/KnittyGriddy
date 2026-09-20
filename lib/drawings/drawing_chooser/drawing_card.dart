
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/drawings/drawing_editor/edit_drawing_page.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawing_operation_exception.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class DrawingCard extends StatelessWidget {
  final DrawingInfo drawingInfo;

  const DrawingCard({
    required this.drawingInfo,
    super.key
  });

  _confirmToDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) => KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (value) {
          if (value.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          title: const Text('Are you sure'),
          content: Text('Are you sure you want to delete drawing ${drawingInfo.name}?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<DrawingsModel>(context, listen: false).deleteDrawing(drawingInfo.id);
              }, 
              child: const Text('Yes')
            ),
          ],
        ),
      )
    );
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
              showDialog(
                context: context,
                barrierDismissible: false, 
                builder: (context) => KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (value) {
                    if (value.logicalKey == LogicalKeyboardKey.escape || value.logicalKey == LogicalKeyboardKey.enter) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: AlertDialog(
                    content: SizedBox(width: 400, height: 50, child: Text(e.message)),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context), 
                        child: const Text('Close'),
                      ),
                    ],
                  ),
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
              Expanded(
                child: ListTile(
                  mouseCursor: SystemMouseCursors.click,
                  leading: const Icon(Icons.design_services),
                  title: Text(drawingInfo.name, overflow: TextOverflow.ellipsis,),
                  subtitle: Text(
                    drawingInfo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    hspacing,
                    Tooltip(
                      message: 'Duplicate',
                      child: IconButton(
                        iconSize: 16,
                        onPressed: () => Provider.of<DrawingsModel>(context, listen: false).duplicateDrawing(drawingInfo), 
                        icon: const Icon(Icons.content_copy)
                      ),
                    ),
                    const Spacer(),
                    Tooltip(
                      message: 'Delete',
                      child: IconButton(
                        iconSize: 16,
                        onPressed: () => _confirmToDelete(context), 
                        icon: const Icon(Icons.delete)
                      ),
                    ),
                    hspacing,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/drawing_operation_exception.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/svg_service.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class ExportDrawingPage extends StatefulWidget {
  final AbstractDrawing drawing;

  const ExportDrawingPage({
    required this.drawing,
    super.key
  });

  @override
  State<ExportDrawingPage> createState() => _ExportDrawingPageState();
}

class _ExportDrawingPageState extends State<ExportDrawingPage> {
  final GlobalKey drawingBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const double toolbarHeight = 50;
    Rect bbox = widget.drawing.getBoundingBox().inflate(20);

    return Scaffold(
      appBar: AppBar(
        title: Text('Export ${widget.drawing is PartDrawing ? 'part drawing' : 'drawing'} ${widget.drawing.name}'),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: const Size(20000, toolbarHeight), 
          child: SizedBox(
            height: toolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                const Align(alignment: Alignment.centerRight, child: Text('Export'),),
                hspacing,
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await Provider.of<DrawingsModel>(context, listen: false).exportDrawing(widget.drawing);
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
                  child: Text('Drawing (${widget.drawing is PartDrawing ? '.kgp' : '.kgd'})')
                ),
                hspacing,
                OutlinedButton(
                  onPressed: () async {
                    RenderRepaintBoundary drawingBoundary = drawingBoundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
                    ui.Image image = await drawingBoundary.toImage(pixelRatio: 3);
                    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                    Uint8List pngBytes = byteData!.buffer.asUint8List();

                    await FilePicker.platform.saveFile(
                        dialogTitle: 'Where do you want to store the output?',
                        fileName: '${widget.drawing.name}.png',
                        bytes: pngBytes,
                      );
                  }, 
                  child: const Text('PNG')
                ),
                hspacing,
                OutlinedButton(
                  onPressed: () async {
                    await SvgService.exportDrawingToSVG(widget.drawing, Size(bbox.width, bbox.height));
                  }, 
                  child: const Text('SVG')
                ),
                hspacing,
              ],
            ),
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
      //          child: FittedBox(
        child: RepaintBoundary(
          key: drawingBoundaryKey,
          child: SizedBox(
            width: bbox.width,
            height: bbox.height,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey)
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {              
                  return CustomPaint(
                    painter: PreviewDrawingPainter(drawing: widget.drawing),
                    size: constraints.biggest,
                  );
                }
              ),
            ),
          ),
        )
      //          ),
      ),
    );
  }
}

class PreviewDrawingPainter extends CustomPainter {
  final AbstractDrawing drawing;

  const PreviewDrawingPainter({
    required this.drawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white..style = PaintingStyle.fill);
    for (DrawingCommand command in drawing.commands) {
      // For PartDrawings, we only draw the parts
      if (drawing is PartDrawing && command is! PartCommand) continue;
      command.paint(canvas, size, drawing, false, forPreview: true);
    }
  }

  @override
  bool shouldRepaint(covariant PreviewDrawingPainter oldDelegate) {
    return oldDelegate.drawing != drawing;
  }

}
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/patterns/export/pdf_service.dart';
import 'package:knitty_griddy/patterns/mainview/preview_pattern_field_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:provider/provider.dart';

class PatternViewer extends StatefulWidget {
  final KnittingPattern pattern;

  const PatternViewer({
    required this.pattern,
    super.key
  });

  @override
  State<PatternViewer> createState() => _PatternViewerState();
}

class _PatternViewerState extends State<PatternViewer> {

  Map<String, GlobalKey> fieldKeys = {};

  Future<Map<String, Uint8List>> loadPanelImages() async {
    Map<String, Uint8List> panelImages = {};
    for (PatternPanelField panelField in widget.pattern.fields.whereType<PatternPanelField>()) {
      RenderRepaintBoundary drawingBoundary = fieldKeys[panelField.id]!.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await drawingBoundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      panelImages[panelField.id] = pngBytes;
    }
    return panelImages;
  }

  Future<Map<String, Uint8List>> loadTextFieldImages() async {
    
    Map<String, Uint8List> textFieldImages = {};

    for (PatternTextEditorField textEditorField in widget.pattern.fields.whereType<PatternTextEditorField>()) {
      RenderRepaintBoundary drawingBoundary = fieldKeys[textEditorField.id]!.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await drawingBoundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      textFieldImages[textEditorField.id] = pngBytes;
    }
    return textFieldImages;
  }

  Future<Map<String, Uint8List>> loadImageFieldImages() async {

    Map<String, Uint8List> imageFieldImages = {};

    for (PatternImageField imageField in widget.pattern.fields.whereType<PatternImageField>()) {
      if (imageField.imageData == null || imageField.imageData!.isEmpty) {
        continue;
      }
      RenderRepaintBoundary drawingBoundary = fieldKeys[imageField.id]!.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await drawingBoundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      imageFieldImages[imageField.id] = pngBytes;
    }
    return imageFieldImages;
  }

  Future<void> saveAsPdf() async {
    Map<String, Uint8List> panelImages = await loadPanelImages();
    Map<String, Uint8List> textFieldImages = await loadTextFieldImages();
    Map<String, Uint8List> imageFieldImages = await loadImageFieldImages();
    PdfService pdfService = PdfService(
      pattern: widget.pattern, 
      panelImages: panelImages, 
      textFieldImages: textFieldImages,
      imageFieldImages: imageFieldImages
    );
    await pdfService.saveAsPdf();
  }

  @override
  void initState() {
    for (PatternPanelField panelField in widget.pattern.fields.whereType<PatternPanelField>()) {
      fieldKeys[panelField.id] = GlobalKey();
    }

    for (PatternTextEditorField textField in widget.pattern.fields.whereType<PatternTextEditorField>()) {
      fieldKeys[textField.id] = GlobalKey();
    }

    for (PatternImageField imageField in widget.pattern.fields.whereType<PatternImageField>()) {
      fieldKeys[imageField.id] = GlobalKey();
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatternViewer oldWidget) {
    fieldKeys.clear();

    for (PatternPanelField panelField in widget.pattern.fields.whereType<PatternPanelField>()) {
      fieldKeys[panelField.id] = GlobalKey();
    }

    for (PatternTextEditorField textField in widget.pattern.fields.whereType<PatternTextEditorField>()) {
      fieldKeys[textField.id] = GlobalKey();
    }

    for (PatternImageField imageField in widget.pattern.fields.whereType<PatternImageField>()) {
      fieldKeys[imageField.id] = GlobalKey();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Export toolbar
        SizedBox(
          height: 50,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Export as:'),
                  ),
                ),
                hspacing,
                OutlinedButton(
                  onPressed: () async => await Provider.of<PatternsModel>(context, listen: false).exportPattern(widget.pattern), 
                  child: const Text('Pattern file (.kgp)')
                ),
                hspacing,
                OutlinedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      await saveAsPdf();
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (error) {
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  }, 
                  child: const Text('PDF')
                ),
                hspacing,
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.grey,
              child: Center(
                child: SizedBox(
                  width: widget.pattern.pageLayout.pagewidth,
                  height: widget.pattern.pageLayout.pageheight * widget.pattern.pageLayout.numberOfPages,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(
                            widget.pattern.pageLayout.pagewidth,
                            widget.pattern.pageLayout.pageheight * widget.pattern.pageLayout.numberOfPages,
                          ),
                          painter: PageSeparatorPainter(pageLayout: widget.pattern.pageLayout),
                        ),
                        for (PatternField field in widget.pattern.fields)
                          Positioned(
                            left: field.positionX,
                            top: field.positionY,
                            child: Transform.rotate(
                              angle: MathUtitilies.toRadians(-field.rotation),
                              // Note: the repaint boundary takes the flipping into account, 
                              // but not the rotation. This is done on purpose to prevent having 
                              // to do the flips in PDF. The rotation _is_ done in PDF to prevent
                              // content clipping
                              child: RepaintBoundary(
                                key: fieldKeys[field.id],
                                child: Transform.flip(
                                  flipX: field.flipX,
                                  flipY: field.flipY,
                                  child: SizedBox(
                                    width: field.width,
                                    height: field.height,
                                    child: PreviewPatternFieldControl(
                                      field: field, 
                                    ),
                                  )
                                ),
                              ),
                            )
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        )
      ]
    );
  }
}

class PageSeparatorPainter extends CustomPainter {
  final PatternPageLayout pageLayout;

  const PageSeparatorPainter({
    required this.pageLayout
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pageLayout.numberOfPages > 1) {
      Paint pageBottomPaint = Paint()..color = Colors.grey.shade400..style = PaintingStyle.stroke;
      for (int page = 1; page <= pageLayout.numberOfPages; page++) {
        Path pageBottom = Path()
          ..moveTo(0, page * pageLayout.pageheight)
          ..lineTo(pageLayout.pagewidth, page * pageLayout.pageheight);
        DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, pageBottom, pageBottomPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}
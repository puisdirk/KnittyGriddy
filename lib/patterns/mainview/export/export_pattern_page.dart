import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/patterns/mainview/export/pdf_service.dart';
//import 'package:knitty_griddy/patterns/mainview/export/pdf_service.dart';
import 'package:knitty_griddy/patterns/mainview/export/preview_pattern_field_control.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_panel_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';
import 'package:provider/provider.dart';

// Version of the pattern export page where I
// - use one control for all pages
// - use images for text and panel fields
// - use svg for drawing and chart fields
// -> Tried to replace by export page that uses separate control 
// per page and uses page image for export, but that was extremely slow

class ExportPatternPage extends StatefulWidget {
  final KnittingPattern pattern;

  const ExportPatternPage({
    required this.pattern,
    super.key
  });

  @override
  State<ExportPatternPage> createState() => _ExportPatternPageState();
}

class _ExportPatternPageState extends State<ExportPatternPage> {

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

  Future<void> saveAsPdf() async {
    Map<String, Uint8List> panelImages = await loadPanelImages();
    Map<String, Uint8List> textFieldImages = await loadTextFieldImages();
    PdfService pdfService = PdfService(pattern: widget.pattern, panelImages: panelImages, textFieldImages: textFieldImages);
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

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ExportPatternPage oldWidget) {
    fieldKeys.clear();

    for (PatternPanelField panelField in widget.pattern.fields.whereType<PatternPanelField>()) {
      fieldKeys[panelField.id] = GlobalKey();
    }

    for (PatternTextEditorField textField in widget.pattern.fields.whereType<PatternTextEditorField>()) {
      fieldKeys[textField.id] = GlobalKey();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export pattern ${widget.pattern.name}'),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: const Size(20000, 50), 
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                const SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Export'),
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
          )
        ),
      ),
      body: SingleChildScrollView(
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
                        child: SizedBox(
                          width: field.width,
                          height: field.height,
                          child: RepaintBoundary(
                            key: fieldKeys[field.id],
                            child: PreviewPatternFieldControl(
                              field: field, 
                            ),
                          )
                        )
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

    // Draw page numbers
    if (pageLayout.showPageNumber) {
      for (int page = 1; page <= pageLayout.numberOfPages; page++) {
        TextStyle style = TextStyle(color: Colors.grey.shade600);
        final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            fontSize: 10,
            fontFamily: style.fontFamily,
            fontStyle: style.fontStyle,
            fontWeight: style.fontWeight,
            textAlign: TextAlign.justify,
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText('$page');

        final ui.Paragraph paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: size.width));

        canvas.drawParagraph(paragraph, 
          Offset(
            pageLayout.pagewidth - PatternPageLayout.margin + 10, 
            (page * pageLayout.pageheight) - PatternPageLayout.margin + 10
          )
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}
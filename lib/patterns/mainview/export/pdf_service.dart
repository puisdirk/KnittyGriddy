import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/charts/export/knitting_chart_svg_service.dart';
import 'package:knitty_griddy/common/file_system.dart';
import 'package:knitty_griddy/drawings/export/drawing_svg_service.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_chart_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_drawing_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_image_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Version of the pdf export service where I
// - use images for text and panel fields
// - use svg for drawing and chart fields
// alternative pdf_service_pagewise was too slow

class PdfService {

  final KnittingPattern pattern;
  final Map<String, Uint8List> panelImages;
  final Map<String, Uint8List> textFieldImages;
  final Map<String, Uint8List> imageFieldImages;

  PdfService({
    required this.pattern,
    required this.panelImages,
    required this.textFieldImages,
    required this.imageFieldImages,
  });

  Future<void> saveAsPdf() async {
    
    String initialFileName = pattern.name;
    if (initialFileName.isEmpty) {
      initialFileName = 'pattern';
    }

    final pw.Document doc = await _toPdf();

    Uint8List bytes = await doc.save();

    await FileSystem.saveFile(
      prompt: 'Please select an output file',
      filename: '$initialFileName.pdf',
      bytes: bytes,
    );
  }

  Future<pw.Document> _toPdf() async {
    final pdf = pw.Document();

    for (int pageNumber = 0; pageNumber < pattern.pageLayout.numberOfPages; pageNumber++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            pattern.pageLayout.getPageDimensionInMM().width * PdfPageFormat.mm, 
            pattern.pageLayout.getPageDimensionInMM().height * PdfPageFormat.mm, 
            marginAll: 0.0 * PdfPageFormat.cm
          ),
          build: (pw.Context context) {
            return pw.Expanded(
              child: pw.Container(
                color: PdfColors.white,
                child: pw.Stack(
                  children: [
                    for (PatternField field in _fieldsOnPage(pattern, pageNumber))
                      pw.Positioned(
                        left: (field.positionX / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                        top: ((field.positionY - (pageNumber * pattern.pageLayout.pageheight)) / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                        child: pw.Builder(
                          builder: (context) {
                            Matrix4 fieldTransformMatrix = Matrix4.rotationZ(MathUtitilies.toRadians(field.rotation));

                            return pw.Transform(
                              transform: fieldTransformMatrix,
                              origin: PdfPoint(
                                ((field.width / 2) / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm, 
                                ((field.height / 2) / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm
                              ),
                              child: pw.SizedBox(
                                width: (field.width / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                                height: (field.height / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                                child: pw.Opacity(
                                  opacity: field.opacity == 0 ? 0 : field.opacity / 255,
                                  child: pw.Stack(
                                    children: [
                                      // The contents
                                      pw.Positioned(
                                        left: (field.contentLeft / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                                        top: (field.contentTop / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                                        child: pw.SizedBox(
                                          width: (field.contentWidth / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                                          height: (field.contentHeight / PatternPageLayout.pixelsPerMM) * PdfPageFormat.mm,
                                          child: pw.Builder(
                                            builder: (context) {
                                              switch(field.fieldType) {
                                                case PatternFieldType.drawing: 
                                                  if ((field as PatternDrawingField).drawing == null) {
                                                    return pw.SizedBox.shrink();
                                                  }
                                                  DrawingSvgService svgService = DrawingSvgService(
                                                    drawing: field.drawing!,
                                                    flipX: field.flipX,
                                                    flipY: field.flipY
                                                  );
                                                  return pw.Center(
                                                    child: pw.SvgImage(svg: svgService.getCompleteDrawing())
                                                  );
                                                case PatternFieldType.knittingchart:
                                                  if ((field as PatternChartField).chart == null) {
                                                    return pw.SizedBox.shrink();
                                                  }
                                                  KnittingChartSvgService svgService = KnittingChartSvgService(
                                                    chart: field.chart!.pruneUnusedStitchesAndColours(), 
                                                    viewSettings: field.viewSettings,
                                                    flipX: field.flipX,
                                                    flipY: field.flipY
                                                  );
                                                  return pw.SvgImage(svg: svgService.getCompleteSvg().svgString);
                                                case PatternFieldType.image:
                                                  PatternImageField imageField = field as PatternImageField;
                                                  if (!imageField.hasImage) {
                                                    return pw.SizedBox.shrink();
                                                  }
//                                                  return pw.Image(pw.MemoryImage(field.imageData!));
                                                  return pw.Image(pw.MemoryImage(imageFieldImages[field.id]!));
                                                case PatternFieldType.panel:
                                                  return pw.Image(pw.MemoryImage(panelImages[field.id]!));
                                                case PatternFieldType.texteditor:
                                                  return pw.Image(pw.MemoryImage(textFieldImages[field.id]!));
                                              }
                                            }
                                          ),
                                        )
                                      )
                                    ]
                                  )
                                ),
                              ),
                            );
                          }
                        )
                      )
                  ]
                )
              )
            );
          }
        )
      );
    }

    return pdf;
  }

  static Iterable<PatternField> _fieldsOnPage(KnittingPattern pattern, int pageNumber) {
    Rect pageRect = Rect.fromLTWH(
      0, 
      pageNumber * pattern.pageLayout.pageheight, 
      pattern.pageLayout.pagewidth, 
      pattern.pageLayout.pageheight
    );

    return pattern.fields.where((f) => f.contentRect.overlaps(pageRect));
  }
}
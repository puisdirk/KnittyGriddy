import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/patterns/mainview/pattern_page.dart';
import 'package:knitty_griddy/patterns/model/pattern_page_layout.dart';
import 'package:knitty_griddy/utils/dashed_painter.dart';

class PageMarginPainter extends CustomPainter {
  final PatternPageLayout pageLayout;
  final PatternPageMode patternPageMode;

  const PageMarginPainter({
    required this.pageLayout,
    required this.patternPageMode,
  });

  @override
  void paint(Canvas canvas, Size size) {

    if (patternPageMode == PatternPageMode.edit) {
      Paint marginPaint = Paint()..color = Colors.blue..style = PaintingStyle.stroke;

      Path leftMargin = Path()
        ..moveTo(PatternPageLayout.margin, 0)
        ..lineTo(PatternPageLayout.margin, pageLayout.pageheight * pageLayout.numberOfPages);
      Path rightMargin = Path()
        ..moveTo(pageLayout.pagewidth - PatternPageLayout.margin, 0)
        ..lineTo(pageLayout.pagewidth - PatternPageLayout.margin, pageLayout.pageheight * pageLayout.numberOfPages);
      
      DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, leftMargin, marginPaint);
      DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, rightMargin, marginPaint);

      for (int page = 0; page < pageLayout.numberOfPages; page++) {
        Path topPath = Path()
          ..moveTo(0, (page * pageLayout.pageheight) + PatternPageLayout.margin)
          ..lineTo(pageLayout.pagewidth, (page * pageLayout.pageheight) + PatternPageLayout.margin);
        Path bottomPath = Path()
          ..moveTo(0, ((page + 1) * pageLayout.pageheight) - PatternPageLayout.margin)
          ..lineTo(pageLayout.pagewidth, ((page + 1) * pageLayout.pageheight) - PatternPageLayout.margin);

        DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, topPath, marginPaint);
        DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.shortStripes.dashPattern).paint(canvas, bottomPath, marginPaint);
      }
    }

    // Draw page bottom if needed
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
        final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
          ParagraphStyle(
            fontSize: 10,
            fontFamily: style.fontFamily,
            fontStyle: style.fontStyle,
            fontWeight: style.fontWeight,
            textAlign: TextAlign.justify,
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText('$page');

        final Paragraph paragraph = paragraphBuilder.build()
        ..layout(ParagraphConstraints(width: size.width));

        canvas.drawParagraph(paragraph, 
          Offset(
            pageLayout.pagewidth - PatternPageLayout.margin + 10, 
            (page * pageLayout.pageheight) - PatternPageLayout.margin + 10
          )
        );
      }
    }

    if (pageLayout.showGrid && patternPageMode == PatternPageMode.edit) {
      Paint gridPaint = Paint()..color = Colors.grey.withAlpha(150)..style = PaintingStyle.stroke;
      double oneCm = 10 * PatternPageLayout.pixelsPerMM;
      for (int page = 0; page < pageLayout.numberOfPages; page++) {
        // Vertical
        for (double xOffset = PatternPageLayout.margin + oneCm; xOffset < pageLayout.pagewidth - PatternPageLayout.margin; xOffset += oneCm) {
          Path gridLine = Path()..moveTo(xOffset, (page * pageLayout.pageheight) + PatternPageLayout.margin)..lineTo(xOffset, (page * pageLayout.pageheight) + pageLayout.pageheight - PatternPageLayout.margin);
          DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, gridLine, gridPaint);
        }
        // Horizontal
        for (double yOffset = (page * pageLayout.pageheight) + PatternPageLayout.margin + oneCm; yOffset < (page * pageLayout.pageheight) + pageLayout.pageheight - PatternPageLayout.margin; yOffset += oneCm) {
          Path gridLine = Path()..moveTo(PatternPageLayout.margin, yOffset)..lineTo(pageLayout.pagewidth - PatternPageLayout.margin, yOffset);
          DashedPainter.pattern(enableCaching: false, dashPattern: DashStyle.dots.dashPattern).paint(canvas, gridLine, gridPaint);
        }        
      }
    }
  }

  @override
  bool shouldRepaint(covariant PageMarginPainter oldDelegate) {
    return pageLayout != oldDelegate.pageLayout || patternPageMode != oldDelegate.patternPageMode;
  }

}

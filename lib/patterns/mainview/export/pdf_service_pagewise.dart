import 'dart:typed_data';

import 'package:knitty_griddy/common/file_system.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Remark: no longer used. This does the export with an image per
// page ... turned out extremely slow

class PdfServicePagewise {

  final KnittingPattern pattern;
  final List<Uint8List> pageImages;

  PdfServicePagewise({
    required this.pattern,
    required this.pageImages,
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

    for (Uint8List image in pageImages) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            pattern.pageLayout.getPageDimensionInMM().width * PdfPageFormat.mm, 
            pattern.pageLayout.getPageDimensionInMM().height * PdfPageFormat.mm, 
            marginAll: 0.0 * PdfPageFormat.cm
          ),
          build: (pw.Context context) {
            return pw.Expanded(
              child: pw.SizedBox(
                width: pattern.pageLayout.getPageDimensionInMM().width * PdfPageFormat.mm,
                height: pattern.pageLayout.getPageDimensionInMM().height * PdfPageFormat.mm,
                  child: pw.Image(
                    pw.MemoryImage(image)
                  )
                )
              );
          }
        )
      );
    }

    return pdf;
  }
}
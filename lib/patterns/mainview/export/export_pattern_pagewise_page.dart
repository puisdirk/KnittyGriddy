import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/patterns/mainview/export/pattern_page_preview.dart';
import 'package:knitty_griddy/patterns/mainview/export/pdf_service_pagewise.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/patterns_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

// Remark: no longer used. This page uses separate controls per pattern page
// and does the export with an image per page ... turned out extremely slow

class ExportPatternPagewisePage extends StatefulWidget {
  final KnittingPattern pattern;

  const ExportPatternPagewisePage({
    required this.pattern,
    super.key
  });

  @override
  State<ExportPatternPagewisePage> createState() => _ExportPatternPagewisePageState();
}

class _ExportPatternPagewisePageState extends State<ExportPatternPagewisePage> {

  List<GlobalKey> pageKeys = [];

  Future<void> saveAsPdf() async {
    List<Uint8List> pageImages = [];
    for (GlobalKey pageKey in pageKeys) {
      RenderRepaintBoundary pageBoundary = pageKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await pageBoundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      pageImages.add(pngBytes);
    }
    PdfServicePagewise pdfService = PdfServicePagewise(pattern: widget.pattern, pageImages: pageImages);
    await pdfService.saveAsPdf();
  }

  @override
  void initState() {
    pageKeys.clear();
    for (int pageNumber = 0; pageNumber < widget.pattern.pageLayout.numberOfPages; pageNumber++) {
      pageKeys.add(GlobalKey());
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ExportPatternPagewisePage oldWidget) {
    pageKeys.clear();
    for (int pageNumber = 0; pageNumber < widget.pattern.pageLayout.numberOfPages; pageNumber++) {
      pageKeys.add(GlobalKey());
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
                      builder: (context) {
                        return AlertDialog(
                          content: SizedBox(
                            width: 300,
                            height: 150,
                            child: Column(
                              children: [
                                Text('Export Pattern "${widget.pattern.name}" to PDF'),
                                vspacing,
                                Text('This action will take approx. ${widget.pattern.pageLayout.numberOfPages} minute${widget.pattern.pageLayout.numberOfPages > 1 ? 's' : ''}', style: smallStyle,),
                                const Spacer(),
                                const CircularProgressIndicator(),
                                const Spacer(),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context), 
                                      child: const Text('Close')
                                    ),
                                    const Spacer(),
                                    OutlinedButton(
                                      onPressed: () {
                                        saveAsPdf().then((value) {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }                                          
                                        },);
                                      }, 
                                      child: const Text('Export')
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
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
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: widget.pattern.pageLayout.pagewidth,
            height: widget.pattern.pageLayout.pageheight * widget.pattern.pageLayout.numberOfPages,
            color: Colors.white,
            child: SingleChildScrollView(
              child: SizedBox(
                width: widget.pattern.pageLayout.pagewidth,
                height: widget.pattern.pageLayout.pageheight * widget.pattern.pageLayout.numberOfPages,
                child: Column(
                  children: [
                    for (int pageNumber = 0; pageNumber < widget.pattern.pageLayout.numberOfPages; pageNumber++)
                      SizedBox(
                        width: widget.pattern.pageLayout.pagewidth,
                        height: widget.pattern.pageLayout.pageheight,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300)
                          ),
                          child: RepaintBoundary(
                            key: pageKeys[pageNumber],
                            child: PatternPagePreview(
                              pattern: widget.pattern, 
                              pageNumber: pageNumber
                            )
                          ),
                        ),
                      )
                  ] 
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

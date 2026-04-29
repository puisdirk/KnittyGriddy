import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knitty_griddy/export/export_settings.dart';
import 'dart:ui' as ui;
import 'package:knitty_griddy/export/export_toolbar.dart';
import 'package:knitty_griddy/export/preview_legend.dart';
import 'package:knitty_griddy/export/preview_stitches_grid.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/utils/svg_service.dart';
import 'package:provider/provider.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final GlobalKey drawingBoundaryKey = GlobalKey();
  final GlobalKey legendBoundaryKey = GlobalKey();
  ExportSettings exportSettings = const ExportSettings();

  @override
  Widget build(BuildContext context) {
    const double toolbarHeight = 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
        backgroundColor: Colors.grey.shade300,
        bottom: PreferredSize(
          preferredSize: const Size(20000, toolbarHeight), 
          child: ExportToolbar(
            height: toolbarHeight, 
            exportSetting: exportSettings,
            settingsChanged: (newSettings) => setState(() => exportSettings = newSettings),
            exportToPNG: () async {
              RenderRepaintBoundary drawingBoundary = drawingBoundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
                ui.Image image = await drawingBoundary.toImage(pixelRatio: 3);
                ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                Uint8List pngBytes = byteData!.buffer.asUint8List();

                /*String? outputPath =*/ await FilePicker.platform.saveFile(
                    dialogTitle: 'Where do you want to store the output?',
                    // TODO: later, we'll have a pattern name here
                    fileName: 'pattern.png',
                    bytes: pngBytes,
                  );
            },
            exportToSVG: () async {
              Size legendSize = Size.zero;
              if (exportSettings.showLegend) {
                RenderRepaintBoundary legendBoundary = legendBoundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
                legendSize = legendBoundary.size;
              }
              RenderRepaintBoundary drawingBoundary = drawingBoundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
              Size drawingSize = drawingBoundary.size;

              await SvgService.exportToSVG(
                Provider.of<KnittyGriddyModel>(context, listen: false).knittingPattern.pruneUnusedStitchesAndColours(), 
                exportSettings, 
                drawingSize, legendSize
              );
            }
          ),
        ),
      ),
      body: RepaintBoundary(
        key: drawingBoundaryKey, 
        child: Padding(                       //ExportPreview(exportSetting: exportSettings,)
          padding: const EdgeInsets.all(20.0),
          child: FittedBox(
            child: exportSettings.showLegend == false ?
              const PreviewStitchesGrid() :
              exportSettings.legendHorizontal ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (exportSettings.legendPosition == LegendPosition.top)
                      RepaintBoundary(key: legendBoundaryKey, child: PreviewLegend(exportSettings: exportSettings,)),
                    const PreviewStitchesGrid(),
                    if (exportSettings.legendPosition == LegendPosition.bottom)
                      RepaintBoundary(key: legendBoundaryKey, child: PreviewLegend(exportSettings: exportSettings,)),
                  ],
                ) :
                Row(
                  children: [
                    if (exportSettings.legendPosition == LegendPosition.left)
                      RepaintBoundary(key: legendBoundaryKey, child: PreviewLegend(exportSettings: exportSettings,)),
                    const PreviewStitchesGrid(),
                    if (exportSettings.legendPosition == LegendPosition.right)
                      RepaintBoundary(key: legendBoundaryKey, child: PreviewLegend(exportSettings: exportSettings,)),
                  ],
                ),
          ),
        )
      ),
    );
  }
}
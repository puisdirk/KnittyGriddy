
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/common/file_system.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';

class DrawingSvgService {
  final AbstractDrawing drawing;
  final bool flipX;
  final bool flipY;

  const DrawingSvgService({
    required this.drawing,
    this.flipX = false,
    this.flipY = false,
  });

  Future<void> exportDrawingToSVG() async {
    
    String completeDrawing = getCompleteDrawing();

    await FileSystem.saveFile(
      prompt: 'Where do you want to store the output?',
      filename: '${drawing.name}.svg',
      bytes: utf8.encode(completeDrawing),
    );
  }

  String getCompleteDrawing() {

    Rect bbox = drawing.getBoundingBox();
    Size drawingSize = bbox.inflate(20).size;
    
    String drawingString = _getDrawingString(drawingSize);

    if (flipX || flipY) {
      double halfWidth = drawingSize.width / 2;
      double halfHeight = drawingSize.height / 2;
      drawingString = '<g class="fieldfliptransform" transform="translate($halfWidth, $halfHeight) scale(${flipX ? -1 : 1}, ${flipY ? -1 : 1}) translate(-$halfWidth, -$halfHeight)">$drawingString</g>';
    }

    String completeDrawing = '<svg width="${drawingSize.width}" height="${drawingSize.height}" viewBox="0 0 ${drawingSize.width} ${drawingSize.height}" xmlns="http://www.w3.org/2000/svg">';
    completeDrawing += drawingString;
    completeDrawing += '</svg>';

    return completeDrawing;
  }

  String _getDrawingString(Size drawingSize) {
    Rect bbox = drawing.getBoundingBox();
    Offset middle = Offset(drawingSize.width / 2, drawingSize.height / 2);
    bbox = bbox.translate(middle.dx, middle.dy);

    double xtrans = -bbox.left + 10;
    double ytrans = -bbox.top + 10;
    String drawingString = '<g class="centeringtransform" transform="translate($xtrans, $ytrans)">';

    String drawingGroup = '<g>';
    for (DrawingCommand command in drawing.commands) {
      // For PartDrawings, we only draw the parts
      if (drawing is PartDrawing && command is! PartCommand) continue;
      if (command is PointCommand) continue;
      drawingGroup += command.toSvg(drawingSize, drawing);
    }
    drawingGroup += '</g>';

    drawingString += drawingGroup;
    drawingString += '</g>';

    return drawingString;
  }
}
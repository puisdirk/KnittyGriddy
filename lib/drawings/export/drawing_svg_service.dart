
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

  const DrawingSvgService({
    required this.drawing,
  });

  Future<void> exportDrawingToSVG() async {
    
    String completeDrawing = getCompleteDrawing();

    await FileSystem.saveFile(
      prompt: 'Where do you want to store the output?',
      filename: '${drawing.name}.svg',
      bytes: utf8.encode(completeDrawing),
    );
  }

  Size getSize() {
    return drawing.getBoundingBox().inflate(20).size;
  }

  String getCompleteDrawing() {

    Size drawingSize = drawing.getBoundingBox().inflate(20).size;
    
    String drawingString = _getDrawingString(drawingSize);
    
    String completeDrawing = '<svg width="${drawingSize.width}" height="${drawingSize.height}" viewBox="0 0 ${drawingSize.width} ${drawingSize.height}" xmlns="http://www.w3.org/2000/svg">';
    completeDrawing += drawingString;
    completeDrawing += '</svg>';

    return completeDrawing;
  }

  String _getDrawingString(Size drawingSize) {
    String drawingString = '<g class="inset" transform="translate(20, 20)">';

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
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:path_drawing/path_drawing.dart';

class DrawingPartIcon extends StatelessWidget {

  final PartInfo partInfo;
  final double size;
  final Color? iconColor;

  const DrawingPartIcon({
    required this.partInfo,
    this.size = 36,
    this.iconColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CustomPaint(
          size: Size(size, size), 
          painter: PartPathPainter(partInfo: partInfo, color: iconColor?? partColor),
        ),
      ),
    );
  }
}

class PartPathPainter extends CustomPainter {
  final PartInfo partInfo;
  final Color color;

  const PartPathPainter({required this.partInfo, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    PartDrawing? partDrawing = PartRepository.getPartDrawingById(partInfo.partDrawingId);
    if (partDrawing != null) {
      PartCommand? partCommand = partDrawing.partById(partInfo.partId);
      if (partCommand != null) {
        Path p = parseSvgPathData(partCommand.previewPath(partDrawing));
        Rect r = p.getBounds();

        Matrix4 tr = Matrix4.identity();
        tr.scale(size.longestSide / r.longestSide);
        tr.translate(-r.left, -r.top);
        // TODO: should center vertically
        p = p.transform(tr.storage);

        canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PartPathPainter oldDelegate) {
    return partInfo != oldDelegate.partInfo || color != oldDelegate.color;
  }

}
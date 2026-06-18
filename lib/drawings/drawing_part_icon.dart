import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:path_drawing/path_drawing.dart';

class DrawingPartIcon extends StatelessWidget {

  final PartInfo partInfo;
  final double size;

  const DrawingPartIcon({
    required this.partInfo,
    this.size = 36,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size), 
        painter: PartPathPainter(partInfo: partInfo),
      ),
    );
  }
}

class PartPathPainter extends CustomPainter {
  final PartInfo partInfo;

  const PartPathPainter({required this.partInfo});

  @override
  void paint(Canvas canvas, Size size) {
    if (partInfo.previewPath.isNotEmpty) {
      Path p = parseSvgPathData(partInfo.previewPath);
      Rect r = p.getBounds();

      Matrix4 tr = Matrix4.identity();
      tr.scale(size.longestSide / r.longestSide);
      tr.translate(-r.left, -r.top);
      p = p.transform(tr.storage);

      canvas.drawPath(p, Paint()..color = partColor..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant PartPathPainter oldDelegate) {
    return partInfo != oldDelegate.partInfo;
  }

}
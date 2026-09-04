import 'dart:math';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/text_field_link.dart';
import 'package:knitty_griddy/utils/constants.dart';

class LinkControl extends StatelessWidget {
  final KnittingPattern pattern;
  final TextFieldLink link;
  final bool dragging;
  final void Function() onDeleteLink;

  const LinkControl({
    required this.pattern,
    required this.link,
    required this.dragging,
    required this.onDeleteLink,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    PatternTextEditorField fromField = pattern.textEditorFields.firstWhere((f) => f.id == link.fromId);
    PatternTextEditorField toField = pattern.textEditorFields.firstWhere((f) => f.id == link.toId);

    Rect outputConnectorRect = Rect.fromLTWH(
      fromField.positionX + fromField.width - kConnectorSize.width - 10,
      fromField.positionY + fromField.height - kConnectorSize.height - 10,
      kConnectorSize.width, kConnectorSize.height);
    Rect inputConnectorRect = Rect.fromLTWH(
      toField.positionX + 10,
      toField.positionY + 10,
      kConnectorSize.width, kConnectorSize.height);

    Rect encompassingRect = inputConnectorRect.expandToInclude(outputConnectorRect);

    return Positioned(
      top: encompassingRect.top,
      left: encompassingRect.left,
      child: Opacity(
        opacity: dragging ? .2 : 1,
        child: SizedBox(
          width: encompassingRect.width,
          height: encompassingRect.height,
          child: Stack(
            children: [
/*              Positioned(
                child: IgnorePointer(
                  child: Container(
                   decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
                  ),
                ),
              ),*/
              CustomPaint(
                size: encompassingRect.size,
                painter: ConnectorPainter(
                  inputConnectorRect: inputConnectorRect,
                  outputConnectorRect: outputConnectorRect,
                ),
              ),
              Positioned(
                top: (encompassingRect.height / 2) - 12,
                left: (encompassingRect.width / 2) - 12,
                child: IconButton(
                  onPressed: onDeleteLink, 
                  icon: const Icon(Icons.delete)
                )
              )
            ]
          ),
        ),
      )
    );
  }
}

class ConnectorPainter extends CustomPainter {
  final Rect inputConnectorRect;
  final Rect outputConnectorRect;

  ConnectorPainter({
    required this.inputConnectorRect,
    required this.outputConnectorRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint connectorPaint = Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 2;

    if (inputConnectorRect.topLeft.dy <= outputConnectorRect.topRight.dy && inputConnectorRect.topLeft.dx >= outputConnectorRect.topRight.dx) {
      // input is above and to the right of the output, so drawing from bottomLeft to topRight
      canvas.drawLine(
        Offset(kConnectorSize.width, size.height - (kConnectorSize.height / 2)), 
        Offset(size.width - kConnectorSize.width, kConnectorSize.height / 2), 
        connectorPaint);
    } else if (inputConnectorRect.topLeft.dy > outputConnectorRect.topRight.dy && inputConnectorRect.topLeft.dx >= outputConnectorRect.topRight.dx) {
      // input is below and to the right of the output, so drawing from topleft to bottomright
      canvas.drawLine(
        Offset(kConnectorSize.width, kConnectorSize.height / 2), 
        Offset(size.width - kConnectorSize.width, size.height - (kConnectorSize.height / 2)), 
        connectorPaint);
    } else if (inputConnectorRect.topLeft.dy <= outputConnectorRect.topRight.dy && inputConnectorRect.topLeft.dx < outputConnectorRect.topRight.dx) {
      // input is above and to the left of the output, so drawing from bottomright to topleft
      canvas.drawLine(
        Offset(size.width, size.height - kConnectorSize.height / 2), 
        Offset(0, kConnectorSize.height / 2), 
        connectorPaint);
    } else {
      // input is below and to the left of the output, so drawing from topright to bottomleft 
      canvas.drawLine(
        Offset(size.width, kConnectorSize.height / 2), 
        Offset(0, size.height - (kConnectorSize.height / 2)), 
        connectorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorPainter oldDelegate) {
    return inputConnectorRect != oldDelegate.inputConnectorRect || outputConnectorRect != oldDelegate.outputConnectorRect;
  }

}
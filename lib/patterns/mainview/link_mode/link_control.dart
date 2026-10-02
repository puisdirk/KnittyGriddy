import 'package:flutter/material.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_text_editor_field.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/text_field_link.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

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
      fromField.positionX, fromField.positionY,
      fromField.width, fromField.height - (kConnectorSize.height / 2));
    outputConnectorRect = outputConnectorRect.inflate(-10);

    Offset fromPoint = outputConnectorRect.bottomRight;

    if (fromField.rotation != 0 || fromField.flipX || fromField.flipY) {
      // Put at 0,0
      outputConnectorRect = outputConnectorRect.translate(
        -(fromField.positionX + (fromField.width / 2)),
        -(fromField.positionY + (fromField.height / 2))
      );
      fromPoint = outputConnectorRect.bottomRight;

      if (fromField.flipX && !fromField.flipY) {
        fromPoint = outputConnectorRect.bottomLeft;
      }
      if (fromField.flipY && !fromField.flipX) {
        fromPoint = outputConnectorRect.topRight;
      }
      if (fromField.flipX && fromField.flipY) {
        fromPoint = outputConnectorRect.topLeft;
      }

      if (fromField.rotation != 0) {
        fromPoint = MathUtitilies.rotatePointAroundZ(fromPoint, MathUtitilies.toRadians(-fromField.rotation));
      }

      // Put back in position
      fromPoint = fromPoint.translate(
        fromField.positionX + (fromField.width / 2),
        fromField.positionY + (fromField.height / 2)
      );

    }

    Rect inputConnectorRect = Rect.fromLTWH(
      toField.positionX, toField.positionY + (kConnectorSize.height / 2),
      toField.width, toField.height - (kConnectorSize.height / 2));
    inputConnectorRect = inputConnectorRect.inflate(-10);

    Offset toPoint = inputConnectorRect.topLeft;

    if (toField.rotation != 0 || toField.flipX || toField.flipY) {
      // Put at 0,0
      inputConnectorRect = inputConnectorRect.translate(
        -(toField.positionX + (toField.width / 2)),
        -(toField.positionY + (toField.height / 2))
      );
      toPoint = inputConnectorRect.topLeft;

      if (toField.flipX && !toField.flipY) {
        toPoint = inputConnectorRect.topRight;
      }
      if (toField.flipY && !toField.flipX) {
        toPoint = inputConnectorRect.bottomLeft;
      }
      if (toField.flipX && toField.flipY) {
        toPoint = inputConnectorRect.bottomRight;
      }

      if (toField.rotation != 0) {
        toPoint = MathUtitilies.rotatePointAroundZ(toPoint, MathUtitilies.toRadians(-toField.rotation));
      }

      // Put back in position
      toPoint = toPoint.translate(
        toField.positionX + (toField.width / 2), 
        toField.positionY + (toField.height / 2)
      );
    }

    Offset deleteButtonOffset = MathUtitilies.middleOfLine(fromPoint, toPoint);

    return Positioned(
      child: Opacity(
        opacity: dragging ? .2 : 1,
        child: Stack(
          children: [
            Positioned(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    size: constraints.biggest,
                    painter: ConnectorPainter(
                      inputPoint: toPoint,
                      outputPoint: fromPoint,
                    ),
                  );
                }
              ),
            ),
            Positioned(
              top: deleteButtonOffset.dy - 18,
              left: deleteButtonOffset.dx - 18,
              child: IconButton(
                onPressed: onDeleteLink, 
                icon: const Icon(Icons.delete)
              )
            )
          ]
        ),
      )
    );
  }
}

class ConnectorPainter extends CustomPainter {
  final Offset inputPoint;
  final Offset outputPoint;

  ConnectorPainter({
    required this.inputPoint,
    required this.outputPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint connectorPaint = Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 1.5;

    canvas.drawLine(outputPoint, inputPoint, connectorPaint);
  }

  @override
  bool shouldRepaint(covariant ConnectorPainter oldDelegate) {
    return inputPoint != oldDelegate.inputPoint || outputPoint != oldDelegate.outputPoint;
  }

}
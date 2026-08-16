import 'package:fitted_scale/fitted_scale.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/charts/stitchrepo/knitting_symbol_control.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class StyledStitchIcon extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final ParchmentStyle style;
  final ParchmentStyle lineStyle;

  const StyledStitchIcon({
    required this.stitchDefinition,
    required this.style,
    required this.lineStyle,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    double iconSize = 18;

    Color bgColor = Colors.transparent;
    if (style.contains(ParchmentAttribute.backgroundColor)) {
      int? val = style.get(ParchmentAttribute.backgroundColor)!.value;
      if (val != null) {
        bgColor = Color(val);
      }
    }

    Color fgColor = Colors.black;
    if (style.contains(ParchmentAttribute.foregroundColor)) {
      int? val = style.get(ParchmentAttribute.foregroundColor)!.value;
      if (val != null) {
        fgColor = Color(val);
      }
    }

    bool isItalics = false;
    if (style.contains(ParchmentAttribute.italic)) {
      isItalics = style.get(ParchmentAttribute.italic)!.value == true;
    }

    ParchmentAttribute? headingAttribute = lineStyle.get(ParchmentAttribute.heading);
    if (headingAttribute != null) {
      FleatherThemeData theme = FleatherTheme.of(context)!;
      TextStyle textStyle = const TextStyle();
      if (headingAttribute == ParchmentAttribute.heading.level1) {
        textStyle = textStyle.merge(theme.heading1.style);
      } else if (headingAttribute == ParchmentAttribute.heading.level2) {
        textStyle = textStyle.merge(theme.heading2.style);
      } else if (headingAttribute == ParchmentAttribute.heading.level3) {
        textStyle = textStyle.merge(theme.heading3.style);
      } else if (headingAttribute == ParchmentAttribute.heading.level4) {
        textStyle = textStyle.merge(theme.heading4.style);
      } else if (headingAttribute == ParchmentAttribute.heading.level5) {
        textStyle = textStyle.merge(theme.heading5.style);
      } else if (headingAttribute == ParchmentAttribute.heading.level6) {
        textStyle = textStyle.merge(theme.heading6.style);
      } else {
        textStyle = textStyle.merge(theme.paragraph.style);
      }

      iconSize = textStyle.fontSize!;
    }

    bool underline = style.contains(ParchmentAttribute.underline);
    bool strikethrough = style.contains(ParchmentAttribute.strikethrough);

    return FittedScale(
      scale: iconSize / stitchCellHeight,
      child: SizedBox(
        width: stitchCellWidth * stitchDefinition.columns,
        height: stitchCellHeight,
        child:
          Stack(
            children: [
              Positioned(
                left: 0, 
                top: 0, 
                child: Container(
                  width: stitchCellWidth * stitchDefinition.columns, 
                  height: stitchCellHeight,
                  color: bgColor,
                )
              ),
              for (int column = 0; column < stitchDefinition.columns; column++) 
                Positioned(
                  left: column * stitchCellWidth, 
                  child: Transform.rotate(
                    angle: isItalics ? MathUtitilies.toRadians(15) : 0,
                    child: KnittingSymbolControl(
                      knittingSymbol: stitchDefinition.symbolAt(column), 
                      symbolColor: fgColor
                    ),
                  )
                ),
              Positioned(
                left: 0,
                top: 0,
                child: CustomPaint(
                  size: Size(stitchCellWidth * stitchDefinition.columns, stitchCellHeight),
                  painter: CharacterStylePainter(
                    underline: underline,
                    strikethrough: strikethrough
                  ),
                ))
            ],
          ),
      ),
    );
  }
}

class CharacterStylePainter extends CustomPainter {
  final bool underline;
  final bool strikethrough;

  const CharacterStylePainter({
    required this.underline,
    required this.strikethrough,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strikethrough) {
      canvas.drawLine(
        Offset(0, size.height / 2), 
        Offset(size.width, size.height / 2), 
        Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    if (underline) {
      canvas.drawLine(
        Offset(0, size.height * .83), 
        Offset(size.width, size.height * .83), 
        Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CharacterStylePainter oldDelegate) {
    return oldDelegate.underline != underline || oldDelegate.strikethrough != strikethrough;
  }

}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/knitting_symbol_part_control.dart';

class KnittingSymbolControl extends StatelessWidget {

  final KnittingSymbol? knittingSymbol;
  final Color? symbolColor;
  final double? symbolSize;
  final void Function()? onTap;

  const KnittingSymbolControl({
    this.knittingSymbol,
    this.symbolColor,
    this.symbolSize,
    this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: symbolSize,
          height: symbolSize, 
          child: ClipRect(
            child: Transform.translate(
              offset: knittingSymbol!.translation,
              child: Transform.scale(
                scaleX: knittingSymbol!.scale.dx,
                scaleY: knittingSymbol!.scale.dy,
                child: Transform.rotate(
                  angle: knittingSymbol!.rotation,
                  child: Stack(
                    children: [
                      for (KnittingSymbolPart part in knittingSymbol!.parts)
                        Positioned(child: KnittingSymbolPartControl(knittingSymbolPart: part, symbolColor: symbolColor?? Colors.black, iconSize: symbolSize,)),
                      // need to detect the tap even if there are no parts
                      if (knittingSymbol!.parts.isEmpty)
                        Positioned(child: Container(color: Colors.transparent,)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
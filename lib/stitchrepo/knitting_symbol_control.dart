
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_path.dart';
import 'package:knitty_griddy/stitchrepo/knitting_symbol_path_control.dart';

class KnittingSymbolControl extends StatelessWidget {

  final KnittingSymbol? knittingSymbol;
  final Color? symbolColor;
  final void Function()? onTap;

  const KnittingSymbolControl({
    this.knittingSymbol,
    this.symbolColor,
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
          width: stitchCellWidth, 
          height: stitchCellHeight, 
          child: knittingSymbol == null ? null :
            ClipRect(
              child: Transform.translate(
                offset: knittingSymbol!.translation,
                child: Transform.scale(
                  scaleX: knittingSymbol!.scale.dx,
                  scaleY: knittingSymbol!.scale.dy,
                  child: Transform.rotate(
                    angle: knittingSymbol!.rotation,
                    child: Stack(
                      children: [
                      for (KnittingSymbolPath path in knittingSymbol!.paths)
                        Positioned(child: KnittingSymbolPathControl(knittingSymbolPath: path, symbolColor: symbolColor?? Colors.black))
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
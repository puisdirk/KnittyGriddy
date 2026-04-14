
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/controls/selectionlayer/selection_control.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:provider/provider.dart';

class SelectionHandleControl extends StatelessWidget {
  final PanType panType;
  final MouseCursor cursor;
  final Function(PanType newPanType) startPan;
  final Function(Offset delta) addPanOffset;
  final Function() endPan;

  const SelectionHandleControl({
    required this.panType,
    required this.cursor,
    required this.startPan,
    required this.addPanOffset,
    required this.endPan,  
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return Selector<KnittyGriddyModel, KnittingPattern>(
      selector: (_, model) => model.knittingPattern,
      builder: (context, pattern, _) {
        Color cellColour = Provider.of<KnittyGriddyModel>(context, listen: false).cellColorAtSelectionHandle(panType);
        Color handleColor = ColorUtilities.contrastingFromColor(cellColour);

        return MouseRegion(
          cursor: cursor,
          child: GestureDetector(
            onPanStart: (details) {
              startPan(panType);
            },
            onPanUpdate: (details) {
              addPanOffset(details.delta);
            },
            onPanEnd: (details) {
              endPan();
            },
            child: SizedBox(
              width: stitchCellWidth / 2, height: stitchCellHeight / 2,
              child: Container(color: handleColor),),
          ),
        );
      }
    );
  }
}
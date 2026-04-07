
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/selectionlayer/selection_handle_control.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:provider/provider.dart';

enum PanType {
  none,
  topleft,
  topright,
  bottomleft,
  bottomright,
  top,
  bottom,
  left,
  right,
  middle
}

class SelectionControl extends StatefulWidget {
  const SelectionControl({super.key});

  @override
  State<SelectionControl> createState() => _SelectionControlState();
}

class _SelectionControlState extends State<SelectionControl> {
  
  // When panType is none, we draw the selection from the model. Otherwise we use panSelectionRect and panSelection
  PanType panType = PanType.none;

  // The offset and size during resizing
  Rect panSelectionRect = Rect.zero;

  Rect knittingPlane = Rect.zero;

  void startPan(PanType newPanType) {
    setState(() {
      panType = newPanType;
      knittingPlane = Rect.fromLTWH(
        stitchCellWidth, stitchCellHeight, 
        Provider.of<KnittyGriddyModel>(context, listen: false).settings.columns * stitchCellWidth, 
        Provider.of<KnittyGriddyModel>(context, listen: false).settings.columns * stitchCellHeight
      );
      panSelectionRect = Provider.of<KnittyGriddyModel>(context, listen: false).selection.asRect;
    });
  }

  void addPanOffset(Offset additional) {

    Rect newSelectionRect = Rect.zero;

    if (panType == PanType.bottomright) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.left, 
        panSelectionRect.top, 
        panSelectionRect.width + additional.dx < stitchCellWidth ? panSelectionRect.left + stitchCellWidth : panSelectionRect.right + additional.dx, 
        panSelectionRect.height + additional.dy < stitchCellHeight ? panSelectionRect.top + stitchCellHeight : panSelectionRect.bottom + additional.dy
      );
      if (newSelectionRect.right > knittingPlane.right) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          newSelectionRect.top, 
          knittingPlane.right, 
          newSelectionRect.bottom
        );
      }
      if (newSelectionRect.bottom > knittingPlane.bottom) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          newSelectionRect.top, 
          newSelectionRect.right, 
          knittingPlane.bottom
        );
      }
    } else if (panType == PanType.bottomleft) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.width - additional.dx < stitchCellWidth ? panSelectionRect.right - stitchCellWidth : panSelectionRect.left + additional.dx, 
        panSelectionRect.top, 
        panSelectionRect.right,
        panSelectionRect.height + additional.dy < stitchCellHeight ? panSelectionRect.top + stitchCellHeight : panSelectionRect.bottom + additional.dy
      );
      if (newSelectionRect.left < knittingPlane.left) {
        newSelectionRect = Rect.fromLTRB(
          knittingPlane.left, 
          newSelectionRect.top, 
          newSelectionRect.right, 
          newSelectionRect.bottom
        );
      }
      if (newSelectionRect.bottom > knittingPlane.bottom) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          newSelectionRect.top, 
          newSelectionRect.right, 
          knittingPlane.bottom
        );
      }
    } else if (panType == PanType.topleft) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.width - additional.dx < stitchCellWidth ? panSelectionRect.right - stitchCellWidth : panSelectionRect.left + additional.dx, 
        panSelectionRect.height - additional.dy < stitchCellHeight ? panSelectionRect.bottom - stitchCellHeight : panSelectionRect.top + additional.dy, 
        panSelectionRect.right, 
        panSelectionRect.bottom);
      if (newSelectionRect.top < knittingPlane.top) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          knittingPlane.top, 
          newSelectionRect.right, 
          newSelectionRect.bottom
        );
      }
      if (newSelectionRect.left < knittingPlane.left) {
        newSelectionRect = Rect.fromLTRB(
          knittingPlane.left, 
          newSelectionRect.top, 
          newSelectionRect.right, 
          newSelectionRect.bottom
        );
      }
    } else if (panType == PanType.topright) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.left, 
        panSelectionRect.height - additional.dy < stitchCellHeight ? panSelectionRect.bottom - stitchCellHeight : panSelectionRect.top + additional.dy, 
        panSelectionRect.width + additional.dx < stitchCellWidth ? panSelectionRect.left + stitchCellWidth : panSelectionRect.right + additional.dx, 
        panSelectionRect.bottom
      );
      if (newSelectionRect.top < knittingPlane.top) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          knittingPlane.top, 
          newSelectionRect.right, 
          newSelectionRect.bottom
        );
      }
      if (newSelectionRect.right > knittingPlane.right) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          newSelectionRect.top, 
          knittingPlane.right, 
          newSelectionRect.bottom
        );
      }
    } else if (panType == PanType.top) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.left, 
        panSelectionRect.height - additional.dy < stitchCellHeight ? panSelectionRect.bottom - stitchCellHeight : panSelectionRect.top + additional.dy, 
        panSelectionRect.right,
        panSelectionRect.bottom
      );
      if (newSelectionRect.top < knittingPlane.top) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          knittingPlane.top, 
          newSelectionRect.right, 
          newSelectionRect.bottom
        );
      }
    } else if (panType == PanType.bottom) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.left, 
        panSelectionRect.top, 
        panSelectionRect.right,
        panSelectionRect.height + additional.dy < stitchCellHeight ? panSelectionRect.top + stitchCellHeight : panSelectionRect.bottom + additional.dy
      );
      if (newSelectionRect.bottom > knittingPlane.bottom) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          newSelectionRect.top, 
          newSelectionRect.right, 
          knittingPlane.bottom
        );
      }
    } else if (panType == PanType.left) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.width - additional.dx < stitchCellWidth ? panSelectionRect.right - stitchCellWidth : panSelectionRect.left + additional.dx, 
        panSelectionRect.top, 
        panSelectionRect.right, 
        panSelectionRect.bottom);
      if (newSelectionRect.left < knittingPlane.left) {
        newSelectionRect = Rect.fromLTRB(
          knittingPlane.left, 
          newSelectionRect.top, 
          newSelectionRect.right, 
          newSelectionRect.bottom
        );
      }
    } else if (panType == PanType.right) {
      newSelectionRect = Rect.fromLTRB(
        panSelectionRect.left, 
        panSelectionRect.top, 
        panSelectionRect.width + additional.dx < stitchCellWidth ? panSelectionRect.left + stitchCellWidth : panSelectionRect.right + additional.dx, 
        panSelectionRect.bottom
      );
      if (newSelectionRect.right > knittingPlane.right) {
        newSelectionRect = Rect.fromLTRB(
          newSelectionRect.left, 
          newSelectionRect.top, 
          knittingPlane.right, 
          newSelectionRect.bottom
        );
      }
    } else if (panType == PanType.middle) {
      
      newSelectionRect = Rect.fromLTWH(
        panSelectionRect.left + additional.dx, 
        panSelectionRect.top + additional.dy, 
        panSelectionRect.width, 
        panSelectionRect.height
      );
      if (newSelectionRect.left < knittingPlane.left) {
        newSelectionRect = Rect.fromLTWH(
          knittingPlane.left, 
          newSelectionRect.top, 
          newSelectionRect.width, 
          newSelectionRect.height
        );
      }
      if (newSelectionRect.top < knittingPlane.top) {
        newSelectionRect = Rect.fromLTWH(
          newSelectionRect.left, 
          knittingPlane.top, 
          newSelectionRect.width, 
          newSelectionRect.height
        );
      }
      if (newSelectionRect.right > knittingPlane.right) {
        newSelectionRect = Rect.fromLTWH(
          knittingPlane.right - newSelectionRect.width, 
          newSelectionRect.top, 
          newSelectionRect.width, 
          newSelectionRect.height
        );
      }
      if (newSelectionRect.bottom > knittingPlane.bottom) {
        newSelectionRect = Rect.fromLTWH(
          newSelectionRect.left, 
          knittingPlane.bottom - newSelectionRect.height, 
          newSelectionRect.width, 
          newSelectionRect.height
        );
      }
    }

    setState(() {
      if (panSelectionRect != newSelectionRect) {
        panSelectionRect = Rect.fromLTWH(
          newSelectionRect.left, newSelectionRect.top,
          newSelectionRect.width, newSelectionRect.height);
      }
    });
  }

  void endPan() {
    double widthLeniency = stitchCellWidth * 0.25;
    double heightLeniency = stitchCellHeight * 0.25;

    if (panType == PanType.middle) {
      int fromRow = ((panSelectionRect.top - heightLeniency) / stitchCellHeight).ceil();
      int fromColumn = ((panSelectionRect.left - widthLeniency) / stitchCellWidth).ceil();
      Provider.of<KnittyGriddyModel>(context, listen: false).selectInRect(
        fromRow: fromRow, 
        upToRow: fromRow + (panSelectionRect.height / stitchCellHeight).toInt() - 1, 
        fromColumn: fromColumn, 
        upToColumn: fromColumn + (panSelectionRect.width / stitchCellWidth).toInt() - 1
      );
    } else {
      Provider.of<KnittyGriddyModel>(context, listen: false).selectInRect(
        fromRow: ((panSelectionRect.top - heightLeniency) / stitchCellHeight).ceil(), 
        upToRow: ((panSelectionRect.bottom - stitchCellHeight + heightLeniency) / stitchCellHeight).floor(), 
        fromColumn: ((panSelectionRect.left - widthLeniency) / stitchCellWidth).ceil(), 
        upToColumn: ((panSelectionRect.right - stitchCellWidth + widthLeniency) / stitchCellWidth).floor()
      );
    }
    setState(() {
      panType = PanType.none;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, Selection>(
      selector: (_, model) => model.selection,
      builder: (context, selection, _) {
        if (panSelectionRect.isEmpty) {
          panSelectionRect = selection.asRect;
        }
        return selection.isEmpty ?
          const Positioned(child: Placeholder(color: Colors.transparent,)) :
          Positioned(
            top: panType == PanType.none ? selection.fromRow * stitchCellHeight : panSelectionRect.top, 
            left: panType == PanType.none ? selection.fromColumn * stitchCellWidth : panSelectionRect.left,
            child: SizedBox(
              width: panType == PanType.none ? selection.numberOfColumns * stitchCellWidth : panSelectionRect.width,
              height: panType == PanType.none ? selection.numberOfRows * stitchCellHeight : panSelectionRect.height,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow.withAlpha(50),
                  border: Border.all(width: 2, color: Colors.green)
                ),
                child: Stack(
                  children: [
                    // Top left
                    Positioned(
                      child: SelectionHandleControl(
                        panType: PanType.topleft, 
                        cursor: SystemMouseCursors.resizeUpLeft, 
                        startPan: startPan, 
                        addPanOffset: addPanOffset, 
                        endPan: endPan
                      ),
                    ),
                    // Top right
                    Positioned(
                      right: 0,
                      child: SelectionHandleControl(
                        panType: PanType.topright, 
                        cursor: SystemMouseCursors.resizeUpRight, 
                        startPan: startPan, 
                        addPanOffset: addPanOffset, 
                        endPan: endPan
                      ),
                    ),
                    // bottom left
                    Positioned(
                      bottom: 0,
                      child: SelectionHandleControl(
                        panType: PanType.bottomleft, 
                        cursor: SystemMouseCursors.resizeDownLeft, 
                        startPan: startPan, 
                        addPanOffset: addPanOffset, 
                        endPan: endPan
                      ),
                    ),
                    // Bottom right
                    Positioned(
                      right: 0, bottom: 0,
                      child: SelectionHandleControl(
                        panType: PanType.bottomright, 
                        cursor: SystemMouseCursors.resizeDownRight, 
                        startPan: startPan, 
                        addPanOffset: addPanOffset, 
                        endPan: endPan
                      ),
                    ),
                    // Top
                    if (panType == PanType.none ? selection.numberOfColumns >= 2 : panSelectionRect.width > (2 * stitchCellWidth))
                      Positioned(
                        left: panType == PanType.none ? 
                          ((selection.numberOfColumns * stitchCellWidth) / 2) - (stitchCellWidth / 4): 
                          (panSelectionRect.width / 2) - (stitchCellWidth / 4), 
                        top: 0,
                        child: SelectionHandleControl(
                          panType: PanType.top, 
                          cursor: SystemMouseCursors.resizeUp, 
                          startPan: startPan, 
                          addPanOffset: addPanOffset, 
                          endPan: endPan
                        ),
                      ),
                    // Bottom
                    if (panType == PanType.none ? selection.numberOfColumns >= 2 : panSelectionRect.width >= (2 * stitchCellWidth))
                      Positioned(
                        left: panType == PanType.none ? 
                          ((selection.numberOfColumns * stitchCellWidth) / 2) - (stitchCellWidth / 4): 
                          (panSelectionRect.width / 2) - (stitchCellWidth / 4), 
                        bottom: 0,
                        child: SelectionHandleControl(
                          panType: PanType.bottom, 
                          cursor: SystemMouseCursors.resizeDown, 
                          startPan: startPan, 
                          addPanOffset: addPanOffset, 
                          endPan: endPan
                        ),
                      ),
                    // Left
                    if (panType == PanType.none ? selection.numberOfRows >= 2 : panSelectionRect.height >= (2 * stitchCellHeight))
                      Positioned(
                        left: 0, 
                        top: panType == PanType.none ?
                          ((selection.numberOfRows * stitchCellHeight) / 2) - (stitchCellHeight / 4) :
                         (panSelectionRect.height / 2) - (stitchCellHeight / 4), 
                        child: SelectionHandleControl(
                          panType: PanType.left, 
                          cursor: SystemMouseCursors.resizeLeft, 
                          startPan: startPan, 
                          addPanOffset: addPanOffset, 
                          endPan: endPan
                        ),
                      ),
                    // Right
                    if (panType == PanType.none ? selection.numberOfRows >= 2 : panSelectionRect.height >= (2 * stitchCellHeight))
                      Positioned(
                        right: 0, 
                        top: panType == PanType.none ?
                          ((selection.numberOfRows * stitchCellHeight) / 2) - (stitchCellHeight / 4) :
                          (panSelectionRect.height / 2) - (stitchCellHeight / 4), 
                        child: SelectionHandleControl(
                          panType: PanType.right, 
                          cursor: SystemMouseCursors.resizeRight, 
                          startPan: startPan, 
                          addPanOffset: addPanOffset, 
                          endPan: endPan
                        ),
                      ),
                    // Middle
                    // don't show if it is as wide and high as the knitting plane
                    if (panType == PanType.none ?
                      selection.asRect != knittingPlane :
                      panSelectionRect != knittingPlane)
                    if (panType == PanType.none ? 
                        (selection.numberOfColumns >= 2 && selection.numberOfRows >= 2) :
                        (panSelectionRect.height >= (2 * stitchCellHeight) && 
                      panSelectionRect.width >= (2 * stitchCellWidth)))
                      Positioned(
                        top: panType == PanType.none ?
                          ((selection.numberOfRows * stitchCellHeight) / 2) - (stitchCellHeight / 4) :
                          (panSelectionRect.height / 2) - (stitchCellHeight / 4), 
                        left: panType == PanType.none ? 
                          ((selection.numberOfColumns * stitchCellWidth) / 2) - (stitchCellWidth / 4): 
                          (panSelectionRect.width / 2) - (stitchCellWidth / 4),
                        child: SelectionHandleControl(
                          panType: PanType.middle, 
                          cursor: SystemMouseCursors.move, 
                          startPan: startPan, 
                          addPanOffset: addPanOffset, 
                          endPan: endPan
                        ),
                      ),
                  ],
                ),
              )
            )
          );
      }
    );
  }
}
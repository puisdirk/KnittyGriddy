
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/stitcheditor/stitch_parts_borders.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/controls/stitcheditor/add_stitch_column_indicator.dart';
import 'package:knitty_griddy/stitchrepo/knitting_symbol_control.dart';
import 'package:knitty_griddy/stitchrepo/knitting_symbol_part_control.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitcheditor/stitch_paths_selection_marker.dart';

class EditStitchPartsControl extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int? selectedColumn;
  final int? selectedRow;

  final void Function(StitchDefinition newDefinition) onStitchDefinitionChanged;
  final void Function(int? newSelectedColumn, int? newSelectedRow) onSelectionChanged;

  static const double spacer = 16;

  const EditStitchPartsControl({
    required this.stitchDefinition,
    required this.selectedColumn,
    required this.selectedRow,
    required this.onStitchDefinitionChanged,
    required this.onSelectionChanged,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return Flexible(
      child: SizedBox(
        // width is for
        // the stitch columns
        // half a column for the add column button
        // +1 because otherwise the border of path controls get clipped
        width: ((stitchDefinition.columns + 0.5) * stitchCellWidth) + 1,
        // height is for 
        // - row for the Add Column control
        // - all the paths
        // - spacer between the paths and the complete symbol 
        // - row below for complete symbol
        // - row for the move icons
        // - row for the delete icons
        height: ((stitchDefinition.maxRows + 4) * stitchCellHeight) + spacer,
        child: Stack(
          children: [
            // The Add column button
            if (stitchDefinition.columns < 18)
              Positioned(
                top: 0,
                right: 0,
                child: AddStitchColumnIndicator(
                  onTap: () => onStitchDefinitionChanged(
                    stitchDefinition.copyWith(
                      symbols: [...stitchDefinition.symbols, const KnittingSymbol(name: 'blank', parts: [])]
                    ),
                  )
                )
              ),
            // The parts
            for (int col = 0; col < stitchDefinition.columns; col++)
              for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++)
                Positioned(
                  bottom: (3 * stitchCellHeight) + spacer + (row * stitchCellHeight),
                  left: col * stitchCellWidth,
                  child: SizedBox(
                    width: stitchCellWidth, 
                    height: stitchCellHeight, 
                    child: KnittingSymbolPartControl(
                      knittingSymbolPart: stitchDefinition.symbolPartAt(col, row),
                      symbolColor: Colors.black,
                      onTap: () => onSelectionChanged(col, row),
                    ),
                  ),
                ),
            // Divider
            Positioned(
              top: ((stitchDefinition.maxRows + 1) * stitchCellHeight) + (spacer / 2) - 1,
              child: SizedBox(
                width: (stitchDefinition.columns * stitchCellWidth),
                height: 2,
                child: Container(color: Colors.black38,),
              )
            ),
            // The symbol
            for (int col = 0; col < stitchDefinition.columns; col++)
              Positioned(
                top: ((stitchDefinition.maxRows + 1) * stitchCellHeight) + spacer,
                left: col * stitchCellWidth,
                child: SizedBox(
                  width: stitchCellWidth, 
                  height: stitchCellHeight, 
                  child: KnittingSymbolControl(
                    knittingSymbol: stitchDefinition.symbolAt(col),
                    onTap: () => onSelectionChanged(col, null),
                  ),
                ),
              ),
              // Grid
              Positioned(
                top: stitchCellHeight,
                child: IgnorePointer(
                  child: SizedBox(
                    width: (stitchDefinition.columns * stitchCellWidth),
                    height: ((stitchDefinition.maxRows + 1) * stitchCellHeight) + spacer,
                    child: StitchPartsBorders(
                      stitchDefinition: stitchDefinition,
                      symbolRowSpace: spacer,
                    ),
                  ),
                ),
              ),
              //Selection markers
              Positioned(
                top: stitchCellHeight,
                child: IgnorePointer(
                  child: SizedBox(
                    width: (stitchDefinition.columns * stitchCellWidth),
                    height: ((stitchDefinition.maxRows + 1) * stitchCellHeight) + spacer,
                    child: StitchPathsSelectionMarker(
                      stitchDefinition: stitchDefinition,
                      selectedColumn: selectedColumn,
                      selectedRow: selectedRow,
                    ),
                  ),
                ),
              ),
              // Controls to move columns and cells
              for (int col = 0; col < stitchDefinition.columns; col++)
                Positioned(
                  top: ((stitchDefinition.maxRows + 2) * stitchCellHeight) + spacer,
                  left: col * stitchCellWidth,
                  child: SizedBox(
                    width: stitchCellWidth,
                    height: stitchCellHeight * 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: stitchCellHeight,
                          child: Row(
                            children: [
                              // Move left
                              if (selectedColumn == col && col > 0)
                                GestureDetector(
                                  onTap: () {
                                    List<KnittingSymbol> newSymbols = [];
                                    int? newSelectedColumn = selectedColumn! - 1;
                                    int? newSelectedRow = selectedRow;
                                    if (selectedRow == null) {
                                      // The whole column, i.e. swap the symbols
                                      for (int col = 0; col < stitchDefinition.columns; col++) {
                                        if (col == selectedColumn! - 1) {
                                          newSymbols.add(stitchDefinition.symbolAt(selectedColumn!));
                                        } else if (col == selectedColumn) {
                                          newSymbols.add(stitchDefinition.symbolAt(selectedColumn! - 1));
                                        } else {
                                          newSymbols.add(stitchDefinition.symbolAt(col));
                                        }
                                      }
                                    } else {
                                      // A single part. We move it
                                      KnittingSymbolPart part = stitchDefinition.symbolPartAt(selectedColumn!, selectedRow!);
                                      for (int col = 0; col < stitchDefinition.columns; col++) {
                                        if (col == selectedColumn! - 1) {
                                          // The column to move to
                                          List<KnittingSymbolPart> newParts = List.from(stitchDefinition.symbolAt(col).parts);
                                          // Try to move to same row; else append
                                          if (newParts.length > selectedRow!) {
                                            newParts.insert(selectedRow!, part);
                                          } else {
                                            newParts.add(part);
                                            newSelectedRow = newParts.length - 1;
                                          }
                                          newSymbols.add(stitchDefinition.symbolAt(col).copyWith(
                                            parts: newParts
                                          ));
                                        } else if (col == selectedColumn) {
                                          // The column to move from
                                          List<KnittingSymbolPart> newParts = List.from(stitchDefinition.symbolAt(col).parts);
                                          newParts.removeAt(selectedRow!);
                                          newSymbols.add(stitchDefinition.symbolAt(col).copyWith(
                                            parts: newParts
                                          ));
                                        } else {
                                          newSymbols.add(stitchDefinition.symbolAt(col));
                                        }
                                      }
                                    }
                                    onStitchDefinitionChanged(
                                      stitchDefinition.copyWith(
                                        symbols: newSymbols
                                      )
                                    );
                                    onSelectionChanged(newSelectedColumn, newSelectedRow);
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SizedBox(
                                      width: stitchCellWidth / 2, 
                                      height: stitchCellHeight / 2,
                                      child: CustomPaint(
                                        painter: ArrowPainter(
                                          direction: Direction.left,
                                          hollow: selectedRow != null
                                        ), 
                                        size: const Size(stitchCellWidth / 2, stitchCellHeight / 2)
                                      )
                                    ),
                                  )
                                ),
                              // Placeholder
                              if (selectedColumn == null || col == 0)
                                const SizedBox(
                                  width: stitchCellWidth / 2, 
                                  height: stitchCellHeight / 2,
                                ),
                              // Move right
                              if (selectedColumn == col && col < (stitchDefinition.columns - 1))
                                GestureDetector(
                                  onTap: (){
                                    List<KnittingSymbol> newSymbols = [];
                                    int? newSelectedColumn = selectedColumn! + 1;
                                    int? newSelectedRow = selectedRow;
                                    if (selectedRow == null) {
                                      // The whole column, i.e. swap the symbols
                                      for (int col = 0; col < stitchDefinition.columns; col++) {
                                        if (col == selectedColumn! + 1) {
                                          newSymbols.add(stitchDefinition.symbolAt(selectedColumn!));
                                        } else if (col == selectedColumn) {
                                          newSymbols.add(stitchDefinition.symbolAt(selectedColumn! + 1));
                                        } else {
                                          newSymbols.add(stitchDefinition.symbolAt(col));
                                        }
                                      }
                                    } else {
                                      // A single part. We move it
                                      KnittingSymbolPart part = stitchDefinition.symbolPartAt(selectedColumn!, selectedRow!);
                                      for (int col = 0; col < stitchDefinition.columns; col++) {
                                        if (col == selectedColumn! + 1) {
                                          // The column to move to
                                          List<KnittingSymbolPart> newParts = List.from(stitchDefinition.symbolAt(col).parts);
                                          // Try to move to same row; else append
                                          if (newParts.length > selectedRow!) {
                                            newParts.insert(selectedRow!, part);
                                          } else {
                                            newParts.add(part);
                                            newSelectedRow = newParts.length - 1;
                                          }
                                          newSymbols.add(stitchDefinition.symbolAt(col).copyWith(
                                            parts: newParts
                                          ));
                                        } else if (col == selectedColumn) {
                                          // column to move from, so we remove the part
                                          List<KnittingSymbolPart> newParts = List.from(stitchDefinition.symbolAt(col).parts);
                                          //newParts[selectedRow!] = KnittingSymbolParts.blankPath;
                                          newParts.removeAt(selectedRow!);
                                          newSymbols.add(stitchDefinition.symbolAt(col).copyWith(
                                            parts: newParts
                                          ));
                                        } else {
                                          newSymbols.add(stitchDefinition.symbolAt(col));
                                        }
                                      }
                                    }
                                    onStitchDefinitionChanged(
                                      stitchDefinition.copyWith(
                                        symbols: newSymbols
                                      )
                                    );
                                    onSelectionChanged(newSelectedColumn, newSelectedRow);
                                  }, 
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SizedBox(
                                      width: stitchCellWidth / 2, 
                                      height: stitchCellHeight / 2,
                                      child: CustomPaint(
                                        painter: ArrowPainter(
                                          direction: Direction.right,
                                          hollow: selectedRow != null
                                        ), 
                                        size: const Size(stitchCellWidth / 2, stitchCellHeight / 2)
                                      )
                                    ),
                                  )
                                ),
                              // Placeholder
                              if (selectedColumn != col || col > (stitchDefinition.columns - 1))
                                const SizedBox(
                                  width: stitchCellWidth / 2, 
                                  height: stitchCellHeight / 2,
                                ),
                            ],
                          ),
                        ),
                        // Delete icons
                        if (selectedColumn == col)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (selectedRow == null) {
                                  // delete the whole column (a symbol)
                                  List<KnittingSymbol> newSymbols = List.from(stitchDefinition.symbols);
                                  newSymbols.removeAt(selectedColumn!);
                                  onStitchDefinitionChanged(
                                    stitchDefinition.copyWith(
                                      symbols: newSymbols
                                    )
                                  );
                                  onSelectionChanged(null, null);
                                } else {
                                  // Delete an individual path
                                  List<KnittingSymbol> newSymbols = [];
                                  for (int col = 0; col < stitchDefinition.columns; col++) {
                                    if (col != selectedColumn) {
                                      newSymbols.add(stitchDefinition.symbols[col]);
                                    } else {
                                      List<KnittingSymbolPart> newParts = List.from(stitchDefinition.symbols[col].parts);
                                      newParts.removeAt(selectedRow!);
                                      // Prevent a symbol without parts
//                                      if (newParts.isEmpty) {
//                                        newParts.add(KnittingSymbolParts.blankPath);
//                                      }
                                      newSymbols.add(stitchDefinition.symbols[col].copyWith(
                                        parts: newParts
                                      ));
                                    }
                                  }
                                  onStitchDefinitionChanged(stitchDefinition.copyWith(
                                    symbols: newSymbols
                                  ));
                                }
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Icon(selectedRow == null ? Icons.delete : Icons.delete_outline)
                              )
                            )
                          )
                      ],
                    )
                  )
                )
          ],
        ),
      ),
    );
  }
}

enum Direction {
  left,
  right,
}

class ArrowPainter extends CustomPainter {

  final Direction direction;
  final bool hollow;

  const ArrowPainter({
    required this.direction,
    required this.hollow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint ink = Paint()
    ..color = Colors.black
    .. style = hollow ? PaintingStyle.stroke : PaintingStyle.fill
    ..strokeWidth = hollow ? 2 : 1;

    Path p = Path();
    switch (direction) {
      case Direction.left:
        if (hollow) {
          p.moveTo((size.width * 0.75) - 1, 1);
          p.lineTo((size.width * 0.75) - 1, size.height - 1);
          p.lineTo(3, size.height / 2);
          p.lineTo((size.width * 0.75) - 1, 1);
          p.close();

        } else {
          p.moveTo(size.width * 0.75, 0);
          p.lineTo(size.width * 0.75, size.height);
          p.lineTo(2, size.height / 2);
          p.lineTo(size.width * 0.75, 0);
          p.close();
        }
        break;
      case Direction.right:
        if (hollow) {
          p.moveTo(size.width * 0.25 + 1, 1);
          p.lineTo(size.width - 3, size.height / 2);
          p.lineTo((size.width * 0.25) + 1, size.height - 1);
          p.lineTo((size.width * 0.25) + 1, 1);
          p.close();
        } else {
          p.moveTo(size.width * 0.25, 0);
          p.lineTo(size.width - 2, size.height / 2);
          p.lineTo(size.width * 0.25, size.height);
          p.lineTo(size.width * 0.25, 0);
          p.close();
        }
    }

    canvas.drawPath(p, ink);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return direction != oldDelegate.direction || hollow != oldDelegate.hollow;
  }

}

import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class SelectionControl extends StatelessWidget {
  const SelectionControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, KnittingPattern>(
      selector: (_, model) => model.knittingPattern,
      builder: (context, knittingPattern, _) {
        return knittingPattern.selection.isEmpty ?
          const Positioned(child: Placeholder(color: Colors.transparent,)) :
          Positioned(
            top: stitchCellHeight,
            left: stitchCellWidth,
            child: SizedBox(
              width: knittingPattern.patternSettings.columns * stitchCellWidth,
              height: knittingPattern.patternSettings.rows * stitchCellHeight,
              child: Stack(
                children: [
                  for (CellAddress address in knittingPattern.selection.selectedCells) 
                    Positioned(
                      top: address.row * stitchCellHeight,
                      left: address.column * stitchCellWidth,
                      child: IgnorePointer(
                        child: SizedBox(
                          width: stitchCellWidth,
                          height: stitchCellHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow.withAlpha(50),
                              backgroundBlendMode: BlendMode.difference,
                              border: Border(
                                top: knittingPattern.selection.isSelected(address.column, address.row - 1) ? BorderSide.none : const BorderSide(width: 2, color: Colors.green),
                                bottom: knittingPattern.selection.isSelected(address.column, address.row + 1) ? BorderSide.none : const BorderSide(width: 2, color: Colors.green),
                                left: knittingPattern.selection.isSelected(address.column - 1, address.row) ? BorderSide.none : const BorderSide(width: 2, color: Colors.green),
                                right: knittingPattern.selection.isSelected(address.column + 1, address.row) ? BorderSide.none : const BorderSide(width: 2, color: Colors.green),
                              )
                            ),
                          ),
                        ),
                      )
                    )
                ]
              ),
            ),
          );
      }
    );
  }
}
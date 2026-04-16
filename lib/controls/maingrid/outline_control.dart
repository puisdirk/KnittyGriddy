
import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/knitty_griddy_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class OutlineControl extends StatelessWidget {
  final int rows;
  final int columns;

  const OutlineControl({
    required this.rows,
    required this.columns,  
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Selector<KnittyGriddyModel, Set<CellAddress>>(
      selector: (_, model) => model.outline,
      builder: (context, outline, _) {
        return SizedBox(
          width: columns * stitchCellWidth,
          height: rows * stitchCellHeight,
          child: Stack(
            children: [
              for (CellAddress address in outline)
                Positioned(
                  top: address.row * stitchCellHeight,
                  left: address.column * stitchCellWidth,
                  child: SizedBox(
                    width: stitchCellWidth,
                    height: stitchCellHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: outline.contains(CellAddress(column: address.column, row: address.row - 1)) ? BorderSide.none : const BorderSide(width: 2, color: Colors.orange),
                          bottom: outline.contains(CellAddress(column: address.column, row: address.row + 1)) ? BorderSide.none : const BorderSide(width: 2, color: Colors.orange),
                          left: outline.contains(CellAddress(column: address.column - 1, row: address.row)) ? BorderSide.none : const BorderSide(width: 2, color: Colors.orange),
                          right: outline.contains(CellAddress(column: address.column + 1, row: address.row)) ? BorderSide.none : const BorderSide(width: 2, color: Colors.orange),
                        )
                      ),
                    ),
                  )
                ),
            ],
          ),
        );
      }
    );
  }
}
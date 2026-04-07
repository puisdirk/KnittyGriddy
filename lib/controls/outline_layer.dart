
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';

class OutlineLayer extends StatelessWidget {
  final int rows;
  final int columns;

  const OutlineLayer({
    required this.rows,
    required this.columns,  
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (columns * stitchCellWidth) + (2 * columnsAndRowNumbersWidth),
      height: (rows * stitchCellHeight) + (2 * columnsAndRowNumbersHeight),
      child: const Placeholder(color: Colors.transparent,),
    );
  }
}
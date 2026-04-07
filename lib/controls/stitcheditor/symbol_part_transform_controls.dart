
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/stitcheditor/linked_spinbox.dart';
import 'package:knitty_griddy/math_utitilies.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class SymbolPartTransformControls extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int symbolPartColumn;
  final int symbolPartRow;
  final Function(StitchDefinition newDefinition) onChanged;

  const SymbolPartTransformControls({
    required this.stitchDefinition,
    required this.symbolPartColumn,
    required this.symbolPartRow,
    required this.onChanged,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Translation')
              )
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                min: -stitchCellWidth,
                max: stitchCellWidth,
                step: 0.1,
                decimals: 1,
                onChanged: (value) { onChanged(stitchDefinition.translateSymbolPartX(symbolPartColumn, symbolPartRow, value)); }, 
                value: stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).translation.dx,
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                min: -stitchCellHeight,
                max: stitchCellHeight,
                step: 0.1,
                decimals: 1,
                onChanged: (value) { onChanged(stitchDefinition.translateSymbolPartY(symbolPartColumn, symbolPartRow, value)); }, 
                value: stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).translation.dy,
              ),
            ),
          ]
        ),
        const SizedBox(height: 10,),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Rotation'),
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 160,
              child: SpinBox(
                min: -360,
                max: 360,
                value: MathUtitilies.toDegrees(stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).rotation),
                onChanged: (value) { onChanged(stitchDefinition.rotateSymbolPart(symbolPartColumn, symbolPartRow, value)); }, 
              ),
            ),
          ],
        ),
        const SizedBox(height: 10,),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Scale'),
              ),
            ),
            const SizedBox(width: 10,),
            LinkedSpinbox(
              width: 160,
              min: -100,
              max: 100,
              step: 1,
              precision: 2,
              onChanged: (value1, value2) { onChanged(stitchDefinition.scaleSymbolPart(symbolPartColumn, symbolPartRow, value1, value2)); }, 
              value1: stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dx,
              value2: stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dy,
            ),
          ],
        ),
      ],
    );
  }
}
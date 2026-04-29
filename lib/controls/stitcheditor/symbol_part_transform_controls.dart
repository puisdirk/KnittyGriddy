
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/controls/stitcheditor/linked_spinbox.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

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
                child: Text('Mirror')
              )
            ),
            const SizedBox(width: 10,),
            IconButton.outlined(
              onPressed: () {
                onChanged(
                  stitchDefinition.scaleSymbolPart(
                    symbolPartColumn, symbolPartRow, 
                    stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dx * -1, 
                    stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dy,
                  )
                );
              }, 
              icon: const Icon(Icons.flip)
            ),
            const SizedBox(width: 20,),
            Transform.rotate(
              angle: MathUtitilies.toRadians(90),
              child: IconButton.outlined(
                onPressed: () {
                  onChanged(
                    stitchDefinition.scaleSymbolPart(
                      symbolPartColumn, symbolPartRow, 
                      stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dx, 
                      stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dy * -1,
                    )
                  );
                }, 
                icon: const Icon(Icons.flip)
              ),
            ),
            const SizedBox(width: 20,),
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Duplicate')
              )
            ),
            const SizedBox(width: 10,),
            IconButton.outlined(
              onPressed: () {
                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == symbolPartColumn) {
                    List<KnittingSymbolPart> newParts = [...stitchDefinition.symbolAt(col).parts, stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow)];
                    newSymbols.add(stitchDefinition.symbolAt(col).copyWith(parts: newParts));
                  } else {
                    newSymbols.add(stitchDefinition.symbolAt(col));
                  }
                }
            
                onChanged(stitchDefinition.copyWith(
                  symbols: newSymbols
                ));
              }, 
              icon: const Icon(Icons.add_to_photos)
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
            Stack(
              children: [
                Positioned(
                  child: SizedBox(
                    width: 160,
                    child: SpinBox(
                      min: -360,
                      max: 360,
                      value: MathUtitilies.toDegrees(stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).rotationRad),
                      onChanged: (value) { onChanged(stitchDefinition.rotateSymbolPart(symbolPartColumn, symbolPartRow, value)); }, 
                    ),
                  ),
                ),
                const Positioned(
                  left: 100,
                  top: 2,
                  child: Text('°', style: TextStyle(fontSize: 24),)
                )
              ]
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
              min: -1000,
              max: 1000,
              step: 1,
              unit: '%',
              onChanged: (value1, value2) { onChanged(stitchDefinition.scaleSymbolPart(symbolPartColumn, symbolPartRow, value1 / 100, value2 / 100)); }, 
              value1: stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dx * 100,
              value2: stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).scale.dy * 100,
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/constants.dart';
import 'package:knitty_griddy/controls/stitcheditor/linked_spinbox.dart';
import 'package:knitty_griddy/math_utitilies.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class SymbolTransformControls extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int symbolColumn;
  final Function(StitchDefinition newDefinition) onChanged;

  const SymbolTransformControls({
    required this.stitchDefinition,
    required this.symbolColumn,
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
                  stitchDefinition.scaleSymbol(
                    symbolColumn,
                    stitchDefinition.symbolAt(symbolColumn).scale.dx * -1, 
                    stitchDefinition.symbolAt(symbolColumn).scale.dy,
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
                    stitchDefinition.scaleSymbol(
                      symbolColumn,
                      stitchDefinition.symbolAt(symbolColumn).scale.dx, 
                      stitchDefinition.symbolAt(symbolColumn).scale.dy * -1,
                    )
                  );
                }, 
                icon: const Icon(Icons.flip)
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
                onChanged: (value) { onChanged(stitchDefinition.translateSymbolX(symbolColumn, value)); }, 
                value: stitchDefinition.symbolAt(symbolColumn).translation.dx,
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
                onChanged: (value) { onChanged(stitchDefinition.translateSymbolY(symbolColumn, value)); }, 
                value: stitchDefinition.symbolAt(symbolColumn).translation.dy,
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
                      onChanged: (value) { onChanged(stitchDefinition.rotateSymbol(symbolColumn, value)); }, 
                      value: MathUtitilies.toDegrees(stitchDefinition.symbolAt(symbolColumn).rotation), 
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
              onChanged: (value1, value2) { onChanged(stitchDefinition.scaleSymbol(symbolColumn, value1 / 100, value2 / 100)); }, 
              value1: stitchDefinition.symbolAt(symbolColumn).scale.dx * 100,
              value2: stitchDefinition.symbolAt(symbolColumn).scale.dy * 100,
            ),
          ],
        ),
      ],
    );
  }
}
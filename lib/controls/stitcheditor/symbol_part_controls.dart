import 'package:flutter/material.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class SymbolPartControls extends StatelessWidget {
  final StitchDefinition stitchDefinition;
  final int symbolPartColumn;
  final int symbolPartRow;
  final Function(StitchDefinition newDefinition) onChanged;

  const SymbolPartControls({
    required this.stitchDefinition,
    required this.symbolPartColumn,
    required this.symbolPartRow,
    required this.onChanged, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return 
      stitchDefinition.symbolPartAt(symbolPartColumn, symbolPartRow).getEditControls(
        stitchDefinition, symbolPartColumn, symbolPartRow, onChanged);
  }
}
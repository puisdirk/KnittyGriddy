
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/stitchrepo/stitch_repository.dart';

// A stitch cell represents one spot on the grid. 
// For stitches that span 2 columns, there will be 2 stitch cells, 
// with stitchDefinitionColumn 0 and 1 respectively
@immutable
class StitchCell {

  final int row;
  final int column;
  final StitchDefinition stitchDefinition;
  final int stitchDefinitionColumn;
  final NamedColour colour;

  const StitchCell({
    required this.row,
    required this.column,
    required this.stitchDefinition,
    required this.colour,
    this.stitchDefinitionColumn = 1,
  });

  factory StitchCell.empty(int row, int column) {
    return StitchCell(row: row, column: column, stitchDefinition: StitchRepository.noStitch, colour: const NamedColour(name: 'MC', color: Colors.white));
  }

  StitchCell copyWith({
    int? row,
    int? column,
    StitchDefinition? stitchDefinition,
    NamedColour? colour,
    int? stitchDefinitionColumn,
  }) {
    return StitchCell(
      row: row?? this.row, 
      column: column?? this.column, 
      stitchDefinition: stitchDefinition?? this.stitchDefinition,
      colour: colour?? this.colour,
      stitchDefinitionColumn: stitchDefinitionColumn?? this.stitchDefinitionColumn,
    );
  }

  @override
  int get hashCode => 
    row.hashCode ^ column.hashCode ^ 
    stitchDefinition.hashCode ^ 
    colour.hashCode ^
    stitchDefinitionColumn.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is StitchCell &&
    row == other.row &&
    column == other.column &&
    stitchDefinition == other.stitchDefinition &&
    colour == other.colour &&
    stitchDefinitionColumn == other.stitchDefinitionColumn;
  
}
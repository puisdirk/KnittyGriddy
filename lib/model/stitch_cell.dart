
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/named_colour.dart';

// A stitch cell represents one spot on the grid. 
// For stitches that span 2 columns, there will be 2 stitch cells, 
// with stitchDefinitionColumn 0 and 1 respectively
@immutable
class StitchCell {

  final int row;
  final int column;
  final String stitchDefinitionId;
  final int stitchDefinitionColumn;
  final NamedColour colour;

  const StitchCell({
    required this.row,
    required this.column,
    required this.stitchDefinitionId,
    required this.colour,
    this.stitchDefinitionColumn = 0,
  });

  factory StitchCell.empty(int row, int column) {
    return StitchCell(row: row, column: column, stitchDefinitionId: BasicStitchesSet.noStitch.id, colour: defaultMainColor);
  }

  StitchCell copyWith({
    int? row,
    int? column,
    String? stitchDefinitionId,
    NamedColour? colour,
    int? stitchDefinitionColumn,
  }) {
    return StitchCell(
      row: row?? this.row, 
      column: column?? this.column, 
      stitchDefinitionId: stitchDefinitionId?? this.stitchDefinitionId,
      colour: colour?? this.colour,
      stitchDefinitionColumn: stitchDefinitionColumn?? this.stitchDefinitionColumn,
    );
  }

  Map<String, Object> toJson() {
    return {
      'row': row,
      'column': column,
      'stitchdefinitionId': stitchDefinitionId,
      'colour': colour.toJson(),
      'stitchdefinitioncolumn': stitchDefinitionColumn,
    };
  }

  static StitchCell fromJson(Map<String, dynamic> json) {
    return StitchCell(
      row: json['row'] as int, 
      column: json['column'] as int, 
      stitchDefinitionId: json['stitchdefinitionId'] as String, 
      colour: NamedColour.fromJson(json['colour'] as Map<String, dynamic>),
      stitchDefinitionColumn: json['stitchdefinitioncolumn'] as int,
    );
  }

  @override
  int get hashCode => 
    row.hashCode ^ column.hashCode ^ 
    stitchDefinitionId.hashCode ^ 
    colour.hashCode ^
    stitchDefinitionColumn.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is StitchCell &&
    row == other.row &&
    column == other.column &&
    stitchDefinitionId == other.stitchDefinitionId &&
    colour == other.colour &&
    stitchDefinitionColumn == other.stitchDefinitionColumn;
  
}
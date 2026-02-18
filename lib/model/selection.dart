
import 'package:flutter/material.dart';
import 'package:knitty_griddy/constants.dart';

const Selection emptySelection = Selection(fromRow: -1, fromColumn: -1, upToRow: -1, upToColumn: -1);

@immutable
class Selection {

  final int fromRow;
  final int fromColumn;
  final int upToRow;
  final int upToColumn;

  const Selection({
    required this.fromRow,
    required this.fromColumn,
    required this.upToRow,
    required this.upToColumn,
  });

  Selection copyWith({
    int? fromRow,
    int? fromColumn,
    int? upToRow,
    int? upToColumn,
  }) {
    return Selection(
      fromRow: fromRow?? this.fromRow, 
      fromColumn: fromColumn?? this.fromColumn, 
      upToRow: upToRow?? this.upToRow, 
      upToColumn: upToColumn?? this.upToColumn);
  }

  @override
  int get hashCode => fromRow.hashCode ^ fromColumn.hashCode ^ upToRow.hashCode ^ upToColumn.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is Selection &&
      fromRow == other.fromRow &&
      fromColumn == other.fromColumn &&
      upToRow == other.upToRow &&
      upToColumn == other.upToColumn;

  bool get isNotEmpty => fromRow != -1;
  bool get isEmpty => !isNotEmpty;

  int get numberOfRows => isEmpty ? 0 : upToRow - fromRow + 1;
  int get numberOfColumns => isEmpty ? 0 : upToColumn - fromColumn + 1;

  bool containsCell(int row, int column) {
    if (isNotEmpty) {
      bool inside = row >= fromRow && row <= upToRow && column >= fromColumn && column <= upToColumn;
      return inside;
    }
    return false;
  }

  Rect get asRect => Rect.fromLTWH(
    fromColumn * stitchCellWidth, 
    fromRow * stitchCellHeight, 
    numberOfColumns * stitchCellWidth, 
    numberOfRows * stitchCellHeight
  );

}
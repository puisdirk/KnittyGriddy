
import 'package:flutter/material.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/controls/selectionlayer/selection_control.dart';

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
    (fromColumn + 1) * stitchCellWidth, 
    (fromRow + 1) * stitchCellHeight, 
    numberOfColumns * stitchCellWidth, 
    numberOfRows * stitchCellHeight
  );

  int getRowOfPanType(PanType panType) {
    if (isEmpty) {
      return 0;
    }
    switch (panType) {
      case PanType.bottom:
      case PanType.bottomleft:
      case PanType.bottomright:
        return upToRow;
      case PanType.left:
      case PanType.middle:
      case PanType.right:
        return (fromRow + ((upToRow - fromRow) / 2)).floor();
      case PanType.top:
      case PanType.topleft:
      case PanType.topright:
        return fromRow;
      case PanType.none:
        return 0;
    }
  }

  int getColOfPanType(PanType panType) {
    if (isEmpty) {
      return 0;
    }
    switch (panType) {
      case PanType.bottom:
      case PanType.middle:
      case PanType.top:
        return (fromColumn + ((upToColumn - fromColumn) / 2)).floor();
      case PanType.right:
      case PanType.bottomright:
      case PanType.topright:
        return upToColumn;
      case PanType.left:
      case PanType.bottomleft:
      case PanType.topleft:
        return fromColumn;
      case PanType.none:
        return 0;
    }
  }
}
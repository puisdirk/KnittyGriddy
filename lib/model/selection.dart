import 'package:knitty_griddy/model/cell_address.dart';

const Selection emptySelection = Selection(selectedCells: {});

class Selection {
  final Set<CellAddress> selectedCells;

  const Selection({
    required this.selectedCells,
  });

  Selection copyWith({
    Set<CellAddress>? selectedCells,
  }) {
    return Selection(
      selectedCells: selectedCells?? this.selectedCells,
    );
  }

  Map<String, Object> toJson() {
    return {
      'selectedcells': selectedCells.map((c) => c.toJson()).toList(),
    };
  }

  static Selection fromJson(Map<String, dynamic> json) {
    Set<CellAddress> cells = {};
    List<Map<String, dynamic>> cellObjects = (json['selectedcells'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> cellObject in cellObjects) {
      cells.add(CellAddress.fromJson(cellObject));
    }

    return Selection(
      selectedCells: cells
    );
  }

  bool isSelected(int column, int row) {
    return selectedCells.contains(CellAddress(column: column, row: row));
  }

  List<CellAddress> addressesOnRow(int row) {
    return selectedCells.where((cell) => cell.row == row).toList();
  }

  bool get isEmpty => selectedCells.isEmpty;
  bool hasWidthOf(int cols) {
    if (cols < 2) { return !isEmpty; }
    List<CellAddress> visited = [];
    for (CellAddress address in selectedCells) {
      if (visited.contains(address)) {
        continue;
      }
      visited.add(address);

      int contiguousCells = 1;
      // Count on the left
      int offset = 1;
      while(true) {
        CellAddress adjacentAddress = CellAddress(column: address.column - offset, row: address.row);
        visited.add(adjacentAddress);
        if (isSelected(adjacentAddress.column, adjacentAddress.row)) {
          contiguousCells++;
          offset++;
        } else {
          break;
        }
      }
      // Count on the left
      offset = 1;
      while(true) {
        CellAddress adjacentAddress = CellAddress(column: address.column + offset, row: address.row);
        visited.add(adjacentAddress);
        if (isSelected(adjacentAddress.column, adjacentAddress.row)) {
          contiguousCells++;
          offset++;
        } else {
          break;
        }
      }
      if (contiguousCells >= cols) {
        return true;
      }
    }

    return false;
  }

  Selection clear() {
    return emptySelection;
  }

  Selection invert(int columns, int rows) {
    Set<CellAddress> newSelectedCells = {};
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!isSelected(col, row)) {
          newSelectedCells.add(CellAddress(column: col, row: row));
        }
      }
    }
    return copyWith(selectedCells: newSelectedCells);
  }

  Selection toggleCell(int column, int row) {
    Set<CellAddress> newSelectedCells = Set.from(selectedCells);

    CellAddress address = CellAddress(column: column, row: row);
    if (newSelectedCells.contains(address)) {
      newSelectedCells.remove(address);
    } else {
      newSelectedCells.add(address);
    }

    return Selection(selectedCells: newSelectedCells);
  }

  Selection toggleColumns(List<int> columns, int numberOfRows) {
    Set<CellAddress> newSelectedCells = Set.from(selectedCells);
    bool deselect = newSelectedCells.any((cell) => columns.contains(cell.column));
    if (deselect) {
      newSelectedCells.removeWhere((cell) => columns.contains(cell.column));
    } else {
      for (int col in columns) {
        for (int row = 0; row < numberOfRows; row++) {
          newSelectedCells.add(CellAddress(column: col, row: row));
        }
      }
    }
    return Selection(selectedCells: newSelectedCells);
  }

  Selection toggleRows(List<int> rows, int numberOfColumns) {
    Set<CellAddress> newSelectedCells = Set.from(selectedCells);
    final bool deselect = newSelectedCells.any((cell) => rows.contains(cell.row));
    if (deselect) {
      newSelectedCells.removeWhere((cell) => rows.contains(cell.row));
    } else {
      for (int row in rows) {
        for (int col = 0; col < numberOfColumns; col++) {
          newSelectedCells.add(CellAddress(column: col, row: row));
        }
      }
    }
    return Selection(selectedCells: newSelectedCells);
  }

  Selection selectAll(int numberOfColumns, int numberOfRows) {
    Set<CellAddress> newSelectedCells = {};
    for (int col = 0; col < numberOfColumns; col++) {
      for (int row = 0; row < numberOfRows; row++) {
        newSelectedCells.add(CellAddress(column: col, row: row));
      }
    }
    return Selection(selectedCells: newSelectedCells);
  }

}
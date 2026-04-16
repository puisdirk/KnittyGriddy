
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/griddy_model.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/model/undo_redo_manager.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/stitchrepo/stitch_repository.dart';

class KnittyGriddyModel extends ChangeNotifier {

  // The immutable model being accessed throughout the app
  GriddyModel _model;
  final UndoRedoManager<KnittingPattern> _undoRedoManager;

  KnittyGriddyModel() : _model = const GriddyModel(), _undoRedoManager = UndoRedoManager() {
    _storeForUndo();
  }

  void _storeForUndo() {
    _undoRedoManager.store(_model.knittingPattern.copyWith());
  }

  bool get canUndo => _undoRedoManager.canUndo();
  bool get canRedo => _undoRedoManager.canRedo();

  void undo() {
    if (_undoRedoManager.canUndo()) {
      _model = _model.copyWith(knittingPattern: _undoRedoManager.undo());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoRedoManager.canRedo()) {
      _model = _model.copyWith(knittingPattern: _undoRedoManager.redo());
      notifyListeners();
    }
  }

  PatternSettings get settings => _model.knittingPattern.patternSettings;
  StitchCell stitchCell(int row, int column) => _model.knittingPattern.stitchCell(row, column);
  List<StitchCell> get stitches => _model.knittingPattern.stitches;
  List<StitchDefinition> get usedStitches => _model.knittingPattern.usedStitches;
  List<NamedColour> get usedColours => _model.knittingPattern.usedColours;
  Selection get selection => _model.knittingPattern.selection;
  Set<CellAddress> get outline => _model.knittingPattern.outline;
  KnittingPattern get knittingPattern => _model.knittingPattern;

  Map<String, List<StitchDefinition>> selectStitchDefinitionsPerCategory(String filter) {
    if (filter.isEmpty) {
      return StitchRepository.getDefinitionsPerCategory(_model.customStitches);
    }

    Map<String, List<StitchDefinition>> filtered = {};
    StitchRepository.getDefinitionsPerCategory(_model.customStitches).forEach((key, value) {
      if (value.any((sd) => sd.passesFilter(filter))) {
        filtered[key] = value.where((sd) => sd.passesFilter(filter)).toList();
      }
    });
    return filtered;
  }

  bool isStitchUsedInPattern(StitchDefinition definition) =>
    _model.knittingPattern.stitches.any((cell) => cell.stitchDefinition == definition);

  bool isColourUsedInPattern(NamedColour colour) =>
    colour.isMainColor || _model.knittingPattern.stitches.any((cell) => cell.colour == colour);

  AppState get appState => _model.appState;
  void appUseStitch(StitchDefinition stitchDefinition) {
    _model = _model.copyWith(
      appState: _model.appState.setSelectedStitchDefinition(stitchDefinition: stitchDefinition)
    );
    notifyListeners();
  }
  void appUseColour(NamedColour colour) {
    _model = _model.copyWith(
      appState: _model.appState.setSelectedColour(colour: colour)
    );
    notifyListeners();
  }
  void setMouseOption(MouseOption option) {
    _model = _model.copyWith(
      appState: _model.appState.setSelectedMouseOption(mouseOption: option)
    );
    notifyListeners();
  }

  void useGridType(GridType newGridType){
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        patternSettings: _model.knittingPattern.patternSettings.copyWith(
          gridType: newGridType
        )
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  // ********************************************* Click and paint *****************************************

  void setStitch(int row, int column, StitchDefinition stitchDefinition, {storeForUndo = true, emitNotification = true}) {
    // Do nothing if there isn't enough room
    if (stitchDefinition.columns + column - 1 > _model.knittingPattern.patternSettings.columns) {
      return;
    }

    // Calculate the cells that will be affected
    List<StitchCell> newStitchCells = [];
    for (int columnOffset = 0; columnOffset < stitchDefinition.columns; columnOffset++) {
      newStitchCells.add(
        _model.knittingPattern.stitches.firstWhere((s) => s.row == row && s.column == column + columnOffset).
          copyWith(stitchDefinition: stitchDefinition, stitchDefinitionColumn: columnOffset));
    }

    // Calculate which cell need to be cleared
    List<StitchCell> clearedCells = [];
    for (StitchCell newCell in newStitchCells) {
      // If the cell under the new stitch is a multi-column
      StitchCell oldCell = _model.knittingPattern.stitches.firstWhere((c) => c.row == newCell.row && c.column == newCell.column);
      if (oldCell.stitchDefinition.columns > 1) {
        int oldCellStart = oldCell.column - (oldCell.stitchDefinitionColumn);
        for (int clearIdx = 0; clearIdx < oldCell.stitchDefinition.columns; clearIdx++) {
          // don't clear if this is already a new cell
          if (!newStitchCells.any((c) => c.row == oldCell.row && c.column == oldCellStart + clearIdx)) {
            clearedCells.add(StitchCell(row: oldCell.row, column: oldCellStart + clearIdx, stitchDefinition: StitchRepository.noStitch, colour: oldCell.colour));
          }
        }
      }
    }
    newStitchCells.addAll(clearedCells);

    if (newStitchCells.isEmpty) {
      return;
    }

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          newStitchCells.any((ns) => stitch.row == ns.row && stitch.column == ns.column) ? 
            newStitchCells.firstWhere((ns) => stitch.row == ns.row && stitch.column == ns.column) : stitch,
        ).toList(),
      )
    );
    if (storeForUndo) {
      _storeForUndo();
    }
    if (emitNotification) {
      notifyListeners();
    }
  }
  
  void setStitchColour(int row, int column, NamedColour colour) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.row != row || stitch.column != column ? stitch : stitch.copyWith(
            colour: colour
          )
        ).toList()
      )
    );
    _storeForUndo();
    notifyListeners();
  }

  // ********************************************* Fill selection ************************************

  void fillSelectionWithStitch(StitchDefinition stitchDefinition) {
    if (!selection.hasWidthOf(stitchDefinition.columns)) {
      return;
    }

    // single-column stitches don't need all these calculations
    if (stitchDefinition.columns < 2) {
      for (CellAddress address in selection.selectedCells) {
        setStitch(address.row, address.column, stitchDefinition);
      }
    } else {
      for (int row = 0; row < _model.knittingPattern.patternSettings.rows; row++) {
        List<CellAddress> addressesOnRow = selection.addressesOnRow(row);
        if (addressesOnRow.isEmpty) {
          continue;
        }
        addressesOnRow.sort();
        List<CellAddress> visited = [];
        for (CellAddress address in addressesOnRow) {
          if (visited.contains(address)) {
            continue;
          }
          visited.add(address);

          List<CellAddress> needed = List.generate(stitchDefinition.columns - 1, (idx) => CellAddress(column: address.column + idx + 1, row: row));
          if (selection.selectedCells.containsAll(needed)) {
            setStitch(row, address.column, stitchDefinition);
            visited.addAll(needed);
          }
        }
      }
    }

    _storeForUndo();
    notifyListeners();
  }

  void fillSelectionWithColor(NamedColour colour) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          _model.knittingPattern.selection.isSelected(stitch.column, stitch.row) ?
            stitch.copyWith(colour: colour) :
            stitch
        ).toList()
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  // ********************************************* Edit grid *****************************************

  void insertColumn(int beforeColumn) {
    // Find multi-column stitches that will get broken
    List<StitchCell> brokenStitches = _model.knittingPattern.stitches.where((stitch) =>
      stitch.stitchDefinition.columns > 1 && 
      beforeColumn > stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      beforeColumn < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + stitch.stitchDefinition.columns
    ).toList();

    // Clear these broken stitches
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinition: StitchRepository.noStitch, stitchDefinitionColumn: 1) : stitch
        ).toList()
      )
    );

    // Move the columns after the insertion point to the right and clear the selection
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        patternSettings: _model.knittingPattern.patternSettings.copyWith(
          columns: _model.knittingPattern.patternSettings.columns + 1,
        ),
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.column < beforeColumn ? 
            stitch : 
            stitch.copyWith(column: stitch.column + 1)
        ).toList(),
        selection: emptySelection
      )
    );

    // Create the new column of cells
    List<StitchCell> newStitches = List.from(_model.knittingPattern.stitches);
    newStitches.addAll(List<StitchCell>.generate(
      _model.knittingPattern.patternSettings.rows,
      (idx) =>
        StitchCell(
          row: idx, 
          column: beforeColumn, 
          stitchDefinition: StitchRepository.noStitch, 
          colour: _model.knittingPattern.mainColour
        )
    ));

    _model = _model.copyWith(knittingPattern: _model.knittingPattern.copyWith(stitches: newStitches));

    _storeForUndo();
    notifyListeners();
  }

  void insertRow(int beforeRow) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        patternSettings: _model.knittingPattern.patternSettings.copyWith(
          rows: _model.knittingPattern.patternSettings.rows + 1
        ),
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.row < beforeRow ? stitch : stitch.copyWith(
            row: stitch.row + 1
          )
        ).toList(),
        selection: emptySelection
      )
    );

    List<StitchCell> newStitches = List.from(_model.knittingPattern.stitches);
    newStitches.addAll(
      List<StitchCell>.generate(
        _model.knittingPattern.patternSettings.columns, 
        (idx) => 
          StitchCell(
            row: beforeRow, 
            column: idx, 
            stitchDefinition: StitchRepository.noStitch, 
            colour: _model.knittingPattern.mainColour
          )
      )
    );

    _model = _model.copyWith(knittingPattern: _model.knittingPattern.copyWith(stitches: newStitches));

    _storeForUndo();
    notifyListeners();
  }

  void deleteColumn(int column) {
    // Find multi-column stitches that will get broken
    List<StitchCell> brokenStitches = _model.knittingPattern.stitches.where((stitch) =>
      stitch.stitchDefinition.columns > 1 && 
      column >= stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      column < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + stitch.stitchDefinition.columns
    ).toList();

    // Clear these broken stitches
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinition: StitchRepository.noStitch, stitchDefinitionColumn: 1) : stitch
        ).toList()
      )
    );

    // Remove the column stitches
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.where((stitch) => stitch.column != column).toList()
      )
    );

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        patternSettings: _model.knittingPattern.patternSettings.copyWith(
          columns: _model.knittingPattern.patternSettings.columns - 1,
        ),
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.column > column ? 
            stitch.copyWith(column: stitch.column - 1) :
            stitch
        ).toList(),
        selection: emptySelection
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void deleteRow(int row) {
    // Remove the stitches
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.where((stitch) => stitch.row != row).toList()
      )
    );

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        patternSettings: _model.knittingPattern.patternSettings.copyWith(
          rows: _model.knittingPattern.patternSettings.rows - 1
        ),
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.row < row ? stitch : stitch.copyWith(
            row: stitch.row - 1
          )
        ).toList(),
        selection: emptySelection
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  // ********************************************* Selection *****************************************

  void selectNone() {
    if (_model.knittingPattern.selection.isEmpty) {
      return;
    }

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: emptySelection
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void selectAll() {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: selection.selectAll(
          _model.knittingPattern.patternSettings.columns, 
          _model.knittingPattern.patternSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void invertSelection() {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.invert(_model.knittingPattern.patternSettings.columns, _model.knittingPattern.patternSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void setOutline() {
    Set<CellAddress> newOutline = {};
    // clear if selection is the same as current marks
    if (!setEquals(selection.selectedCells, outline)) {
      newOutline.addAll(selection.selectedCells);
    }

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        outline: newOutline
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleCell(int column, int row) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleCell(column, row)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleRow(int row) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleRows(
          [row], 
          _model.knittingPattern.patternSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleColumn(int column) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleColumns(
          [column], 
          _model.knittingPattern.patternSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleOddRows() {
    List<int> rows = [];
    for (int row = 1; row < _model.knittingPattern.patternSettings.rows; row += 2) {
      rows.add(row);
    }
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleRows(
          rows, _model.knittingPattern.patternSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleEvenRows() {
    List<int> rows = [];
    for (int row = 0; row < _model.knittingPattern.patternSettings.rows; row += 2) {
      rows.add(row);
    }
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleRows(
          rows, _model.knittingPattern.patternSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleOddColumns() {
    List<int> columns = [];
    for (int col = 1; col < _model.knittingPattern.patternSettings.columns; col += 2) {
      columns.add(col);
    }
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleColumns(
          columns, _model.knittingPattern.patternSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleEvenColumns() {
    List<int> columns = [];
    for (int col = 0; col < _model.knittingPattern.patternSettings.columns; col += 2) {
      columns.add(col);
    }
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.toggleColumns(
          columns, _model.knittingPattern.patternSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

// ************************ Edit or create colours *******************************************

  void setNamedColour(NamedColour colour, Color newColor, String newName) {

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        usedColours: _model.knittingPattern.usedColours.map((col) =>
          col.name != colour.name ? col : col.copyWith(
            name: newName,
            color: newColor
          )
        ).toList(),
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.colour != colour ? stitch : stitch.copyWith(
            colour: stitch.colour.copyWith(
              name: newName,
              color: newColor
            )
          )
        ).toList()
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void addNamedColour(Color newColor, String newName) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        usedColours: [..._model.knittingPattern.usedColours, NamedColour(name: newName, color: newColor)]
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  // *************************** Stitch repo ************************************************

  void toggleUsedStitch(StitchDefinition definition) {
    final bool wantToRemove = _model.knittingPattern.usedStitches.contains(definition);
    
    if (wantToRemove) {
      // Guard against removing definitions in use on the pattern
      if (isStitchUsedInPattern(definition)) {
        return;
      }

      _model = _model.copyWith(
        knittingPattern: _model.knittingPattern.copyWith(
          usedStitches: _model.knittingPattern.usedStitches.where((s) => s != definition).toList()
        )
      );
    } else {
      _model = _model.copyWith(
        knittingPattern: _model.knittingPattern.copyWith(
          usedStitches: [..._model.knittingPattern.usedStitches, definition]
        )
      );
    }

    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedStitches() {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        usedStitches: _model.knittingPattern.usedStitches.where((us) => us == StitchRepository.noStitch || isStitchUsedInPattern(us)).toList()
      )
    );
    
    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedColours() {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        usedColours: _model.knittingPattern.usedColours.where((uc) => isColourUsedInPattern(uc)).toList()
      )
    );

    _storeForUndo();
    notifyListeners();
  }

}


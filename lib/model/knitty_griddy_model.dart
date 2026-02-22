
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/griddy_model.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/model/selection.dart';
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
  KnittingPattern get knittingPattern => _model.knittingPattern;

/*  List<StitchDefinition> selectStitchDefinitions(String filter) {
    if (filter.isEmpty) {
      return StitchRepository.definitions;
    }

    return StitchRepository.definitions.where((sd) => sd.passesFilter(filter)).toList();
  }
*/
  Map<String, List<StitchDefinition>> selectStitchDefinitionsPerCategory(String filter) {
    if (filter.isEmpty) {
      return StitchRepository.definitionsPerCategory;
    }

    Map<String, List<StitchDefinition>> filtered = {};
    StitchRepository.definitionsPerCategory.forEach((key, value) {
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
          copyWith(stitchDefinition: stitchDefinition, stitchDefinitionColumn: columnOffset + 1));
    }

    // Calculate which cell need to be cleared
    List<StitchCell> clearedCells = [];
    for (StitchCell newCell in newStitchCells) {
      // If the cell under the new stitch is a multi-column
      StitchCell oldCell = _model.knittingPattern.stitches.firstWhere((c) => c.row == newCell.row && c.column == newCell.column);
      if (oldCell.stitchDefinition.columns > 1) {
        int oldCellStart = oldCell.column - (oldCell.stitchDefinitionColumn - 1);
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
    // selection must be wide enough
    if (selection.numberOfColumns < stitchDefinition.columns) {
      return;
    }

    // We go column per column to take multi-column stitches into account
    for (int row = selection.fromRow; row <= selection.upToRow; row++) {
      for (int startCol = selection.fromColumn; startCol + stitchDefinition.columns - 1 <= selection.upToColumn; startCol += stitchDefinition.columns) {
        setStitch(row, startCol, stitchDefinition, storeForUndo: false, emitNotification: false);
      }
    }

    _storeForUndo();
    notifyListeners();
  }

  void fillSelectionWithColor(NamedColour colour) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          _model.knittingPattern.selection.containsCell(stitch.row, stitch.column) ?
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

    // Move the columns after the insertion point to the right
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
          row: idx + 1, 
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
        (col) => 
          StitchCell(
            row: beforeRow, 
            column: col + 1, 
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
        selection: Selection(
          fromRow: 1, fromColumn: 1, 
          upToRow: _model.knittingPattern.patternSettings.rows, 
          upToColumn: _model.knittingPattern.patternSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void selectInRect({
    required int fromRow, 
    required int upToRow, 
    required int fromColumn,
    required int upToColumn
  }) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: Selection(
          fromRow: fromRow, 
          upToRow: upToRow, 
          fromColumn: fromColumn,
          upToColumn: upToColumn)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void selectRow(int row) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: Selection(
          fromRow: row + 1, 
          upToRow: row + 1, 
          fromColumn: 1,
          upToColumn: _model.knittingPattern.patternSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void selectColumn(int column) {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: Selection(
          fromColumn: column + 1, 
          upToColumn: column + 1,
          fromRow: 1, 
          upToRow: _model.knittingPattern.patternSettings.rows, 
        )
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



import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/named_colour.dart';
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

  void setStitch(int row, int column, StitchDefinition stitchDefinition) {
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

    _storeForUndo();

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          newStitchCells.any((ns) => stitch.row == ns.row && stitch.column == ns.column) ? 
            newStitchCells.firstWhere((ns) => stitch.row == ns.row && stitch.column == ns.column) : stitch,
        ).toList(),
      )
    );
    notifyListeners();
  }
  
  void setStitchColour(int row, int column, NamedColour colour) {

    _storeForUndo();
    
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) =>
          stitch.row != row || stitch.column != column ? stitch : stitch.copyWith(
            colour: colour
          )
        ).toList()
      )
    );
    notifyListeners();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/controls/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitty_griddy_save_model.dart';
import 'package:knitty_griddy/model/named_colour.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_parts.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/griddy_model.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/model/undo_redo_manager.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class KnittyGriddyModel extends ChangeNotifier {

  final ModelRepository _repository;

  // The immutable model being accessed throughout the app
  GriddyModel _model;
  
  final UndoRedoManager<KnittingPattern> _undoRedoManager;

  KnittyGriddySaveModel? _lastSaved;

  Future<void> autoSave() async {
    if (_lastSaved == null) {
      _lastSaved = KnittyGriddySaveModel(
        knittingPattern: _model.knittingPattern, 
        patternInfos: _model.patternInfos, 
        stitchSets: List.from(StitchRepository.instance.sets),
      );
      return;
    }

    final KnittyGriddySaveModel oldModel = _lastSaved!.copyWith();
    _lastSaved = _lastSaved!.copyWith(
      griddyModel: _model,
      stitchSets: List.from(StitchRepository.instance.sets),
    );

    if (oldModel.patternInfos != _lastSaved!.patternInfos) {
      await _repository.savePatternInfos(_lastSaved!.patternInfos);
    }

    if (oldModel.stitchSets != _lastSaved!.stitchSets) {
      await _repository.saveStitchSets(_lastSaved!.stitchSets);
    }

    if (oldModel.knittingPattern != _lastSaved!.knittingPattern) {
      await _repository.savePattern(_lastSaved!.knittingPattern);
    }

    if (oldModel.stitchSets != _lastSaved!.stitchSets) {
      await _repository.saveStitchSets(_lastSaved!.stitchSets);
    }
  }

  KnittyGriddyModel({
    required ModelRepository repository,
  }) : 
    _repository = repository, 
    _model = const GriddyModel(), 
    _undoRedoManager = UndoRedoManager() {
    // Initialize the undo-redo manager
    _storeForUndo();
  }

  void loadOnStartup() {
    _repository.loadPatternInfos().then((List<PatternInfo> patternInfos) {
      _model = _model.copyWith(
        patternInfos: patternInfos,
      );
      _repository.loadStitchSets().then((List<StitchSet> stitchSets) {
        StitchRepository.loadInitialStitchSets(stitchSets);
        notifyListeners();
      });
    });
  }

  Future<void> saveCurrentPattern() async {
    await _repository.savePattern(_model.knittingPattern);
  }

  Future<void> _savePatternInfos() async {
    await _repository.savePatternInfos(_model.patternInfos);
  }

  Future<void> createNewPattern(String name) async {
    final String id = const UuidV4Gen().get();

    _model = _model.copyWith(
      patternInfos: List.from(_model.patternInfos)..add(PatternInfo(id: id, name: name)),
      knittingPattern: KnittingPattern(id: id, name: name)
    );

    await autoSave();
    notifyListeners();
  }

  Future<void> exportPattern() async {
    await _repository.exportPattern(_model.knittingPattern);
  }

  Future<void> importPattern() async {
    KnittingPattern? pattern = await _repository.importPattern();
    if (pattern != null && !patternInfos.any((pi) => pi.id == pattern.id)) {
      await _repository.savePattern(pattern);
      _model = _model.copyWith(
        patternInfos: [..._model.patternInfos, PatternInfo(id: pattern.id, name: pattern.name, description: pattern.description)],
      );
      _savePatternInfos();
      notifyListeners();
    }
  }

  void deletePattern(String patternId) {
    _model = _model.copyWith(
      patternInfos: _model.patternInfos.where((pi) => pi.id != patternId).toList()
    );

    _repository.deletePattern(patternId);
    _savePatternInfos();
    notifyListeners();
  }

  Future<void> loadPattern(String patternId) async {
    KnittingPattern pattern = await _repository.loadPattern(patternId);
    // Import unknown stitches
    for (StitchDefinition def in pattern.usedStitches) {
      if (!StitchRepository.hasStitch(def)) {
        StitchDefinition? sameStitchContent = StitchRepository.getStitchDefinitionByContent(def);
        if (sameStitchContent != null) {
          // We have a stitchdefinition in the repo that is the same except for the id. So use that
          pattern = pattern.copyWith(
            usedStitches: pattern.usedStitches.map((us) => us != def ? def : sameStitchContent).toList(),
            stitches: pattern.stitches.map((sc) => sc.stitchDefinitionId != def.id ? sc : sc.copyWith(stitchDefinitionId: sameStitchContent.id)).toList()
          );
        } else {
          StitchRepository.addStitchToImportedSet(def);
        }
      }
    }
    _model = _model.copyWith(
      knittingPattern: pattern,
    );
    notifyListeners();
  }

  void setPatternName(String name) {
    _model = _model.copyWith(
      patternInfos: _model.patternInfos.map((pi) =>
        pi.id != _model.knittingPattern.id ? pi :
        pi.copyWith(name: name)
      ).toList(),
      knittingPattern: _model.knittingPattern.copyWith(name: name)
    );

    _storeForUndo();
    notifyListeners();
  }

  void setPatternDescription(String description) {
    _model = _model.copyWith(
      patternInfos: _model.patternInfos.map((pi) =>
        pi.id != _model.knittingPattern.id ? pi :
        pi.copyWith(description: description)
      ).toList(),
      knittingPattern: _model.knittingPattern.copyWith(description: description)
    );

    _storeForUndo();
    notifyListeners();
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

  List<PatternInfo> get patternInfos => _model.patternInfos;
  PatternSettings get settings => _model.knittingPattern.patternSettings;
  StitchCell stitchCell(int row, int column) => _model.knittingPattern.stitchCell(row, column);
  List<StitchCell> get stitches => _model.knittingPattern.stitches;
  StitchCell stitchAt(int column, int row) => _model.knittingPattern.stitches.firstWhere((cell) => cell.column == column && cell.row == row);
  List<StitchDefinition> get usedStitches => _model.knittingPattern.usedStitches;
  List<NamedColour> get usedColours => _model.knittingPattern.usedColours;
  Selection get selection => _model.knittingPattern.selection;
  Set<CellAddress> get outline => _model.knittingPattern.outline;
  KnittingPattern get knittingPattern => _model.knittingPattern;
  AppState get appState => _model.appState;

  List<StitchSet> filteredStitchSets(String filter) {
    return StitchRepository.filteredStitchSets(filter);
  }

  Map<String, List<StitchDefinition>> selectStitchDefinitionsPerCategory(String filter) {
    if (filter.isEmpty) {
      return StitchRepository.getDefinitionsPerCategory();
    }

    Map<String, List<StitchDefinition>> filtered = {};
    StitchRepository.getDefinitionsPerCategory().forEach((key, value) {
      if (value.any((sd) => sd.passesFilter(filter))) {
        filtered[key] = value.where((sd) => sd.passesFilter(filter)).toList();
      }
    });
    return filtered;
  }

  String createStitchSet(String name, List<StitchDefinition> stitches) {
    String id = StitchRepository.createStitchSet(name, stitches);
    notifyListeners();
    return id;
  }

  void renameStitchSet(String id, String newName) {
    StitchRepository.renameStitchSet(id, newName);
    notifyListeners();
  }

  Future<void> exportStitchesSet(StitchSet stitchSet) async {
    await _repository.exportStitchesSet(stitchSet);
  }

  Future<String?> importStitchesSet() async {
    StitchSet? importedSet = await _repository.importStitchesSet();

    if (importedSet != null) {
      if (!StitchRepository.hasStitchSet(importedSet.id)) {
        StitchRepository.addStitchSet(importedSet);
        notifyListeners();
      }
      return importedSet.id;
    }
    return null;
  }

  void restoreBasicStitchSet() {
    StitchRepository.restoreBasicStitchSet();
    notifyListeners();
  }

  void deleteStitchSet(String id) {
    StitchRepository.deleteStitchSet(id);
    notifyListeners();
  }

  bool isStitchUsedInPattern(StitchDefinition definition) =>
    _model.knittingPattern.isStitchUsedInPattern(definition);

  bool isColourUsedInPattern(NamedColour colour) =>
    _model.knittingPattern.isColourUsedInPattern(colour);

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

  void setStitch(int row, int column, StitchDefinition stitchDefinition, {bool storeForUndo = true, bool emitNotification = true}) {
    // Do nothing if there isn't enough room
    if (stitchDefinition.columns + column > _model.knittingPattern.patternSettings.columns) {
      return;
    }

    // Calculate the cells that will be affected
    List<StitchCell> newStitchCells = [];
    for (int columnOffset = 0; columnOffset < stitchDefinition.columns; columnOffset++) {
      newStitchCells.add(
        stitchAt(column + columnOffset, row).copyWith(
          stitchDefinitionId: stitchDefinition.id, stitchDefinitionColumn: columnOffset));
    }

    // Calculate which cell need to be cleared
    List<StitchCell> clearedCells = [];
    for (StitchCell newCell in newStitchCells) {
      // If the cell under the new stitch is a multi-column stitch, it will be broken
      StitchCell oldCell = stitchAt(newCell.column, newCell.row);
      StitchDefinition oldDef = StitchRepository.getStitchDefinitionById(oldCell.stitchDefinitionId);
      if (oldDef.columns > 1) {
        // Clear the broken cells
        int oldCellStart = oldCell.column - (oldCell.stitchDefinitionColumn);
        for (int clearIdx = 0; clearIdx < oldDef.columns; clearIdx++) {
          // don't clear if this is already a new cell
          if (!newStitchCells.any((c) => c.row == oldCell.row && c.column == oldCellStart + clearIdx)) {
            clearedCells.add(
              StitchCell(
                row: oldCell.row, 
                column: oldCellStart + clearIdx, 
                stitchDefinitionId: BasicStitchesSet.noStitchId, 
                colour: oldCell.colour));
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
          newStitchCells.firstWhere((ns) => stitch.row == ns.row && stitch.column == ns.column, orElse: () => stitch),
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
        setStitch(address.row, address.column, stitchDefinition, storeForUndo: false, emitNotification: false);
      }
    } else {
      // We check for spots row by row
      for (int row = 0; row < _model.knittingPattern.patternSettings.rows; row++) {
        List<CellAddress> addressesOnRow = selection.addressesOnRow(row);
        if (addressesOnRow.isEmpty) {
          continue;
        }
        // Sort per column to go left to right
        addressesOnRow.sort();
        List<CellAddress> visited = [];
        for (CellAddress address in addressesOnRow) {
          if (visited.contains(address)) {
            continue;
          }
          visited.add(address);

          // If there is room, place the stitch, then keep going in this row 
          List<CellAddress> needed = List.generate(stitchDefinition.columns - 1, (idx) => CellAddress(column: address.column + idx + 1, row: row));
          if (selection.selectedCells.containsAll(needed)) {
            setStitch(row, address.column, stitchDefinition, storeForUndo: false, emitNotification: false);
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
            stitch.copyWith(colour: colour) : stitch
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
      StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns > 1 && 
      beforeColumn > stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      beforeColumn < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns
    ).toList();

    // Clear these broken stitches
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 1) : stitch
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
          stitchDefinitionId: BasicStitchesSet.noStitch.id, 
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
            stitchDefinitionId: BasicStitchesSet.noStitch.id, 
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
      StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns > 1 && 
      column >= stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      column < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns
    ).toList();

    // Clear these broken stitches
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        stitches: _model.knittingPattern.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 1) : stitch
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

  void toggleStitchDefinition(StitchDefinition stitchDefinition) {
    if (!_model.knittingPattern.isStitchUsedInPattern(stitchDefinition)) {
      return;
    }

    bool selectionContainsStitch = false;
    Set<CellAddress> affectedAddresses = {};

    for (StitchCell cell in _model.knittingPattern.stitches) {
      if (cell.stitchDefinitionId == stitchDefinition.id) {
        CellAddress address = CellAddress(column: cell.column, row: cell.row);
        affectedAddresses.add(address);
        if (selection.selectedCells.contains(address)) {
          selectionContainsStitch = true;
        }
      }
    }

    Set<CellAddress> newAddresses = Set.from(selection.selectedCells);
    if (selectionContainsStitch) {
      // Remove them from the selection
      newAddresses.removeAll(affectedAddresses);
    } else {
      // Add them to the selection
      newAddresses.addAll(affectedAddresses);
    }

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.copyWith(
          selectedCells: newAddresses
        )
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleColour(NamedColour colour) {
    if (!_model.knittingPattern.isColourUsedInPattern(colour)) {
      return;
    }

    bool selectionContainsColour = false;
    Set<CellAddress> affectedAddresses = {};

    for (StitchCell cell in _model.knittingPattern.stitches) {
      if (cell.colour == colour) {
        CellAddress address = CellAddress(column: cell.column, row: cell.row);
        affectedAddresses.add(address);
        if (selection.selectedCells.contains(address)) {
          selectionContainsColour = true;
        }
      }
    }

    Set<CellAddress> newAddresses = Set.from(selection.selectedCells);
    if (selectionContainsColour) {
      // Remove them from the selection
      newAddresses.removeAll(affectedAddresses);
    } else {
      // Add them to the selection
      newAddresses.addAll(affectedAddresses);
    }

    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.copyWith(
        selection: _model.knittingPattern.selection.copyWith(
          selectedCells: newAddresses
        )
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

  StitchDefinition addStitch({required String category, required String stitchSetId}) {
    StitchDefinition sd = StitchDefinition(
      id: const UuidV4Gen().get(), 
      name: '', abbreviation: '', 
      symbols: const [KnittingSymbol(name: '', parts: [KnittingSymbolParts.blankPart])], 
      category: category,
    );

    StitchRepository.addStitchToSet(sd, stitchSetId);

    notifyListeners();

    return sd;
  }

  void updateStitchDefinition({
    required StitchDefinition olddef,
    required StitchDefinition newdef}
  ) {
    StitchRepository.updateStitchDefinition(olddef, newdef);

    // the custom stitches are not part of the knittingpattern, so no undo here
    notifyListeners();
  } 

  void deleteStitch(StitchDefinition stitchDefinition) {
    StitchRepository.deleteStitchDefinition(stitchDefinition);

    notifyListeners();
  }

  void moveStitchToSet({
    required StitchDefinition stitchDefinition, 
    required String sourceSetId,
    required String targetSetId}) {
    StitchRepository.moveStitchToSet(stitchDefinition, sourceSetId, targetSetId);

    notifyListeners();
  }

  void addStitchToSet({required StitchSet targetStitchSet, required StitchDefinition stitchDefinition}) {
    StitchRepository.addStitchToSet(stitchDefinition, targetStitchSet.id);
    notifyListeners();
  }

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
      knittingPattern: _model.knittingPattern.pruneUnusedStitches()
    );
    
    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedColours() {
    _model = _model.copyWith(
      knittingPattern: _model.knittingPattern.pruneUnusedColours()
    );

    _storeForUndo();
    notifyListeners();
  }

}


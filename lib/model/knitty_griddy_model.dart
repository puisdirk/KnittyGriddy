
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/charts_save_model.dart';
import 'package:knitty_griddy/model/named_colour.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_parts.dart';
import 'package:knitty_griddy/model/chart_info.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/model/app_state.dart';
import 'package:knitty_griddy/model/charts_model.dart';
import 'package:knitty_griddy/model/knitting_chart.dart';
import 'package:knitty_griddy/model/chart_settings.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/model/undo_redo_manager.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class KnittyGriddyModel extends ChangeNotifier {

  final ModelRepository _repository;

  // The immutable models being accessed throughout the app
  ChartsModel _chartsModel;
  
  final UndoRedoManager<KnittingChart> _undoRedoManager;

  ChartsSaveModel? _lastSaved;

  Future<void> autoSave() async {
    if (_lastSaved == null) {
      _lastSaved = ChartsSaveModel(
        knittingChart: _chartsModel.knittingChart, 
        chartInfos: _chartsModel.chartInfos, 
        stitchSets: List.from(StitchRepository.instance.sets),
      );
      return;
    }

    final ChartsSaveModel oldModel = _lastSaved!.copyWith();
    _lastSaved = _lastSaved!.copyWith(
      griddyModel: _chartsModel,
      stitchSets: List.from(StitchRepository.instance.sets),
    );

    if (oldModel.chartInfos != _lastSaved!.chartInfos) {
      await _repository.saveChartInfos(_lastSaved!.chartInfos);
    }

    if (oldModel.stitchSets != _lastSaved!.stitchSets) {
      await _repository.saveStitchSets(_lastSaved!.stitchSets);
    }

    if (oldModel.knittingChart != _lastSaved!.knittingChart) {
      await _repository.saveChart(_lastSaved!.knittingChart);
    }

    if (oldModel.stitchSets != _lastSaved!.stitchSets) {
      await _repository.saveStitchSets(_lastSaved!.stitchSets);
    }
  }

  KnittyGriddyModel({
    required ModelRepository repository,
  }) : 
    _repository = repository, 
    _chartsModel = const ChartsModel(), 
    _undoRedoManager = UndoRedoManager() {
    // Initialize the undo-redo manager
    _storeForUndo();
  }

  void loadOnStartup() {
    _repository.loadChartInfos().then((List<ChartInfo> chartInfos) {
      _chartsModel = _chartsModel.copyWith(
        chartInfos: chartInfos,
      );
      _repository.loadStitchSets().then((List<StitchSet> stitchSets) {
        StitchRepository.loadInitialStitchSets(stitchSets);
        notifyListeners();
      });
    });
  }

  Future<void> saveCurrentChart() async {
    await _repository.saveChart(_chartsModel.knittingChart);
  }

  Future<void> _saveChartInfos() async {
    await _repository.saveChartInfos(_chartsModel.chartInfos);
  }

  Future<void> createNewChart(String name) async {
    final String id = const UuidV4Gen().get();

    _chartsModel = _chartsModel.copyWith(
      chartInfos: List.from(_chartsModel.chartInfos)..add(ChartInfo(id: id, name: name)),
      knittingChart: KnittingChart(id: id, name: name)
    );

    await autoSave();
    notifyListeners();
  }

  Future<void> exportChart() async {
    await _repository.exportChart(_chartsModel.knittingChart);
  }

  Future<void> importChart() async {
    KnittingChart? chart = await _repository.importChart();
    if (chart != null && !chartInfos.any((pi) => pi.id == chart.id)) {
      await _repository.saveChart(chart);
      _chartsModel = _chartsModel.copyWith(
        chartInfos: [..._chartsModel.chartInfos, ChartInfo(id: chart.id, name: chart.name, description: chart.description)],
      );
      _saveChartInfos();
      notifyListeners();
    }
  }

  void deleteChart(String chartId) {
    _chartsModel = _chartsModel.copyWith(
      chartInfos: _chartsModel.chartInfos.where((pi) => pi.id != chartId).toList()
    );

    _repository.deleteChart(chartId);
    _saveChartInfos();
    notifyListeners();
  }

  Future<void> loadChart(String chartId) async {
    KnittingChart chart = await _repository.loadChart(chartId);
    // Import unknown stitches
    for (StitchDefinition def in chart.usedStitches) {
      if (!StitchRepository.hasStitch(def)) {
        StitchDefinition? sameStitchContent = StitchRepository.getStitchDefinitionByContent(def);
        if (sameStitchContent != null) {
          // We have a stitchdefinition in the repo that is the same except for the id. So use that
          chart = chart.copyWith(
            usedStitches: chart.usedStitches.map((us) => us != def ? def : sameStitchContent).toList(),
            stitches: chart.stitches.map((sc) => sc.stitchDefinitionId != def.id ? sc : sc.copyWith(stitchDefinitionId: sameStitchContent.id)).toList()
          );
        } else {
          StitchRepository.addStitchToImportedSet(def);
        }
      }
    }
    _chartsModel = _chartsModel.copyWith(
      knittingChart: chart,
    );
    notifyListeners();
  }

  void setChartName(String name) {
    _chartsModel = _chartsModel.copyWith(
      chartInfos: _chartsModel.chartInfos.map((pi) =>
        pi.id != _chartsModel.knittingChart.id ? pi :
        pi.copyWith(name: name)
      ).toList(),
      knittingChart: _chartsModel.knittingChart.copyWith(name: name)
    );

    _storeForUndo();
    notifyListeners();
  }

  void setChartDescription(String description) {
    _chartsModel = _chartsModel.copyWith(
      chartInfos: _chartsModel.chartInfos.map((pi) =>
        pi.id != _chartsModel.knittingChart.id ? pi :
        pi.copyWith(description: description)
      ).toList(),
      knittingChart: _chartsModel.knittingChart.copyWith(description: description)
    );

    _storeForUndo();
    notifyListeners();
  }
 
  void _storeForUndo() {
    _undoRedoManager.store(_chartsModel.knittingChart.copyWith());
  }

  bool get canUndo => _undoRedoManager.canUndo();
  bool get canRedo => _undoRedoManager.canRedo();

  void undo() {
    if (_undoRedoManager.canUndo()) {
      _chartsModel = _chartsModel.copyWith(knittingChart: _undoRedoManager.undo());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoRedoManager.canRedo()) {
      _chartsModel = _chartsModel.copyWith(knittingChart: _undoRedoManager.redo());
      notifyListeners();
    }
  }

  List<ChartInfo> get chartInfos => _chartsModel.chartInfos;
  ChartSettings get settings => _chartsModel.knittingChart.chartSettings;
  StitchCell stitchCell(int row, int column) => _chartsModel.knittingChart.stitchCell(row, column);
  List<StitchCell> get stitches => _chartsModel.knittingChart.stitches;
  StitchCell stitchAt(int column, int row) => _chartsModel.knittingChart.stitches.firstWhere((cell) => cell.column == column && cell.row == row);
  List<StitchDefinition> get usedStitches => _chartsModel.knittingChart.usedStitches;
  List<NamedColour> get usedColours => _chartsModel.knittingChart.usedColours;
  Selection get selection => _chartsModel.knittingChart.selection;
  Set<CellAddress> get outline => _chartsModel.knittingChart.outline;
  KnittingChart get knittingChart => _chartsModel.knittingChart;
  AppState get appState => _chartsModel.appState;

  List<StitchSet> filteredStitchSets(String filter) {
    return StitchRepository.filteredStitchSets(filter);
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

  bool isStitchUsedInChart(StitchDefinition definition) =>
    _chartsModel.knittingChart.isStitchUsedInChart(definition);

  bool isColourUsedInChart(NamedColour colour) =>
    _chartsModel.knittingChart.isColourUsedInChart(colour);

  void appUseStitch(StitchDefinition stitchDefinition) {
    _chartsModel = _chartsModel.copyWith(
      appState: _chartsModel.appState.setSelectedStitchDefinition(stitchDefinition: stitchDefinition)
    );
    notifyListeners();
  }
  void appUseColour(NamedColour colour) {
    _chartsModel = _chartsModel.copyWith(
      appState: _chartsModel.appState.setSelectedColour(colour: colour)
    );
    notifyListeners();
  }
  void setMouseOption(MouseOption option) {
    _chartsModel = _chartsModel.copyWith(
      appState: _chartsModel.appState.setSelectedMouseOption(mouseOption: option)
    );
    notifyListeners();
  }

  void useGridType(GridType newGridType){
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        chartSettings: _chartsModel.knittingChart.chartSettings.copyWith(
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
    if (stitchDefinition.columns + column > _chartsModel.knittingChart.chartSettings.columns) {
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

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
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
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
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
      for (int row = 0; row < _chartsModel.knittingChart.chartSettings.rows; row++) {
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
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
          _chartsModel.knittingChart.selection.isSelected(stitch.column, stitch.row) ?
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
    List<StitchCell> brokenStitches = _chartsModel.knittingChart.stitches.where((stitch) =>
      StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns > 1 && 
      beforeColumn > stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      beforeColumn < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns
    ).toList();

    // Clear these broken stitches
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 1) : stitch
        ).toList()
      )
    );

    // Move the columns after the insertion point to the right and clear the selection
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        chartSettings: _chartsModel.knittingChart.chartSettings.copyWith(
          columns: _chartsModel.knittingChart.chartSettings.columns + 1,
        ),
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
          stitch.column < beforeColumn ? 
            stitch : 
            stitch.copyWith(column: stitch.column + 1)
        ).toList(),
        selection: emptySelection
      )
    );

    // Create the new column of cells
    List<StitchCell> newStitches = List.from(_chartsModel.knittingChart.stitches);
    newStitches.addAll(List<StitchCell>.generate(
      _chartsModel.knittingChart.chartSettings.rows,
      (idx) =>
        StitchCell(
          row: idx, 
          column: beforeColumn, 
          stitchDefinitionId: BasicStitchesSet.noStitch.id, 
          colour: _chartsModel.knittingChart.mainColour
        )
    ));

    _chartsModel = _chartsModel.copyWith(knittingChart: _chartsModel.knittingChart.copyWith(stitches: newStitches));

    _storeForUndo();
    notifyListeners();
  }

  void insertRow(int beforeRow) {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        chartSettings: _chartsModel.knittingChart.chartSettings.copyWith(
          rows: _chartsModel.knittingChart.chartSettings.rows + 1
        ),
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
          stitch.row < beforeRow ? stitch : stitch.copyWith(
            row: stitch.row + 1
          )
        ).toList(),
        selection: emptySelection
      )
    );

    List<StitchCell> newStitches = List.from(_chartsModel.knittingChart.stitches);
    newStitches.addAll(
      List<StitchCell>.generate(
        _chartsModel.knittingChart.chartSettings.columns, 
        (idx) => 
          StitchCell(
            row: beforeRow, 
            column: idx, 
            stitchDefinitionId: BasicStitchesSet.noStitch.id, 
            colour: _chartsModel.knittingChart.mainColour
          )
      )
    );

    _chartsModel = _chartsModel.copyWith(knittingChart: _chartsModel.knittingChart.copyWith(stitches: newStitches));

    _storeForUndo();
    notifyListeners();
  }

  void deleteColumn(int column) {
    // Find multi-column stitches that will get broken
    List<StitchCell> brokenStitches = _chartsModel.knittingChart.stitches.where((stitch) =>
      StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns > 1 && 
      column >= stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      column < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns
    ).toList();

    // Clear these broken stitches
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 1) : stitch
        ).toList()
      )
    );

    // Remove the column stitches
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.where((stitch) => stitch.column != column).toList()
      )
    );

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        chartSettings: _chartsModel.knittingChart.chartSettings.copyWith(
          columns: _chartsModel.knittingChart.chartSettings.columns - 1,
        ),
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
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
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        stitches: _chartsModel.knittingChart.stitches.where((stitch) => stitch.row != row).toList()
      )
    );

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        chartSettings: _chartsModel.knittingChart.chartSettings.copyWith(
          rows: _chartsModel.knittingChart.chartSettings.rows - 1
        ),
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
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
    if (_chartsModel.knittingChart.selection.isEmpty) {
      return;
    }

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: emptySelection
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void selectAll() {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: selection.selectAll(
          _chartsModel.knittingChart.chartSettings.columns, 
          _chartsModel.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleStitchDefinition(StitchDefinition stitchDefinition) {
    if (!_chartsModel.knittingChart.isStitchUsedInChart(stitchDefinition)) {
      return;
    }

    bool selectionContainsStitch = false;
    Set<CellAddress> affectedAddresses = {};

    for (StitchCell cell in _chartsModel.knittingChart.stitches) {
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

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.copyWith(
          selectedCells: newAddresses
        )
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleColour(NamedColour colour) {
    if (!_chartsModel.knittingChart.isColourUsedInChart(colour)) {
      return;
    }

    bool selectionContainsColour = false;
    Set<CellAddress> affectedAddresses = {};

    for (StitchCell cell in _chartsModel.knittingChart.stitches) {
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

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.copyWith(
          selectedCells: newAddresses
        )
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void invertSelection() {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.invert(_chartsModel.knittingChart.chartSettings.columns, _chartsModel.knittingChart.chartSettings.rows)
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

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        outline: newOutline
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleCell(int column, int row) {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleCell(column, row)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleRow(int row) {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleRows(
          [row], 
          _chartsModel.knittingChart.chartSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleColumn(int column) {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleColumns(
          [column], 
          _chartsModel.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleOddRows() {
    List<int> rows = [];
    for (int row = 1; row < _chartsModel.knittingChart.chartSettings.rows; row += 2) {
      rows.add(row);
    }
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleRows(
          rows, _chartsModel.knittingChart.chartSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleEvenRows() {
    List<int> rows = [];
    for (int row = 0; row < _chartsModel.knittingChart.chartSettings.rows; row += 2) {
      rows.add(row);
    }
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleRows(
          rows, _chartsModel.knittingChart.chartSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleOddColumns() {
    List<int> columns = [];
    for (int col = 1; col < _chartsModel.knittingChart.chartSettings.columns; col += 2) {
      columns.add(col);
    }
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleColumns(
          columns, _chartsModel.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleEvenColumns() {
    List<int> columns = [];
    for (int col = 0; col < _chartsModel.knittingChart.chartSettings.columns; col += 2) {
      columns.add(col);
    }
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        selection: _chartsModel.knittingChart.selection.toggleColumns(
          columns, _chartsModel.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

// ************************ Edit or create colours *******************************************

  void setNamedColour(NamedColour colour, Color newColor, String newName) {

    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        usedColours: _chartsModel.knittingChart.usedColours.map((col) =>
          col.name != colour.name ? col : col.copyWith(
            name: newName,
            color: newColor
          )
        ).toList(),
        stitches: _chartsModel.knittingChart.stitches.map((stitch) =>
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
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.copyWith(
        usedColours: [..._chartsModel.knittingChart.usedColours, NamedColour(name: newName, color: newColor)]
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

    // the custom stitches are not part of the knittingchart, so no undo here
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
    final bool wantToRemove = _chartsModel.knittingChart.usedStitches.contains(definition);
    
    if (wantToRemove) {
      // Guard against removing definitions in use on the chart
      if (isStitchUsedInChart(definition)) {
        return;
      }

      _chartsModel = _chartsModel.copyWith(
        knittingChart: _chartsModel.knittingChart.copyWith(
          usedStitches: _chartsModel.knittingChart.usedStitches.where((s) => s != definition).toList()
        )
      );
    } else {
      _chartsModel = _chartsModel.copyWith(
        knittingChart: _chartsModel.knittingChart.copyWith(
          usedStitches: [..._chartsModel.knittingChart.usedStitches, definition]
        )
      );
    }

    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedStitches() {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.pruneUnusedStitches()
    );
    
    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedColours() {
    _chartsModel = _chartsModel.copyWith(
      knittingChart: _chartsModel.knittingChart.pruneUnusedColours()
    );

    _storeForUndo();
    notifyListeners();
  }

}



import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/charts/model/charts_save_model_object.dart';
import 'package:knitty_griddy/charts/model/named_colour.dart';
import 'package:knitty_griddy/charts/model/cell_address.dart';
import 'package:knitty_griddy/charts/model/knitting_symbol.dart';
import 'package:knitty_griddy/charts/model/knitting_symbol_parts.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/selection.dart';
import 'package:knitty_griddy/charts/model/app_state.dart';
import 'package:knitty_griddy/charts/model/charts_model_object.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/charts/model/chart_settings.dart';
import 'package:knitty_griddy/charts/model/stitch_cell.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_repository.dart';
import 'package:knitty_griddy/charts/storage/charts_model_repository.dart';

class ChartsModel extends ChangeNotifier {

  final ChartsModelRepository _repository;

  // The immutable models being accessed throughout the app
  ChartsModelObject _chartsModelObject;
  
  final UndoRedoManager<KnittingChart> _undoRedoManager;

  ChartsSaveModelObject? _lastSaved;

  ChartsModel({
    required ChartsModelRepository repository,
  }) : 
    _repository = repository, 
    _chartsModelObject = const ChartsModelObject(), 
    _undoRedoManager = UndoRedoManager() {
    // Initialize the undo-redo manager
    _storeForUndo();
  }

  void clearUndoRedo() {
    _undoRedoManager.clear();
  }

  void loadOnStartup() {
    _repository.loadChartInfos().then((List<ChartInfo> chartInfos) {
      _chartsModelObject = _chartsModelObject.copyWith(
        chartInfos: chartInfos,
      );
      _repository.loadStitchSets().then((List<StitchSet> stitchSets) {
        StitchRepository.loadInitialStitchSets(stitchSets);
        notifyListeners();
      });
    });
  }

  Future<void> autoSave() async {
    if (_lastSaved == null) {
      _lastSaved = ChartsSaveModelObject(
        knittingChart: _chartsModelObject.knittingChart, 
        chartInfos: _chartsModelObject.chartInfos, 
        stitchSets: List.from(StitchRepository.instance.sets),
      );
      return;
    }

    final ChartsSaveModelObject oldModel = _lastSaved!.copyWith();
    _lastSaved = _lastSaved!.copyWith(
      griddyModel: _chartsModelObject,
      stitchSets: List.from(StitchRepository.instance.sets),
    );

    if (!listEquals(oldModel.chartInfos, _lastSaved!.chartInfos)) {
      await _repository.saveChartInfos(_lastSaved!.chartInfos);
    }

    if (!listEquals(oldModel.stitchSets, _lastSaved!.stitchSets)) {
      await _repository.saveStitchSets(_lastSaved!.stitchSets);
    }

    if (oldModel.knittingChart != _lastSaved!.knittingChart) {
      await _repository.saveChart(_lastSaved!.knittingChart);
      _chartsModelObject = _chartsModelObject.copyWith(
        chartInfos: _chartsModelObject.chartInfos.map((ci) => 
          ci.id != _chartsModelObject.knittingChart.id ? ci : ci.copyWith(
            contentHashCode: _chartsModelObject.knittingChart.contentHashCode
          )
        ).toList()
      );
      await _saveChartInfos();
    }
  }

  Future<void> saveCurrentChart() async {
    await _repository.saveChart(_chartsModelObject.knittingChart);
    _chartsModelObject = _chartsModelObject.copyWith(
      chartInfos: _chartsModelObject.chartInfos.map((ci) => 
        ci.id != _chartsModelObject.knittingChart.id ? ci : ci.copyWith(
          contentHashCode: _chartsModelObject.knittingChart.contentHashCode
        )
      ).toList()
    );
    await _saveChartInfos();
  }

  Future<void> _saveChartInfos() async {
    await _repository.saveChartInfos(_chartsModelObject.chartInfos);
  }

  Future<void> createNewChart(String name) async {
    final String id = const UuidV4Gen().get();

    KnittingChart chart = KnittingChart(id: id, name: name);

    _chartsModelObject = _chartsModelObject.copyWith(
      chartInfos: List.from(_chartsModelObject.chartInfos)..add(
        ChartInfo(id: id, name: name, contentHashCode: chart.contentHashCode)),
      knittingChart: chart,
    );

    await autoSave();
    _storeForUndo();
    notifyListeners();
  }

  Future<void> exportChart() async {
    await _repository.exportChart(_chartsModelObject.knittingChart);
  }

  Future<void> importChart() async {
    KnittingChart? chart = await _repository.importChart();
    if (chart != null && !chartInfos.any((pi) => pi.id == chart.id)) {
      await _repository.saveChart(chart);
      _chartsModelObject = _chartsModelObject.copyWith(
        chartInfos: [..._chartsModelObject.chartInfos, ChartInfo(
          id: chart.id, 
          name: chart.name, 
          description: chart.description,
          contentHashCode: chart.contentHashCode,
        )],
      );
      _saveChartInfos();
      notifyListeners();
    }
  }

  void deleteChart(String chartId) {
    _chartsModelObject = _chartsModelObject.copyWith(
      chartInfos: _chartsModelObject.chartInfos.where((pi) => pi.id != chartId).toList()
    );

    _repository.deleteChart(chartId);
    _saveChartInfos();
    notifyListeners();
  }

  bool _stitchBrokenOverEdge(KnittingChart chart, StitchCell cell) {
    StitchDefinition stitchDef = StitchRepository.getStitchDefinitionById(cell.stitchDefinitionId);
    if (stitchDef.columns < 2) return false;

    if (cell.column - cell.stitchDefinitionColumn + stitchDef.columns - 1 >= chart.chartSettings.columns) {
      return true;
    }

    return false;
  }

  Future<void> updateChart(KnittingChart newChart) async {
    KnittingChart healedChart = newChart;
    if (newChart.chartSettings.columns < _chartsModelObject.knittingChart.chartSettings.columns) {
      List<StitchCell> brokenStitches = [];
        brokenStitches.addAll(newChart.stitches.where((stitch) => _stitchBrokenOverEdge(healedChart, stitch)
      ).toList());
      // Clear these broken stitches
      healedChart = healedChart.copyWith(
        stitches: healedChart.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 0) : stitch
        ).toList()
      );
    }

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: healedChart,
      chartInfos: _chartsModelObject.chartInfos.map((ci) => ci.id != healedChart.id ? ci : ci.copyWith(
        name: healedChart.name,
        description: healedChart.description,
        contentHashCode: healedChart.contentHashCode,
      )).toList()
    );

    _storeForUndo();
    await _saveChartInfos();
    await saveCurrentChart();
    notifyListeners();
  }

  Future<KnittingChart> getChart(ChartInfo chartInfo) async {
    KnittingChart chart = await _repository.loadChart(chartInfo.id);
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
    return chart;
  }

  bool hasChart(KnittingChart chart) {
    return chartInfos.any((ci) => 
      ci.id == chart.id && 
      ci.name == chart.name && 
      ci.description == chart.description &&
      ci.contentHashCode == chart.contentHashCode
    );
  }

  bool hasChartWithId(String id) {
    return chartInfos.any((ci) => ci.id == id);
  }

  Future<KnittingChart?> getSimilarChart(KnittingChart original) async {
    List<ChartInfo> candidates = _chartsModelObject.chartInfos.where((ci) => ci.contentHashCode == original.contentHashCode).toList();
    if (candidates.isNotEmpty) {
      return await getChart(candidates.first);
    }
    return null;
  }

  Future<KnittingChart> saveChartAndAux(KnittingChart chart) async {
    
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

    await _repository.saveChart(chart);
    
    _chartsModelObject = _chartsModelObject.copyWith(
      chartInfos: [..._chartsModelObject.chartInfos, 
        ChartInfo(
          id: chart.id, 
          name: chart.name, 
          description: chart.description,
          contentHashCode: chart.contentHashCode,
        )
      ]
    );

    _saveChartInfos();
    notifyListeners();

    return chart;
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
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: chart,
    );

    _storeForUndo();
    notifyListeners();
  }

  void setChartName(String name) {
    _chartsModelObject = _chartsModelObject.copyWith(
      chartInfos: _chartsModelObject.chartInfos.map((pi) =>
        pi.id != _chartsModelObject.knittingChart.id ? pi :
        pi.copyWith(name: name)
      ).toList(),
      knittingChart: _chartsModelObject.knittingChart.copyWith(name: name)
    );

    _storeForUndo();
    notifyListeners();
  }

  void setChartDescription(String description) {
    _chartsModelObject = _chartsModelObject.copyWith(
      chartInfos: _chartsModelObject.chartInfos.map((pi) =>
        pi.id != _chartsModelObject.knittingChart.id ? pi :
        pi.copyWith(description: description)
      ).toList(),
      knittingChart: _chartsModelObject.knittingChart.copyWith(description: description)
    );

    _storeForUndo();
    notifyListeners();
  }
 
  void _storeForUndo() {
    if (_chartsModelObject.knittingChart != placeholderChart) {
      _undoRedoManager.store(_chartsModelObject.knittingChart.copyWith());
    }
  }

  bool get canUndo => _undoRedoManager.canUndo();
  bool get canRedo => _undoRedoManager.canRedo();

  void undo() {
    if (_undoRedoManager.canUndo()) {
      _chartsModelObject = _chartsModelObject.copyWith(knittingChart: _undoRedoManager.undo());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoRedoManager.canRedo()) {
      _chartsModelObject = _chartsModelObject.copyWith(knittingChart: _undoRedoManager.redo());
      notifyListeners();
    }
  }

  List<ChartInfo> get chartInfos => _chartsModelObject.chartInfos;
  ChartSettings get settings => _chartsModelObject.knittingChart.chartSettings;
  StitchCell stitchCell(int row, int column) => _chartsModelObject.knittingChart.stitchCell(row, column);
  List<StitchCell> get stitches => _chartsModelObject.knittingChart.stitches;
  StitchCell stitchAt(int column, int row) => _chartsModelObject.knittingChart.stitches.firstWhere((cell) => cell.column == column && cell.row == row);
  List<StitchDefinition> get usedStitches => _chartsModelObject.knittingChart.usedStitches;
  List<NamedColour> get usedColours => _chartsModelObject.knittingChart.usedColours;
  Selection get selection => _chartsModelObject.knittingChart.selection;
  Set<CellAddress> get outline => _chartsModelObject.knittingChart.outline;
  KnittingChart get knittingChart => _chartsModelObject.knittingChart;
  AppState get appState => _chartsModelObject.appState;

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
    _chartsModelObject.knittingChart.isStitchUsedInChart(definition);

  bool isColourUsedInChart(NamedColour colour) =>
    _chartsModelObject.knittingChart.isColourUsedInChart(colour);

  void appUseStitch(StitchDefinition stitchDefinition) {
    _chartsModelObject = _chartsModelObject.copyWith(
      appState: _chartsModelObject.appState.setSelectedStitchDefinition(stitchDefinition: stitchDefinition)
    );
    notifyListeners();
  }
  void appUseColour(NamedColour colour) {
    _chartsModelObject = _chartsModelObject.copyWith(
      appState: _chartsModelObject.appState.setSelectedColour(colour: colour)
    );
    notifyListeners();
  }
  void setMouseOption(MouseOption option) {
    _chartsModelObject = _chartsModelObject.copyWith(
      appState: _chartsModelObject.appState.setSelectedMouseOption(mouseOption: option)
    );
    notifyListeners();
  }

  void useGridType(GridType newGridType){
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        chartSettings: _chartsModelObject.knittingChart.chartSettings.copyWith(
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
    if (stitchDefinition.columns + column > _chartsModelObject.knittingChart.chartSettings.columns) {
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

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
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
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
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
      for (int row = 0; row < _chartsModelObject.knittingChart.chartSettings.rows; row++) {
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
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
          _chartsModelObject.knittingChart.selection.isSelected(stitch.column, stitch.row) ?
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
    List<StitchCell> brokenStitches = _chartsModelObject.knittingChart.stitches.where((stitch) =>
      StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns > 1 && 
      beforeColumn > stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      beforeColumn < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns
    ).toList();

    // Clear these broken stitches
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 0) : stitch
//            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 1) : stitch
        ).toList()
      )
    );

    // Move the columns after the insertion point to the right and clear the selection
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        chartSettings: _chartsModelObject.knittingChart.chartSettings.copyWith(
          columns: _chartsModelObject.knittingChart.chartSettings.columns + 1,
        ),
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
          stitch.column < beforeColumn ? 
            stitch : 
            stitch.copyWith(column: stitch.column + 1)
        ).toList(),
        selection: emptySelection
      )
    );

    // Create the new column of cells
    List<StitchCell> newStitches = List.from(_chartsModelObject.knittingChart.stitches);
    newStitches.addAll(List<StitchCell>.generate(
      _chartsModelObject.knittingChart.chartSettings.rows,
      (idx) =>
        StitchCell(
          row: idx, 
          column: beforeColumn, 
          stitchDefinitionId: BasicStitchesSet.noStitch.id, 
          colour: _chartsModelObject.knittingChart.mainColour
        )
    ));

    _chartsModelObject = _chartsModelObject.copyWith(knittingChart: _chartsModelObject.knittingChart.copyWith(stitches: newStitches));

    _storeForUndo();
    notifyListeners();
  }

  void insertRow(int beforeRow) {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        chartSettings: _chartsModelObject.knittingChart.chartSettings.copyWith(
          rows: _chartsModelObject.knittingChart.chartSettings.rows + 1
        ),
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
          stitch.row < beforeRow ? stitch : stitch.copyWith(
            row: stitch.row + 1
          )
        ).toList(),
        selection: emptySelection
      )
    );

    List<StitchCell> newStitches = List.from(_chartsModelObject.knittingChart.stitches);
    newStitches.addAll(
      List<StitchCell>.generate(
        _chartsModelObject.knittingChart.chartSettings.columns, 
        (idx) => 
          StitchCell(
            row: beforeRow, 
            column: idx, 
            stitchDefinitionId: BasicStitchesSet.noStitch.id, 
            colour: _chartsModelObject.knittingChart.mainColour
          )
      )
    );

    _chartsModelObject = _chartsModelObject.copyWith(knittingChart: _chartsModelObject.knittingChart.copyWith(stitches: newStitches));

    _storeForUndo();
    notifyListeners();
  }

  void deleteColumn(int column) {
    // Find multi-column stitches that will get broken
    List<StitchCell> brokenStitches = _chartsModelObject.knittingChart.stitches.where((stitch) =>
      StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns > 1 && 
      column >= stitch.column - (stitch.stitchDefinitionColumn - 1) && 
      column < (stitch.column - (stitch.stitchDefinitionColumn - 1)) + StitchRepository.getStitchDefinitionById(stitch.stitchDefinitionId).columns
    ).toList();

    // Clear these broken stitches
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) => 
          brokenStitches.contains(stitch) ? stitch.copyWith(
            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 0) : stitch
//            stitchDefinitionId: BasicStitchesSet.noStitch.id, stitchDefinitionColumn: 1) : stitch
        ).toList()
      )
    );

    // Remove the column stitches
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.where((stitch) => stitch.column != column).toList()
      )
    );

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        chartSettings: _chartsModelObject.knittingChart.chartSettings.copyWith(
          columns: _chartsModelObject.knittingChart.chartSettings.columns - 1,
        ),
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
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
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        stitches: _chartsModelObject.knittingChart.stitches.where((stitch) => stitch.row != row).toList()
      )
    );

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        chartSettings: _chartsModelObject.knittingChart.chartSettings.copyWith(
          rows: _chartsModelObject.knittingChart.chartSettings.rows - 1
        ),
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
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
    if (_chartsModelObject.knittingChart.selection.isEmpty) {
      return;
    }

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: emptySelection
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void selectAll() {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: selection.selectAll(
          _chartsModelObject.knittingChart.chartSettings.columns, 
          _chartsModelObject.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleStitchDefinition(StitchDefinition stitchDefinition) {
    if (!_chartsModelObject.knittingChart.isStitchUsedInChart(stitchDefinition)) {
      return;
    }

    bool selectionContainsStitch = false;
    Set<CellAddress> affectedAddresses = {};

    for (StitchCell cell in _chartsModelObject.knittingChart.stitches) {
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

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.copyWith(
          selectedCells: newAddresses
        )
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleColour(NamedColour colour) {
    if (!_chartsModelObject.knittingChart.isColourUsedInChart(colour)) {
      return;
    }

    bool selectionContainsColour = false;
    Set<CellAddress> affectedAddresses = {};

    for (StitchCell cell in _chartsModelObject.knittingChart.stitches) {
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

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.copyWith(
          selectedCells: newAddresses
        )
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void invertSelection() {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.invert(_chartsModelObject.knittingChart.chartSettings.columns, _chartsModelObject.knittingChart.chartSettings.rows)
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

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        outline: newOutline
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleCell(int column, int row) {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleCell(column, row)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleRow(int row) {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleRows(
          [row], 
          _chartsModelObject.knittingChart.chartSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleColumn(int column) {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleColumns(
          [column], 
          _chartsModelObject.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleOddRows() {
    List<int> rows = [];
    for (int row = 1; row < _chartsModelObject.knittingChart.chartSettings.rows; row += 2) {
      rows.add(row);
    }
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleRows(
          rows, _chartsModelObject.knittingChart.chartSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleEvenRows() {
    List<int> rows = [];
    for (int row = 0; row < _chartsModelObject.knittingChart.chartSettings.rows; row += 2) {
      rows.add(row);
    }
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleRows(
          rows, _chartsModelObject.knittingChart.chartSettings.columns)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleOddColumns() {
    List<int> columns = [];
    for (int col = 1; col < _chartsModelObject.knittingChart.chartSettings.columns; col += 2) {
      columns.add(col);
    }
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleColumns(
          columns, _chartsModelObject.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void toggleEvenColumns() {
    List<int> columns = [];
    for (int col = 0; col < _chartsModelObject.knittingChart.chartSettings.columns; col += 2) {
      columns.add(col);
    }
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        selection: _chartsModelObject.knittingChart.selection.toggleColumns(
          columns, _chartsModelObject.knittingChart.chartSettings.rows)
      )
    );

    _storeForUndo();
    notifyListeners();
  }

// ************************ Edit or create colours *******************************************

  void setNamedColour(NamedColour oldColour, NamedColour newColour) {

    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        usedColours: _chartsModelObject.knittingChart.usedColours.map((col) =>
          col != oldColour ? col : newColour
        ).toList(),
        stitches: _chartsModelObject.knittingChart.stitches.map((stitch) =>
          stitch.colour != oldColour ? stitch : stitch.copyWith(
            colour: newColour
          )
        ).toList()
      )
    );

    _storeForUndo();
    notifyListeners();
  }

  void addNamedColour(NamedColour colour) {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.copyWith(
        usedColours: [..._chartsModelObject.knittingChart.usedColours, colour]
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
    final bool wantToRemove = _chartsModelObject.knittingChart.usedStitches.contains(definition);
    
    if (wantToRemove) {
      // Guard against removing definitions in use on the chart
      if (isStitchUsedInChart(definition)) {
        return;
      }

      _chartsModelObject = _chartsModelObject.copyWith(
        knittingChart: _chartsModelObject.knittingChart.copyWith(
          usedStitches: _chartsModelObject.knittingChart.usedStitches.where((s) => s != definition).toList()
        )
      );
    } else {
      _chartsModelObject = _chartsModelObject.copyWith(
        knittingChart: _chartsModelObject.knittingChart.copyWith(
          usedStitches: [..._chartsModelObject.knittingChart.usedStitches, definition]
        )
      );
    }

    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedStitches() {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.pruneUnusedStitches()
    );
    
    _storeForUndo();
    notifyListeners();
  }

  void pruneUnusedColours() {
    _chartsModelObject = _chartsModelObject.copyWith(
      knittingChart: _chartsModelObject.knittingChart.pruneUnusedColours()
    );

    _storeForUndo();
    notifyListeners();
  }

}


import 'package:flutter/foundation.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';
import 'package:knitty_griddy/patterns/model/patterns_model_object.dart';
import 'package:knitty_griddy/patterns/model/patterns_save_model_object.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';

class PatternsModel extends ChangeNotifier {

  final PatternsModelRepository _repository;

  PatternsModelObject _patternsModelObject;

  PatternsSaveModelObject? _lastSaved;

  final UndoRedoManager<KnittingPattern> _undoRedoManager;

  PatternsModel({
    required PatternsModelRepository repository,
  }) :
    _repository = repository,
    _patternsModelObject = const PatternsModelObject(),
    _undoRedoManager = UndoRedoManager() {
      // Initialize the undo-redo manager
      _storeForUndo();
    }

  void clearUndoRedo() {
    _undoRedoManager.clear();
  }

  void _storeForUndo() {
    if (_patternsModelObject.pattern != placeholderPattern) {
      _undoRedoManager.store(_patternsModelObject.pattern.copyWith());
    }
  }

  bool get canUndo => _undoRedoManager.canUndo();
  bool get canRedo => _undoRedoManager.canRedo();

  void undo() {
    if (_undoRedoManager.canUndo()) {
      _patternsModelObject = _patternsModelObject.copyWith(pattern: _undoRedoManager.undo());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoRedoManager.canRedo()) {
      _patternsModelObject = _patternsModelObject.copyWith(pattern: _undoRedoManager.redo());
      notifyListeners();
    }
  }

  List<KnittingPatternInfo> get patternInfos => _patternsModelObject.patternInfos;
  KnittingPattern get pattern => _patternsModelObject.pattern;

  void loadOnStartup() {
    _repository.loadPatternInfos().then((List<KnittingPatternInfo> patternInfos) {
      _patternsModelObject = _patternsModelObject.copyWith(
        patternInfos: patternInfos,
      );
    });
  }

  Future<void> autoSave() async {
    if (_lastSaved == null) {
      _lastSaved = PatternsSaveModelObject(
        pattern: _patternsModelObject.pattern, 
        patternInfos: _patternsModelObject.patternInfos,
      );
      return;
    }

    final PatternsSaveModelObject oldModel = _lastSaved!.copyWith();
    _lastSaved = _lastSaved!.copyWith(
      pattern: _patternsModelObject.pattern,
      patternInfos: _patternsModelObject.patternInfos,
    );

    if (!listEquals(oldModel.patternInfos, _lastSaved!.patternInfos)) {
      await _repository.savePatternInfos(_lastSaved!.patternInfos);
    }

    if (oldModel.pattern != _lastSaved!.pattern) {
      await _repository.savePattern(_lastSaved!.pattern);
    }
  }

  Future<void> updateKnittingPattern({
    required KnittingPattern oldPattern,
    required KnittingPattern newPattern,
  }) async {
    _patternsModelObject = _patternsModelObject.copyWith(pattern: newPattern);

    if (oldPattern.name != newPattern.name || oldPattern.description != newPattern.description) {
      _patternsModelObject = _patternsModelObject.copyWith(
        patternInfos: _patternsModelObject.patternInfos.map((pi) => pi.id != oldPattern.id ? pi : pi.copyWith(name: newPattern.name, description: newPattern.description)).toList()
      );
      await _savePatternInfos();
    }

    notifyListeners();
  }

  Future<void> savePattern(KnittingPattern pattern) async {
    await _repository.savePattern(pattern);
  }

  Future<void> saveCurrentPattern() async {
    await _repository.savePattern(_patternsModelObject.pattern);

    _patternsModelObject = _patternsModelObject.copyWith(
      patternInfos: patternInfos.map((pi) => pi.id != pattern.id ? pi : pi.copyWith(
        name: _patternsModelObject.pattern.name,
        description: _patternsModelObject.pattern.description,
      )).toList()
    );

    await _savePatternInfos();
  }

  Future<void> _savePatternInfos() async {
    await _repository.savePatternInfos(_patternsModelObject.patternInfos);
  }

  Future<void> duplicatePattern(KnittingPatternInfo originalInfo) async {
    // TODO: replace with a getChart that also load the auxillaries
    KnittingPattern original = await _repository.loadPattern(originalInfo.id);
    
    final String id = const UuidV4Gen().get();

    KnittingPattern newPattern = original.copyWith(
      id: id,
      name: '${original.name} copy',
    );
    savePattern(newPattern);

    _patternsModelObject = _patternsModelObject.copyWith(
      patternInfos: [..._patternsModelObject.patternInfos, KnittingPatternInfo(
        id: id, 
        name: newPattern.name, 
        description: newPattern.description,
      )]
    );

    _savePatternInfos();
    notifyListeners();
  }

  Future<void> createNewPattern(String name) async {
    final String id = const UuidV4Gen().get();

    _patternsModelObject = _patternsModelObject.copyWith(
      pattern: KnittingPattern(id: id, name: name),
      patternInfos: List.from(_patternsModelObject.patternInfos)..add(KnittingPatternInfo(id: id, name: name))
    );

    await autoSave();
    _storeForUndo();
    notifyListeners();
  }

  Future<void> exportPattern() async {
    await _repository.exportPattern(_patternsModelObject.pattern);
  }

  Future<KnittingPattern?> importPattern() async {
    KnittingPattern? patt = await _repository.importPattern();
    if (patt != null && !patternInfos.any((pi) => pi.id == patt.id)) {
      await _repository.savePattern(patt);
      _patternsModelObject = _patternsModelObject.copyWith(
        patternInfos: [..._patternsModelObject.patternInfos, KnittingPatternInfo(id: patt.id, name: patt.name, description: patt.description)]
      );
      _savePatternInfos();
      notifyListeners();
    }
    return patt;
  }

  void deletePattern(String patternId) {
    _patternsModelObject = _patternsModelObject.copyWith(
      patternInfos: _patternsModelObject.patternInfos.where((pi) => pi.id != patternId).toList()
    );

    _repository.deletePattern(patternId);
    _savePatternInfos();
    notifyListeners();
  }

  Future<void> loadPattern(String patternId) async {
    KnittingPattern patt = await _repository.loadPattern(patternId);

    _patternsModelObject = _patternsModelObject.copyWith(
      pattern: patt
    );

    _storeForUndo();
    notifyListeners();
  }

  void setPatternName(String name) {
    _patternsModelObject = _patternsModelObject.copyWith(
      patternInfos: _patternsModelObject.patternInfos.map((pi) =>
        pi.id != _patternsModelObject.pattern.id ? pi :
        pi.copyWith(name: name)
      ).toList(),
      pattern: _patternsModelObject.pattern.copyWith(name: name)
    );

    _storeForUndo();
    notifyListeners();
  }

  void setPatternDescription(String description) {
    _patternsModelObject = _patternsModelObject.copyWith(
      patternInfos: _patternsModelObject.patternInfos.map((pi) =>
        pi.id != _patternsModelObject.pattern.id ? pi :
        pi.copyWith(description: description)
      ).toList(),
      pattern: _patternsModelObject.pattern.copyWith(description: description)
    );

    _storeForUndo();
    notifyListeners();
  }
}
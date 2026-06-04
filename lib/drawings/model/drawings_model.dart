import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/measurement_command.dart';
import 'package:knitty_griddy/drawings/model/commands/variable_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model_object.dart';
import 'package:knitty_griddy/drawings/model/drawings_save_model_object.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';
import 'package:knitty_griddy/utils/undo_redo_manager.dart';

class DrawingsModel extends ChangeNotifier {

  final DrawingsModelRepository _repository;

  DrawingsModelObject _drawingsModelObject;

  final UndoRedoManager<Drawing> _undoRedoManager;

  DrawingsSaveModelObject? _lastSaved;

  DrawingsModel({
    required DrawingsModelRepository repository,
  }) :
    _repository = repository,
    _drawingsModelObject = const DrawingsModelObject(),
    _undoRedoManager = UndoRedoManager() {
      _storeForUndo();
    }

  void clearUndoRedo() {
    _undoRedoManager.clear();
    _storeForUndo();
  }

  void _storeForUndo() {
    _undoRedoManager.store(_drawingsModelObject.drawing.copyWith());
  }

  bool get canUndo => _undoRedoManager.canUndo();
  bool get canRedo => _undoRedoManager.canRedo();

  void undo() {
    if (_undoRedoManager.canUndo()) {
      _drawingsModelObject = _drawingsModelObject.copyWith(drawing: _undoRedoManager.undo());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoRedoManager.canRedo()) {
      _drawingsModelObject = _drawingsModelObject.copyWith(drawing: _undoRedoManager.redo());
      notifyListeners();
    }
  }

  List<DrawingInfo> get drawingInfos => _drawingsModelObject.drawingInfos;
  Drawing get drawing => _drawingsModelObject.drawing;

  void loadOnStartup() {
    _repository.loadDrawingInfos().then((List<DrawingInfo> drawingInfos) {
     _drawingsModelObject =  _drawingsModelObject.copyWith(
      drawingInfos: drawingInfos,
     );
    });
  }

  Future<void> autoSave() async {
    if (_lastSaved == null) {
      _lastSaved = DrawingsSaveModelObject(
        drawing: _drawingsModelObject.drawing,
        drawingInfos: _drawingsModelObject.drawingInfos,
      );
      return;
    }

    final DrawingsSaveModelObject oldModel = _lastSaved!.copyWith();
    _lastSaved = _lastSaved!.copyWith(
      drawing: _drawingsModelObject.drawing,
      drawingInfos: _drawingsModelObject.drawingInfos,
    );

    if (!listEquals(oldModel.drawingInfos, _lastSaved!.drawingInfos)) {
      await _repository.saveDrawingInfos(_lastSaved!.drawingInfos);
    }

    if (oldModel.drawing != _lastSaved!.drawing) {
      await _repository.saveDrawing(_lastSaved!.drawing);
    }
  }

  Future<void> saveCurrentDrawing() async {
    await _repository.saveDrawing(_drawingsModelObject.drawing);
  }

  Future<void> _saveDrawingInfos() async {
    await _repository.saveDrawingInfos(_drawingsModelObject.drawingInfos);
  }

  Future<void> createNewDrawing(String name) async {
    final String id = const UuidV4Gen().get();

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: List.from(_drawingsModelObject.drawingInfos)..add(DrawingInfo(id: id, name: name)),
      drawing: Drawing(id: id, name: name)
    );

    await autoSave();
    notifyListeners();
  }

  Future<void> exportDrawing() async {
    await _repository.exportDrawing(_drawingsModelObject.drawing);
  }

  Future<void> importDrawing() async {
    Drawing? drawing = await _repository.importDrawing();
    if (drawing != null && !drawingInfos.any((di) => di.id == drawing.id)) {
      await _repository.saveDrawing(drawing);
      _drawingsModelObject = _drawingsModelObject.copyWith(
        drawingInfos: [...drawingInfos, DrawingInfo(id: drawing.id, name: drawing.name, description: drawing.description)],
      );
      _saveDrawingInfos();
      notifyListeners();
    }
  }

  void deleteDrawing(String drawingId) {
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: _drawingsModelObject.drawingInfos.where((di) => di.id != drawingId).toList(),
    );

    _repository.deleteDrawing(drawingId);
    _saveDrawingInfos();
    notifyListeners();
  }

  Future<void> loadDrawing(String drawingId) async {
    Drawing drawing = await _repository.loadDrawing(drawingId);

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: drawing
    );

    notifyListeners();
  }

  //==================== Commands =====================

  String addMeasurementCommand() {
    String id = const UuidV4Gen().get();
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: [..._drawingsModelObject.drawing.commands, 
          MeasurementCommand(id: id, label: _drawingsModelObject.drawing.nextMeasurementLabel)]
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
    return id;
  }

  String addVariableCommand() {
    String id = const UuidV4Gen().get();
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: [..._drawingsModelObject.drawing.commands, 
          VariableCommand(id: id, label: _drawingsModelObject.drawing.nextVariableLabel)]
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
    return id;
  }

  String addPointCommand() {
    String id = const UuidV4Gen().get();
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: [..._drawingsModelObject.drawing.commands, 
          PointCommand(id: id, label: _drawingsModelObject.drawing.nextPointLabel)]
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
    return id;
  }

  String addLineCommand() {
    String id = const UuidV4Gen().get();
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: [..._drawingsModelObject.drawing.commands, 
          LineCommand(id: id, label: _drawingsModelObject.drawing.nextLineLabel)]
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
    return id;
  }

  String addCurveCommand() {
    String id = const UuidV4Gen().get();
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: [..._drawingsModelObject.drawing.commands,
          CurveCommand(id: id, label: _drawingsModelObject.drawing.nextCurveLabel)]
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
    return id;
  }

  void changeDrawingCommand(DrawingCommand newCommand) {
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: _drawingsModelObject.drawing.commands.map((c) => c.id != newCommand.id ? c : newCommand).toList()
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
  }

  void deleteCommand({required String commandId}) {
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: _drawingsModelObject.drawing.commands
          .where((c) => c.id != commandId)
          .map((c) => c.deleteReference(commandId: commandId)).toList()
      )
    );

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.validate()
    );

    _storeForUndo();
    notifyListeners();
  }

  void reorderCommands(int oldIndex, int newIndex) {
    List<DrawingCommand> newCommands = List.from(_drawingsModelObject.drawing.commands);
    DrawingCommand temp = newCommands.removeAt(oldIndex);
    newCommands.insert(newIndex, temp);

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: _drawingsModelObject.drawing.copyWith(
        commands: newCommands
      )
    );

    _storeForUndo();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawing_info.dart';
import 'package:knitty_griddy/drawings/model/drawings_model_object.dart';
import 'package:knitty_griddy/drawings/model/drawings_save_model_object.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/model/part_set_info.dart';
import 'package:knitty_griddy/drawings/partrepo/part_repository.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';
import 'package:knitty_griddy/drawings/storage/drawings_model_repository.dart';

class DrawingsModel extends ChangeNotifier {

  final DrawingsModelRepository _repository;

  DrawingsModelObject _drawingsModelObject;

  DrawingsSaveModelObject? _lastSaved;

  DrawingsModel({
    required DrawingsModelRepository repository,
  }) :
    _repository = repository,
    _drawingsModelObject = const DrawingsModelObject();

  // ====================== Part repo =========================

  PartDrawing addPartDrawing({required String category, required String partSetId}) {
    PartDrawing pd = PartDrawing(
      id: const UuidV4Gen().get(), 
      name: 'Unnamed',
      category: category,
    );

    PartRepository.addPartDrawingToSet(pd, partSetId);

    notifyListeners();

    return pd;
  }

  List<DrawingInfo> filteredDrawingInfos(String filter) {
    return drawingInfos.where((di) => 
      di.name.toLowerCase().contains(filter.toLowerCase()) ||
      di.description.toLowerCase().contains(filter.toLowerCase())
    ).toList();
  }

  List<PartSet> filteredPartSets(String filter) {
    return PartRepository.filteredPartSets(filter);
  }
  
  List<PartSetInfo> filteredPartSetInfos(String filter) {
    return PartRepository.filteredPartSetInfos(filter);
  }

  String createPartSet(String name, List<PartDrawing> parts) {
    String id = PartRepository.createPartSet(name, parts);
    notifyListeners();
    return id;
  }

  void renamePartSet(String id, String newName) {
    PartRepository.renamePartSet(id, newName);
    notifyListeners();
  }

  Future<void> exportPartSet(PartSet partSet) async {
    await _repository.exportPartSet(partSet);
  }

  Future<String?> importPartSet() async {
    PartSet? importedSet = await _repository.importPartSet();

    if (importedSet != null) {
      if (!PartRepository.hasPartSet(importedSet.id)) {
        PartRepository.addPartSet(importedSet);
        notifyListeners();
      }
      return importedSet.id;
    }

    return null;
  }

  Future<void> importPartDrawing(String partSetId) async {
    PartDrawing? importedPartDrawing = await _repository.importPartDrawing();

    if (importedPartDrawing != null) {
      importedPartDrawing = importedPartDrawing.validate();
      if (!PartRepository.hasPartDrawing(importedPartDrawing)) {
        PartRepository.addPartDrawingToSet(importedPartDrawing, partSetId);
        notifyListeners();
      }
    }
  }

  void restoreBasicPartSet() {
    PartRepository.restoreBasicPartSet();
    notifyListeners();
  }

  void deletePartSet(String id) {
    PartRepository.deletePartSet(id);
    notifyListeners();
  }

  void movePartToSet({
    required PartDrawing partDrawing,
    required String sourceSetId,
    required String targetSetId}) {
    PartRepository.movePartToSet(partDrawing, sourceSetId, targetSetId);
    notifyListeners();
  }

  void addPartToSet({required PartSet targetPartSet, required PartDrawing part}) {
    PartRepository.addPartDrawingToSet(part, targetPartSet.id);
    notifyListeners();
  }

  void deletePartDrawing(PartDrawing partDrawing) {
    PartRepository.deletePart(partDrawing);
    notifyListeners();
  }

  void updateDrawing({
    required AbstractDrawing oldDrawing,
    required AbstractDrawing newDrawing,
  }) {
    if (oldDrawing is PartDrawing && newDrawing is PartDrawing) {
      PartRepository.updatePartDrawing(oldDrawing, newDrawing);
    } else {
      _drawingsModelObject = _drawingsModelObject.copyWith(
        drawing: newDrawing as Drawing,
        drawingInfos: _drawingsModelObject.drawingInfos.map((di) => 
          di.id != newDrawing.id ? di : di.copyWith(
            name: newDrawing.name,
            description: newDrawing.description,
            contentHashCode: newDrawing.contentHashCode
          )
        ).toList()
      );
      _saveDrawingInfos();
    }

    notifyListeners();
  }

  // ===================== Drawing infos =======================

  List<DrawingInfo> get drawingInfos => _drawingsModelObject.drawingInfos;

  Drawing get drawing => _drawingsModelObject.drawing;
  
  void loadOnStartup() {
    _repository.loadDrawingInfos().then((List<DrawingInfo> drawingInfos) {
     _drawingsModelObject =  _drawingsModelObject.copyWith(
      drawingInfos: drawingInfos,
     );
     _repository.loadPartSets().then((List<PartSet> partSets) {
       PartRepository.loadInitialPartSets(partSets);
       notifyListeners();
     },);
    });
  }

  Future<void> autoSave() async {
    if (_lastSaved == null) {
      _lastSaved = DrawingsSaveModelObject(
        drawing: _drawingsModelObject.drawing,
        drawingInfos: _drawingsModelObject.drawingInfos,
        partSets: List.from(PartRepository.instance.sets),
      );
      return;
    }

    final DrawingsSaveModelObject oldModel = _lastSaved!.copyWith();
    _lastSaved = _lastSaved!.copyWith(
      drawing: _drawingsModelObject.drawing,
      drawingInfos: _drawingsModelObject.drawingInfos,
      partSets: List.from(PartRepository.instance.sets),
    );

    if (!listEquals(oldModel.drawingInfos, _lastSaved!.drawingInfos)) {
      await _repository.saveDrawingInfos(_lastSaved!.drawingInfos);
    }

    if (!listEquals(oldModel.partSets, _lastSaved!.partSets)) {
      await _repository.savePartSets(_lastSaved!.partSets);
    }

    if (oldModel.drawing != _lastSaved!.drawing) {
      await _repository.saveDrawing(_lastSaved!.drawing);
      _drawingsModelObject = _drawingsModelObject.copyWith(
        drawingInfos: _drawingsModelObject.drawingInfos.map((di) =>
          di.id != _drawingsModelObject.drawing.id ? di : di.copyWith(
            contentHashCode: _drawingsModelObject.drawing.contentHashCode
          )
        ).toList()
      );
      await _saveDrawingInfos();
    }
  }

  Future<void> saveCurrentDrawing() async {
    await _repository.saveDrawing(_drawingsModelObject.drawing);

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: drawingInfos.map((di) => di.id != drawing.id ? di : di.copyWith(
        name: _drawingsModelObject.drawing.name,
        description: _drawingsModelObject.drawing.description,
        contentHashCode: _drawingsModelObject.drawing.contentHashCode,
      )).toList()
    );

    await _saveDrawingInfos();
  }

  Future<void> _saveDrawingInfos() async {
    await _repository.saveDrawingInfos(_drawingsModelObject.drawingInfos);
  }

  Future<void> duplicateDrawing(DrawingInfo originalInfo) async {
    Drawing original = await getDrawing(originalInfo);

    final String id = const UuidV4Gen().get();

    Drawing newDrawing = original.copyWith(
      id: id,
      name: '${original.name} copy',
    );

    await _repository.saveDrawing(newDrawing);

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: [..._drawingsModelObject.drawingInfos, DrawingInfo(
        id: newDrawing.id, 
        name: newDrawing.name, 
        contentHashCode: newDrawing.contentHashCode)
      ]
    );

    _saveDrawingInfos();
    notifyListeners();
  }

  Future<void> createNewDrawing(String name) async {
    final String id = const UuidV4Gen().get();

    Drawing newDrawing = Drawing(id: id, name: name);

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: List.from(_drawingsModelObject.drawingInfos)..add(DrawingInfo(id: id, name: name, contentHashCode: newDrawing.contentHashCode)),
      drawing: newDrawing
    );

    await autoSave();
    notifyListeners();
  }

  Future<void> exportDrawing(AbstractDrawing drawing) async {
    if (drawing is PartDrawing) {
      await _repository.exportPartDrawing(drawing);
    } else {
      await _repository.exportDrawing(_drawingsModelObject.drawing);
    }
  }

  Future<void> importDrawing() async {
    Drawing? drawing = await _repository.importDrawing();
    if (drawing != null) {
      // We already seem to have this drawing
      if (drawingInfos.any((di) => di.id == drawing!.id)) {
        // import anyway, but under different id
        drawing = drawing.copyWith(id: const UuidV4Gen().get());
      }
      
      // copy over to our own repo location
      await _repository.saveDrawing(drawing);
      _drawingsModelObject = _drawingsModelObject.copyWith(
        drawingInfos: [...drawingInfos, DrawingInfo(
          id: drawing.id, 
          name: drawing.name, 
          description: drawing.description,
          contentHashCode: drawing.contentHashCode
        )],
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

  Future<Drawing> getDrawing(DrawingInfo drawingInfo) async {
    Drawing drawing = await _repository.loadDrawing(drawingInfo.id);

    // Import unknown parts
    for (PartDrawing partDrawing in drawing.usedPartDrawings) {
      // Check if we have this part (same id and content)
      if (!PartRepository.hasPartDrawing(partDrawing)) {
        // If not, is there a part with same content and different id?
        PartDrawing? samedrawingcontent = PartRepository.getPartByContent(partDrawing);
        if (samedrawingcontent != null) {
          // We have a partdrawing in the repo that is the same except for the id. So use that instead
          drawing = drawing.copyWith(
            usedPartDrawings: drawing.usedPartDrawings.map((pd) => pd != partDrawing ? pd : samedrawingcontent).toList()
          );
        } else {
          // We don't have the required part, so we import into the repo under the "imported" set
          String newId = const UuidV4Gen().get();
          PartDrawing copy = partDrawing.copyWith(id: newId,).validate();
          PartRepository.addPartDrawingToImportedSet(copy);
          drawing = drawing.copyWith(
            usedPartDrawings: drawing.usedPartDrawings.map((upd) => upd.id == partDrawing.id ? copy : upd).toList(),
            commands: drawing.commands.map((c) => c is! IncludedPartCommand ? 
              c.changePartDrawingReference(oldId: partDrawing.id, newId: newId) : 
              c.copyWith(partDrawingId: newId,
            )).toList()
          );
        }
      }
    }

    return drawing;
  }

  bool hasDrawing(Drawing drawing) {
    return drawingInfos.any((di) => di.id == drawing.id && di.name == drawing.name);
  }

  bool hasDrawingWithId(String id) {
    return drawingInfos.any((di) => di.id == id);
  }

  Future<Drawing?> getSimilarDrawing(Drawing original) async {
    List<DrawingInfo> candidates = _drawingsModelObject.drawingInfos.where((di) => di.contentHashCode == drawing.contentHashCode).toList();
    if (candidates.isNotEmpty) {
      return await getDrawing(candidates.first);
    }
    return null;
  }

  Future<Drawing> saveDrawingAndAux(Drawing drawing) async {

    // Import unknown parts
    for (PartDrawing partDrawing in drawing.usedPartDrawings) {
      // Check if we have this part (same id and content)
      if (!PartRepository.hasPartDrawing(partDrawing)) {
        // If not, is there a part with same content and different id?
        PartDrawing? samedrawingcontent = PartRepository.getPartByContent(partDrawing);
        if (samedrawingcontent != null) {
          // We have a partdrawing in the repo that is the same except for the id. So use that instead
          drawing = drawing.copyWith(
            usedPartDrawings: drawing.usedPartDrawings.map((pd) => pd != partDrawing ? pd : samedrawingcontent).toList()
          );
        } else {
          // We don't have the required part, so we import into the repo under the "imported" set
          String newId = const UuidV4Gen().get();
          PartDrawing copy = partDrawing.copyWith(id: newId,).validate();
          PartRepository.addPartDrawingToImportedSet(copy);
          drawing = drawing.copyWith(
            usedPartDrawings: drawing.usedPartDrawings.map((upd) => upd.id == partDrawing.id ? copy : upd).toList(),
            commands: drawing.commands.map((c) => c is! IncludedPartCommand ? 
              c.changePartDrawingReference(oldId: partDrawing.id, newId: newId) : 
              c.copyWith(partDrawingId: newId,
            )).toList()
          );
        }
      }
    }

    await _repository.saveDrawing(drawing);

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: [..._drawingsModelObject.drawingInfos, DrawingInfo(
        id: drawing.id, 
        name: drawing.name, 
        description: drawing.description,
        contentHashCode: drawing.contentHashCode
      )]
    );

    _saveDrawingInfos();
    notifyListeners();

    return drawing;
  }

  Future<void> loadDrawing(String drawingId) async {
    Drawing drawing = await _repository.loadDrawing(drawingId);

    // Import unknown parts
    for (PartDrawing partDrawing in drawing.usedPartDrawings) {
      // Check if we have this part (same id and content)
      if (!PartRepository.hasPartDrawing(partDrawing)) {
        // If not, is there a part with same content and different id?
        PartDrawing? samedrawingcontent = PartRepository.getPartByContent(partDrawing);
        if (samedrawingcontent != null) {
          // We have a partdrawing in the repo that is the same except for the id. So use that instead
          drawing = drawing.copyWith(
            usedPartDrawings: drawing.usedPartDrawings.map((pd) => pd != partDrawing ? pd : samedrawingcontent).toList()
          );
        } else {
          // We don't have the required part, so we import into the repo under the "imported" set
          String newId = const UuidV4Gen().get();
          PartDrawing copy = partDrawing.copyWith(id: newId,).validate();
          PartRepository.addPartDrawingToImportedSet(copy);
          drawing = drawing.copyWith(
            usedPartDrawings: drawing.usedPartDrawings.map((upd) => upd.id == partDrawing.id ? copy : upd).toList(),
            commands: drawing.commands.map((c) => c is! IncludedPartCommand ? 
              c.changePartDrawingReference(oldId: partDrawing.id, newId: newId) : 
              c.copyWith(partDrawingId: newId,
            )).toList()
          );
        }
      }
    }

    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawing: drawing.fixMeasurementOverrides().validate()
    );

    notifyListeners();
  }

  void updateDrawingInfo() {
    _drawingsModelObject = _drawingsModelObject.copyWith(
      drawingInfos: _drawingsModelObject.drawingInfos.map((di) => di.id != _drawingsModelObject.drawing.id ? di : di.copyWith(
        name: _drawingsModelObject.drawing.name,
        description: _drawingsModelObject.drawing.description,
        contentHashCode: _drawingsModelObject.drawing.contentHashCode,
      )).toList()
    );

    _saveDrawingInfos();
    notifyListeners();
  }

}

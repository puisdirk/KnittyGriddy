
import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/part_drawing.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/drawings/model/part_set_info.dart';
import 'package:knitty_griddy/drawings/partrepo/basic_parts_set.dart';
import 'package:knitty_griddy/drawings/partrepo/imported_parts_set.dart';
import 'package:knitty_griddy/drawings/partrepo/part_set.dart';

class PartRepository {

  List<PartSet> sets = [];

  PartRepository._();
  static PartRepository instance = PartRepository._();

  static String getSetName(int index) {
    if (index < 0 || index >= instance.sets.length) {
      return '';
    }

    return instance.sets[index].name;
  }

  static int indexOfSet(String partSetId) {
    return instance.sets.indexWhere((s) => s.id == partSetId);
  }

  static void renamePartSet(String id, String newName) {
    instance.sets = instance.sets.map((partSet) => partSet.id != id ? partSet : partSet.copyWith(
      name: newName
    )).toList();
  }

  static void loadInitialPartSets(List<PartSet> partSets) {
    if (partSets.isEmpty) {
      BasicPartsSet.loadFromAssets().then((set) => instance.sets = [set]);
    } else {
      instance.sets = List.from(partSets);
    }
  }

  static void restoreBasicPartSet() {
    BasicPartsSet.loadFromAssets().then((set) => 
      instance.sets = [set, ...instance.sets]);
  }

  static void addPartDrawingToSet(PartDrawing part, String partSetId) {
    instance.sets = instance.sets.map((s) => s.id != partSetId ? s : s.copyWith(
      partDrawings: [...s.partDrawings, part]
    )).toList();
  }

  static void addPartDrawingToImportedSet(PartDrawing part) {
    if (instance.sets.any((s) => s.id == ImportedPartsSet.importedPartsSetId)) {
      instance.sets = instance.sets.map((s) => s.id != ImportedPartsSet.importedPartsSetId ? s : s.copyWith(
        partDrawings: [...s.partDrawings, part]
      )).toList();
    } else {
      instance.sets = [...instance.sets, const ImportedPartsSet().copyWith(partDrawings: [part])];
    }
  }

  static String createPartSet(String name, List<PartDrawing> parts) {
    String newId = const UuidV4Gen().get();
    instance.sets =[...instance.sets, PartSet(id: newId, name: name, parts: parts)];
    return newId;
  }

  static void movePartToSet(PartDrawing part, String sourceSetId, String targetSetId) {
    // Take the part out of its current set and move it to the given set
    instance.sets = instance.sets.map((s) {
      if (s.id == targetSetId) {
        return s.copyWith(
          partDrawings: [...s.partDrawings, part]
        );
      } else if (s.id == sourceSetId) {
        return s.copyWith(
          partDrawings: s.partDrawings.where((sd) => sd != part).toList()
        );
      } else {
        return s;
      }
    }).toList();
  }

  static bool hasPartSetNamed(String name) {
    return instance.sets.any((s) => s.name == name);
  }

  static bool hasPartSet(String id) {
    return instance.sets.any((s) => s.id == id);
  }

  static void addPartSet(PartSet partSet) {
    instance.sets = [...instance.sets, partSet];
  }

  static void deletePartSet(String id) {
    instance.sets = instance.sets.where((s) => s.id != id).toList();
  }

  static void updatePartDrawing(PartDrawing oldDrawing, PartDrawing newDrawing) {
    instance.sets = instance.sets.map((s) => s.copyWith(
      partDrawings: s.partDrawings.map((p) => p != oldDrawing ? p : newDrawing).toList()
    )).toList();
  }

  static void deletePart(PartDrawing part) {
    instance.sets = instance.sets.map((s) => s.copyWith(
      partDrawings: s.partDrawings.where((p) => p != part).toList()
    )).toList();
  }

  static List<PartSet> filteredPartSets(String filter) {
    List<PartSet> result = [];
    for (PartSet partSet in instance.sets) {
      result.add(partSet.copyWith(
        partDrawings: partSet.partDrawings.where((p) => p.passesFilter(filter)).toList()
      ));
    }
    return result;
  }

  static List<PartSetInfo> filteredPartSetInfos(String filter) {
    List<PartSetInfo> results = [];

    for (PartSet partSet in instance.sets) {
      List<PartInfo> infos = [];
      for (PartDrawing partDrawing in partSet.partDrawings) {
        for (DrawingCommand partCommand in partDrawing.commands.where((c) => c is PartCommand && c.validated && c.valid)) {
          infos.add(PartInfo(
            partDrawingId: partDrawing.id, 
            partId: partCommand.id, 
            partLabel: partCommand.label,
            category: partDrawing.category,
          ));
        }
      }
      if (infos.isNotEmpty) {
        results.add(PartSetInfo(setName: partSet.name, partInfos: infos));
      }
    }

    return results.where((r) => r.passesFilter(filter)).toList();
  }

  static PartDrawing? getPartDrawingById(String id) {
    PartDrawing? part;
    for (PartSet partSet in instance.sets) {
      part = partSet.partById(id);
      if (part != null) {
        return part;
      }
    }

    return null;
  }

  static bool hasPartDrawing(PartDrawing part) {
    return instance.sets.any((s) => s.partDrawings.any((p) => p == part));
  }

  static PartDrawing? getPartByContent(PartDrawing part) {
    for (PartSet partSet in instance.sets) {
      if (partSet.partDrawings.any((p) => p.sameContentAs(part))) {
        return partSet.partDrawings.firstWhere((p) => p.sameContentAs(part));
      }
    }
    return null;
  }

}
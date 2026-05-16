import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/controls/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/controls/stitchrepo/imported_stitches_set.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';

class StitchRepository {

  List<StitchSet> sets = [
  ];

  StitchRepository._();
  static StitchRepository instance = StitchRepository._();

  static String getSetName(int index) {
    if (index < 0 || index >= instance.sets.length) {
      return '';
    }

    return instance.sets[index].name;
  }

  static int indexOfSet(String stitchSetId) {
    return instance.sets.indexWhere((s) => s.id == stitchSetId);
  }

  static void renameStitchSet(String id, String newName) {
    instance.sets = instance.sets.map((stitchSet) => stitchSet.id != id ? stitchSet : stitchSet.copyWith(
      name: newName
    )).toList();
  }

  static void loadInitialStitchSets(List<StitchSet> stitchSets) {
    if (stitchSets.isEmpty) {
      instance.sets = [BasicStitchesSet()];
    } else {
      instance.sets = List.from(stitchSets);
    }
  }

  static void restoreBasicStitchSet() {
    instance.sets = [BasicStitchesSet(), ...instance.sets];
  }

  static void addStitchToSet(StitchDefinition def, String stitchSetId) {
    instance.sets = instance.sets.map((s) => s.id != stitchSetId ? s : s.copyWith(
      stitchDefinitions: [...s.definitions, def]
    )).toList();
  }

  static void addStitchToImportedSet(StitchDefinition def) {
    if (instance.sets.any((s) => s.id == ImportedStitchesSet.importedStitchesSetId)) {
      instance.sets = instance.sets.map((s) => s.id != ImportedStitchesSet.importedStitchesSetId ? s : s.copyWith(
        stitchDefinitions: [...s.definitions, def]
      )).toList();
    } else {
      instance.sets = [...instance.sets, const ImportedStitchesSet().copyWith(stitchDefinitions: [def])];
    }
  }

  static String createStitchSet(String name, List<StitchDefinition> stitches) {
    String newId = const UuidV4Gen().get();
    instance.sets =[...instance.sets, StitchSet(id: newId, name: name, stitchDefinitions: stitches)];
    return newId;
  }

  static void moveStitchToSet(StitchDefinition def, String sourceSetId, String targetSetId) {
    // Take the stitch out of its current set and move it to the given set
    instance.sets = instance.sets.map((s) {
      if (s.id == targetSetId) {
        return s.copyWith(
          stitchDefinitions: [...s.definitions, def]
        );
      } else if (s.id == sourceSetId) {
        return s.copyWith(
          stitchDefinitions: s.definitions.where((sd) => sd != def).toList()
        );
      } else {
        return s;
      }
    }).toList();
  }

  static bool hasStitchSetNamed(String name) {
    return instance.sets.any((s) => s.name == name);
  }

  static bool hasStitchSet(String id) {
    return instance.sets.any((s) => s.id == id);
  }

  static void addStitchSet(StitchSet stitchSet) {
    instance.sets = [...instance.sets, stitchSet];
  }

  static void deleteStitchSet(String id) {
    instance.sets = instance.sets.where((s) => s.id != id).toList();
  }

  static void updateStitchDefinition(StitchDefinition oldDef, StitchDefinition newDef) {
    instance.sets = instance.sets.map((s) => s.copyWith(
      stitchDefinitions: s.definitions.map((sd) => sd != oldDef ? sd : newDef).toList()
    )).toList();
  }

  static void deleteStitchDefinition(StitchDefinition def) {
    instance.sets = instance.sets.map((s) => s.copyWith(
      stitchDefinitions: s.definitions.where((sd) => sd != def).toList()
    )).toList();
  }

  static List<StitchSet> filteredStitchSets(String filter) {
    List<StitchSet> result = [];
    for (StitchSet stsSet in instance.sets) {
      result.add(stsSet.copyWith(
        stitchDefinitions: stsSet.definitions.where((sd) => sd.passesFilter(filter)).toList()
      ));
    }
    return result;
  }

  static Map<String, List<StitchDefinition>> getDefinitionsPerCategory() {
    // TODO: this should be set once only when loading a stitches set
    // but I think it will disappear by then
    Map<String, List<StitchDefinition>> defs = {};
    for (StitchSet stsSet in instance.sets) {
      for (StitchDefinition def in stsSet.definitions) {
        if (!defs.containsKey(def.category)) {
          defs[def.category] = [];
        }
        defs[def.category]!.add(def);
      }
    }

    return defs;
  }

  static StitchDefinition getStitchDefinitionById(String id) {
    StitchDefinition? def;
    for (StitchSet stsSet in instance.sets) {
      def = stsSet.stitchDefinitionById(id);
      if (def != null) {
        return def;
      }
    }

    return BasicStitchesSet.noStitch;
  }

  static bool hasStitch(StitchDefinition def) {
    return instance.sets.any((s) => s.definitions.any((d) => d == def));
  }

  static StitchDefinition? getStitchDefinitionByContent(StitchDefinition def) {
    for (StitchSet stitchSet in instance.sets) {
      if (stitchSet.definitions.any((s) => s.sameContentAs(def))) {
        return stitchSet.definitions.firstWhere((s) => s.sameContentAs(def));
      }
    }
    return null;
  }

}
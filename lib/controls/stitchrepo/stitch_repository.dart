import 'package:id_gen/id_gen.dart';
import 'package:knitty_griddy/controls/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';

class StitchRepository {

  List<StitchesSet> sets = [
  ];

  StitchRepository._();
  static StitchRepository instance = StitchRepository._();

  static String getSetName(int index) {
    if (index < 0 || index >= instance.sets.length) {
      return '';
    }

    return instance.sets[index].name;
  }

  static void renameStitchSet(String id, String newName) {
    instance.sets = instance.sets.map((stitchSet) => stitchSet.id != id ? stitchSet : stitchSet.copyWith(
      name: newName
    )).toList();
  }

  static void loadInitialStitchSets(List<StitchesSet> stitchSets) {
    if (stitchSets.isEmpty) {
      instance.sets = [BasicStitchesSet()];
    } else {
      instance.sets = List.from(stitchSets);
    }
  }

  static void addStitchToSet(StitchDefinition def, String stitchSetId) {
    instance.sets = instance.sets.map((s) => s.id != stitchSetId ? s : s.copyWith(
      stitchDefinitions: [...s.definitions, def]
    )).toList();
  }

  static void createStitchSet(String name, List<StitchDefinition> stitches) {
    instance.sets =[...instance.sets, StitchesSet(id: const UuidV4Gen().get(), name: name, stitchDefinitions: stitches)];
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

  static void addStitchSet(StitchesSet stitchSet) {
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

  static List<StitchesSet> filteredStitchSets(String filter) {
    List<StitchesSet> result = [];
    for (StitchesSet stsSet in instance.sets) {
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
    for (StitchesSet stsSet in instance.sets) {
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
    for (StitchesSet stsSet in instance.sets) {
      def = stsSet.stitchDefinitionById(id);
      if (def != null) {
        return def;
      }
    }

    return BasicStitchesSet.noStitch;
  }
}
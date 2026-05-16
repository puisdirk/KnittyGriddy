
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class NoOpModelRepository implements ModelRepository {

  const NoOpModelRepository();

  @override
  Future<List<PatternInfo>> loadPatternInfos() async {
    return [];
  }

    @override
  Future<KnittingPattern> loadPattern(String patternId) async {
    return const KnittingPattern(id: 'default', name: 'default', patternSettings: PatternSettings(rows: 10, columns: 10, gridType: GridType.flat));
  }

  @override
  Future<void> savePattern(KnittingPattern pattern) async {
  }
  
  @override
  Future<void> savePatternInfos(List<PatternInfo> patternInfos) async {
  }

  @override
  Future<void> deletePattern(String patternId) async {
  }

  @override
  Future<List<StitchSet>> loadStitchSets() async {
    return [];
  }

  @override
  Future<void> saveStitchSets(List<StitchSet> stitchSets) async {
  }

  @override
  Future<void> exportStitchesSet(StitchSet stitchSet) async {
  }
  
  @override
  Future<StitchSet?> importStitchesSet() async {
    return null;
  }
  
  @override
  Future<KnittingPattern?> importPattern() async {
    return null;
  }
  
  @override
  Future<void> exportPattern(KnittingPattern pattern) async {
  }
}
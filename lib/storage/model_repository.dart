
import 'package:knitty_griddy/controls/stitchrepo/stitches_set.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';

abstract class ModelRepository {

  Future<List<PatternInfo>> loadPatternInfos();
  Future<void> savePatternInfos(List<PatternInfo> patternInfos);

  Future<KnittingPattern> loadPattern(String patternId);
  Future<void> savePattern(KnittingPattern pattern);
  Future<void> deletePattern(String patternId);

  Future<List<StitchesSet>> loadStitchSets();
  Future<void> saveStitchSets(List<StitchesSet> stitchSets);

  Future<void> exportStitchesSet(StitchesSet stitchSet);
  Future<StitchesSet?> importStitchesSet();
}
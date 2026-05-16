
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';

abstract class ModelRepository {

  Future<List<PatternInfo>> loadPatternInfos();
  Future<void> savePatternInfos(List<PatternInfo> patternInfos);

  Future<KnittingPattern> loadPattern(String patternId);
  Future<void> savePattern(KnittingPattern pattern);
  Future<void> deletePattern(String patternId);

  Future<void> exportPattern(KnittingPattern pattern);
  Future<KnittingPattern?> importPattern();

  Future<List<StitchSet>> loadStitchSets();
  Future<void> saveStitchSets(List<StitchSet> stitchSets);

  Future<void> exportStitchesSet(StitchSet stitchSet);
  Future<StitchSet?> importStitchesSet();
}
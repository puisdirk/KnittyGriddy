import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';

abstract class PatternsModelRepository {

  Future<List<KnittingPatternInfo>> loadPatternInfos();
  Future<void> savePatternInfos(List<KnittingPatternInfo> patternInfos);

  Future<KnittingPattern> loadPattern(String patternId);
  Future<void> savePattern(KnittingPattern pattern);
  Future<void> deletePattern(String patternId);

  Future<void> exportPattern(KnittingPattern pattern);
  Future<KnittingPattern?> importPattern();
}
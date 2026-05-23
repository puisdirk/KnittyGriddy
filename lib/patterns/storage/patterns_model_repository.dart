import 'package:knitty_griddy/patterns/model/pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_info.dart';

abstract class PatternsModelRepository {

  Future<List<PatternInfo>> loadPatternInfos();
  Future<void> savePatternInfos(List<PatternInfo> patternInfos);

  Future<Pattern> loadPattern(String patternId);
  Future<void> savePattern(Pattern pattern);
  Future<void> deletePattern(String patternId);

  Future<void> exportPattern(Pattern pattern);
  Future<Pattern?> importPattern();
}
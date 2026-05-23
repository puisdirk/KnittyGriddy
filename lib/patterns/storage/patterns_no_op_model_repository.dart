
import 'package:knitty_griddy/patterns/model/pattern.dart';
import 'package:knitty_griddy/patterns/model/pattern_info.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';

class PatternsNoOpModelRepository implements PatternsModelRepository {

  const PatternsNoOpModelRepository();

  @override
  Future<void> deletePattern(String patternId) async {
  }

  @override
  Future<void> exportPattern(Pattern pattern) async {
  }

  @override
  Future<Pattern?> importPattern() async {
    return null;
  }

  @override
  Future<Pattern> loadPattern(String patternId) async {
    return const Pattern(id: 'default', name: 'default');
  }

  @override
  Future<List<PatternInfo>> loadPatternInfos() async {
    return [];
  }

  @override
  Future<void> savePattern(Pattern pattern) async {
  }

  @override
  Future<void> savePatternInfos(List<PatternInfo> patternInfos) async {
  }
}
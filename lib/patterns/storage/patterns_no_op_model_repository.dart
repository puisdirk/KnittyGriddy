
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';
import 'package:knitty_griddy/patterns/storage/patterns_model_repository.dart';

class PatternsNoOpModelRepository implements PatternsModelRepository {

  const PatternsNoOpModelRepository();

  @override
  Future<void> deletePattern(String patternId) async {
  }

  @override
  Future<void> exportPattern(KnittingPattern pattern) async {
  }

  @override
  Future<KnittingPattern?> importPattern() async {
    return null;
  }

  @override
  Future<KnittingPattern> loadPattern(String patternId) async {
    return const KnittingPattern(id: 'default', name: 'default');
  }

  @override
  Future<List<KnittingPatternInfo>> loadPatternInfos() async {
    return [];
  }

  @override
  Future<void> savePattern(KnittingPattern pattern) async {
  }

  @override
  Future<void> savePatternInfos(List<KnittingPatternInfo> patternInfos) async {
  }
}
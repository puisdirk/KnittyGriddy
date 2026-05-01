
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class InMemoryModelRepository implements ModelRepository {
  List<KnittingPattern> patterns = [];
  List<PatternInfo> patternInfos = [];
  List<StitchDefinition> customStitches = [];

  @override
  Future<void> deletePattern(String patternId) async {
    patternInfos = patternInfos.where((p) => p.id != patternId).toList();
  }

  @override
  Future<KnittingPattern> loadPattern(String patternId) async {
    return patterns.firstWhere((p) => p.id == patternId);
  }

  @override
  Future<List<PatternInfo>> loadPatternInfos() async {
    return patternInfos;
  }

  @override
  Future<void> savePattern(KnittingPattern pattern) async {
    if (patterns.any((p) => p.id == pattern.id)) {
      patterns = patterns.map((p) => p.id == pattern.id ? pattern : p).toList();
    } else {
      patterns.add(pattern);
    }
  }

  @override
  Future<void> savePatternInfos(List<PatternInfo> patternInfos) async {
    patternInfos = patternInfos;
  }

  @override
  Future<List<StitchDefinition>> loadCustomstitches() async {
    return [];
  }

  @override
  Future<void> saveCustomstitches(List<StitchDefinition> stitches) async {
    customStitches = stitches;
  }

}
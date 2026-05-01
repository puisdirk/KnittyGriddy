
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/storage/model_repository.dart';

class JsonFilesModelRepository implements ModelRepository {

  const JsonFilesModelRepository();

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
  Future<List<StitchDefinition>> loadCustomstitches() async {
    return [];
  }
  
  @override
  Future<void> saveCustomstitches(List<StitchDefinition> stitches) async {
  }

}
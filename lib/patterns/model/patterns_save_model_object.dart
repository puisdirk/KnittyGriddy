
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';

class PatternsSaveModelObject {
  final KnittingPattern pattern;
  final List<KnittingPatternInfo> patternInfos;

  const PatternsSaveModelObject({
    required this.pattern,
    required this.patternInfos
  });

  PatternsSaveModelObject copyWith({
    KnittingPattern? pattern,
    List<KnittingPatternInfo>? patternInfos,
  }) {
    return PatternsSaveModelObject(
      pattern: pattern?? this.pattern, 
      patternInfos: patternInfos?? this.patternInfos,
    );
  }
}
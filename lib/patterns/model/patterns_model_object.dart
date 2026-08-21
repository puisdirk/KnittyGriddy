
import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern.dart';
import 'package:knitty_griddy/patterns/model/knitting_pattern_info.dart';

@immutable
class PatternsModelObject {
  final KnittingPattern pattern;
  final List<KnittingPatternInfo> patternInfos;

  const PatternsModelObject({
    this.pattern = placeholderPattern,
    this.patternInfos = const[],
  });

  PatternsModelObject copyWith({
    KnittingPattern? pattern,
    List<KnittingPatternInfo>? patternInfos,
  }) {
    return PatternsModelObject(
      pattern: pattern?? this.pattern,
      patternInfos: patternInfos?? this.patternInfos,
    );
  }

  PatternsModelObject clear() {
    return PatternsModelObject(
      patternInfos: patternInfos
    );
  }

  @override
  int get hashCode => pattern.hashCode ^ patternInfos.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is PatternsModelObject &&
      runtimeType == other.runtimeType &&
      pattern == other.pattern &&
      listEquals(patternInfos, other.patternInfos);
  
}
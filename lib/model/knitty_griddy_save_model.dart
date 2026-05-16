import 'package:flutter/cupertino.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_set.dart';
import 'package:knitty_griddy/model/griddy_model.dart';
import 'package:knitty_griddy/model/knitting_pattern.dart';
import 'package:knitty_griddy/model/pattern_info.dart';

@immutable
class KnittyGriddySaveModel {
  final KnittingPattern knittingPattern;
  final List<PatternInfo> patternInfos;
  final List<StitchSet> stitchSets;

  const KnittyGriddySaveModel({
    required this.knittingPattern,
    required this.patternInfos,
    required this.stitchSets,
  });

  KnittyGriddySaveModel copyWith({
    GriddyModel? griddyModel,
    List<StitchSet>? stitchSets,
  }) {
    return KnittyGriddySaveModel(
      knittingPattern: griddyModel?.knittingPattern?? knittingPattern, 
      patternInfos: griddyModel?.patternInfos?? patternInfos, 
      stitchSets: stitchSets?? this.stitchSets,
    );
  }
}
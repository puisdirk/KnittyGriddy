import 'dart:ui';

import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/basicshapes/knitting_symbol_path.dart';
import 'package:knitty_griddy/model/knitting_symbols.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchRepository {
  StitchRepository._();

  static const StitchDefinition noStitch = StitchDefinition(name: 'No stitch', abbreviation: '', symbols: [KnittingSymbols.nostitch], category: 'General');
  static const StitchDefinition knit = StitchDefinition(name: 'Knit', abbreviation: 'k', symbols: [KnittingSymbols.knit], category: 'General');
  static const StitchDefinition purl = StitchDefinition(name: 'Purl', abbreviation: 'p', symbols: [KnittingSymbols.purl], category: 'General');

  static const List<StitchDefinition> definitions = [
    noStitch, knit, purl, 
    StitchDefinition(name: 'K2tog', abbreviation: 'k2tog', symbols: [KnittingSymbols.k2tog], category: 'Decrease'), 
    StitchDefinition(name: 'K3tog', abbreviation: 'k3tog', symbols: [KnittingSymbols.k3tog], category: 'Decrease'), 
    StitchDefinition(name: 'P2tog', abbreviation: 'p2tog', symbols: [KnittingSymbols.p2tog], category: 'Decrease'), 
    StitchDefinition(name: 'P3tog', abbreviation: 'p3tog', symbols: [KnittingSymbols.p3tog], category: 'Decrease'), 
    StitchDefinition(name: 'SSK', abbreviation: 'ssk', symbols: [KnittingSymbols.ssk], category: 'Decrease'), 
    StitchDefinition(name: 'SSP', abbreviation: 'ssp', symbols: [KnittingSymbols.ssp], category: 'Decrease'), 
    StitchDefinition(name: 'KTBL', abbreviation: 'ktbl', symbols: [KnittingSymbols.ktbl], category: 'General'), 
    StitchDefinition(name: 'YO', abbreviation: 'yo', symbols: [KnittingSymbols.yarnover], category: 'Increase'), 

  ];

  static Map<String, List<StitchDefinition>> getDefinitionsPerCategory(List<StitchDefinition> customStitches) {
    Map<String, List<StitchDefinition>> defs = {};
    for (StitchDefinition def in definitions) {
      if (!defs.containsKey(def.category)) {
        defs[def.category] = [];
      }
      defs[def.category]!.add(def);
    }

    if (customStitches.isNotEmpty) {
      defs['Custom'] = [... customStitches];
    }

    return defs;
  }
}
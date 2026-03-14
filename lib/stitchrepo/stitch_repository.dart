import 'package:knitty_griddy/knitting_icons.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class StitchRepository {
  StitchRepository._();

  static const StitchDefinition noStitch = StitchDefinition(name: 'No stitch', abbreviation: '', iconData: [[Knitting.nostitch]], category: 'General');
  static const StitchDefinition knit = StitchDefinition(name: 'Knit', abbreviation: 'k', iconData: [[Knitting.knit]], category: 'General');
  static const StitchDefinition purl = StitchDefinition(name: 'Purl', abbreviation: 'p', iconData: [[Knitting.purl]], category: 'General');

  static const List<StitchDefinition> definitions = [
    noStitch, knit, purl, 
    StitchDefinition(name: 'K2tog', abbreviation: 'k2tog', iconData: [[Knitting.k2tog]], category: 'Decrease'), 
    StitchDefinition(name: 'K3tog', abbreviation: 'k3tog', iconData: [[Knitting.k3tog]], category: 'Decrease'), 
    StitchDefinition(name: 'P2tog', abbreviation: 'p2tog', iconData: [[Knitting.p2tog]], category: 'Decrease'), 
    StitchDefinition(name: 'P3tog', abbreviation: 'p3tog', iconData: [[Knitting.p3tog]], category: 'Decrease'), 
    StitchDefinition(name: 'SSK', abbreviation: 'ssk', iconData: [[Knitting.ssk]], category: 'Decrease'), 
    StitchDefinition(name: 'SSP', abbreviation: 'ssp', iconData: [[Knitting.ssp]], category: 'Decrease'), 
    StitchDefinition(name: 'KTBL', abbreviation: 'ktbl', iconData: [[Knitting.ktbl]], category: 'General'), 
    StitchDefinition(name: 'YO', abbreviation: 'yo', iconData: [[Knitting.yarnover]], category: 'Increase'), 
  ];

  static Map<String, List<StitchDefinition>> getDefinitionsPerCategory() {
    Map<String, List<StitchDefinition>> defs = {};
    for (StitchDefinition def in definitions) {
      if (!defs.containsKey(def.category)) {
        defs[def.category] = [];
      }
      defs[def.category]!.add(def);
    }

    return defs;
  }
}
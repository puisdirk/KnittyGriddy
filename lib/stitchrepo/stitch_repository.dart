
import 'package:flutter/material.dart';
import 'package:knitty_griddy/knitting_icons.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

//const noStitchDefinition = StitchDefinition(name: 'No stitch', abbreviation: '', iconData: [[Knitting.clear]], category: 'General');

//@immutable
class StitchRepository {
  //final List<StitchDefinition> stitchDefinitions;

  StitchRepository._();

/*  const StitchRepository() : stitchDefinitions = const[
    noStitchDefinition,
    StitchDefinition(name: 'Knit', abbreviation: 'k', iconData: [[Knitting.knit]], category: 'General'),
    StitchDefinition(name: 'Purl', abbreviation: 'p', iconData: [[Knitting.purl]], category: 'General'),
    StitchDefinition(name: 'C2R', abbreviation: 'C2R', iconData: [[Knitting.knit], [Knitting.purl], [Knitting.knit], [Knitting.purl]], category: 'Cables'),
    StitchDefinition(name: 'JUSTUSINGAREALLYREALLYLONGNAMEHEREWWW', abbreviation: 's', iconData: [[Knitting.knit]]),
  ];
*/

  static const StitchDefinition noStitch = StitchDefinition(name: 'No stitch', abbreviation: '', iconData: [[Knitting.clear]], category: 'General');
  static const StitchDefinition errorStitch = StitchDefinition(name: 'Error stitch', abbreviation: '', iconData: [[Icons.question_mark]]);
  static const StitchDefinition knit = StitchDefinition(name: 'Knit', abbreviation: 'k', iconData: [[Knitting.knit]], category: 'General');
  static const StitchDefinition purl = StitchDefinition(name: 'Purl', abbreviation: 'p', iconData: [[Knitting.purl]], category: 'General');
  static const StitchDefinition c2r = StitchDefinition(name: 'C2R', abbreviation: 'C2R', iconData: [[Knitting.knit], [Knitting.purl], [Knitting.knit], [Knitting.purl]], category: 'Cables');
}
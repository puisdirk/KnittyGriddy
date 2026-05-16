
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/controls/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/model/cell_address.dart';
import 'package:knitty_griddy/model/selection.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/model/named_colour.dart';
import 'package:knitty_griddy/model/pattern_settings.dart';
import 'package:knitty_griddy/model/stitch_cell.dart';
import 'package:knitty_griddy/controls/stitchrepo/stitch_definition.dart';

const String placeholderPatternId = '_placeholder_pattern_id_';
const KnittingPattern placeholderPattern = KnittingPattern(
  id: placeholderPatternId,
  name: placeholderPatternId,
  patternSettings: PatternSettings(rows: defaultGridRows, columns: defaultGridColumns, gridType: GridType.flat),
);

@immutable
class KnittingPattern {

  final String id;
  final String name;
  final String description;
  final PatternSettings patternSettings;
  final List<StitchCell> stitches;
  final List<StitchDefinition> usedStitches;
  final List<NamedColour> usedColours;
  final Selection selection;
  final Set<CellAddress> outline;

  const KnittingPattern({
    required this.id,
    required this.name,
    this.description = '',
    this.patternSettings = const PatternSettings(rows: 10, columns: 10, gridType: GridType.flat),
    this.usedStitches = const[BasicStitchesSet.noStitch, BasicStitchesSet.knit, BasicStitchesSet.purl, ],
    this.usedColours = const[defaultMainColor],
    this.stitches = defaultStitches,
    this.selection = emptySelection,
    this.outline = const {},
  });

  KnittingPattern copyWith({
    String? id,
    String? name,
    String? description,
    PatternSettings? patternSettings,
    List<StitchCell>? stitches,
    List<StitchDefinition>? usedStitches,
    List<NamedColour>? usedColours,
    Selection? selection,
    Set<CellAddress>? outline,
  }) {
    return KnittingPattern(
      id: id?? this.id,
      name: name?? this.name,
      description: description?? this.description,
      patternSettings: patternSettings?? this.patternSettings,
      stitches: stitches?? this.stitches,
      usedStitches: usedStitches?? this.usedStitches,
      usedColours: usedColours?? this.usedColours,
      selection: selection?? this.selection,
      outline: outline?? this.outline,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'patternsettings': patternSettings.toJson(),
      'stitches': stitches.map((stitch) => stitch.toJson()).toList(),
      'usedstitches': usedStitches.map((stitch) => stitch.toJson()).toList(),
      'usedcolours': usedColours.map((colour) => colour.toJson()).toList(),
      'selection': selection.toJson(),
      'outline': outline.map((addresss) => addresss.toJson()).toList()
    };
  }

  static KnittingPattern fromJson(Map<String, dynamic> json) {
    List<StitchCell> stitches = [];
    List<Map<String, dynamic>> stitchObjects = (json['stitches'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> stitchObject in stitchObjects) {
      stitches.add(StitchCell.fromJson(stitchObject));
    }

    List<StitchDefinition> usedStitches = [];
    List<Map<String, dynamic>> stitchDefinitionObjects = (json['usedstitches'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> stitchDefinitionObject in stitchDefinitionObjects) {
      usedStitches.add(StitchDefinition.fromJson(stitchDefinitionObject));
    }

    List<NamedColour> usedColours = [];
    List<Map<String, dynamic>> colourObjects = (json['usedcolours'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> colourObject in colourObjects) {
      usedColours.add(NamedColour.fromJson(colourObject));
    }

    Set<CellAddress> outline = {};
    List<Map<String, dynamic>> addressObjects = (json['outline'] as List).map((o) => o as Map<String, dynamic>).toList();
    for (Map<String, dynamic> addressObject in addressObjects) {
      outline.add(CellAddress.fromJson(addressObject));
    }

    return KnittingPattern(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      patternSettings: PatternSettings.fromJson(json['patternsettings'] as Map<String, dynamic>),
      stitches: stitches,
      usedStitches: usedStitches,
      usedColours: usedColours,
      selection: Selection.fromJson(json['selection'] as Map<String, dynamic>),
      outline: outline,
    );
  }

  StitchCell stitchCell(int row, int column) {
    if (stitches.any((cell) => cell.row == row && cell.column == column)) {
      return stitches.firstWhere((cell) => cell.row == row && cell.column == column);
    }
    return StitchCell.empty(row, column);
  }

  NamedColour get mainColour => usedColours.firstWhere((colour) => colour.isMainColor);

  bool isStitchUsedInPattern(StitchDefinition definition) =>
    stitches.any((cell) => cell.stitchDefinitionId == definition.id);

  KnittingPattern pruneUnusedStitches() {
    return copyWith(
      usedStitches: usedStitches.where((us) => us == BasicStitchesSet.noStitch || isStitchUsedInPattern(us)).toList()
    );
  }

  bool isColourUsedInPattern(NamedColour colour) =>
    colour.isMainColor || stitches.any((cell) => cell.colour == colour);

  KnittingPattern pruneUnusedColours() {
    return copyWith(
      usedColours: usedColours.where((colour) => isColourUsedInPattern(colour)).toList()
    );
  }

  KnittingPattern pruneUnusedStitchesAndColours() {
    return copyWith(
      usedStitches: usedStitches.where((us) => us == BasicStitchesSet.noStitch || isStitchUsedInPattern(us)).toList(),
      usedColours: usedColours.where((colour) => isColourUsedInPattern(colour)).toList()
    );
  }

  @override
  int get hashCode => 
    id.hashCode ^ name.hashCode ^ description.hashCode ^ patternSettings.hashCode ^ 
    stitches.hashCode ^ usedStitches.hashCode ^ usedColours.hashCode ^ 
    selection.hashCode ^ outline.hashCode;
    
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingPattern &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      patternSettings == other.patternSettings &&
      listEquals(stitches, other.stitches) &&
      listEquals(usedStitches, other.usedStitches) &&
      listEquals(usedColours, other.usedColours) &&
      selection == other.selection &&
      setEquals(outline, other.outline);
}
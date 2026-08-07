
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:knitty_griddy/charts/stitchrepo/basic_stitches_set.dart';
import 'package:knitty_griddy/charts/model/cell_address.dart';
import 'package:knitty_griddy/charts/model/selection.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/charts/model/named_colour.dart';
import 'package:knitty_griddy/charts/model/chart_settings.dart';
import 'package:knitty_griddy/charts/model/stitch_cell.dart';
import 'package:knitty_griddy/charts/stitchrepo/stitch_definition.dart';

const String placeholderChartId = '_placeholder_chart_id_';
const KnittingChart placeholderChart = KnittingChart(
  id: placeholderChartId,
  name: placeholderChartId,
  chartSettings: ChartSettings(rows: defaultGridRows, columns: defaultGridColumns, gridType: GridType.flat),
);

@immutable
class KnittingChart {

  final String id;
  final String name;
  final String description;
  final ChartSettings chartSettings;
  final List<StitchCell> stitches;
  final List<StitchDefinition> usedStitches;
  final List<NamedColour> usedColours;
  final Selection selection;
  final Set<CellAddress> outline;

  const KnittingChart({
    required this.id,
    required this.name,
    this.description = '',
    this.chartSettings = const ChartSettings(rows: 10, columns: 10, gridType: GridType.flat),
    this.usedStitches = const[BasicStitchesSet.noStitch, BasicStitchesSet.knit, BasicStitchesSet.purl, ],
    this.usedColours = const[defaultMainColor],
    this.stitches = defaultStitches,
    this.selection = emptySelection,
    this.outline = const {},
  });

  KnittingChart copyWith({
    String? id,
    String? name,
    String? description,
    ChartSettings? chartSettings,
    List<StitchCell>? stitches,
    List<StitchDefinition>? usedStitches,
    List<NamedColour>? usedColours,
    Selection? selection,
    Set<CellAddress>? outline,
  }) {
    return KnittingChart(
      id: id?? this.id,
      name: name?? this.name,
      description: description?? this.description,
      chartSettings: chartSettings?? this.chartSettings,
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
      'chartsettings': chartSettings.toJson(),
      'stitches': stitches.map((stitch) => stitch.toJson()).toList(),
      'usedstitches': usedStitches.map((stitch) => stitch.toJson()).toList(),
      'usedcolours': usedColours.map((colour) => colour.toJson()).toList(),
      'selection': selection.toJson(),
      'outline': outline.map((addresss) => addresss.toJson()).toList()
    };
  }

  static KnittingChart fromJson(Map<String, dynamic> json) {
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

    return KnittingChart(
      id: json['id'] as String, 
      name: json['name'] as String,
      description: json['description'] as String,
      chartSettings: ChartSettings.fromJson(json['chartsettings'] as Map<String, dynamic>),
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

  bool isStitchUsedInChart(StitchDefinition definition) =>
    stitches.any((cell) => cell.stitchDefinitionId == definition.id);

  KnittingChart pruneUnusedStitches() {
    return copyWith(
      usedStitches: usedStitches.where((us) => us == BasicStitchesSet.noStitch || isStitchUsedInChart(us)).toList()
    );
  }

  bool isColourUsedInChart(NamedColour colour) =>
    colour.isMainColor || stitches.any((cell) => cell.colour == colour);

  KnittingChart pruneUnusedColours() {
    return copyWith(
      usedColours: usedColours.where((colour) => isColourUsedInChart(colour)).toList()
    );
  }

  KnittingChart pruneUnusedStitchesAndColours() {
    return copyWith(
      usedStitches: usedStitches.where((us) => us == BasicStitchesSet.noStitch || isStitchUsedInChart(us)).toList(),
      usedColours: usedColours.where((colour) => isColourUsedInChart(colour)).toList()
    );
  }

  @override
  int get hashCode => 
    id.hashCode ^ name.hashCode ^ description.hashCode ^ chartSettings.hashCode ^ 
    stitches.hashCode ^ usedStitches.hashCode ^ usedColours.hashCode ^ 
    selection.hashCode ^ outline.hashCode;

  String get contentHashCode => jsonEncode({
      'chartsettings': chartSettings.contentHashCode,
      'stitches': stitches.map((stitch) => stitch.contentHashCode).toList(),
      'usedstitches': usedStitches.map((stitch) => stitch.contentHashCode).toList(),
      'usedcolours': usedColours.map((colour) => colour.contentHashCode).toList(),
      'selection': selection.contentHashCode,
      'outline': outline.map((addresss) => addresss.contentHashCode).toList()
    });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingChart &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      chartSettings == other.chartSettings &&
      listEquals(stitches, other.stitches) &&
      listEquals(usedStitches, other.usedStitches) &&
      listEquals(usedColours, other.usedColours) &&
      selection == other.selection &&
      setEquals(outline, other.outline);
}
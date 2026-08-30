enum LegendPosition {
  bottom,
  top, 
  left,
  right
}

class KnittingChartViewSettings {
  final LegendPosition legendPosition;
  final bool showGrid;
  final bool showNoStichCells;
  final bool showStitches;
  final bool showStitchDescriptions;
  final bool showColours;

  const KnittingChartViewSettings({
    this.legendPosition = LegendPosition.right,
    this.showGrid = true,
    this.showNoStichCells = true,
    this.showStitches = true,
    this.showStitchDescriptions = false,
    this.showColours = true,
  });
  
  KnittingChartViewSettings copyWith({
    LegendPosition? legendPosition,
    bool? showGrid,
    bool? showNoStichCells,
    bool? showStitches,
    bool? showStitchDescriptions,
    bool? showColours,
  }) {
    return KnittingChartViewSettings(
      legendPosition: legendPosition?? this.legendPosition,
      showGrid: showGrid?? this.showGrid,
      showNoStichCells: showNoStichCells?? this.showNoStichCells,
      showStitches: showStitches?? this.showStitches,
      showStitchDescriptions: showStitchDescriptions?? this.showStitchDescriptions,
      showColours: showColours?? this.showColours,
    );
  }

  Map<String, Object> toJson() {
    return {
      'pos': legendPosition.name,
      'grid': showGrid,
      'nostitch': showNoStichCells,
      'sts': showStitches,
      'desc': showStitchDescriptions,
      'cols': showColours,
    };
  }

  static KnittingChartViewSettings fromJson(Map<String, dynamic> json) {
    return KnittingChartViewSettings(
      legendPosition: LegendPosition.values.byName(json['pos'] as String),
      showGrid: json['grid'] as bool,
      showNoStichCells: json.containsKey('nostitch') ? json['nostitch'] as bool : true,
      showStitches: json['sts'] as bool,
      showStitchDescriptions: json['desc'] as bool,
      showColours: json['cols'] as bool,
    );
  }

  bool get showLegend => showStitches || showColours;
  bool get legendVertical => legendPosition == LegendPosition.left || legendPosition == LegendPosition.right;
  bool get legendHorizontal => legendPosition == LegendPosition.top || legendPosition == LegendPosition.bottom;
}

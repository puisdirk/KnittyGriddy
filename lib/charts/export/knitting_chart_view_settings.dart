enum LegendPosition {
  bottom,
  top, 
  left,
  right
}

class KnittingChartViewSettings {
  final LegendPosition legendPosition;
  final bool showGrid;
  final bool showStitches;
  final bool showStitchDescriptions;
  final bool showColours;

  const KnittingChartViewSettings({
    LegendPosition? legendPosition,
    bool? showGrid,
    bool? showStitches,
    bool? showStitchDescriptions,
    bool? showColours,
  }) :
    legendPosition = legendPosition?? LegendPosition.right,
    showGrid = showGrid?? true,
    showStitches = showStitches?? true,
    showStitchDescriptions = showStitchDescriptions?? false,
    showColours = showColours?? true;
  
  KnittingChartViewSettings copyWith({
    LegendPosition? legendPosition,
    bool? showGrid,
    bool? showStitches,
    bool? showStitchDescriptions,
    bool? showColours,
  }) {
    return KnittingChartViewSettings(
      legendPosition: legendPosition?? this.legendPosition,
      showGrid: showGrid?? this.showGrid,
      showStitches: showStitches?? this.showStitches,
      showStitchDescriptions: showStitchDescriptions?? this.showStitchDescriptions,
      showColours: showColours?? this.showColours,
    );
  }

  Map<String, Object> toJson() {
    return {
      'pos': legendPosition.name,
      'grid': showGrid,
      'sts': showStitches,
      'desc': showStitchDescriptions,
      'cols': showColours,
    };
  }

  static KnittingChartViewSettings fromJson(Map<String, dynamic> json) {
    return KnittingChartViewSettings(
      legendPosition: LegendPosition.values.byName(json['pos'] as String),
      showGrid: json['grid'] as bool,
      showStitches: json['sts'] as bool,
      showStitchDescriptions: json['desc'] as bool,
      showColours: json['cols'] as bool,
    );
  }

  bool get showLegend => showStitches || showColours;
  bool get legendVertical => legendPosition == LegendPosition.left || legendPosition == LegendPosition.right;
  bool get legendHorizontal => legendPosition == LegendPosition.top || legendPosition == LegendPosition.bottom;
}

enum LegendPosition {
  bottom,
  top, 
  left,
  right
}

class ExportSettings {
  final LegendPosition legendPosition;
  final bool showStitches;
  final bool showStitchDescriptions;
  final bool showColours;

  const ExportSettings({
    LegendPosition? legendPosition,
    bool? showStitches,
    bool? showStitchDescriptions,
    bool? showColours,
  }) :
    legendPosition = legendPosition?? LegendPosition.right,
    showStitches = showStitches?? true,
    showStitchDescriptions = showStitchDescriptions?? false,
    showColours = showColours?? true;
  
  ExportSettings copyWith({
    LegendPosition? legendPosition,
    bool? showStitches,
    bool? showStitchDescriptions,
    bool? showColours,
  }) {
    return ExportSettings(
      legendPosition: legendPosition?? this.legendPosition,
      showStitches: showStitches?? this.showStitches,
      showStitchDescriptions: showStitchDescriptions?? this.showStitchDescriptions,
      showColours: showColours?? this.showColours,
    );
  }

  bool get showLegend => showStitches || showColours;
  bool get legendVertical => legendPosition == LegendPosition.left || legendPosition == LegendPosition.right;
  bool get legendHorizontal => legendPosition == LegendPosition.top || legendPosition == LegendPosition.bottom;
}

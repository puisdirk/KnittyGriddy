
import 'package:knitty_griddy/charts/export/knitting_chart_view_settings.dart';
import 'package:knitty_griddy/charts/model/chart_info.dart';
import 'package:knitty_griddy/charts/model/knitting_chart.dart';
import 'package:knitty_griddy/patterns/model/fields/pattern_field.dart';

class PatternChartField extends PatternField {
  final KnittingChart? chart;
  final KnittingChartViewSettings viewSettings;

  const PatternChartField({
    required super.id,
    super.positionX,
    super.positionY,
    super.width,
    super.height,
    super.opacity,
    this.chart,
    this.viewSettings = const KnittingChartViewSettings(),
  }) : super(fieldType: PatternFieldType.knittingchart);

  PatternChartField copyWith({
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    int? opacity,
    KnittingChart? chart,
    KnittingChartViewSettings? viewSettings,
  }) {
    return PatternChartField(
      id: id,
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      opacity: opacity?? this.opacity,
      chart: chart?? this.chart,
      viewSettings: viewSettings?? this.viewSettings,
    );
  }

  PatternChartField clearChart() {
    // Note: we can't use copyWith here as passing null will keep the current chart
    return PatternChartField(
      id: id,
      positionX: positionX,
      positionY: positionY,
      width: width,
      height: height,
      opacity: opacity,
      chart: null,
      viewSettings: viewSettings,
    );
  }

  @override
  PatternChartField abstractCopyWith({
    double? positionX, 
    double? positionY, 
    double? width, 
    double? height, 
    int? opacity,
  }) {
    return copyWith(
      positionX: positionX?? this.positionX,
      positionY: positionY?? this.positionY,
      width: width?? this.width,
      height: height?? this.height,
      opacity: opacity?? this.opacity,
    );
  }

  ChartInfo get chartInfo => chart == null ? ChartInfo.emptyChartInfo : ChartInfo(id: chart!.id, name: chart!.name, description: chart!.description);

  @override
  Map<String, Object> toJson() {
    if (chart != null) {
      return {
        'type': fieldType.name,
        'id': id,
        'x': positionX,
        'y': positionY,
        'w': width,
        'h': height,
        'o': opacity,
        'chart': chart!.toJson(),
        'settings': viewSettings.toJson(),
      };
    }

    return {
      'type': fieldType.name,
      'id': id,
      'x': positionX,
      'y': positionY,
      'w': width,
      'h': height,
      'o': opacity,
      'settings': viewSettings.toJson(),
    };
  }

  static PatternChartField fromJson(Map<String, dynamic> json) {
    KnittingChart? chart;
    if (json.containsKey('chart')) {
      chart = KnittingChart.fromJson(json['chart']);
    }

    return PatternChartField(
      id: json['id'] as String, 
      positionX: json['x'] as double,
      positionY: json['y'] as double,
      width: json['w'] as double,
      height: json['h'] as double,
      opacity: json['o'] as int,
      chart: chart,
      viewSettings: KnittingChartViewSettings.fromJson(json['settings']),
    );
  }

  @override
  bool operator ==(Object other)  =>
    identical(this, other) ||
    other is PatternChartField &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    fieldType == other.fieldType &&
    positionX == other.positionX &&
    positionY == other.positionY &&
    width == other.width &&
    height == other.height &&
    opacity == other.opacity &&
    chart == other.chart &&
    viewSettings == other.viewSettings;

  @override
  int get hashCode => super.hashCode ^ chart.hashCode ^ viewSettings.hashCode;
}
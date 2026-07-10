import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/arrow_painter.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';

enum DashStyle {
  full(dashPattern: []),
  stripes(dashPattern: [10,3]),
  mediumStripes(dashPattern: [7,3]),
  shortStripes(dashPattern: [3, 1]),
  dots(dashPattern: [1, 1]),
  stripesAndDots(dashPattern: [10, 2, 1, 2]);

  final List<double> dashPattern;

  const DashStyle({
    required this.dashPattern
  });
}

class StylingCommand extends DrawingCommand {
  final Set<String> commandIds;
  final Color color;
  final double thickness;
  final DashStyle dashStyle;
  final ArrowType startArrow;
  final ArrowType endArrow;

  const StylingCommand({
    required super.id,
    required super.label,
    required super.version,
    this.commandIds = const{},
    this.color = Colors.black,
    this.thickness = 1,
    this.dashStyle = DashStyle.full,
    this.startArrow = ArrowType.none,
    this.endArrow = ArrowType.none,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  StylingCommand copyWith({
    String? label,
    Set<String>? commandIds,
    Color? color,
    double? thickness,
    DashStyle? dashStyle,
    ArrowType? startArrow,
    ArrowType? endArrow,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return StylingCommand(
      id: id, 
      label: label?? this.label, 
      version: version + 1,
      commandIds: commandIds?? this.commandIds,
      color: color?? this.color,
      thickness: thickness?? this.thickness,
      dashStyle: dashStyle?? this.dashStyle,
      startArrow: startArrow?? this.startArrow,
      endArrow: endArrow?? this.endArrow,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 510;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) => Rect.zero;

  @override
  StylingCommand setInitiallyClosed() => copyWith(initiallyOpen: false);

  @override
  StylingCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription']
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) => commandIds;

  @override
  StylingCommand dependentLabelChanged(String oldLabel, String newLabel) => this;

  @override
  StylingCommand changePartDrawingReference({required String oldId, required String newId}) {
    return this;
  }

  @override
  StylingCommand deleteReference({required String commandId}) {
    return copyWith(commandIds: commandIds.where((c) => c != commandId).toSet());
  }

  @override
  DrawingCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[],);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[]}) {
  }

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.stylingCommand.name,
      'id': id,
      'label': label,
      'colour': {'red': color.red, 'blue': color.blue, 'green': color.green, 'alpha': color.alpha},
      'thickness': thickness,
      'dashstyle': dashStyle.name,
      'ids': commandIds.toList(),
      'startarrow': startArrow.name,
      'endarrow': endArrow.name,
    };
  }

  static StylingCommand fromJson(Map<String, dynamic> json) {
    return StylingCommand(
      id: json['id'] as String, 
      label: json['label'] as String, 
      version: 0,
      color: Color.fromARGB(json['colour']['alpha'] as int, json['colour']['red'] as int, json['colour']['green'] as int, json['colour']['blue'] as int),
      thickness: json['thickness'] as double,
      dashStyle: DashStyle.values.byName(json['dashstyle'] as String),
      commandIds: (json['ids'] as List).map((o) => o as String).toSet(),
      startArrow: ArrowType.values.byName(json['startarrow'] as String),
      endArrow: ArrowType.values.byName(json['endarrow'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
  identical(this, other) ||
    other is StylingCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    setEquals(commandIds, other.commandIds) &&
    label == other.label &&
    color == other.color &&
    thickness == other.thickness &&
    dashStyle == other.dashStyle &&
    startArrow == other.startArrow &&
    endArrow == other.endArrow;
  
  @override
  int get hashCode => super.hashCode ^ commandIds.hashCode ^ color.hashCode ^ thickness.hashCode ^ 
    dashStyle.hashCode ^ startArrow.hashCode ^ endArrow.hashCode;

  @override
  DrawingCommand validate(AbstractDrawing drawing) {
    return copyWith(
      valid: true,
      validated: true,
      errors: [],
    );
  }

}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/arrow_painter.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';

enum DashStyle {
  full(dashPattern: [], svgString: ''),
  stripes(dashPattern: [10,3], svgString: '10 3'),
  mediumStripes(dashPattern: [7,3], svgString: '7 3'),
  shortStripes(dashPattern: [3, 1], svgString: '3 1'),
  dots(dashPattern: [1, 1], svgString: '1 1'),
  separatedDots(dashPattern: [1, 3], svgString: '1 3'),
  stripesAndDots(dashPattern: [10, 2, 1, 2], svgString: '10 2 1 2'),
  stripesAndDotDots(dashPattern: [10, 2, 1, 2, 1, 2], svgString: '10 2 1 2 1 2');

  final List<double> dashPattern;
  final String svgString;

  const DashStyle({
    required this.dashPattern,
    required this.svgString,
  });
}

enum ArrowSize {
  small(label: 'S', size: 5),
  medium(label: 'M', size: 10),
  large(label: 'L', size: 16),
  ;

  final String label;
  final double size;

  const ArrowSize({
    required this.label,
    required this.size,
  });
}

class StylingCommand extends DrawingCommand {
  final Set<String> commandIds;
  final Color color;
  final double thickness;
  final DashStyle dashStyle;
  final ArrowType startArrow;
  final ArrowType endArrow;
  final ArrowSize arrowSize;

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
    this.arrowSize = ArrowSize.medium,
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
    ArrowSize? arrowSize,
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
      arrowSize: arrowSize?? this.arrowSize,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  double get editHeight => 520;

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
    return copyWith(
      commandIds: commandIds.map((cid) => cid.replaceAll(oldId, newId)).toSet()
    );
  }

  @override
  StylingCommand deleteReference({required String commandId}) {
    return copyWith(commandIds: commandIds.where((c) => c != commandId && !c.startsWith('$commandId.')).toSet());
  }

  @override
  DrawingCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[],);
  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], bool drawDirectionArrow = false, bool forPreview = false}) {
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]}) => '';

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
      'arrowsize': arrowSize.name,
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': DrawingCommandTypes.stylingCommand.name,
    'label': label,
    'colour': {'red': color.red, 'blue': color.blue, 'green': color.green, 'alpha': color.alpha},
    'thickness': thickness,
    'dashstyle': dashStyle.name,
    'ids': commandIds.toList(),
    'startarrow': startArrow.name,
    'endarrow': endArrow.name,
    'arrowsize': arrowSize.name,
  });

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
      arrowSize: ArrowSize.values.byName(json['arrowsize']),
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
    endArrow == other.endArrow &&
    arrowSize == other.arrowSize &&
    validated == other.validated &&
    valid == other.valid &&
    listEquals(errors, other.errors);
  
  @override
  bool isSameAs(Object other) =>
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
    endArrow == other.endArrow &&
    arrowSize == other.arrowSize;
  
  @override
  int get hashCode => super.hashCode ^ commandIds.hashCode ^ color.hashCode ^ thickness.hashCode ^ 
    dashStyle.hashCode ^ startArrow.hashCode ^ endArrow.hashCode ^ arrowSize.hashCode;

  @override
  DrawingCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    if (commandIds.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires elements to apply the style');
    } else {
      for (String commandId in commandIds) {
        if (commandId.contains('.')) {
          // Need to wait on validation of the included part command
          IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == commandId.split('.')[2]);
          if (!ipc.validated) {
            isvalid = false;
          }
        } else {
          DrawingCommand? command = drawing.commandById(commandId);
          if (command == null) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Element $commandId does not exist');
          } else if (!command.validated) {
            // We are not valid, but we should retry
            isvalid = false;
          } else if (!command.valid) {
            isvalid = false;
            retryValidation = false;
            validationErrors.add('Element ${command.label} has errors');
          }
        }
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
    );
  }

}
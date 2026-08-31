
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/utils/collection_utilities.dart';

enum DrawingCommandTypes {
  commentCommand,
  measurementCommand,
  variableCommand,
  pointCommand,
  lineCommand,
  curveCommand,
  partCommand,
  includedPartCommand,
  stylingCommand,
  textCommand,
  tapeCommand,
  repeatCommand,
}

@immutable
abstract class DrawingCommand implements SameAs {
  final String id;
  final int version;
  final String label;

  final bool valid;
  final bool validated;
  final List<String> errors;

  final bool initiallyOpen;

  Iterable<String> get labels => [];

  const DrawingCommand({
    required this.id,
    required this.version,
    required this.label,
    this.valid = false,
    this.validated = false,
    this.errors = const[],
    this.initiallyOpen = false,
  });

  DrawingCommand abstractCopyWith({
    String? id,
    String? label,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  });

  // How much space does the control need?
  double get editHeight;
  
  Map<String, Object> toJson();  

  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, 
    {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], 
     bool drawDirectionArrow = false, bool forPreview = false});
  
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]});

  Rect getBoundingBox(AbstractDrawing drawing);

  // React to a command being deleted by removing references to it
  DrawingCommand deleteReference({required String commandId});

  DrawingCommand changePartDrawingReference({required String oldId, required String newId});

  // React to a change in label of a command we depend on
  DrawingCommand dependentLabelChanged(String oldLabel, String newLabel);

  // Make sure the control will stay closed once we close it
  DrawingCommand setInitiallyClosed() => abstractCopyWith(initiallyOpen: false);

  DrawingCommand clearValidation() => abstractCopyWith(validated: false, valid: false, errors: const[]);

  DrawingCommand validate(AbstractDrawing drawing);

  // Get the Ids of dependent commands
  Set<String> dependencies(AbstractDrawing drawing);

  DrawingCommand markAsCyclic(String cycleDescription) => abstractCopyWith(
    validated: true,
    valid: false,
    errors: ['Cycle detected: $cycleDescription']
  );

  bool get hasErrors => validated && !valid && errors.isNotEmpty;

  String previewPath(AbstractDrawing drawing) { return ''; }

  String get contentHashCode;
  
  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ valid.hashCode ^ validated.hashCode ^ errors.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DrawingCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    valid == other.valid &&
    validated == other.validated &&
    listEquals(errors, other.errors);
}
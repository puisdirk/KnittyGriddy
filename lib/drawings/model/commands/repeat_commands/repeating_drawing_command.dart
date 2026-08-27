
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/utils/collection_utilities.dart';

enum RepeatingDrawingCommandTypes {
  repeatvariableCommand,
  repeatpointCommand,
  repeatlineCommand,
  repeatcurveCommand,
  repeattextCommand,
}

@immutable
abstract class RepeatingDrawingCommand implements SameAs {
  final String id;
  final int version;
  final String label;

  final bool valid;
  final bool validated;
  final bool retryValidation;
  final List<String> errors;

  final bool initiallyOpen;

  const RepeatingDrawingCommand({
    required this.id,
    required this.version,
    required this.label,
    this.valid = false,
    this.validated = false,
    this.retryValidation = true,
    this.errors = const[],
    this.initiallyOpen = false,
  });

  RepeatingDrawingCommand abstractCopyWith({
    String? id,
    String? label,
    bool? initiallyOpen,
  });

  double get editHeight;
  String get wrappedId;
  
  Map<String, Object> toJson();

  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected,
    {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const[], 
     bool drawDirectionArrow = false, bool forPreview = false});
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const[]});
  Rect getBoundingBox(AbstractDrawing drawing);

  RepeatingDrawingCommand deleteReference({required String commandId});
  RepeatingDrawingCommand changePartDrawingReference({required String oldId, required String newId});
  RepeatingDrawingCommand dependentLabelChanged(String oldLabel, String newLabel);
  // TODO: can't I implement this here by calling abstractCopy?
  RepeatingDrawingCommand setInitiallyClosed();

  RepeatingDrawingCommand clearValidation();
  RepeatingDrawingCommand validate(AbstractDrawing drawing, RepeatCommand repeatContext, int repeatValue);

  // Get the Ids of dependent commands
  Set<String> dependencies(AbstractDrawing drawing);

  // TODO: can't I implement this here by calling abstractCopy?
  RepeatingDrawingCommand markAsCyclic(String cycleDescription);
  bool get hasErrors => validated && !valid && errors.isNotEmpty;

  String previewPath(AbstractDrawing drawing, int repeatIndex) { return ''; }

  String get contentHashCode;
  
  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ valid.hashCode ^ validated.hashCode ^ retryValidation.hashCode ^ errors.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RepeatingDrawingCommand &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    label == other.label &&
    valid == other.valid &&
    validated == other.validated &&
    retryValidation == other.retryValidation &&
    listEquals(errors, other.errors);
}
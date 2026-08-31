import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/colour_reference.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/utils/color_utilities.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class TextCommand extends DrawingCommand {
  final String text;
  final String anchorPointId;
  final bool italic;
  final bool bold;
  final int textSize;
  final ColourReference textColor;

  final Offset? storedAnchorCoordinate;

  const TextCommand({
    required super.id,
    required super.label,
    required super.version,
    this.text = '',
    this.anchorPointId = originId,
    this.italic = false,
    this.bold = false,
    this.textSize = 12,
    this.textColor = const ColourReference(),
    this.storedAnchorCoordinate,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  TextCommand copyWith({
    String? id,
    String? label,
    String? text,
    String? anchorPointId,
    bool? italic,
    bool? bold,
    int? textSize,
    ColourReference? textColor,
    Offset? storedAnchorCoordinate,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return TextCommand(
      id: id?? this.id, 
      label: label?? this.label, 
      version: version + 1,
      text: text?? this.text,
      anchorPointId: anchorPointId?? this.anchorPointId,
      italic: italic?? this.italic,
      bold: bold?? this.bold,
      textSize: textSize?? this.textSize,
      textColor: textColor?? this.textColor,
      storedAnchorCoordinate: storedAnchorCoordinate?? this.storedAnchorCoordinate,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  TextCommand abstractCopyWith({
    String? id, 
    String? label, 
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen
  }) {
    return copyWith(
      id: id?? this.id,
      label: label?? this.label,
      validated: validated?? this.validated,
      valid: valid?? this.valid,
      errors: errors?? this.errors,
      initiallyOpen: initiallyOpen?? this.initiallyOpen,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is TextCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      text == other.text &&
      anchorPointId == other.anchorPointId &&
      italic == other.italic &&
      bold == other.bold &&
      textSize == other.textSize &&
      textColor == other.textColor &&
      storedAnchorCoordinate == other.storedAnchorCoordinate &&
      valid == other.valid &&
      validated == other.validated &&
      listEquals(errors, other.errors);
  
  @override
  bool isSameAs(Object other) =>
    identical(this, other) ||
      other is TextCommand &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      label == other.label &&
      text == other.text &&
      anchorPointId == other.anchorPointId &&
      italic == other.italic &&
      bold == other.bold &&
      textSize == other.textSize &&
      textColor == other.textColor;
  
  @override
  int get hashCode => super.hashCode ^ text.hashCode ^ anchorPointId.hashCode ^ italic.hashCode ^ bold.hashCode ^
    textSize.hashCode ^ textColor.hashCode ^ storedAnchorCoordinate.hashCode;

  @override
  Map<String, Object> toJson() {
    return {
      'type': DrawingCommandTypes.textCommand.name,
      'id': id,
      'label': label,
      'text': text,
      'anchor': anchorPointId,
      'italic': italic,
      'bold': bold,
      'textsize': textSize,
      'textcolour': textColor.toJson(),
    };
  }

  @override
  String get contentHashCode => jsonEncode({
    'type': DrawingCommandTypes.textCommand.name,
    'label': label,
    'text': text,
    'anchor': anchorPointId,
    'italic': italic,
    'bold': bold,
    'textsize': textSize,
    'textcolour': textColor.toJson(),
  });

  static TextCommand fromJson(Map<String, dynamic> json) {
    return TextCommand(
      id: json['id'] as String, 
      label: json['label'] as String, 
      version: 0,
      text: json['text'] as String,
      anchorPointId: json['anchor'] as String,
      italic: json['italic'] as bool,
      bold: json['bold'] as bool,
      textSize: json['textsize'] as int,
      textColor: ColourReference.fromJson(json['textcolour']),
    );
  }

  @override
  double get editHeight => 310;

  Offset? getAnchorCoordinate(AbstractDrawing drawing) {
    return storedAnchorCoordinate;
  }

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    if (!valid || text.isEmpty) return Rect.zero;
    Offset? anchorCoordinate = getAnchorCoordinate(drawing);
//    PointCommand? anchor = drawing.pointById(anchorPointId);
    if (anchorCoordinate == null) return Rect.zero;
    TextStyle style = TextStyle(
      fontSize: textSize.toDouble(), 
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal);
    Size ts = MathUtitilies.textSize(text, style, maxLines: text.split('\n').length);

    return Rect.fromLTWH(anchorCoordinate.dx, anchorCoordinate.dy, ts.width, ts.height);
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    Set<String> deps = {};
    if (anchorPointId.isNotEmpty) deps.add(anchorPointId);
    if (textColor.measurementId.isNotEmpty) deps.add(textColor.measurementId);
    return deps;
  }

  @override
  TextCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(anchorPointId: anchorPointId.replaceAll(oldId, newId));
  }

  @override
  TextCommand deleteReference({required String commandId}) {
    return copyWith(
      anchorPointId: (anchorPointId == commandId || anchorPointId.startsWith('$commandId.')) ? '' : anchorPointId,
      textColor: textColor.deleteReference(commandId: commandId),
    );
  }

  @override
  TextCommand dependentLabelChanged(String oldLabel, String newLabel) {
    return copyWith(
      textColor: textColor.dependentLabelChanged(oldLabel, newLabel),
    );
  }

  @override
  String toSvg(Size drawingSize, AbstractDrawing drawing, {List<StylingCommand> stylings = const []}) {
    if (!valid) return '';

    Offset? coord = getAnchorCoordinate(drawing);
    if (coord == null) return '';
    coord = coord.scale(1, -1);

    Offset middle = Offset(drawingSize.width / 2, drawingSize.height / 2);
    coord += middle;

    return '<g id="$label"><text fill="${ColorUtilities.colorToSvhHex(textColor.color)}" font-style="${italic ? 'italic' : 'normal'}" font-weight="${bold ? 'bold' : 'normal'}" font-size="$textSize" font-family="Roboto" x="${coord.dx}" y="${coord.dy}">$text</text></g>';

  }

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const [], bool drawDirectionArrow = false, bool forPreview = false}) {
    if (!valid) return;

    Offset? coord = getAnchorCoordinate(drawing);
    if (coord == null) return;
    coord = coord.scale(1, -1);

    Offset middle = Offset(size.width / 2, size.height / 2);
    coord += middle;

    TextStyle style = TextStyle(
      color: (!forPreview && selected) ? selectedColor : textColor.color,
      fontSize: textSize.toDouble(),
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
    );

    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        fontSize: style.fontSize,
        fontStyle: style.fontStyle,
        fontWeight: style.fontWeight,
        textAlign: TextAlign.justify,
      ),
    )
    ..pushStyle(style.getTextStyle())
    ..addText(text);

    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph, coord);

  }

  @override
  DrawingCommand validate(AbstractDrawing drawing) {
    bool isvalid = true;
    bool retryValidation = true;
    List<String> validationErrors = [];

    if (label.isEmpty) { isvalid = false; retryValidation = false; validationErrors.add('Requires a label'); }
    if (drawing.commands.any((c) => c.id != id && c.label == label)) { isvalid = false; retryValidation = false; validationErrors.add('Label should be unique'); }

    PointCommand? anchorPoint;
    if (anchorPointId.isEmpty) {
      isvalid = false;
      retryValidation = false;
      validationErrors.add('Requires an anchor point');
    } else if (anchorPointId == originId) {
      anchorPoint = origin;
    } else {
      anchorPoint = drawing.pointById(anchorPointId);
      if (anchorPoint == null) {
        isvalid = false;
        retryValidation = false;
        validationErrors.add('Anchor point does not exist');
      } else if (anchorPointId.contains('.')) {
        // need to wait on validation of the included part command
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.id == anchorPointId.split('.')[2]);
        if (!ipc.validated) {
          isvalid = false;
        }
      } else {
        if (!anchorPoint.validated) {
          // We are not valid, but we should retry
          isvalid = false;
        } else if (!anchorPoint.valid) {
          isvalid = false;
          retryValidation = false;
          validationErrors.add('Anchor point ${anchorPoint.label} has errors');
        }
      }
    }

    return copyWith(
      valid: isvalid,
      validated: (isvalid || !retryValidation),
      errors: validationErrors,
      textColor: textColor.checkForUpdate(drawing),
      storedAnchorCoordinate: isvalid ? anchorPoint?.getCoordinate(drawing) : null,
    );
  }
}
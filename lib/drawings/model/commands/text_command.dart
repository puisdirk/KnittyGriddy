import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/styling_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:knitty_griddy/utils/math_utitilies.dart';

class TextCommand extends DrawingCommand {
  final String text;
  final String anchorPointId;
  final bool italic;
  final bool bold;
  final int textSize;
  final Color textColor;

  const TextCommand({
    required super.id,
    required super.label,
    required super.version,
    this.text = '',
    this.anchorPointId = originId,
    this.italic = false,
    this.bold = false,
    this.textSize = 12,
    this.textColor = Colors.black,
    super.validated,
    super.valid,
    super.errors,
    super.initiallyOpen,
  });

  TextCommand copyWith({
    String? label,
    String? text,
    String? anchorPointId,
    bool? italic,
    bool? bold,
    int? textSize,
    Color? textColor,
    bool? validated,
    bool? valid,
    List<String>? errors,
    bool? initiallyOpen,
  }) {
    return TextCommand(
      id: id, 
      label: label?? this.label, 
      version: version + 1,
      text: text?? this.text,
      anchorPointId: anchorPointId?? this.anchorPointId,
      italic: italic?? this.italic,
      bold: bold?? this.bold,
      textSize: textSize?? this.textSize,
      textColor: textColor?? this.textColor,
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
      valid == other.valid &&
      validated == other.validated &&
      listEquals(errors, other.errors);
  
  @override
  int get hashCode => super.hashCode ^ text.hashCode ^ anchorPointId.hashCode ^ italic.hashCode ^ bold.hashCode ^
    textSize.hashCode ^ textColor.hashCode;

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
      'textcolour': {'red': textColor.red, 'blue': textColor.blue, 'green': textColor.green, 'alpha': textColor.alpha},
    };
  }

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
      textColor: Color.fromARGB(json['textcolour']['alpha'] as int, json['textcolour']['red'] as int, json['textcolour']['green'] as int, json['textcolour']['blue'] as int),
    );
  }

  @override
  double get editHeight => 300;

  @override
  Rect getBoundingBox(AbstractDrawing drawing) {
    if (!valid || text.isEmpty) return Rect.zero;
    PointCommand? anchor = drawing.pointById(anchorPointId);
    if (anchor == null) return Rect.zero;
    TextStyle style = TextStyle(
      fontSize: textSize.toDouble(), 
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal);
    Size ts = MathUtitilies.textSize(text, style, maxLines: text.split('\n').length);

    return Rect.fromLTWH(anchor.getCoordinate(drawing)!.dx, anchor.getCoordinate(drawing)!.dy, ts.width, ts.height);
  }

  @override
  TextCommand setInitiallyClosed() {
    return copyWith(initiallyOpen: false);
  }

  @override
  TextCommand markAsCyclic(String cycleDescription) {
    return copyWith(
      validated: true,
      valid: false,
      errors: ['Cycle detected: $cycleDescription'],
    );
  }

  @override
  Set<String> dependencies(AbstractDrawing drawing) {
    if (anchorPointId.isNotEmpty) return {anchorPointId};
    return {};
  }

  @override
  TextCommand clearValidation() {
    return copyWith(validated: false, valid: false, errors: const[]);
  }

  @override
  TextCommand changePartDrawingReference({required String oldId, required String newId}) {
    return copyWith(anchorPointId: anchorPointId.replaceAll(oldId, newId));
  }

  @override
  TextCommand deleteReference({required String commandId}) {
    return copyWith(anchorPointId: anchorPointId == commandId ? '' : anchorPointId);
  }

  @override
  DrawingCommand dependentLabelChanged(String oldLabel, String newLabel) => this;

  @override
  void paint(Canvas canvas, Size size, AbstractDrawing drawing, bool selected, {bool asPart = false, String prefixLabel = '', List<StylingCommand> stylings = const []}) {
    if (!valid) return;

    PointCommand? anchorPoint = drawing.pointById(anchorPointId);
    if (anchorPoint == null) return;

    Offset? coord = anchorPoint.getCoordinate(drawing);
    if (coord == null) return;
    coord = coord.scale(1, -1);

    Offset middle = Offset(size.width / 2, size.height / 2);
    coord += middle;

    TextStyle style = TextStyle(
      color: selected ? selectedColor : textColor,
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
        IncludedPartCommand ipc = drawing.includedParts.firstWhere((c) => c.partInfo?.partDrawingId == anchorPointId.split('.').first);
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
    );
  }
}
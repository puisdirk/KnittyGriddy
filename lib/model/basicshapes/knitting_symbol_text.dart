import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:knitty_griddy/model/basicshapes/text_entry_control.dart';
import 'package:knitty_griddy/model/knitting_symbol.dart';
import 'package:knitty_griddy/model/knitting_symbol_part.dart';
import 'package:knitty_griddy/stitchrepo/stitch_definition.dart';

class KnittingSymbolText extends KnittingSymbolPart {

  static const String _defaultText = 'T';
  static const bool _defaultBold = false;
  static const bool _defaultItalic = false;

  final String text;
  final bool bold;
  final bool italic;

  const KnittingSymbolText({
    required super.name,
    String? text,
    bool? bold,
    bool? italic,
    super.filled,
    super.strokeWidth,
    super.scale,
    super.translation,
    super.rotation,
  }) : 
    text = text?? _defaultText,
    bold = bold?? _defaultBold,
    italic = italic?? _defaultItalic,
    super(allowStroke: false);

  @override
  KnittingSymbolPart copyWith({
    String? name, 
    String? text,
    bool? bold,
    bool? italic,
    Offset? scale, 
    Offset? translation, 
    double? rotation, 
    bool? filled, 
    double? strokeWidth}) {
    return KnittingSymbolText(
      name: name?? this.name, 
      text: text?? this.text,
      bold: bold?? this.bold,
      italic: italic?? this.italic,
      scale: scale?? this.scale,
      translation: translation?? this.translation,
      rotation: rotation?? this.rotation,
      filled: filled?? this.filled,
      strokeWidth: strokeWidth?? this.strokeWidth,
    );
  }

  @override
  int get hashCode => super.hashCode ^ text.hashCode ^ bold.hashCode ^ italic.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is KnittingSymbolText &&
      name == other.name &&
      text == other.text &&
      bold == other.bold &&
      italic == other.italic &&
      scale == other.scale &&
      translation == other.translation &&
      rotation == other.rotation &&
      filled == other.filled &&
      strokeWidth == other.strokeWidth;

  @override
  void drawPart(Canvas canvas, Size size, Paint ink) {
    TextStyle style = TextStyle(
      color: ink.color,// Colors.black,
      fontSize: 24,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );

    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(
        fontSize: style.fontSize,
        fontFamily: style.fontFamily,
        fontStyle: style.fontStyle,
        fontWeight: style.fontWeight,
        textAlign: TextAlign.center,
      ),
    )
    ..pushStyle(style.getTextStyle())
    ..addText(text);

    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width * 100));

    canvas.drawParagraph(paragraph, 
      Offset(
        (size.width / 2) - (paragraph.width / 2), 
        (size.height / 2) - (paragraph.height / 2)
      )
    );
  }

  @override
  Widget getPartControls(StitchDefinition stitchDefinition, int partColumn, int partRow, Function(StitchDefinition newDefinition) onChanged) {
    Set<String> styles = {};
    if (bold) { styles.add('bold'); }
    if (italic) { styles.add('italic'); }
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Text'),
              ),
            ),
            const SizedBox(width: 10,),
            TextEntryControl(
              initialText: text,
              width: 250,
              onChanged: (String newText) {
                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == partColumn) {
                    List<KnittingSymbolPart> newParts = [];
                    for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                      if (row == partRow) {
                        newParts.add(copyWith(text: newText));
                      } else {
                        newParts.add(stitchDefinition.symbolPartAt(col, row));
                      }
                    }
                    newSymbols.add(stitchDefinition.symbolAt(col).copyWith(parts: newParts));
                  } else {
                    newSymbols.add(stitchDefinition.symbolAt(col));
                  }
                }
            
                onChanged(stitchDefinition.copyWith(
                  symbols: newSymbols
                ));
              }
            ),
            const SizedBox(width: 10,),
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Style'),
              ),
            ),
            const SizedBox(width: 10,),
            SegmentedButton<String>(
              emptySelectionAllowed: true,
              multiSelectionEnabled: true,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 'bold',
                  label: Text('Bold', style: TextStyle(fontWeight: FontWeight.w900),)
                ),
                ButtonSegment(
                  value: 'italic',
                  label: Text('Italic', style: TextStyle(fontStyle: FontStyle.italic),)
                )
              ], 
              selected: styles,
              onSelectionChanged: (values) {
                bool becomebold = values.contains('bold');
                bool becomeItalic = values.contains('italic');

                List<KnittingSymbol> newSymbols = [];
            
                for (int col = 0; col < stitchDefinition.columns; col++) {
                  if (col == partColumn) {
                    List<KnittingSymbolPart> newParts = [];
                    for (int row = 0; row < stitchDefinition.symbolAt(col).rows; row++) {
                      if (row == partRow) {
                        newParts.add(copyWith(bold: becomebold, italic: becomeItalic));
                      } else {
                        newParts.add(stitchDefinition.symbolPartAt(col, row));
                      }
                    }
                    newSymbols.add(stitchDefinition.symbolAt(col).copyWith(parts: newParts));
                  } else {
                    newSymbols.add(stitchDefinition.symbolAt(col));
                  }
                }
            
                onChanged(stitchDefinition.copyWith(
                  symbols: newSymbols
                ));
              },
            )
          ],
        )
      ],
    );
  }

  @override
  String toString() {
    String defString = '''
KnittingSymbolText(
  name: '$name',''';

    if (text != _defaultText) {
      defString += '''text: '$text',''';
    }

    if (bold != _defaultBold) {
      defString += '''bold: $bold,''';
    }

    if (italic != _defaultItalic) {
      defString += '''italic: $italic,''';
    }

    if (scale != KnittingSymbolPart.defaultScale) {
      defString += '''scale: Offset(${scale.dx}, ${scale.dy}),''';
    }
    
    if (translation != KnittingSymbolPart.defaultTranslation) {
      defString += '''translation: Offset(${translation.dx}, ${translation.dy}),''';
    }
    
    if (rotation != KnittingSymbolPart.defaultRotation) {
      defString += '''rotation: $rotation,''';
    }

    if (filled != KnittingSymbolPart.defaultFilled) {
      defString += '''filled: $filled,''';
    }
  
    if (strokeWidth != KnittingSymbolPart.defaultStrokeWidth) {
      defString += '''strokeWidth: $strokeWidth,''';
    }

    defString += ''')''';

    return defString;
  }
}
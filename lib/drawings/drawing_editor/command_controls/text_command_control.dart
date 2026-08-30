import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_multiline_text_field.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/colour_reference.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/text_command.dart';
import 'package:knitty_griddy/pick_colour_dialog.dart';
import 'package:knitty_griddy/pick_colour_reference_dialog.dart';
import 'package:knitty_griddy/utils/constants.dart';

class TextCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final TextCommand command;
  final bool sorting;
  final bool editing;
  final void Function(TextCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(TextCommand newCommand) onChanged;

  const TextCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<TextCommandControl> createState() => _TextCommandControlState();
}

class _TextCommandControlState extends State<TextCommandControl> {

  static const double _fieldWidth = 260;

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      // No need to tell others, so no need to call onChangeLabel
      widget.onChanged(widget.command.copyWith(label: newText));
    }
  }

  Widget createViewContent() {

    return Row(
      children: [
        const Icon(Icons.title),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold),
                TextSpan(text: widget.command.text.isEmpty ? ' ???' : ' ${widget.command.text}', style: smallStyle,)
              ]  
            ),
          )
        )
      ],
    );
  }

  Widget createEditContent() {
    Set<String> styles = {};
    if (widget.command.bold) { styles.add('bold'); }
    if (widget.command.italic) { styles.add('italic'); }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.title),
            hspacing,
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label',),
            hspacing,
            SmallTextField(
              key: ValueKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: labelChanged,
            ),
            hspacing,
            const SmallLabel(label: 'Anchor'),
            hspacing,
            DropdownButton<String>(
              key: ValueKey('${widget.command.id}-anchor'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in widget.drawing.points)
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.anchorPointId) {
                  widget.onChanged(
                    widget.command.copyWith(
                      anchorPointId: value?? '',
                    )
                  );
                }
              },
              value: widget.command.anchorPointId,
            ),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Text'),
            hspacing,
            SmallMultilineTextField(
              initialText: widget.command.text, 
              width: _fieldWidth, 
              lines: 3, 
              onTextChanged: (newText) => widget.onChanged(widget.command.copyWith(text: newText)),
            ),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Size'),
            hspacing,
            SizedBox(
              width: 180,
              child: SpinBox(
                key: ValueKey('${widget.command.id}-textSize'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != widget.command.textSize) {
                    widget.onChanged(widget.command.copyWith(textSize: value.toInt()));
                  }
                },
                min: 3,
                max: 200,
                value: widget.command.textSize.toDouble(),
              ),
            )
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Colour'),
            hspacing,
            GestureDetector(
              onTap: () async {
                ColourReference? newColorRef = await showDialog(
                  context: context,
                  builder: (context) {
                    return PickColourReferenceDialog(
                      drawing: widget.drawing,
                      initialColor: widget.command.textColor,
                      knownColours: widget.drawing.knownColours,
                    );
                  }
                );
                if (newColorRef != null && newColorRef != widget.command.textColor) {
                  widget.onChanged(widget.command.copyWith(textColor: newColorRef));
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)), 
                        border: Border.all(color: Colors.grey)
                      ), 
                      width: 40, 
                      height: 30,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                            color: widget.command.textColor.color,
                          ),
                          width: 34,
                          height: 24,
                        ),
                      ),
                    ),
                    hspacing,
                    if (widget.command.textColor.measurementId.isNotEmpty)
                      Text('@${widget.command.textColor.measurementLabel}', style: smallStyle,)                    
                  ],
                ),
              ),
            ),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Style'),
            hspacing,
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

                widget.onChanged(widget.command.copyWith(bold: becomebold, italic: becomeItalic));
              }
            )
          ],
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
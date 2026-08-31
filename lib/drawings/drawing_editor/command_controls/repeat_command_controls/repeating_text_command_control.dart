import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_multiline_text_field.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/colour_reference.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_text_command.dart';
import 'package:knitty_griddy/common/pick_colour_reference_dialog.dart';
import 'package:knitty_griddy/utils/constants.dart';

class RepeatingTextCommandControl extends StatelessWidget {
  final AbstractDrawing drawing;
  final RepeatingTextCommand command;
  final RepeatCommand repeatContext;
  final bool sorting;
  final bool editing;
  final void Function(RepeatingTextCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatingTextCommand newCommand) onChanged;

  const RepeatingTextCommandControl({
    required this.drawing,
    required this.command,
    required this.repeatContext,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  static const double _fieldWidth = 210;

  void labelChanged(String newText) {
    if (command.label != newText) {
      // No need to tell others, so no need to call onChangeLabel
      onChanged(command.copyWith(label: newText, wrappedText: command.wrappedText.copyWith(label: newText)));
    }
  }

  Widget createViewContent() {

    return Row(
      children: [
        const Icon(Icons.title),
        hspacing,
        SizedBox(
          width: command.hasErrors ? repeatcommandControlViewWidth : repeatcommandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: command.label, style: smallStyleBold),
                TextSpan(text: command.wrappedText.text.isEmpty ? ' ???' : ' ${command.wrappedText.text}', style: smallStyle,)
              ]  
            ),
          )
        )
      ],
    );
  }

  Widget createEditContent(BuildContext context) {
    Set<String> styles = {};
    if (command.wrappedText.bold) { styles.add('bold'); }
    if (command.wrappedText.italic) { styles.add('italic'); }

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
              key: ValueKey('${command.id}-${command.version}-label'),
              initialText: command.label,
              width: 100,
              onTextChanged: labelChanged,
            ),
            const SmallLabel(label: 'Anchor'),
            hspacing,
            DropdownButton<String>(
              key: ValueKey('${command.id}-anchor'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),

                for (RepeatingPointCommand point in repeatContext.points)
                  DropdownMenuItem(value: point.id, child: Text(point.label)),

                DropdownMenuItem(value: origin.id, child: Text(origin.label)),

                for (PointCommand point in drawing.points)
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != command.wrappedText.anchorPointId) {
                  onChanged(
                    command.copyWith(
                      wrappedText: command.wrappedText.copyWith(
                        anchorPointId: value?? '',
                    )
                  ));
                }
              },
              value: command.wrappedText.anchorPointId,
            ),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Text'),
            hspacing,
            SmallMultilineTextField(
              initialText: command.wrappedText.text, 
              width: _fieldWidth, 
              lines: 3, 
              onTextChanged: (newText) => onChanged(
                command.copyWith(
                  wrappedText: command.wrappedText.copyWith(
                    text: newText
                  )
                )
              ),
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
                key: ValueKey('${command.id}-textSize'),
                textStyle: smallStyle,
                onChanged: (value) {
                  if (value != command.wrappedText.textSize) {
                    onChanged(
                      command.copyWith(
                        wrappedText: command.wrappedText.copyWith(
                          textSize: value.toInt()
                        )
                      )
                    );
                  }
                },
                min: 3,
                max: 200,
                value: command.wrappedText.textSize.toDouble(),
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
                      drawing: drawing,
                      initialColor: command.wrappedText.textColor,
                      knownColours: drawing.knownColours,
                    );
                  }
                );
                if (newColorRef != null && newColorRef != command.wrappedText.textColor) {
                  onChanged(
                    command.copyWith(
                      wrappedText: command.wrappedText.copyWith(
                        textColor: newColorRef
                      )
                    )
                  );
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
                            color: command.wrappedText.textColor.color
                          ),
                          width: 34,
                          height: 24,
                        ),
                      ),
                    ),
                    hspacing,
                    if (command.wrappedText.textColor.measurementId.isNotEmpty)
                      Text('@${command.wrappedText.textColor.measurementLabel}')
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

                onChanged(
                  command.copyWith(
                    wrappedText: command.wrappedText.copyWith(
                      bold: becomebold, italic: becomeItalic
                    )
                  )
                );
              }
            )
          ],
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return (editing && !sorting) ? createEditContent(context) : createViewContent();
  }
}
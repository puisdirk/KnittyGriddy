import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/repeat_commands/repeating_point_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepeatingLineCommandControl extends StatelessWidget {
  final AbstractDrawing drawing;
  final RepeatingLineCommand command;
  final RepeatCommand repeatContext;
  final bool sorting;
  final bool editing;
  final void Function(RepeatingLineCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(RepeatingLineCommand newCommand) onChanged;

  const RepeatingLineCommandControl({
    required this.drawing,
    required this.command,
    required this.repeatContext,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  void lineLabelChanged(String newText) {
    if (command.label != newText) {
      onChangeLabel(
        command.copyWith(
          label: newText,
          wrappedLine: command.wrappedLine.copyWith(label: newText)
        ), 
        command.label
      );
    }
  }

  Widget createViewContent() {
    String content = '';

    String point1label = drawing.commandLabelIncluded(command.wrappedLine.fromPointId, repeatContext: repeatContext);
    String point2label = drawing.commandLabelIncluded(command.wrappedLine.toPointId, repeatContext: repeatContext);

    content += 'from $point1label to $point2label';

    return Row(
      children: [
        const Icon(Symbols.pen_size_2),
        hspacing,
        SizedBox(
          width: command.hasErrors ? repeatcommandControlViewWidth : repeatcommandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: command.label, style: smallStyleBold,),
                TextSpan(text: ' $content', style: smallStyle)
              ]  
            ),
          )
        )
      ],
    );
  }

  Widget createEditContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.pen_size_2),
            hspacing,
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(
              key: ValueKey('${command.id}-${command.version}-label'),
              initialText: command.label,
              width: 100,
              onTextChanged: lineLabelChanged,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'From'),
            hspacing,
            DropdownButton<String>(
              key: ValueKey('${command.id}-from'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),

                for (RepeatingPointCommand point in repeatContext.points.where((p) => p.id != command.wrappedLine.toPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),

                if (command.wrappedLine.toPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                
                for (PointCommand point in drawing.pointsIncluded.where((p) => p.id != command.wrappedLine.toPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != command.wrappedLine.fromPointId) {
                  onChanged(command.copyWith(
                    wrappedLine: command.wrappedLine.copyWith(
                      fromPointId: value?? ''
                    )
                  ));
                }
              },
              value: command.wrappedLine.fromPointId,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'To'),
            hspacing,
            DropdownButton<String>(
              key: ValueKey('${command.id}-to'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),

                for (RepeatingPointCommand point in repeatContext.points.where((p) => p.id != command.wrappedLine.fromPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),

                if (command.wrappedLine.fromPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                
                for (PointCommand point in drawing.pointsIncluded.where((p) => p.id != command.wrappedLine.fromPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != command.wrappedLine.toPointId) {
                  onChanged(command.copyWith(
                    wrappedLine: command.wrappedLine.copyWith(
                      toPointId: value?? ''
                    )
                  ));
                }
              },
              value: command.wrappedLine.toPointId,
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (editing && !sorting) ? createEditContent() : createViewContent();
  }
}
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class LineCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final LineCommand command;
  final bool sorting;
  final bool editing;
  final void Function(LineCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(LineCommand newCommand) onChanged;

  const LineCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<LineCommandControl> createState() => _LineCommandControlState();
}

class _LineCommandControlState extends State<LineCommandControl> {

  void lineLabelChanged(String newText) {
    if (widget.command.label != newText) {
      widget.onChangeLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget createViewContent() {
    String content = '';

    String point1label = widget.drawing.commandLabelIncluded(widget.command.fromPointId);
    String point2label = widget.drawing.commandLabelIncluded(widget.command.toPointId);

    content += 'from $point1label to $point2label';

    return Row(
      children: [
        const Icon(Symbols.pen_size_2),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold,),
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
              key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
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
              key: GlobalObjectKey('${widget.command.id}-from'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                if (widget.command.toPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in widget.drawing.pointsIncluded.where((p) => p.id != widget.command.toPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.fromPointId) {
                  widget.onChanged(widget.command.copyWith(fromPointId: value?? ''));
                }
              },
              value: widget.command.fromPointId,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'To'),
            hspacing,
            DropdownButton<String>(
              key: GlobalObjectKey('${widget.command.id}-to'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                if (widget.command.fromPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in widget.drawing.pointsIncluded.where((p) => p.id != widget.command.fromPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.toPointId) {
                  widget.onChanged(widget.command.copyWith(toPointId: value?? ''));
                }
              },
              value: widget.command.toPointId,
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
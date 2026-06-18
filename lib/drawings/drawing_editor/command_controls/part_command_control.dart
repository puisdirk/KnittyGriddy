
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/drawing_command.dart';
import 'package:knitty_griddy/drawings/model/commands/part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class PartCommandControl extends StatefulWidget {
  final PartCommand command;
  final bool sorting;
  final bool editing;
  
  const PartCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<PartCommandControl> createState() => _PartCommandControlState();
}

class _PartCommandControlState extends State<PartCommandControl> {

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommandLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  Widget createViewContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    String content = ' Part with';
    String partLabels = '???';

    if (widget.command.commandIds.isNotEmpty) {
      partLabels = '';
      for (String id in widget.command.commandIds) {
        partLabels += drawing.commandById(id).label;
        partLabels += ', ';
      }
    }

    return Row(
      children: [
        const Icon(Icons.extension_outlined),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold),
                TextSpan(text: '$content $partLabels', style: smallStyle,)
              ]  
            ),
          )
        )
      ],
    );
  }

  Widget createEditContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Part', style: smallStyle,),
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
              onTextChanged: labelChanged,
            ),
            hspacing,
            const SmallLabel(label: 'Anchor'),
            hspacing,
            DropdownButton<String>(
              key: GlobalObjectKey('${widget.command.id}-anchor'),
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != widget.command.id))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              value: widget.command.anchorPointId,
              onChanged: (value) {
                if (value != null && value != widget.command.anchorPointId) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(anchorPointId: value));
                }
              },
            ),
          ],
        ),
        vspacing,
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SmallLabel(label: 'Elements'),
            vspacing,
            SizedBox(
              width: 320, height: 180,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(5))
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      DropdownButton<DrawingCommand>(
                        key: GlobalObjectKey('${widget.command.id}-chooser'),
                        isDense: true,
                        autofocus: false,
                        style: smallStyle,
                        itemHeight: kMinInteractiveDimension,
                        focusColor: Colors.transparent,
                        underline: Container(),
                        items: [
                          for (DrawingCommand cmd in drawing.linesAndCurves.where((c) => !widget.command.commandIds.contains(c.id)))
                            DropdownMenuItem(value: cmd, child: Text(cmd.label)),
                        ], 
                        onChanged: (value) {
                          if (value != null) {
                            Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(
                              widget.command.copyWith(commandIds: {...widget.command.commandIds, value.id}));
                          }
                        },
                        value: null,
                      ),
                      for (String id in widget.command.commandIds)
                        Chip(
                          label: Text(drawing.commandLabel(id), style: smallStyle,),
                          onDeleted: () => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(
                            widget.command.copyWith(commandIds: widget.command.commandIds.where((c) => c != id).toSet())
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class LineCommandControl extends StatefulWidget {
  final LineCommand command;
  final void Function(LineCommand newCommand) finishedEditing;
  final bool sorting;

  const LineCommandControl({
    required this.command,
    required this.finishedEditing,
    required this.sorting,
    super.key
  });

  @override
  State<LineCommandControl> createState() => _LineCommandControlState();
}

class _LineCommandControlState extends State<LineCommandControl> {
  bool editing = false;
  late LineCommand changedCommand;

  late TextEditingController lineLabelController;

  void lineLabelChanged() {
    setState(() => changedCommand = changedCommand.copyWith(label: lineLabelController.text));
  }

  @override
  void initState() {
    changedCommand = widget.command.copyWith();

    lineLabelController = TextEditingController(text: changedCommand.label);
    lineLabelController.addListener(lineLabelChanged);

    super.initState();
  }

  @override
  void dispose() {
    lineLabelController.removeListener(lineLabelChanged);
    lineLabelController.dispose();

    super.dispose();
  }

  Widget createViewContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;
    
    String content = 'Line ';

    String point1label = '???';
    PointCommand? p1 = drawing.pointById(changedCommand.fromPointId);
    if (p1 != null) {
      point1label = p1.label;
    }

    String point2label = '???';
    PointCommand? p2 = drawing.pointById(changedCommand.toPointId);
    if (p2 != null) {
      point2label = p2.label;
    }

    content += 'from $point1label to $point2label';

    return Row(
      children: [
        Text(changedCommand.label, style: smallStyleBold,),
        hspacing,
        Text(content, style: smallStyle,),
        const Spacer(),
        if (!widget.sorting && widget.command.isValidated && !widget.command.valid && widget.command.errors.isNotEmpty)
          Tooltip(
            message: widget.command.errors.join('\n'),
            child: const Icon(Icons.error_outline),
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
            Text('Line', style: smallStyle,),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(controller: lineLabelController, width: 100),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'From'),
            hspacing,
            DropdownButton<String>(
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                if (changedCommand.toPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != changedCommand.toPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(fromPointId: value)),
              value: changedCommand.fromPointId,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'To'),
            hspacing,
            DropdownButton<String>(
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                const DropdownMenuItem(value: '', child: Text('')),
                if (changedCommand.fromPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != changedCommand.fromPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(toPointId: value)),
              value: changedCommand.toPointId,
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double controlHeight = 60;
    if (editing && !widget.sorting) {
      controlHeight = 170;
    }

    return SizedBox(
      height: controlHeight,
      child: Container(
        decoration: BoxDecoration(
          color: (widget.command.validated && !widget.command.valid) ? Colors.red.withAlpha(20) : Colors.grey.shade100,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: (editing && !widget.sorting) ? createEditContent() : createViewContent(),
              ),
              if (!widget.sorting)
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (editing) {
                        widget.finishedEditing(changedCommand);
                      }
                      setState(() => editing = !editing);
                    }, 
                    icon: editing ? const Icon(Icons.check) : const Icon(Icons.edit),
                  ),
                  if (editing)
                    IconButton(
                      onPressed: () => widget.finishedEditing(changedCommand), 
                      icon: const Icon(Icons.refresh)
                    ),
                  const Spacer(),
                  if (editing && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
                    Tooltip(
                      message: widget.command.errors.join('\n'),
                      child: const Icon(Icons.error_outline),
                    ),
                  if (editing && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
                    const Spacer(),
                  if (editing)
                    IconButton(
                      onPressed: () => Provider.of<DrawingsModel>(context, listen: false).deleteCommand(commandId: changedCommand.id), 
                      icon: const Icon(Icons.delete)
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
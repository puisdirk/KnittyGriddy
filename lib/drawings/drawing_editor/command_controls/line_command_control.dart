import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class LineCommandControl extends StatefulWidget {
  final LineCommand command;
  final bool sorting;
  final bool editing;

  const LineCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<LineCommandControl> createState() => _LineCommandControlState();
}

class _LineCommandControlState extends State<LineCommandControl> {
  late TextEditingController lineLabelController;

  void lineLabelChanged() {
    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: lineLabelController.text));
  }

  @override
  void initState() {
    lineLabelController = TextEditingController(text: widget.command.label);
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
    PointCommand? p1 = drawing.pointById(widget.command.fromPointId);
    if (p1 != null) {
      point1label = p1.label;
    }

    String point2label = '???';
    PointCommand? p2 = drawing.pointById(widget.command.toPointId);
    if (p2 != null) {
      point2label = p2.label;
    }

    content += 'from $point1label to $point2label';

    return Row(
      children: [
        Text(widget.command.label, style: smallStyleBold,),
        hspacing,
        Text(content, style: smallStyle,),
        const Spacer(),
        if (!widget.sorting && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
          Tooltip(
            message: widget.command.errors.join('\n'),
            child: const Icon(Icons.error_outline),
          ),
        if (!widget.sorting && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
          hspacing,
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
            SmallTextField(
              key: GlobalObjectKey('${widget.command.id}-label'),
              controller: lineLabelController, 
              width: 100
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
                for (PointCommand point in drawing.points.where((p) => p.id != widget.command.toPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(fromPointId: value?? '')),
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
                for (PointCommand point in drawing.points.where((p) => p.id != widget.command.fromPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) => Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(toPointId: value?? '')),
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
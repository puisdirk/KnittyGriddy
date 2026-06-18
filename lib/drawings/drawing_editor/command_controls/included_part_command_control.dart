
import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/drawing_part_icon.dart';
import 'package:knitty_griddy/drawings/model/commands/included_part_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/drawings/model/part_info.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class IncludedPartCommandControl extends StatefulWidget {
  final IncludedPartCommand command;
  final bool sorting;
  final bool editing;

  const IncludedPartCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<IncludedPartCommandControl> createState() => _IncludedPartCommandControlState();
}

class _IncludedPartCommandControlState extends State<IncludedPartCommandControl> {

  void labelChanged(String newText) {
    if (widget.command.label != newText) {
      // Included part labels are never used in formula's, so we don't need to call changeDrawingCommandLabel
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: newText));
    }
  }

  Widget createViewContent() {
    String content = ' Included part ???';

    return Row(
      children: [
        const Icon(Symbols.apparel),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold,),
                TextSpan(text: content, style: smallStyle,)
              ]
            )
          ),
        )
      ],
    );
  }

  Widget createEditContent() {
    Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;
    List<PartInfo> partInfos = Provider.of<DrawingsModel>(context, listen: false).partInfos;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Included part', style: smallStyle,),
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
          ],
        ),
        vspacing,
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Part'),
            hspacing,
            if (partInfos.isEmpty)
              const Text('No parts found', style: smallStyle,),
            if (partInfos.isNotEmpty)
              DropdownButton<String>(
                key: GlobalObjectKey('${widget.command.id}-part'),
                isDense: true,
                autofocus: false,
                style: smallStyle,
                itemHeight: kMinInteractiveDimension,
                focusColor: Colors.transparent,
                underline: Container(),
                items: [
                  const DropdownMenuItem(value: '', child: Text('')),
                  for (PartInfo partInfo in partInfos.where((p) => p.drawingId != drawing.id))
                    DropdownMenuItem(
                      value: partInfo.id, 
                      child: Row(
                        children: [
                          DrawingPartIcon(partInfo: partInfo,),
                          hspacing,
                          Text(partInfo.name),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != widget.command.partId) {
                    Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(partId: value?? ''));
                  }
                },
                value: widget.command.partId,
              ),
          ]
        ),
        vspacing,
        vspacing,
        Row(
          children: [
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
                const DropdownMenuItem(value: '', child: Text('')),
                DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points)
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) {
                if (value != widget.command.anchorPointId) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(anchorPointId: value?? ''));
                }
              },
              value: widget.command.anchorPointId,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
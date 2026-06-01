import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/formula_field.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class CurveCommandControl extends StatefulWidget {
  final CurveCommand command;
  final void Function(CurveCommand newCommand) finishedEditing;
  final bool sorting;

  const CurveCommandControl({
    required this.command,
    required this.finishedEditing,
    required this.sorting,
    super.key
  });

  @override
  State<CurveCommandControl> createState() => _CurveCommandControlState();
}

class _CurveCommandControlState extends State<CurveCommandControl> {
  bool editing = false;
  late CurveCommand changedCommand;

  late TextEditingController curveLabelController;
  late TextEditingController amplitudeFormulaController;
  late FocusNode amplitudeFormulaFocusNode;
  late TextEditingController slantFormulaController;
  late FocusNode slantFormulaFocusNode;

  void curveLabelChanged() {
    setState(() => changedCommand = changedCommand.copyWith(label: curveLabelController.text));
  }

  void amplitudeFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(amplitudeFormula: amplitudeFormulaController.text));
  }

  void slantFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(slantFormula: slantFormulaController.text));
  }

  @override
  void initState() {
    changedCommand = widget.command.copyWith();

    curveLabelController = TextEditingController(text: changedCommand.label);
    curveLabelController.addListener(curveLabelChanged);

    amplitudeFormulaController = TextEditingController(text: changedCommand.amplitudeFormula);
    amplitudeFormulaController.addListener(amplitudeFormulaChanged);
    amplitudeFormulaFocusNode = FocusNode();

    slantFormulaController = TextEditingController(text: changedCommand.slantFormula);
    slantFormulaController.addListener(slantFormulaChanged);
    slantFormulaFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    curveLabelController.removeListener(curveLabelChanged);
    curveLabelController.dispose();

    amplitudeFormulaController.removeListener(amplitudeFormulaChanged);
    amplitudeFormulaController.dispose();
    amplitudeFormulaFocusNode.dispose();

    slantFormulaController.removeListener(slantFormulaChanged);
    slantFormulaController.dispose();
    slantFormulaFocusNode.dispose();

    super.dispose();
  }

  Widget createViewContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    String content = 'Curve ';

    String startPointLabel = '???';
    PointCommand? startPoint = drawing.pointById(changedCommand.startPointId);
    if (startPoint != null) {
      startPointLabel = startPoint.label;
    }

    String endPointLabel = '???';
    PointCommand? endPoint = drawing.pointById(changedCommand.endPointId);
    if (endPoint != null) {
      endPointLabel = endPoint.label;
    }

    String ampLabel = '???';
    if (changedCommand.amplitudeFormula.isNotEmpty) {
      ampLabel = changedCommand.amplitudeFormula;
    }

    String slantLabel = '???';
    if (changedCommand.slantFormula.isNotEmpty) {
      slantLabel = changedCommand.slantFormula;
    }

    content += 'between $startPointLabel and $endPointLabel with amplitude $ampLabel and slant $slantLabel';
  
    return Row(
      children: [
        Text(changedCommand.label, style: smallStyleBold,),
        hspacing,
        Text(content, style: smallStyle,),
        const Spacer(),
        if (!widget.sorting && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
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
            Text('Curve', style: smallStyle,),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(controller: curveLabelController, width: 100),
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
                if (changedCommand.endPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != changedCommand.endPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(startPointId: value)),
              value: changedCommand.startPointId,
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
                if (changedCommand.startPointId != origin.id)
                  DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                for (PointCommand point in drawing.points.where((p) => p.id != changedCommand.startPointId))
                  DropdownMenuItem(value: point.id, child: Text(point.label)),
              ],
              onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(endPointId: value)),
              value: changedCommand.endPointId,
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Amplitude'),
            hspacing,
            FormulaField(
              controller: amplitudeFormulaController, 
              focusNode: amplitudeFormulaFocusNode,
              width: 100, 
              excludeCommand: changedCommand,
            ),
          ]
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Slant'),
            hspacing,
            FormulaField(
              controller: slantFormulaController, 
              focusNode: slantFormulaFocusNode,
              width: 100, 
              excludeCommand: changedCommand,
            ),
          ]
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double controlHeight = 60;
    if (editing && !widget.sorting) {
      controlHeight = 260;
    }

    return SizedBox(
      height: controlHeight,
      child: Container(
        decoration: BoxDecoration(
          color: (widget.command.validated && !widget.command.valid) ? Colors.red.withAlpha(20) : Colors.grey.shade100,
          border: Border.all(color: Colors.grey, ),
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
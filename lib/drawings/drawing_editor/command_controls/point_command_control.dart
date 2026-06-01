import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/formula_field.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:provider/provider.dart';

class PointCommandControl extends StatefulWidget {
  final PointCommand command;
  final void Function(PointCommand newCommand) finishedEditing;
  final bool sorting;

  const PointCommandControl({
    required this.command,
    required this.finishedEditing,
    required this.sorting,
    super.key
  });

  @override
  State<PointCommandControl> createState() => _PointCommandControlState();
}

class _PointCommandControlState extends State<PointCommandControl> {
  bool editing = false;
  late PointCommand changedCommand;
  late TextEditingController pointLabelController;
  late TextEditingController distanceFormulaController;
  late FocusNode distanceFormulaFocusNode;
  late TextEditingController directionAngleFormulaController;
  late FocusNode directionAngleFormulaFocusNode;
  late TextEditingController onLineFractionFormulaController;
  late FocusNode onLineFractionFormulaFocusNode;
  late TextEditingController onCurveFractionFormulaController;
  late FocusNode onCurveFractionFormulaFocusNode;

  void pointLabelChanged() {
    setState(() => changedCommand = changedCommand.copyWith(label: pointLabelController.text));
  }

  void distanceFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(distanceFormula: distanceFormulaController.text));
  }

  void directionAngleFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(directionAngleFormula: directionAngleFormulaController.text));
  }

  void onLineFractionFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(onLineFractionFormula: onLineFractionFormulaController.text));
  }

  void onCurveFractionFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(onCurveFractionFormula: onCurveFractionFormulaController.text));
  }

  @override
  void initState() {
    changedCommand = widget.command.copyWith();

    pointLabelController = TextEditingController(text: changedCommand.label);
    pointLabelController.addListener(pointLabelChanged);

    distanceFormulaController = TextEditingController(text: changedCommand.distanceFormula);
    distanceFormulaController.addListener(distanceFormulaChanged);
    distanceFormulaFocusNode = FocusNode();

    directionAngleFormulaController = TextEditingController(text: changedCommand.directionAngleFormula);
    directionAngleFormulaController.addListener(directionAngleFormulaChanged);
    directionAngleFormulaFocusNode = FocusNode();

    onLineFractionFormulaController = TextEditingController(text: changedCommand.onLineFractionFormula);
    onLineFractionFormulaController.addListener(onLineFractionFormulaChanged);
    onLineFractionFormulaFocusNode = FocusNode();

    onCurveFractionFormulaController = TextEditingController(text: changedCommand.onCurveFractionFormula);
    onCurveFractionFormulaController.addListener(onCurveFractionFormulaChanged);
    onCurveFractionFormulaFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    pointLabelController.removeListener(pointLabelChanged);
    pointLabelController.dispose();

    distanceFormulaFocusNode.dispose();
    distanceFormulaController.removeListener(distanceFormulaChanged);
    distanceFormulaController.dispose();

    directionAngleFormulaFocusNode.dispose();
    directionAngleFormulaController.removeListener(directionAngleFormulaChanged);
    directionAngleFormulaController.dispose();

    onLineFractionFormulaFocusNode.dispose();
    onLineFractionFormulaController.removeListener(onLineFractionFormulaChanged);
    onLineFractionFormulaController.dispose();

    onCurveFractionFormulaFocusNode.dispose();
    onCurveFractionFormulaController.removeListener(onCurveFractionFormulaChanged);
    onCurveFractionFormulaController.dispose();

    super.dispose();
  }

  Widget createViewContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    String content = 'Point ';

    if (changedCommand.pointDefinitionType == PointDefinitionType.relativeToPoint) {
      String distanceLabel = '???';
      if (changedCommand.distanceFormula.isNotEmpty) {
        distanceLabel = changedCommand.distanceFormula;
      }

      String directionLabel = '???';
      if (changedCommand.direction == RelativePointDirection.angle) {
        String angleFormulaLabel = '???';
        if (changedCommand.directionAngleFormula.isNotEmpty) {
          angleFormulaLabel = changedCommand.directionAngleFormula;
        }
        directionLabel = 'at angle $angleFormulaLabel';
      } else {
        directionLabel = changedCommand.direction.label;
      }

      String fromPointLabel = '???';
      PointCommand? fromPoint = drawing.pointById(changedCommand.fromPointId);
      if (fromPoint != null) {
        fromPointLabel = fromPoint.label;
      }

      content += '$distanceLabel $directionLabel of $fromPointLabel';

    } else if (changedCommand.pointDefinitionType == PointDefinitionType.onLine) {
      String onlineLabel = '???';
      LineCommand? line = drawing.lineById(changedCommand.onLineId);
      if (line != null) {
        onlineLabel = line.label;
      }

      String fractionLabel = '???';
      if (changedCommand.onLineFractionFormula.isNotEmpty) {
        fractionLabel = changedCommand.onLineFractionFormula;
      }

      content += 'on line $onlineLabel at $fractionLabel';
    } else if (changedCommand.pointDefinitionType == PointDefinitionType.onCurve) {
      String oncurveLabel = '???';
      CurveCommand? curve = drawing.curveById(changedCommand.onCurveId);
      if (curve != null) {
        oncurveLabel = curve.label;
      }

      String fractionLabel = '???';
      if (changedCommand.onCurveFractionFormula.isNotEmpty) {
        fractionLabel = changedCommand.onCurveFractionFormula;
      }

      content += 'on curve $oncurveLabel at $fractionLabel';
    } else if (changedCommand.pointDefinitionType == PointDefinitionType.onIntersection) {
      String l1label = '???';
      LineCommand? l1 = drawing.lineById(changedCommand.intersectionLine1Id);
      if (l1 != null) {
        l1label = l1.label;
      }
      
      String l2label = '???';
      LineCommand? l2 = drawing.lineById(changedCommand.intersectionLine2Id);
      if (l2 != null) {
        l2label = l2.label;
      }
      content += 'on intersection of $l1label and $l2label';
    }

    return Row(
      children: [
        Text(changedCommand.label, style: smallStyleBold, ),
        hspacing,
        Text(content, style: smallStyle,),
        const Spacer(),
        if (!widget.sorting && widget.command.isValidated && !widget.command.valid && widget.command.errors.isNotEmpty)
          Tooltip(
            message: widget.command.errors.join('\n'),
            child: const Icon(Icons.error_outline)
          ),
      ],
    );
  }

  Widget createEditContent() {
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Point', style: smallStyle,),
            hspacing,
            DropdownButton<PointDefinitionType>(
              isDense: true,
              autofocus: false,
              style: smallStyle,
              itemHeight: kMinInteractiveDimension,
              focusColor: Colors.transparent,
              underline: Container(),
              items: [
                for (PointDefinitionType pdt in PointDefinitionType.values)
                  DropdownMenuItem(value: pdt, child: Text(pdt.label))
              ],
              value: changedCommand.pointDefinitionType,
              onChanged: (value) {
                setState(() => changedCommand = changedCommand.copyWith(pointDefinitionType: value));
              },
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(controller: pointLabelController, width: 100),
          ],
        ),
        vspacing,
        if (changedCommand.pointDefinitionType == PointDefinitionType.relativeToPoint)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Distance'),
                  hspacing,
                  FormulaField(
                    controller: distanceFormulaController, 
                    focusNode: distanceFormulaFocusNode,
                    width: 100, 
                    excludeCommand: changedCommand,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Direction'),
                  hspacing,
                  DropdownButton<RelativePointDirection>(
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      for (RelativePointDirection direction in RelativePointDirection.values)
                        DropdownMenuItem(value: direction, child: Text(direction.label)),
                    ], 
                    onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(direction: value)),
                    value: changedCommand.direction,
                  ),
                  hspacing,
                  if (changedCommand.direction == RelativePointDirection.angle)
                    Stack(
                      children: [
                        Positioned(
                          child: FormulaField(
                            controller: directionAngleFormulaController, 
                            focusNode: directionAngleFormulaFocusNode,
                            width: 100, 
                            excludeCommand: changedCommand,
                          )
                        ),
                        const Positioned(right: 5, child: Text(' °', style: TextStyle(fontSize: 24))),
                      ]
                    ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Of'),
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
                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                      for (PointCommand point in drawing.points.where((p) => p.id != changedCommand.id))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(fromPointId: value)),
                    value: changedCommand.fromPointId,
                  )
                ]
              ),
            ]
          ),
        if (changedCommand.pointDefinitionType == PointDefinitionType.onLine)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Line'),
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
                      for (LineCommand line in drawing.lines)
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(onLineId: value)),
                    value: changedCommand.onLineId,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Fraction'),
                  hspacing,
                  FormulaField(
                    controller: onLineFractionFormulaController, 
                    focusNode: onLineFractionFormulaFocusNode,
                    width: 100, 
                    excludeCommand: changedCommand
                  )
                ],
              )
            ],
          ),
        if (changedCommand.pointDefinitionType == PointDefinitionType.onCurve)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Curve'),
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
                      for (CurveCommand curve in drawing.curves)
                        DropdownMenuItem(value: curve.id, child: Text(curve.label))
                    ], 
                    onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(onCurveId: value)),
                    value: changedCommand.onCurveId,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Fraction'),
                  hspacing,
                  FormulaField(
                    controller: onCurveFractionFormulaController, 
                    focusNode: onCurveFractionFormulaFocusNode,
                    width: 100, 
                    excludeCommand: changedCommand
                  )
                ],
              )
            ],
          ),
        if (changedCommand.pointDefinitionType == PointDefinitionType.onIntersection)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Line 1'),
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
                      for (LineCommand line in drawing.lines.where((l) => l.id != changedCommand.intersectionLine2Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(intersectionLine1Id: value)),
                    value: changedCommand.intersectionLine1Id,
                  ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Line 2'),
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
                      for (LineCommand line in drawing.lines.where((l) => l.id != changedCommand.intersectionLine1Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) => setState(() => changedCommand = changedCommand.copyWith(intersectionLine2Id: value)),
                    value: changedCommand.intersectionLine2Id,
                  ),
                ],
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
      if (changedCommand.pointDefinitionType == PointDefinitionType.relativeToPoint) {
        if (changedCommand.direction == RelativePointDirection.angle) {
          controlHeight = 230;
        } else {
          controlHeight = 220;
        }
      }
      if (changedCommand.pointDefinitionType == PointDefinitionType.onLine) {
        controlHeight = 190;
      }
      if (changedCommand.pointDefinitionType == PointDefinitionType.onCurve) {
        controlHeight = 190;
      }
      if (changedCommand.pointDefinitionType == PointDefinitionType.onIntersection) {
        controlHeight = 190;
      }
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
                child:  (editing && !widget.sorting) ? createEditContent() : createViewContent(),
              ),
              if (!widget.sorting)
              Column(
                children: [
                  IconButton(
                    onPressed:() {
                      if (editing) {
                        widget.finishedEditing(changedCommand);
                      }
                      setState(() => editing = !editing);
                    },
                    icon: editing ? const Icon(Icons.check) : const Icon(Icons.edit)
                  ),
                  if (editing)
                    IconButton(
                      onPressed: () => widget.finishedEditing(changedCommand), 
                      icon: const Icon(Icons.refresh)
                    ),
                  const Spacer(),
                  if (editing && widget.command.isValidated && !widget.command.valid && widget.command.errors.isNotEmpty)
                    Tooltip(
                      message: widget.command.errors.join('\n'),
                      child: const Icon(Icons.error_outline)
                    ),
                  if (editing && widget.command.isValidated && !widget.command.valid && widget.command.errors.isNotEmpty)
                    const Spacer(),
                  if (editing)
                    IconButton(
                      onPressed: () => Provider.of<DrawingsModel>(context, listen: false).deleteCommand(commandId: changedCommand.id), 
                      icon: const Icon(Icons.delete)
                    ),
                ],
              ),
            ]
          )
        ),
      )
    );
  }
}
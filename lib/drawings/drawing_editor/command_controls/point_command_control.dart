import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:provider/provider.dart';

class PointCommandControl extends StatefulWidget {
  final PointCommand command;
  final bool valid;
  final void Function(PointCommand newCommand) finishedEditing;

  const PointCommandControl({
    required this.command,
    required this.valid,
    required this.finishedEditing,
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
  late TextEditingController directionAngleFormulaController;

  final TextStyle smallStyle = const TextStyle(fontSize: 10, color: Colors.black);
  final SizedBox spacing = const SizedBox(width: 5,);

  void pointLabelChanged() {
    setState(() => changedCommand = changedCommand.copyWith(label: pointLabelController.text));
  }

  void distanceFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(distanceFormula: distanceFormulaController.text));
  }

  void directionAngleFormulaChanged() {
    setState(() => changedCommand = changedCommand.copyWith(directionAngleFormula: directionAngleFormulaController.text));
  }

  @override
  void initState() {
    changedCommand = widget.command.copyWith();

    pointLabelController = TextEditingController(text: changedCommand.label);
    pointLabelController.addListener(pointLabelChanged);

    distanceFormulaController = TextEditingController(text: changedCommand.distanceFormula);
    distanceFormulaController.addListener(distanceFormulaChanged);

    directionAngleFormulaController = TextEditingController(text: changedCommand.directionAngleFormula);
    directionAngleFormulaController.addListener(directionAngleFormulaChanged);

    super.initState();
  }

  @override
  void dispose() {
    pointLabelController.removeListener(pointLabelChanged);
    pointLabelController.dispose();

    distanceFormulaController.removeListener(distanceFormulaChanged);
    distanceFormulaController.dispose();

    directionAngleFormulaController.removeListener(directionAngleFormulaChanged);
    directionAngleFormulaController.dispose();

    super.dispose();
  }

  Widget createViewContent() {
    Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    String content = 'Point ${changedCommand.label} ';

    if (changedCommand.pointDefinitionType == PointDefinitionType.relativeToPoint) {
      String fromPointLabel = '???';
      PointCommand? fromPoint = drawing.pointById(changedCommand.fromPointId);
      if (fromPoint != null) {
        fromPointLabel = fromPoint.label;
      }
      content += 'xxx from $fromPointLabel';
    } else if (changedCommand.pointDefinitionType == PointDefinitionType.onLine) {

    }

    return Text(content, style: smallStyle,);
  }

  Widget createEditContent() {
    Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            spacing,
            Text('Point', style: smallStyle,),
            spacing,
            SizedBox(
              width: 100,
              child: TextField(
                style: smallStyle,
                controller: pointLabelController,
              ),
            ),
            const Spacer(),
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
            spacing,
          ],
        ),
        if (changedCommand.pointDefinitionType == PointDefinitionType.relativeToPoint)
          Row(
            children: [
              spacing,
              Text('in direction ', style: smallStyle,),
              // TODO: use a formula field
              DropdownButton<RelativePointDirection>(
                items: [
                  for (RelativePointDirection direction in RelativePointDirection.values)
                    DropdownMenuItem(value: direction, child: Text(direction.label)),
                ], 
                onChanged: (value) => changedCommand = changedCommand.copyWith(direction: value),
                value: changedCommand.direction,
              ),
              spacing,
              if (changedCommand.direction == RelativePointDirection.angle)
                // TODO: use a formula field
                SizedBox(
                  width: 100,
                  child: TextField(
                    style: smallStyle,
                    controller: directionAngleFormulaController,
                  ),
                ),
              if (changedCommand.direction == RelativePointDirection.angle)
                spacing,
              Text('at distance', style: smallStyle,),
              SizedBox(
                width: 100,
                child: TextField(
                  style: smallStyle,
                  controller: distanceFormulaController
                )
              ),
              Text('from point ', style: smallStyle,),
              spacing,
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
        if (changedCommand.pointDefinitionType == PointDefinitionType.onLine)
          Row(
            children: [
              spacing,
              const Text('line'),
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
              )
            ]
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double controlHeight = 60;
    if (editing) {
      if (changedCommand.pointDefinitionType == PointDefinitionType.relativeToPoint) {
        controlHeight = 3 * 40;
      }
      if (changedCommand.pointDefinitionType == PointDefinitionType.onLine) {
        controlHeight = 2 * 40;
      }
    }
    return SizedBox(
      height: controlHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              Expanded(
                child: editing ? createEditContent() : createViewContent(),
              ),
              IconButton(
                onPressed:() {
                  if (editing) {
                    widget.finishedEditing(changedCommand);
                  }
                  setState(() => editing = !editing);
                },
                icon: editing ? const Icon(Icons.check) : const Icon(Icons.edit)
              ),
            ]
          )
        ),
      )
    );
  }
}
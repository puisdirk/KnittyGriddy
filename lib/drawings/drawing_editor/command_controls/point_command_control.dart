import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/drawings/model/drawing.dart';
import 'package:knitty_griddy/drawings/model/drawings_model.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class PointCommandControl extends StatefulWidget {
  final PointCommand command;
  final bool sorting;
  final bool editing;

  const PointCommandControl({
    required this.command,
    required this.sorting,
    required this.editing,
    super.key
  });

  @override
  State<PointCommandControl> createState() => _PointCommandControlState();
}

class _PointCommandControlState extends State<PointCommandControl> {
  void pointLabelChanged(String newText) {
    if (widget.command.label != newText) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(label: newText));
    }
  }

  void distanceFormulaChanged(String formula) {
    if (widget.command.distanceFormula != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(distanceFormula: formula));
    }
  }

  void directionAngleFormulaChanged(String formula) {
    if (widget.command.directionAngleFormula != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(directionAngleFormula: formula));
    }
  }

  void onLineFractionFormulaChanged(String formula) {
    if (widget.command.onLineFractionFormula != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(onLineFractionFormula: formula));
    }
  }

  void onCurveFractionFormulaChanged(String formula) {
    if (widget.command.onCurveFractionFormula != formula) {
      Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(onCurveFractionFormula: formula));
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
    final Drawing drawing = Provider.of<DrawingsModel>(context, listen: false).drawing;

    String content = 'Point ';

    if (widget.command.pointDefinitionType == PointDefinitionType.relativeToPoint) {
      String distanceLabel = '???';
      if (widget.command.distanceFormula.isNotEmpty) {
        distanceLabel = widget.command.distanceFormula;
      }

      String directionLabel = '???';
      if (widget.command.direction == RelativePointDirection.angle) {
        String angleFormulaLabel = '???';
        if (widget.command.directionAngleFormula.isNotEmpty) {
          angleFormulaLabel = widget.command.directionAngleFormula;
        }
        directionLabel = 'at angle $angleFormulaLabel';
      } else {
        directionLabel = widget.command.direction.label;
      }

      String fromPointLabel = '???';
      PointCommand? fromPoint = drawing.pointById(widget.command.fromPointId);
      if (fromPoint != null) {
        fromPointLabel = fromPoint.label;
      }

      content += '$distanceLabel $directionLabel of $fromPointLabel';

    } else if (widget.command.pointDefinitionType == PointDefinitionType.onLine) {
      String onlineLabel = '???';
      LineCommand? line = drawing.lineById(widget.command.onLineId);
      if (line != null) {
        onlineLabel = line.label;
      }

      String fractionLabel = '???';
      if (widget.command.onLineFractionFormula.isNotEmpty) {
        fractionLabel = widget.command.onLineFractionFormula;
      }

      content += 'on line $onlineLabel at $fractionLabel';
    } else if (widget.command.pointDefinitionType == PointDefinitionType.onCurve) {
      String oncurveLabel = '???';
      CurveCommand? curve = drawing.curveById(widget.command.onCurveId);
      if (curve != null) {
        oncurveLabel = curve.label;
      }

      String fractionLabel = '???';
      if (widget.command.onCurveFractionFormula.isNotEmpty) {
        fractionLabel = widget.command.onCurveFractionFormula;
      }

      content += 'on curve $oncurveLabel at $fractionLabel';
    } else if (widget.command.pointDefinitionType == PointDefinitionType.onIntersection) {
      String l1label = '???';
      LineCommand? l1 = drawing.lineById(widget.command.intersectionLine1Id);
      if (l1 != null) {
        l1label = l1.label;
      }
      
      String l2label = '???';
      LineCommand? l2 = drawing.lineById(widget.command.intersectionLine2Id);
      if (l2 != null) {
        l2label = l2.label;
      }
      content += 'on intersection of $l1label and $l2label';
    }

    return Row(
      children: [
        const Icon(Symbols.line_start_circle),
        hspacing,
        Text(widget.command.label, style: smallStyleBold),
        hspacing,
        Text(content, style: smallStyle, overflow: TextOverflow.ellipsis,),
        const Spacer(),
        if (!widget.sorting && widget.command.validated && !widget.command.valid && widget.command.errors.isNotEmpty)
          Tooltip(
            message: widget.command.errors.join('\n'),
            child: const Icon(Icons.error_outline)
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Point', style: smallStyle,),
            hspacing,
            DropdownButton<PointDefinitionType>(
              key: GlobalObjectKey('${widget.command.id}-pdt'),
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
              value: widget.command.pointDefinitionType,
              onChanged: (value) {
                if (value != widget.command.pointDefinitionType) {
                  Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(pointDefinitionType: value));
                }
              },
            ),
          ],
        ),
        vspacing,
        Row(
          children: [
            const SmallLabel(label: 'Label'),
            hspacing,
            SmallTextField(
              key: GlobalObjectKey('${widget.command.id}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: pointLabelChanged,
            ),
          ],
        ),
        vspacing,
        if (widget.command.pointDefinitionType == PointDefinitionType.relativeToPoint)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Distance'),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-dist'),
                    formula: widget.command.distanceFormula,
                    width: 200, 
                    excludeCommand: widget.command,
                    onFormulaChanged: distanceFormulaChanged,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Direction'),
                  hspacing,
                  DropdownButton<RelativePointDirection>(
                    key: GlobalObjectKey('${widget.command.id}-dir'),
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
                    onChanged: (value) {
                      if (value != widget.command.direction) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(direction: value));
                      }
                    },
                    value: widget.command.direction,
                  ),
                  hspacing,
                  if (widget.command.direction == RelativePointDirection.angle)
                    FormulaFieldControl(
                      key: GlobalObjectKey('${widget.command.id}-angle'),
                      formula: widget.command.directionAngleFormula,
                      width: 200, 
                      excludeCommand: widget.command,
                      onFormulaChanged: directionAngleFormulaChanged,
                      unitLabel: ' °',
                    ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Of'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-of'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      DropdownMenuItem(value: origin.id, child: Text(origin.label)),
                      for (PointCommand point in drawing.points.where((p) => p.id != widget.command.id))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != widget.command.fromPointId) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(fromPointId: value?? ''));
                      }
                    },
                    value: widget.command.fromPointId,
                  )
                ]
              ),
            ]
          ),
        if (widget.command.pointDefinitionType == PointDefinitionType.onLine)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Line'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-line'),
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
                    onChanged: (value) {
                      if (value != widget.command.onLineId) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(onLineId: value?? ''));
                      }
                    },
                    value: widget.command.onLineId,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Fraction'),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-linefrac'),
                    formula: widget.command.onLineFractionFormula,
                    width: 100, 
                    excludeCommand: widget.command,
                    onFormulaChanged: onLineFractionFormulaChanged,
                  )
                ],
              )
            ],
          ),
        if (widget.command.pointDefinitionType == PointDefinitionType.onCurve)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Curve'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-curve'),
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
                    onChanged: (value) {
                      if (value != widget.command.onCurveId) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(onCurveId: value?? ''));
                      }
                    },
                    value: widget.command.onCurveId,
                  ),
                ]
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Fraction'),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-curvefrac'),
                    formula: widget.command.onCurveFractionFormula,
                    width: 200, 
                    excludeCommand: widget.command,
                    onFormulaChanged: onCurveFractionFormulaChanged,
                  )
                ],
              )
            ],
          ),
        if (widget.command.pointDefinitionType == PointDefinitionType.onIntersection)
          Column(
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Line 1'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-line1'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      for (LineCommand line in drawing.lines.where((l) => l.id != widget.command.intersectionLine2Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != widget.command.intersectionLine1Id) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(intersectionLine1Id: value?? ''));
                      }
                    },
                    value: widget.command.intersectionLine1Id,
                  ),
                ],
              ),
              vspacing,
              Row(
                children: [
                  const SmallLabel(label: 'Line 2'),
                  hspacing,
                  DropdownButton<String>(
                    key: GlobalObjectKey('${widget.command.id}-line2'),
                    isDense: true,
                    autofocus: false,
                    style: smallStyle,
                    itemHeight: kMinInteractiveDimension,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('')),
                      for (LineCommand line in drawing.lines.where((l) => l.id != widget.command.intersectionLine1Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != widget.command.intersectionLine2Id) {
                        Provider.of<DrawingsModel>(context, listen: false).changeDrawingCommand(widget.command.copyWith(intersectionLine2Id: value?? ''));
                      }
                    },
                    value: widget.command.intersectionLine2Id,
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
    return (widget.editing && !widget.sorting) ? createEditContent() : createViewContent();
  }
}
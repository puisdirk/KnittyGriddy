import 'package:flutter/material.dart';
import 'package:knitty_griddy/drawings/formulas/formula_field_control.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_label.dart';
import 'package:knitty_griddy/drawings/drawing_editor/command_controls/small_text_field.dart';
import 'package:knitty_griddy/drawings/model/abstract_drawing.dart';
import 'package:knitty_griddy/drawings/model/commands/curve_command.dart';
import 'package:knitty_griddy/drawings/model/commands/line_command.dart';
import 'package:knitty_griddy/drawings/model/commands/point_command.dart';
import 'package:knitty_griddy/utils/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class PointCommandControl extends StatefulWidget {
  final AbstractDrawing drawing;
  final PointCommand command;
  final bool sorting;
  final bool editing;
  final void Function(PointCommand newCommand, String oldLabel) onChangeLabel;
  final void Function(PointCommand newCommand) onChanged;

  const PointCommandControl({
    required this.drawing,
    required this.command,
    required this.sorting,
    required this.editing,
    required this.onChangeLabel,
    required this.onChanged,
    super.key
  });

  @override
  State<PointCommandControl> createState() => _PointCommandControlState();
}

class _PointCommandControlState extends State<PointCommandControl> {

  void pointLabelChanged(String newText) {
    if (widget.command.label != newText) {
      widget.onChangeLabel(widget.command.copyWith(label: newText), widget.command.label);
    }
  }

  void distanceFormulaChanged(String formula) {
    if (widget.command.distanceFormula != formula) {
      widget.onChanged(widget.command.copyWith(distanceFormula: formula));
    }
  }

  void directionAngleFormulaChanged(String formula) {
    if (widget.command.directionAngleFormula != formula) {
      widget.onChanged(widget.command.copyWith(directionAngleFormula: formula));
    }
  }

  void onLineFractionFormulaChanged(String formula) {
    if (widget.command.onLineFractionFormula != formula) {
      widget.onChanged(widget.command.copyWith(onLineFractionFormula: formula));
    }
  }

  void onCurveFractionFormulaChanged(String formula) {
    if (widget.command.onCurveFractionFormula != formula) {
      widget.onChanged(widget.command.copyWith(onCurveFractionFormula: formula));
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
    String content = ' ';

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

      String fromPointLabel = widget.drawing.commandLabelIncluded(widget.command.fromPointId);

      content += '$distanceLabel $directionLabel of $fromPointLabel';

    } else if (widget.command.pointDefinitionType == PointDefinitionType.onLine) {
      String onlineLabel = widget.drawing.commandLabelIncluded(widget.command.onLineId);

      String fractionLabel = '???';
      if (widget.command.onLineFractionFormula.isNotEmpty) {
        fractionLabel = widget.command.onLineFractionFormula;
      }

      content += 'on line $onlineLabel at $fractionLabel';
    } else if (widget.command.pointDefinitionType == PointDefinitionType.onCurve) {
      String oncurveLabel = widget.drawing.commandLabelIncluded(widget.command.onCurveId);

      String fractionLabel = '???';
      if (widget.command.onCurveFractionFormula.isNotEmpty) {
        fractionLabel = widget.command.onCurveFractionFormula;
      }

      content += 'on curve $oncurveLabel at $fractionLabel';
    } else if (widget.command.pointDefinitionType == PointDefinitionType.onIntersection) {
      String l1label = widget.drawing.commandLabelIncluded(widget.command.intersectionLine1Id);      
      String l2label = widget.drawing.commandLabelIncluded(widget.command.intersectionLine2Id);

      content += 'on intersection of $l1label and $l2label';
    }

    return Row(
      children: [
        const Icon(Symbols.line_start_circle),
        hspacing,
        SizedBox(
          width: widget.command.hasErrors ? commandControlViewWidth : commandControlViewWidthNoError,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: widget.command.label, style: smallStyleBold),
                TextSpan(text: content, style: smallStyle,)
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.line_start_circle),
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
                  widget.onChanged(widget.command.copyWith(pointDefinitionType: value));
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
              key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-label'),
              initialText: widget.command.label,
              width: 100,
              onTextChanged: pointLabelChanged,
            ),
          ],
        ),
        vspacing,
        if (widget.command.pointDefinitionType == PointDefinitionType.relativeToPoint)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SmallLabel(label: 'Distance'),
                  hspacing,
                  FormulaFieldControl(
                    key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-${widget.command.version}-dist'),
                    formula: widget.command.distanceFormula,
                    width: 240, 
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
                        widget.onChanged(widget.command.copyWith(direction: value));
                      }
                    },
                    value: widget.command.direction,
                  ),
                  hspacing,
                  if (widget.command.direction == RelativePointDirection.angle)
                    FormulaFieldControl(
                      key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-angle'),
                      formula: widget.command.directionAngleFormula,
                      width: 155, 
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
                      for (PointCommand point in widget.drawing.pointsIncluded.where((p) => p.id != widget.command.id))
                        DropdownMenuItem(value: point.id, child: Text(point.label)),
                    ],
                    onChanged: (value) {
                      if (value != widget.command.fromPointId) {
                        widget.onChanged(widget.command.copyWith(fromPointId: value?? ''));
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      for (LineCommand line in widget.drawing.linesIncluded)
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != widget.command.onLineId) {
                        widget.onChanged(widget.command.copyWith(onLineId: value?? ''));
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
                    key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-linefrac'),
                    formula: widget.command.onLineFractionFormula,
                    width: 240, 
                    excludeCommand: widget.command,
                    onFormulaChanged: onLineFractionFormulaChanged,
                  )
                ],
              )
            ],
          ),
        if (widget.command.pointDefinitionType == PointDefinitionType.onCurve)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      for (CurveCommand curve in widget.drawing.curvesIncluded)
                        DropdownMenuItem(value: curve.id, child: Text(curve.label))
                    ], 
                    onChanged: (value) {
                      if (value != widget.command.onCurveId) {
                        widget.onChanged(widget.command.copyWith(onCurveId: value?? ''));
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
                    key: GlobalObjectKey('${widget.command.id}-${widget.command.version}-curvefrac'),
                    formula: widget.command.onCurveFractionFormula,
                    width: 240, 
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
                      for (LineCommand line in widget.drawing.linesIncluded.where((l) => l.id != widget.command.intersectionLine2Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != widget.command.intersectionLine1Id) {
                        widget.onChanged(widget.command.copyWith(intersectionLine1Id: value?? ''));
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
                      for (LineCommand line in widget.drawing.linesIncluded.where((l) => l.id != widget.command.intersectionLine1Id))
                        DropdownMenuItem(value: line.id, child: Text(line.label))
                    ], 
                    onChanged: (value) {
                      if (value != widget.command.intersectionLine2Id) {
                        widget.onChanged(widget.command.copyWith(intersectionLine2Id: value?? ''));
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